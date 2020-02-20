import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:provider/provider.dart';

import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:audiofileplayer/audio_system.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:tsacdop/class/audiostate.dart';
import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/episodes/episodedetail.dart';
import 'package:tsacdop/home/audiopanel.dart';
import 'package:tsacdop/util/pageroute.dart';

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
  bool _isLoading;
  Color _c;
  EpisodeBrief episode;

  @override
  void initState() {
    super.initState();
    AudioSystem.instance.addMediaEventListener(_mediaEventListener);
    _isLoading = false;
    _remoteAudioLoading = true;
  }

  //open episoddetail page
  _gotoEpisode() async {
    Navigator.push(
      context,
      SlideUptRoute(
          page: EpisodeDetail(episodeItem: episode, heroTag: 'playpanel')),
    );
  }

  //init audio player from url
  void _initbackgroundAudioPlayer(String url) {
    _remoteErrorMessage = null;
    _remoteAudioLoading = true;
    Provider.of<AudioPlay>(context, listen: false).audioState = AudioState.load;

    if (_backgroundAudioPlaying == true)
    { _backgroundAudio?.pause();
    AudioSystem.instance.stopBackgroundDisplay();}
    _backgroundAudio?.dispose();
    _backgroundAudio = Audio.loadFromRemoteUrl(url,
        onDuration: (double durationSeconds) {
          setState(() {
            _backgroundAudioDurationSeconds = durationSeconds;
            _remoteAudioLoading = false;
            Provider.of<AudioPlay>(context, listen: false).audioState =
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
              Provider.of<AudioPlay>(context, listen: false).audioState =
                  AudioState.error;
            }),
        onComplete: () => setState(() {
              _backgroundAudioPlaying = false;
              _remoteAudioLoading = false;
              Provider.of<AudioPlay>(context, listen: false).audioState =
                  AudioState.complete;
            }),
        looping: false,
        playInBackground: true)
      ..play();
  }

  //init audio player form local file
  void _initbackgroundAudioPlayerLocal(String path) {
    _remoteErrorMessage = null;
    _remoteAudioLoading = true;
    ByteData audio = getAudio(path);
    Provider.of<AudioPlay>(context, listen: false).audioState = AudioState.load;
    if (_backgroundAudioPlaying == true) 
    {_backgroundAudio?.pause();
    AudioSystem.instance.stopBackgroundDisplay();}
    _backgroundAudio?.dispose();
    _backgroundAudio = Audio.loadFromByteData(audio,
        onDuration: (double durationSeconds) {
          setState(() {
            _backgroundAudioDurationSeconds = durationSeconds;
            _remoteAudioLoading = false;
          });
          _setNotification();
          Provider.of<AudioPlay>(context, listen: false).audioState =
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
              Provider.of<AudioPlay>(context, listen: false).audioState =
                  AudioState.error;
            }),
        onComplete: () => setState(() {
              _backgroundAudioPlaying = false;
              _remoteAudioLoading = false;
              Provider.of<AudioPlay>(context, listen: false).audioState =
                  AudioState.complete;
            }),
        looping: false,
        playInBackground: true)
      ..play();
  }

  //if downloaded
  Future<String> _getFile(String url) async {
    final task = await FlutterDownloader.loadTasksWithRawQuery(
        query: "SELECT * FROM task WHERE url = '$url' AND status = 3");
    if (task.length != 0) {
      String _filePath = task.first.savedDir + '/' + task.first.filename;
      return _filePath;
    }
    return 'NotDownload';
  }

  //get local audio file
  ByteData getAudio(String path) {
    File audioFile = File(path);
    Uint8List audio = audioFile.readAsBytesSync();
    return ByteData.view(audio.buffer);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final url = Provider.of<AudioPlay>(context).episode?.enclosureUrl;
    if (url != this.url) {
      setState(() {
        this.url = url;
        episode = Provider.of<AudioPlay>(context).episode;
        var color = json.decode(episode?.primaryColor);
        (color[0] > 200 && color[1] > 200 && color[2] > 200)
            ? _c = Color.fromRGBO(
                (255 - color[0]), 255 - color[1], 255 - color[2], 1.0)
            : _c = Color.fromRGBO(color[0], color[1], color[2], 1.0);
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
    final Uint8List imageBytes =
        File('${episode.imagePath}').readAsBytesSync();
    AudioSystem.instance.setMetadata(AudioMetadata(
        title: episode.title,
        artist:episode.feedTitle,
        album: episode.feedTitle,
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
      Provider.of<AudioPlay>(context, listen: false).audioState =
          AudioState.play;
    });
    final Uint8List imageBytes =
        File('${episode.imagePath}').readAsBytesSync();
    AudioSystem.instance.setMetadata(AudioMetadata(
        title: episode.title,
        artist: episode.feedTitle,
        album: episode.feedTitle,
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
      Provider.of<AudioPlay>(context, listen: false).audioState =
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

  Widget _expandedPanel() => Container(
        height: 300,
        color: Colors.grey[100],
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 80.0,
                padding: EdgeInsets.all(20),
                alignment: Alignment.center,
                child: (episode.title.length > 10)
                    ? Marquee(
                        text: episode.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                        scrollAxis: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        blankSpace: 30.0,
                        velocity: 50.0,
                        pauseAfterRound: Duration(seconds: 1),
                        startPadding: 30.0,
                        accelerationDuration: Duration(seconds: 1),
                        accelerationCurve: Curves.linear,
                        decelerationDuration: Duration(milliseconds: 500),
                        decelerationCurve: Curves.easeOut,
                      )
                    : Text(
                        episode.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
              ),
              Container(
                padding: EdgeInsets.only(left: 30, right: 30),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.blue[100],
                    inactiveTrackColor: Colors.grey[300],
                    trackHeight: 3.0,
                    thumbColor: Colors.blue[400],
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
                    overlayColor: Colors.blue.withAlpha(32),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 14.0),
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
              ),
              Container(
                height: 20.0,
                padding: EdgeInsets.symmetric(horizontal: 50.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      _stringForSeconds(_backgroundAudioPositionSeconds) ?? '',
                      style: TextStyle(fontSize: 10),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: _remoteErrorMessage != null
                            ? Text(_remoteErrorMessage,
                                style: const TextStyle(
                                    color: const Color(0xFFFF0000)))
                            : Text(
                                _remoteAudioLoading ? 'Buffring...' : '',
                                style: TextStyle(color: Colors.blue),
                              ),
                      ),
                    ),
                    Text(
                      _stringForSeconds(_backgroundAudioDurationSeconds) ?? '',
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              Container(
                height: 100,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: IconButton(
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          onPressed: _backgroundAudioPlaying
                              ? () => _forwardBackgroundAudio(-10)
                              : null,
                          iconSize: 32.0,
                          icon: Icon(Icons.replay_10),
                          color: Colors.black),
                    ),
                    _backgroundAudioPlaying
                        ? Material(
                            color: Colors.transparent,
                            child: IconButton(
                                padding: EdgeInsets.symmetric(horizontal: 30.0),
                                onPressed: _backgroundAudioPlaying
                                    ? () {
                                        _pauseBackgroundAudio();
                                      }
                                    : null,
                                iconSize: 40.0,
                                icon: Icon(Icons.pause_circle_filled),
                                color: Colors.black),
                          )
                        : Material(
                            color: Colors.transparent,
                            child: IconButton(
                                padding: EdgeInsets.symmetric(horizontal: 30.0),
                                onPressed: _backgroundAudioPlaying
                                    ? null
                                    : () {
                                        _resumeBackgroundAudio();
                                      },
                                iconSize: 40.0,
                                icon: Icon(Icons.play_circle_filled),
                                color: Colors.black),
                          ),
                    Material(
                      color: Colors.transparent,
                      child: IconButton(
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          onPressed: _backgroundAudioPlaying
                              ? () => _forwardBackgroundAudio(30)
                              : null,
                          iconSize: 32.0,
                          icon: Icon(Icons.forward_30),
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Container(
                  height: 50.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(10.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          child: Container(
                            height: 30.0,
                            width: 30.0,
                            color: Colors.white,
                            child: Image.file(
                                    File("${episode.imagePath}"))
                          ),
                        ),
                      ),
                      Spacer(),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _gotoEpisode(),
                          child: Icon(Icons.info),
                        ),
                      ),
                    ],
                  ))
            ]),
      );
  Widget _miniPanel(double width) => Container(
        height: 60,
        color: Colors.grey[100],
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(
                    value: _seekSliderValue,
                    backgroundColor: Colors.grey[100],
                    valueColor: AlwaysStoppedAnimation<Color>(_c),
                  )),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 15, right: 10),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          alignment: Alignment.centerLeft,
                          child: (episode.title.length > 55)
                              ? Marquee(
                                  text: episode.title,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  scrollAxis: Axis.vertical,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  episode.title,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.center,
                          child: _remoteAudioLoading
                              ? Text(
                                  'Buffring...',
                                  style: TextStyle(color: Colors.blue),
                                )
                              : Row(
                                  children: <Widget>[
                                    Text(
                                      _stringForSeconds(
                                              _backgroundAudioDurationSeconds -
                                                  _backgroundAudioPositionSeconds)  ??
                                          '',
                                      style: TextStyle(color: _c),
                                    ),
                                    Text(
                                      '  Left',
                                      style: TextStyle(color: _c),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _backgroundAudioPlaying
                                ? Material(
                                    color: Colors.transparent,
                                    child: IconButton(
                                        onPressed: _backgroundAudioPlaying
                                            ? () {
                                                _pauseBackgroundAudio();
                                              }
                                            : null,
                                        iconSize: 25.0,
                                        icon: Icon(Icons.pause_circle_filled),
                                        color: Colors.black),
                                  )
                                : Material(
                                    color: Colors.transparent,
                                    child: IconButton(
                                        onPressed: _backgroundAudioPlaying
                                            ? null
                                            : () {
                                                _resumeBackgroundAudio();
                                              },
                                        iconSize: 25.0,
                                        icon: Icon(Icons.play_circle_filled),
                                        color: Colors.black),
                                  ),
                            Material(
                              color: Colors.transparent,
                              child: IconButton(
                                  onPressed: _backgroundAudioPlaying
                                      ? () => _forwardBackgroundAudio(30)
                                      : null,
                                  iconSize: 25.0,
                                  icon: Icon(Icons.forward_30),
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
      );
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return !_isLoading
        ? Center()
        : AudioPanel(
            miniPanel: _miniPanel(_width), expandedPanel: _expandedPanel());
  }
}
