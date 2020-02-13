import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:provider/provider.dart';

import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:audiofileplayer/audio_system.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:tsacdop/class/audiostate.dart';

final Logger _logger = Logger('audiofileplayer');

class PlayerWidget extends StatefulWidget {
  @override
  _PlayerWidgetState createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  static const String replay10ButtonId = 'replay10ButtonId';
  static const String newReleasesButtonId = 'newReleasesButtonId';
  static const String likeButtonId = 'likeButtonId';
  static const String pausenowButtonId = 'pausenowButtonId';
  static const String forwardButtonId = 'forwardButtonId';

  Audio _backgroundAudio;
  bool _backgroundAudioPlaying;
  double _backgroundAudioDurationSeconds;
  double _backgroundAudioPositionSeconds = 0;
  bool _remoteAudioLoading;
  String _remoteErrorMessage;
  double _seekSliderValue = 0.0;
  String url;
  String _title;
  String _feedtitle;
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    AudioSystem.instance.addMediaEventListener(_mediaEventListener);
    _isLoading = false;
  }

  void _initbackgroundAudioPlayer(String url) {
    _remoteErrorMessage = null;
    _remoteAudioLoading = true;
    Provider.of<Urlchange>(context, listen: false).audioState = AudioState.load;

    if (_backgroundAudioPlaying == true) _backgroundAudio?.pause();
    _backgroundAudio?.dispose();
    _backgroundAudio = Audio.loadFromRemoteUrl(url,
        onDuration: (double durationSeconds) {
          setState(() {
            _backgroundAudioDurationSeconds = durationSeconds;
            _remoteAudioLoading = false;
            Provider.of<Urlchange>(context, listen: false).audioState =
                AudioState.play;
          });
          _setNotification();
        },
        onPosition: (double positionSeconds) {
          setState(() {
            if (_backgroundAudioPositionSeconds <
                _backgroundAudioDurationSeconds) {
              _seekSliderValue = _backgroundAudioPositionSeconds /
                  _backgroundAudioDurationSeconds;
              _backgroundAudioPositionSeconds = positionSeconds;
            } else {
              _seekSliderValue = 1;
              _backgroundAudioPositionSeconds = _backgroundAudioDurationSeconds;
            }
          });
        },
        onError: (String message) => setState(() {
              _remoteErrorMessage = message;
              _backgroundAudio.dispose();
              _backgroundAudio = null;
              _backgroundAudioPlaying = false;
              _remoteAudioLoading = false;
              Provider.of<Urlchange>(context, listen: false).audioState =
                  AudioState.error;
            }),
        onComplete: () => setState(() {
              _backgroundAudioPlaying = false;
              _remoteAudioLoading = false;
              Provider.of<Urlchange>(context, listen: false).audioState =
                  AudioState.complete;
            }),
        looping: false,
        playInBackground: true)
      ..play();
  }

  void _initbackgroundAudioPlayerLocal(String path) {
    _remoteErrorMessage = null;
    _remoteAudioLoading = true;
    ByteData audio = getAudio(path);
    Provider.of<Urlchange>(context, listen: false).audioState = AudioState.load;
    if (_backgroundAudioPlaying == true) _backgroundAudio?.pause();
    _backgroundAudio?.dispose();
    _backgroundAudio = Audio.loadFromByteData(audio,
        onDuration: (double durationSeconds) {
          setState(() {
            _backgroundAudioDurationSeconds = durationSeconds;
            _remoteAudioLoading = false;
          });
          _setNotification();
          Provider.of<Urlchange>(context, listen: false).audioState =
              AudioState.play;
        },
        onPosition: (double positionSeconds) {
          setState(() {
            if (_backgroundAudioPositionSeconds <
                _backgroundAudioDurationSeconds) {
              _seekSliderValue = _backgroundAudioPositionSeconds /
                  _backgroundAudioDurationSeconds;
              _backgroundAudioPositionSeconds = positionSeconds;
            } else {
              _seekSliderValue = 1;
              _backgroundAudioPositionSeconds = _backgroundAudioDurationSeconds;
            }
          });
        },
        onError: (String message) => setState(() {
              _remoteErrorMessage = message;
              _backgroundAudio.dispose();
              _backgroundAudio = null;
              _backgroundAudioPlaying = false;
              _remoteAudioLoading = false;
              Provider.of<Urlchange>(context, listen: false).audioState =
                  AudioState.error;
            }),
        onComplete: () => setState(() {
              _backgroundAudioPlaying = false;
              _remoteAudioLoading = false;
              Provider.of<Urlchange>(context, listen: false).audioState =
                  AudioState.complete;
            }),
        looping: false,
        playInBackground: true)
      ..play();
  }

  Future<String> _getFile(String url) async {
    final task = await FlutterDownloader.loadTasksWithRawQuery(
        query: "SELECT * FROM task WHERE url = '$url' AND status = 3");
    if (task.length != 0) {
      String _filePath = task.first.savedDir + '/' + task.first.filename;
      return _filePath;
    }
    return 'NotDownload';
  }

  ByteData getAudio(String path) {
    File audioFile = File(path);
    Uint8List audio = audioFile.readAsBytesSync();
    return ByteData.view(audio.buffer);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final url = Provider.of<Urlchange>(context).audiourl;
    if (url != this.url) {
      setState(() {
        this.url = url;
        _title = Provider.of<Urlchange>(context).title;
        _feedtitle = Provider.of<Urlchange>(context).feedtitle;
        _backgroundAudioPlaying = true;
        _isLoading = true;
        _getFile(url).then((result) {
          result == 'NotDownload'
              ? _initbackgroundAudioPlayer(url)
              : _initbackgroundAudioPlayerLocal(result);
        });
      });
    }
  }

  @override
  void dispose() {
    AudioSystem.instance.removeMediaEventListener(_mediaEventListener);
    _backgroundAudio?.dispose();
    super.dispose();
  }

  static String _stringForSeconds(double seconds) {
    if (seconds == null) return null;
    return '${(seconds ~/ 60)}:${(seconds.truncate() % 60).toString().padLeft(2, '0')}';
  }

  void _mediaEventListener(MediaEvent mediaEvent) {
    _logger.info('App received media event of type: ${mediaEvent.type}');
    final MediaActionType type = mediaEvent.type;
    if (type == MediaActionType.play) {
      _resumeBackgroundAudio();
    } else if (type == MediaActionType.pause) {
      _pauseBackgroundAudio();
    } else if (type == MediaActionType.playPause) {
      _backgroundAudioPlaying
          ? _pauseBackgroundAudio()
          : _resumeBackgroundAudio();
    } else if (type == MediaActionType.stop) {
      _stopBackgroundAudio();
    } else if (type == MediaActionType.seekTo) {
      _backgroundAudio.seek(mediaEvent.seekToPositionSeconds);
      AudioSystem.instance
          .setPlaybackState(true, mediaEvent.seekToPositionSeconds);
    } else if (type == MediaActionType.skipForward) {
      final double skipIntervalSeconds = mediaEvent.skipIntervalSeconds;
      _forwardBackgroundAudio(skipIntervalSeconds);
      _logger.info(
          'Skip-forward event had skipIntervalSeconds $skipIntervalSeconds.');
    } else if (type == MediaActionType.skipBackward) {
      final double skipIntervalSeconds = mediaEvent.skipIntervalSeconds;
      _forwardBackgroundAudio(skipIntervalSeconds);
      _logger.info(
          'Skip-backward event had skipIntervalSeconds $skipIntervalSeconds.');
    } else if (type == MediaActionType.custom) {
      if (mediaEvent.customEventId == replay10ButtonId) {
        _forwardBackgroundAudio(-10.0);
      } else if (mediaEvent.customEventId == likeButtonId) {
        _resumeBackgroundAudio();
      } else if (mediaEvent.customEventId == forwardButtonId) {
        _forwardBackgroundAudio(30.0);
      } else if (mediaEvent.customEventId == pausenowButtonId) {
        _pauseBackgroundAudio();
      }
    }
  }

  final _pauseButton = AndroidCustomMediaButton(
      'pausenow', pausenowButtonId, 'ic_stat_pause_circle_filled');
  final _replay10Button = AndroidCustomMediaButton(
      'replay10', replay10ButtonId, 'ic_stat_replay_10');
  final _forwardButton = AndroidCustomMediaButton(
      'forward', forwardButtonId, 'ic_stat_forward_30');
  final _playnowButton = AndroidCustomMediaButton(
      'playnow', likeButtonId, 'ic_stat_play_circle_filled');

  Future<void> _setNotification() async {
    var dir = await getApplicationDocumentsDirectory();
    final Uint8List imageBytes =
        File('${dir.path}/$_feedtitle.png').readAsBytesSync();
    AudioSystem.instance.setMetadata(AudioMetadata(
        title: _title,
        artist: _feedtitle,
        album: _feedtitle,
        genre: "Podcast",
        durationSeconds: _backgroundAudioDurationSeconds,
        artBytes: imageBytes));
    AudioSystem.instance
        .setPlaybackState(true, _backgroundAudioPositionSeconds);
    AudioSystem.instance.setAndroidNotificationButtons(<dynamic>[
      AndroidMediaButtonType.pause,
      _forwardButton,
      AndroidMediaButtonType.stop,
    ], androidCompactIndices: <int>[
      0,
      1
    ]);

    AudioSystem.instance.setSupportedMediaActions(<MediaActionType>{
      MediaActionType.playPause,
      MediaActionType.pause,
      MediaActionType.next,
      MediaActionType.previous,
      MediaActionType.skipForward,
      MediaActionType.skipBackward,
      MediaActionType.seekTo,
      MediaActionType.custom,
    }, skipIntervalSeconds: 30);
  }

  Future<void> _resumeBackgroundAudio() async {
    _backgroundAudio.resume();
    setState(() {
      _backgroundAudioPlaying = true;
      Provider.of<Urlchange>(context, listen: false).audioState =
          AudioState.play;
    });
    var dir = await getApplicationDocumentsDirectory();
    final Uint8List imageBytes =
        File('${dir.path}/$_feedtitle.png').readAsBytesSync();
    AudioSystem.instance.setMetadata(AudioMetadata(
        title: _title,
        artist: _feedtitle,
        album: _feedtitle,
        genre: "Podcast",
        durationSeconds: _backgroundAudioDurationSeconds,
        artBytes: imageBytes));

    AudioSystem.instance
        .setPlaybackState(true, _backgroundAudioPositionSeconds);

    AudioSystem.instance.setAndroidNotificationButtons(<dynamic>[
      AndroidMediaButtonType.pause,
      _forwardButton,
      AndroidMediaButtonType.stop,
    ], androidCompactIndices: <int>[
      0,
      1
    ]);

    AudioSystem.instance.setSupportedMediaActions(<MediaActionType>{
      MediaActionType.playPause,
      MediaActionType.pause,
      MediaActionType.next,
      MediaActionType.previous,
      MediaActionType.skipForward,
      MediaActionType.skipBackward,
      MediaActionType.seekTo,
      MediaActionType.custom,
    }, skipIntervalSeconds: 30);
  }

  void _pauseBackgroundAudio() {
    _backgroundAudio.pause();
    setState(() {
      _backgroundAudioPlaying = false;
      Provider.of<Urlchange>(context, listen: false).audioState =
          AudioState.pause;
    });

    AudioSystem.instance
        .setPlaybackState(false, _backgroundAudioPositionSeconds);

    AudioSystem.instance.setAndroidNotificationButtons(<dynamic>[
      AndroidMediaButtonType.play,
      _forwardButton,
      AndroidMediaButtonType.stop,
    ], androidCompactIndices: <int>[
      0,
      1,
    ]);

    AudioSystem.instance.setSupportedMediaActions(<MediaActionType>{
      MediaActionType.playPause,
      MediaActionType.play,
      MediaActionType.next,
      MediaActionType.previous,
    });
  }

  void _stopBackgroundAudio() {
    _backgroundAudio.pause();
    setState(() => _backgroundAudioPlaying = false);
    AudioSystem.instance.stopBackgroundDisplay();
  }

  void _forwardBackgroundAudio(double seconds) {
    final double forwardposition = _backgroundAudioPositionSeconds + seconds;
    _backgroundAudio.seek(forwardposition);
    AudioSystem.instance.setPlaybackState(true, forwardposition);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Urlchange(),
      child: !_isLoading
          ? Center()
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              color: Colors.grey[100],
              height: 120.0,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      child: _remoteErrorMessage != null
                          ? Text(_remoteErrorMessage,
                              style: const TextStyle(
                                  color: const Color(0xFFFF0000)))
                          : Text(
                              _remoteAudioLoading ? 'Buffring...' : '',
                              style: TextStyle(color: Colors.blue),
                            ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.blue[100],
                        inactiveTrackColor: Colors.grey[300],
                        trackHeight: 2.0,
                        thumbColor: Colors.blue[400],
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 5.0),
                        overlayColor: Colors.blue.withAlpha(32),
                        overlayShape:
                            RoundSliderOverlayShape(overlayRadius: 14.0),
                      ),
                      child: Slider(
                          value: _seekSliderValue,
                          onChanged: (double val) {
                            setState(() => _seekSliderValue = val);
                            final double positionSeconds =
                                val * _backgroundAudioDurationSeconds;
                            _backgroundAudio.seek(positionSeconds);
                            AudioSystem.instance
                                .setPlaybackState(true, positionSeconds);
                          }),
                    ),
                    Container(
                      height: 20.0,
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            _stringForSeconds(
                                    _backgroundAudioPositionSeconds) ??
                                '',
                            style: TextStyle(fontSize: 10),
                          ),
                          Expanded(
                              child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            alignment: Alignment.center,
                            child: (_title.length > 50)
                                ? Marquee(
                                    text: _title,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    scrollAxis: Axis.horizontal,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    blankSpace: 30.0,
                                    velocity: 50.0,
                                    pauseAfterRound: Duration(seconds: 1),
                                    startPadding: 30.0,
                                    accelerationDuration: Duration(seconds: 1),
                                    accelerationCurve: Curves.linear,
                                    decelerationDuration:
                                        Duration(milliseconds: 500),
                                    decelerationCurve: Curves.easeOut,
                                  )
                                : Text(
                                    _title,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                          )),
                          Text(
                            _stringForSeconds(
                                    _backgroundAudioDurationSeconds) ??
                                '',
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            padding: EdgeInsets.symmetric(horizontal: 30.0),
                            onPressed: _backgroundAudioPlaying
                                ? () => _forwardBackgroundAudio(-10)
                                : null,
                            iconSize: 25.0,
                            icon: Icon(Icons.replay_10),
                            color: Colors.black),
                        _backgroundAudioPlaying
                            ? IconButton(
                                padding: EdgeInsets.symmetric(horizontal: 30.0),
                                onPressed: _backgroundAudioPlaying
                                    ? () {
                                        _pauseBackgroundAudio();
                                      }
                                    : null,
                                iconSize: 32.0,
                                icon: Icon(Icons.pause_circle_filled),
                                color: Colors.black)
                            : IconButton(
                                padding: EdgeInsets.symmetric(horizontal: 30.0),
                                onPressed: _backgroundAudioPlaying
                                    ? null
                                    : () {
                                        _resumeBackgroundAudio();
                                      },
                                iconSize: 32.0,
                                icon: Icon(Icons.play_circle_filled),
                                color: Colors.black),
                        IconButton(
                            padding: EdgeInsets.symmetric(horizontal: 30.0),
                            onPressed: _backgroundAudioPlaying
                                ? () => _forwardBackgroundAudio(30)
                                : null,
                            iconSize: 25.0,
                            icon: Icon(Icons.forward_30),
                            color: Colors.black),
                        /*IconButton(
                  onPressed: _isPlaying || _isPaused ? () => _stop() : null,
                  iconSize: 32.0,
                  icon: Icon(Icons.stop),
                  color: Colors.black), */
                      ],
                    ),
                  ]),
            ),
    );
  }
}
