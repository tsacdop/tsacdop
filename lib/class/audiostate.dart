import 'dart:typed_data';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tsacdop/class/episodebrief.dart';
import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:logging/logging.dart';
import 'package:audiofileplayer/audio_system.dart';
import 'package:tsacdop/local_storage/key_value_storage.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';

enum AudioState { load, play, pause, complete, error, stop }

class PlayHistory {
  String title;
  String url;
  double seconds;
  double seekValue;
  PlayHistory(this.title, this.url, this.seconds, this.seekValue);
}

class Playlist {
  String name;
  DBHelper dbHelper = DBHelper();
  List<String> urls;
  List<EpisodeBrief> _playlist;
  List<EpisodeBrief> get playlist => _playlist;
  KeyValueStorage storage = KeyValueStorage('playlist');
  Playlist(this.name, {List<String> urls}) : urls = urls ?? [];

  getPlaylist() async{
    List<String> _urls = await storage.getPlayList();
    if (_urls.length == 0) {
      _playlist = [];
    } else {
      _playlist = [];
      await Future.forEach(_urls, (url) async{
        EpisodeBrief episode = await dbHelper.getRssItemWithUrl(url);
        print(episode.title);
        _playlist.add(episode);
      });
    }
    print(_playlist.length);
  }

  savePlaylist() async {
    urls = [];
    urls.addAll(_playlist.map((e) => e.enclosureUrl));
    print(urls);
    await storage.savePlaylist(urls);
  }

  addToPlayList(EpisodeBrief episodeBrief) async {
    _playlist.add(episodeBrief);
    await savePlaylist();
  }

  delFromPlaylist(EpisodeBrief episodeBrief) {
    _playlist.remove(episodeBrief);
    savePlaylist();
  }
}

class AudioPlayer extends ChangeNotifier {
  static const String replay10ButtonId = 'replay10ButtonId';
  static const String newReleasesButtonId = 'newReleasesButtonId';
  static const String likeButtonId = 'likeButtonId';
  static const String pausenowButtonId = 'pausenowButtonId';
  static const String forwardButtonId = 'forwardButtonId';

  DBHelper dbHelper = DBHelper();
  EpisodeBrief _episode;
  Playlist _queue = Playlist('now');
  bool _playerRunning = false;
  Audio _backgroundAudio;
  bool _backgroundAudioPlaying = false;
  double _backgroundAudioDurationSeconds = 0;
  double _backgroundAudioPositionSeconds = 0;
  bool _remoteAudioLoading = false;
  String _remoteErrorMessage;
  double _seekSliderValue = 0.0;
  final Logger _logger = Logger('audiofileplayer');

  bool get backgroundAudioPlaying => _backgroundAudioPlaying;
  bool get remoteAudioLoading => _remoteAudioLoading;
  double get backgroundAudioDuration => _backgroundAudioDurationSeconds;
  double get backgroundAudioPosition => _backgroundAudioPositionSeconds;
  double get seekSliderValue => _seekSliderValue;
  String get remoteErrorMessage => _remoteErrorMessage;
  bool get playerRunning => _playerRunning;

  Playlist get queue => _queue;

  AudioState _audioState = AudioState.stop;
  AudioState get audioState => _audioState;

  EpisodeBrief get episode => _episode;
  
  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _queue.getPlaylist();
  }

  episodeLoad(EpisodeBrief episode) async {
    AudioSystem.instance.addMediaEventListener(_mediaEventListener);
    _episode = episode;
    await _queue.getPlaylist();
    if (_queue.playlist.contains(_episode)) {
      _queue.playlist.remove(_episode);
      _queue.playlist.insert(0, _episode);
    } else {
      _queue.playlist.insert(0, _episode);
    }
    await _queue.savePlaylist();
    await _play(_episode);
    _playerRunning = true;
    _backgroundAudioPlaying = true;
    notifyListeners();
  }

  playNext() async {
    PlayHistory history = PlayHistory(_episode.title, _episode.enclosureUrl,
        backgroundAudioDuration, seekSliderValue);
    await dbHelper.saveHistory(history);
    await _queue.delFromPlaylist(_episode);
    if (_queue.playlist.length > 0) {
      _episode = _queue.playlist.first;
      _play(_episode);
      _backgroundAudioPlaying = true;
      notifyListeners();
    } else {
      _backgroundAudioPlaying = false;
      _remoteAudioLoading = false;
      notifyListeners();
    }
  }

  addToPlaylist(EpisodeBrief episode) async {
    _queue.addToPlayList(episode);
    await _queue.getPlaylist();
    notifyListeners();
  }

  pauseAduio() async {
    _pauseBackgroundAudio();
    _audioState = AudioState.pause;
    notifyListeners();
    PlayHistory history = PlayHistory(_episode.title, _episode.enclosureUrl,
        backgroundAudioDuration, seekSliderValue);
    await dbHelper.saveHistory(history);
    await _queue.delFromPlaylist(_episode);
  }

  resumeAudio() {
    _resumeBackgroundAudio();
    _audioState = AudioState.play;
    notifyListeners();
  }

  forwardAudio(double s) {
    _forwardBackgroundAudio(s);
    notifyListeners();
  }

  sliderSeek(double val) {
    _seekSliderValue = val;
    notifyListeners();
    final double positionSeconds = val * _backgroundAudioDurationSeconds;
    _backgroundAudio.seek(positionSeconds);
    AudioSystem.instance.setPlaybackState(true, positionSeconds);
  }

  disopse() {
    AudioSystem.instance.removeMediaEventListener(_mediaEventListener);
    _backgroundAudio?.dispose();
  }

  _play(EpisodeBrief episodeBrief) async {
    String url = _queue.playlist.first.enclosureUrl;
    _getFile(url).then((result) {
      result == 'NotDownload'
          ? _initbackgroundAudioPlayer(url)
          : _initbackgroundAudioPlayerLocal(result);
    });
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

  ByteData _getAudio(String path) {
    File audioFile = File(path);
    Uint8List audio = audioFile.readAsBytesSync();
    return ByteData.view(audio.buffer);
  }

  void _initbackgroundAudioPlayerLocal(String path) {
    _remoteErrorMessage = null;
    _remoteAudioLoading = true;
    ByteData audio = _getAudio(path);
    if (_backgroundAudioPlaying == true) {
      _stopBackgroundAudio();
    }
    _backgroundAudioPositionSeconds = 0;
    _setNotification(false);
    _backgroundAudio =
        Audio.loadFromByteData(audio, onDuration: (double durationSeconds) {
      _backgroundAudioDurationSeconds = durationSeconds;
      _remoteAudioLoading = false;
      _backgroundAudioPlaying = true;
      _setNotification(true);
      notifyListeners();
    }, onPosition: (double positionSeconds) {
      if (_backgroundAudioPositionSeconds < _backgroundAudioDurationSeconds) {
        _seekSliderValue =
            _backgroundAudioPositionSeconds / _backgroundAudioDurationSeconds;
        _backgroundAudioPositionSeconds = positionSeconds;
        notifyListeners();
      } else {
        _seekSliderValue = 1;
        _backgroundAudioPositionSeconds = _backgroundAudioDurationSeconds;
        notifyListeners();
      }
    }, onError: (String message) {
      _remoteErrorMessage = message;
      _backgroundAudio.dispose();
      _backgroundAudio = null;
      _backgroundAudioPlaying = false;
      _remoteAudioLoading = false;
    }, onComplete: () {
      playNext();
    }, looping: false, playInBackground: true)
          ..play();
  }

  void _initbackgroundAudioPlayer(String url) {
    _remoteErrorMessage = null;
    _remoteAudioLoading = true;
    notifyListeners();
    if (_backgroundAudioPlaying == true) {
      _stopBackgroundAudio();
    }
    _backgroundAudioPositionSeconds = 0;
    _setNotification(false);
    _backgroundAudio =
        Audio.loadFromRemoteUrl(url, onDuration: (double durationSeconds) {
      _backgroundAudioDurationSeconds = durationSeconds;
      _remoteAudioLoading = false;
      _backgroundAudioPlaying = true;
      _setNotification(true);
      notifyListeners();
    }, onPosition: (double positionSeconds) {
      if (_backgroundAudioPositionSeconds < _backgroundAudioDurationSeconds) {
        _seekSliderValue =
            _backgroundAudioPositionSeconds / _backgroundAudioDurationSeconds;
        _backgroundAudioPositionSeconds = positionSeconds;
        notifyListeners();
      } else {
        _seekSliderValue = 1;
        _backgroundAudioPositionSeconds = _backgroundAudioDurationSeconds;
        notifyListeners();
      }
    }, onError: (String message) {
      _remoteErrorMessage = message;
      _backgroundAudio.dispose();
      _backgroundAudio = null;
      _backgroundAudioPlaying = false;
      _remoteAudioLoading = false;
    }, onComplete: () {
      playNext();
    }, looping: false, playInBackground: true)
          ..resume();
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

  Future<void> _setNotification(bool b) async {
    final Uint8List imageBytes =
        File('${_episode.imagePath}').readAsBytesSync();
    AudioSystem.instance.setMetadata(AudioMetadata(
        title: episode.title,
        artist: episode.feedTitle,
        album: episode.feedTitle,
        genre: "Podcast",
        durationSeconds: _backgroundAudioDurationSeconds,
        artBytes: imageBytes));
    AudioSystem.instance.setPlaybackState(b, _backgroundAudioPositionSeconds);
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

    _backgroundAudioPlaying = true;

    final Uint8List imageBytes =
        File('${_episode.imagePath}').readAsBytesSync();
    AudioSystem.instance.setMetadata(AudioMetadata(
        title: _episode.title,
        artist: _episode.feedTitle,
        album: _episode.feedTitle,
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
    _backgroundAudioPlaying = false;
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
    _backgroundAudio?.pause();
    _backgroundAudio?.dispose();
    _backgroundAudioPlaying = false;
    AudioSystem.instance.stopBackgroundDisplay();
  }

  void _forwardBackgroundAudio(double seconds) {
    final double forwardposition = _backgroundAudioPositionSeconds + seconds;
    _backgroundAudio.seek(forwardposition);
    //AudioSystem.instance.setPlaybackState(true, _backgroundAudioDurationSeconds);
  }

  final _pauseButton = AndroidCustomMediaButton(
      'pausenow', pausenowButtonId, 'ic_stat_pause_circle_filled');
  final _replay10Button = AndroidCustomMediaButton(
      'replay10', replay10ButtonId, 'ic_stat_replay_10');
  final _forwardButton = AndroidCustomMediaButton(
      'forward', forwardButtonId, 'ic_stat_forward_30');
  final _playnowButton = AndroidCustomMediaButton(
      'playnow', likeButtonId, 'ic_stat_play_circle_filled');
}
