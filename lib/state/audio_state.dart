import 'dart:async';
import 'dart:math' as math;

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../type/episodebrief.dart';
import '../type/play_histroy.dart';
import '../type/playlist.dart';

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_stat_play_circle_filled',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_stat_pause_circle_filled',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl skipToNextControl = MediaControl(
  androidIcon: 'drawable/baseline_skip_next_white_24',
  label: 'Next',
  action: MediaAction.skipToNext,
);
MediaControl skipToPreviousControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_previous',
  label: 'Previous',
  action: MediaAction.skipToPrevious,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/baseline_close_white_24',
  label: 'Stop',
  action: MediaAction.stop,
);
MediaControl forward = MediaControl(
  androidIcon: 'drawable/baseline_fast_forward_white_24',
  label: 'forward',
  action: MediaAction.fastForward,
);

void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

/// Sleep timer mode.
enum SleepTimerMode { endOfEpisode, timer, undefined }
enum PlayerHeight { short, mid, tall }
//enum ShareStatus { generate, download, complete, undefined, error }

class AudioPlayerNotifier extends ChangeNotifier {
  DBHelper dbHelper = DBHelper();
  var positionStorage = KeyValueStorage(audioPositionKey);
  var autoPlayStorage = KeyValueStorage(autoPlayKey);
  var autoSleepTimerStorage = KeyValueStorage(autoSleepTimerKey);
  var defaultSleepTimerStorage = KeyValueStorage(defaultSleepTimerKey);
  var autoSleepTimerModeStorage = KeyValueStorage(autoSleepTimerModeKey);
  var autoSleepTimerStartStorage = KeyValueStorage(autoSleepTimerStartKey);
  var autoSleepTimerEndStorage = KeyValueStorage(autoSleepTimerEndKey);
  var fastForwardSecondsStorage = KeyValueStorage(fastForwardSecondsKey);
  var rewindSecondsStorage = KeyValueStorage(rewindSecondsKey);
  var playerHeightStorage = KeyValueStorage(playerHeightKey);
  var speedStorage = KeyValueStorage(speedKey);
  var skipSilenceStorage = KeyValueStorage(skipSilenceKey);
  var boostVolumeStorage = KeyValueStorage(boostVolumeKey);
  var volumeGainStorage = KeyValueStorage(volumeGainKey);

  /// Current playing episdoe.
  EpisodeBrief _episode;

  /// Current playlist.
  Playlist _queue;

  /// Notifier for playlist change.
  bool _queueUpdate = false;

  /// Player state.
  AudioProcessingState _audioState = AudioProcessingState.none;

  /// Player playing.
  bool _playing = false;

  /// Fastforward second.
  int _fastForwardSeconds = 0;

  /// Rewind seconds.
  int _rewindSeconds = 0;

  /// No slide, set true if slide on seekbar.
  bool _noSlide = true;

  /// Current episode duration.
  int _backgroundAudioDuration = 0;

  /// Current episode positin.
  int _backgroundAudioPosition = 0;

  /// Erroe maeesage.
  String _remoteErrorMessage;

  /// Seekbar value, min 0, max 1.0.
  double _seekSliderValue = 0.0;

  /// Record plyaer position.
  int _lastPostion = 0;

  /// Set true if sleep timer mode is end of episode.
  bool _stopOnComplete = false;

  /// Sleep timer timer.
  Timer _stopTimer;

  /// Sleep timer time left.
  int _timeLeft = 0;

  /// Start sleep timer.
  bool _startSleepTimer = false;

  /// Control sleep timer anamation.
  double _switchValue = 0;

  /// Sleep timer mode.
  SleepTimerMode _sleepTimerMode = SleepTimerMode.undefined;

  //Auto stop at the end of episode when you start play at scheduled time.
  bool _autoSleepTimer;

  //set autoplay episode in playlist
  bool _autoPlay;

  /// Datetime now.
  DateTime _current;

  /// Current position.
  int _currentPosition;

  /// Current speed.
  double _currentSpeed = 1;

  ///Update episode card when setting changed
  bool _episodeState = false;

  /// Player height.
  PlayerHeight _playerHeight;

  /// Player skip silence.
  bool _skipSilence;

  /// Boost volumn
  bool _boostVolume;

  /// Boost volume gain.
  int _volumeGain;

  // ignore: prefer_final_fields
  bool _playerRunning = false;

  AudioProcessingState get audioState => _audioState;
  int get backgroundAudioDuration => _backgroundAudioDuration;
  int get backgroundAudioPosition => _backgroundAudioPosition;
  double get seekSliderValue => _seekSliderValue;
  String get remoteErrorMessage => _remoteErrorMessage;
  bool get playerRunning => _playerRunning;
  bool get buffering => _audioState != AudioProcessingState.ready;
  int get lastPositin => _lastPostion;
  Playlist get queue => _queue;
  bool get playing => _playing;
  bool get queueUpdate => _queueUpdate;
  EpisodeBrief get episode => _episode;
  bool get stopOnComplete => _stopOnComplete;
  bool get startSleepTimer => _startSleepTimer;
  SleepTimerMode get sleepTimerMode => _sleepTimerMode;
  int get timeLeft => _timeLeft;
  double get switchValue => _switchValue;
  double get currentSpeed => _currentSpeed;
  bool get episodeState => _episodeState;
  bool get autoSleepTimer => _autoSleepTimer;
  int get fastForwardSeconds => _fastForwardSeconds;
  int get rewindSeconds => _rewindSeconds;
  PlayerHeight get playerHeight => _playerHeight;
  bool get skipSilence => _skipSilence;
  bool get boostVolume => _boostVolume;
  int get volumeGain => _volumeGain;

  set setSwitchValue(double value) {
    _switchValue = value;
    notifyListeners();
  }

  set setEpisodeState(bool boo) {
    _episodeState = !_episodeState;
    notifyListeners();
  }

  set setPlayerHeight(PlayerHeight mode) {
    _playerHeight = mode;
    notifyListeners();
    _savePlayerHeight();
  }

  set setVolumeGain(int volumeGain) {
    _volumeGain = volumeGain;
    if (_playerRunning && _boostVolume) {
      setBoostVolume(boostVolume: _boostVolume, gain: _volumeGain);
    }
    notifyListeners();
    volumeGainStorage.saveInt(volumeGain);
  }

  Future _initAudioData() async {
    var index = await playerHeightStorage.getInt(defaultValue: 0);
    _playerHeight = PlayerHeight.values[index];
    _currentSpeed = await speedStorage.getDoubel(defaultValue: 1.0);
    _skipSilence = await skipSilenceStorage.getBool(defaultValue: false);
    _boostVolume = await boostVolumeStorage.getBool(defaultValue: false);
    _volumeGain = await volumeGainStorage.getInt(defaultValue: 3000);
  }

  Future _savePlayerHeight() async {
    await playerHeightStorage.saveInt(_playerHeight.index);
  }

  Future _getAutoPlay() async {
    var i = await autoPlayStorage.getInt();
    _autoPlay = i == 0;
  }

  Future _getAutoSleepTimer() async {
    var i = await autoSleepTimerStorage.getInt();
    _autoSleepTimer = i == 1;
  }

  set setSleepTimerMode(SleepTimerMode timer) {
    _sleepTimerMode = timer;
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _initAudioData();
    //  _queueUpdate = false;
    // _getAutoSleepTimer();
    AudioService.connect();
    var running = AudioService.running;
    if (running) {}
  }

  Future<void> loadPlaylist() async {
    _queue = Playlist();
    await _queue.getPlaylist();
    await _getAutoPlay();
    _lastPostion = await positionStorage.getInt();
    if (_lastPostion > 0 && _queue.playlist.length > 0) {
      final episode = _queue.playlist.first;
      final duration = episode.duration * 1000;
      final seekValue = duration != 0 ? _lastPostion / duration : 1;
      final history = PlayHistory(
          episode.title, episode.enclosureUrl, _lastPostion ~/ 1000, seekValue);
      await dbHelper.saveHistory(history);
    }
    var lastWorkStorage = KeyValueStorage(lastWorkKey);
    await lastWorkStorage.saveInt(0);
  }

  Future<void> playlistLoad() async {
    await _queue.getPlaylist();
    _backgroundAudioDuration = 0;
    _backgroundAudioPosition = 0;
    _seekSliderValue = 0;
    _episode = _queue.playlist.first;
    _queueUpdate = !_queueUpdate;
    _audioState = AudioProcessingState.none;
    _playerRunning = true;
    notifyListeners();
    _startAudioService(_lastPostion ?? 0, _queue.playlist.first.enclosureUrl);
  }

  Future<void> episodeLoad(EpisodeBrief episode,
      {int startPosition = 0}) async {
    final episodeNew = await dbHelper.getRssItemWithUrl(episode.enclosureUrl);
    //TODO  load episode from last position when player running
    if (playerRunning) {
      final history = PlayHistory(_episode.title, _episode.enclosureUrl,
          backgroundAudioPosition ~/ 1000, seekSliderValue);
      await dbHelper.saveHistory(history);
      AudioService.addQueueItemAt(episodeNew.toMediaItem(), 0);
      _queue.playlist.removeAt(0);
      _queue.playlist.removeWhere((item) => item == episode);
      _queue.playlist.insert(0, episodeNew);
      _queueUpdate != _queueUpdate;
      _remoteErrorMessage = null;
      notifyListeners();
      await _queue.savePlaylist();
      if (episodeNew.isNew == 1) {
        await dbHelper.removeEpisodeNewMark(episodeNew.enclosureUrl);
      }
    } else {
      await _queue.getPlaylist();
      await _queue.addToPlayListAt(episodeNew, 0);
      _backgroundAudioDuration = 0;
      _backgroundAudioPosition = 0;
      _seekSliderValue = 0;
      _episode = episodeNew;
      _playerRunning = true;
      notifyListeners();
      _startAudioService(startPosition, episodeNew.enclosureUrl);
    }
  }

  _startAudioService(int position, String url) async {
    _stopOnComplete = false;
    _sleepTimerMode = SleepTimerMode.undefined;
    _switchValue = 0;

    /// Connect to audio service.
    if (!AudioService.connected) {
      await AudioService.connect();
    }

    /// Get fastword and rewind seconds.
    _fastForwardSeconds =
        await fastForwardSecondsStorage.getInt(defaultValue: 30);
    _rewindSeconds = await rewindSecondsStorage.getInt(defaultValue: 10);

    /// Start audio service.
    await AudioService.start(
        backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
        androidNotificationChannelName: 'Tsacdop',
        androidNotificationColor: 0xFF4d91be,
        androidNotificationIcon: 'drawable/ic_notification',
        androidEnableQueue: true,
        androidStopForegroundOnPause: true,
        fastForwardInterval: Duration(seconds: _fastForwardSeconds),
        rewindInterval: Duration(seconds: _rewindSeconds));

    //Check autoplay setting, if true only add one episode, else add playlist.
    await _getAutoPlay();
    if (_autoPlay) {
      for (var episode in _queue.playlist) {
        await AudioService.addQueueItem(episode.toMediaItem());
      }
    } else {
      await AudioService.addQueueItem(_queue.playlist.first.toMediaItem());
    }
    //Check auto sleep timer setting
    await _getAutoSleepTimer();
    if (_autoSleepTimer) {
      var startTime =
          await autoSleepTimerStartStorage.getInt(defaultValue: 1380);
      var endTime = await autoSleepTimerEndStorage.getInt(defaultValue: 360);
      var currentTime = DateTime.now().hour * 60 + DateTime.now().minute;
      if ((startTime > endTime &&
              (currentTime > startTime || currentTime < endTime)) ||
          ((startTime < endTime) &&
              (currentTime > startTime && currentTime < endTime))) {
        var mode = await autoSleepTimerModeStorage.getInt();
        _sleepTimerMode = SleepTimerMode.values[mode];
        var defaultTimer =
            await defaultSleepTimerStorage.getInt(defaultValue: 30);
        sleepTimer(defaultTimer);
      }
    }

    /// Set player speed.
    if (_currentSpeed != 1.0) {
      await AudioService.customAction('setSpeed', _currentSpeed);
    }

    /// Set slipsilence.
    if (_skipSilence) {
      await AudioService.customAction('setSkipSilence', skipSilence);
    }

    /// Set boostValome.
    if (_boostVolume) {
      await AudioService.customAction(
          'setBoostVolume', [_boostVolume, _volumeGain]);
    }

    await AudioService.play();

    AudioService.currentMediaItemStream
        .where((event) => event != null)
        .listen((item) async {
      var episode = await dbHelper.getRssItemWithMediaId(item.id);

      _backgroundAudioDuration = item.duration?.inMilliseconds ?? 0;
      if (episode != null) {
        _episode = episode;
        _backgroundAudioDuration = item.duration.inMilliseconds ?? 0;
        if (position > 0 &&
            _backgroundAudioDuration > 0 &&
            _episode.enclosureUrl == url) {
          AudioService.seekTo(Duration(milliseconds: position));
          position = 0;
        }
        notifyListeners();
      } else {
        //  _queue.playlist.removeAt(0);
        AudioService.skipToNext();
      }
    });
    AudioService.playbackStateStream
        .distinct()
        .where((event) => event != null)
        .listen((event) async {
      _current = DateTime.now();
      _audioState = event.processingState;
      _playing = event?.playing;
      _currentSpeed = event.speed;
      _currentPosition = event.currentPosition.inMilliseconds ?? 0;

      if (_audioState == AudioProcessingState.stopped) {
        if (_switchValue > 0) _switchValue = 0;
      }

      /// Get error state.
      if (_audioState == AudioProcessingState.error) {
        _remoteErrorMessage = 'Network Error';
      }

      /// Reset error state.
      if (_audioState != AudioProcessingState.error) {
        _remoteErrorMessage = null;
      }
      notifyListeners();
    });

    AudioService.customEventStream.distinct().listen((event) async {
      if (event is String && _episode.title == event) {
        _queue.delFromPlaylist(_episode);
        _lastPostion = 0;
        notifyListeners();
        await positionStorage.saveInt(_lastPostion);
        final history = PlayHistory(_episode.title, _episode.enclosureUrl,
            backgroundAudioPosition ~/ 1000, seekSliderValue);
        await dbHelper.saveHistory(history);
      }
      if (event is Map && event['playerRunning'] == false) {
        if (_playerRunning) {
          _playerRunning = false;
          notifyListeners();
          final history = PlayHistory(_episode.title, _episode.enclosureUrl,
              _lastPostion ~/ 1000, _seekSliderValue);
          await dbHelper.saveHistory(history);
        }
      }
    });

    //double s = _currentSpeed ?? 1.0;
    var getPosition = 0;
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      var s = _currentSpeed ?? 1.0;
      if (_noSlide) {
        if (_playing && !buffering) {
          getPosition = _currentPosition +
              ((DateTime.now().difference(_current).inMilliseconds) * s)
                  .toInt();
          _backgroundAudioPosition =
              math.min(getPosition, _backgroundAudioDuration);
        } else {
          _backgroundAudioPosition = _currentPosition ?? 0;
        }

        if (_backgroundAudioDuration != null &&
            _backgroundAudioDuration != 0 &&
            _backgroundAudioPosition != null) {
          _seekSliderValue =
              _backgroundAudioPosition / _backgroundAudioDuration ?? 0;
        } else {
          _seekSliderValue = 0;
        }

        if (_backgroundAudioPosition > 0 &&
            _backgroundAudioPosition < _backgroundAudioDuration) {
          _lastPostion = _backgroundAudioPosition;
          positionStorage.saveInt(_lastPostion);
        }
        notifyListeners();
      }
      if (_audioState == AudioProcessingState.stopped) {
        timer.cancel();
      }
    });
  }

  playNext() async {
    _remoteErrorMessage = null;
    await AudioService.skipToNext();
    _queueUpdate = !_queueUpdate;
    notifyListeners();
  }

  addToPlaylist(EpisodeBrief episode) async {
    var episodeNew = await dbHelper.getRssItemWithUrl(episode.enclosureUrl);
    if (!_queue.playlist.contains(episodeNew)) {
      if (playerRunning) {
        await AudioService.addQueueItem(episodeNew.toMediaItem());
      }
      await _queue.addToPlayList(episodeNew);
      _queueUpdate = !_queueUpdate;
      notifyListeners();
    }
  }

  addToPlaylistAt(EpisodeBrief episode, int index) async {
    var episodeNew = await dbHelper.getRssItemWithUrl(episode.enclosureUrl);
    if (playerRunning) {
      await AudioService.addQueueItemAt(episodeNew.toMediaItem(), index);
    }
    await _queue.addToPlayListAt(episodeNew, index);
    _queueUpdate = !_queueUpdate;
    notifyListeners();
  }

  addNewEpisode(List<String> group) async {
    var newEpisodes = <EpisodeBrief>[];
    if (group.first == 'All') {
      newEpisodes = await dbHelper.getRecentNewRssItem();
    } else {
      newEpisodes = await dbHelper.getGroupNewRssItem(group);
    }
    if (newEpisodes.length > 0 && newEpisodes.length < 100) {
      for (var episode in newEpisodes) {
        await addToPlaylist(episode);
      }
    }
    if (group.first == 'All') {
      await dbHelper.removeAllNewMark();
    } else {
      await dbHelper.removeGroupNewMark(group);
    }
  }

  updateMediaItem(EpisodeBrief episode) async {
    var index = _queue.playlist
        .indexWhere((item) => item.enclosureUrl == episode.enclosureUrl);
    if (index > 0) {
      var episodeNew = await dbHelper.getRssItemWithUrl(episode.enclosureUrl);
      await delFromPlaylist(episode);
      await addToPlaylistAt(episodeNew, index);
    }
  }

  Future<int> delFromPlaylist(EpisodeBrief episode) async {
    var episodeNew = await dbHelper.getRssItemWithUrl(episode.enclosureUrl);
    if (playerRunning) {
      await AudioService.removeQueueItem(episodeNew.toMediaItem());
    }
    var index = await _queue.delFromPlaylist(episodeNew);
    if (index == 0) {
      _lastPostion = 0;
      await positionStorage.saveInt(0);
    }
    _queueUpdate = !_queueUpdate;
    notifyListeners();
    return index;
  }

  Future reorderPlaylist(int oldIndex, int newIndex) async {
    var episode = _queue.playlist[oldIndex];
    if (playerRunning) {
      await AudioService.removeQueueItem(episode.toMediaItem());
      await AudioService.addQueueItemAt(episode.toMediaItem(), newIndex);
    }
    await _queue.addToPlayListAt(episode, newIndex);
    if (newIndex == 0) {
      _lastPostion = 0;
      await positionStorage.saveInt(0);
    }
  }

  Future<bool> moveToTop(EpisodeBrief episode) async {
    await delFromPlaylist(episode);
    if (playerRunning) {
      await AudioService.addQueueItemAt(episode.toMediaItem(), 1);
      await _queue.addToPlayListAt(episode, 1, existed: false);
    } else {
      await _queue.addToPlayListAt(episode, 0, existed: false);
      _lastPostion = 0;
      positionStorage.saveInt(_lastPostion);
    }
    _queueUpdate = !_queueUpdate;
    notifyListeners();
    return true;
  }

  Future<void> pauseAduio() async {
    await AudioService.pause();
  }

  Future<void> resumeAudio() async {
    _remoteErrorMessage = null;
    notifyListeners();
    if (_audioState != AudioProcessingState.connecting &&
        _audioState != AudioProcessingState.none) AudioService.play();
  }

  forwardAudio(int s) {
    var pos = _backgroundAudioPosition + s * 1000;
    AudioService.seekTo(Duration(milliseconds: pos));
  }

  fastForward() async {
    await AudioService.fastForward();
  }

  rewind() async {
    await AudioService.rewind();
  }

  seekTo(int position) async {
    if (_audioState != AudioProcessingState.connecting &&
        _audioState != AudioProcessingState.none) {
      await AudioService.seekTo(Duration(milliseconds: position));
    }
  }

  sliderSeek(double val) async {
    if (_audioState != AudioProcessingState.connecting &&
        _audioState != AudioProcessingState.none) {
      _noSlide = false;
      _seekSliderValue = val;
      notifyListeners();
      _currentPosition = (val * _backgroundAudioDuration).toInt();
      await AudioService.seekTo(Duration(milliseconds: _currentPosition));
      _noSlide = true;
    }
  }

  /// Set player speed.
  setSpeed(double speed) async {
    await AudioService.customAction('setSpeed', speed);
    _currentSpeed = speed;
    await speedStorage.saveDouble(_currentSpeed);
    notifyListeners();
  }

  setSkipSilence({@required bool skipSilence}) async {
    await AudioService.customAction('setSkipSilence', skipSilence);
    _skipSilence = skipSilence;
    await skipSilenceStorage.saveBool(_skipSilence);
    notifyListeners();
  }

  setBoostVolume({@required bool boostVolume, int gain}) async {
    await AudioService.customAction(
        'setBoostVolume', [boostVolume, _volumeGain]);
    _boostVolume = boostVolume;
    notifyListeners();
    await boostVolumeStorage.saveBool(boostVolume);
  }

  //Set sleep timer
  sleepTimer(int mins) {
    if (_sleepTimerMode == SleepTimerMode.timer) {
      _startSleepTimer = true;
      _switchValue = 1;
      notifyListeners();
      _timeLeft = mins * 60;
      Timer.periodic(Duration(seconds: 1), (timer) {
        if (_timeLeft == 0) {
          timer.cancel();
          notifyListeners();
        } else {
          _timeLeft = _timeLeft - 1;
          notifyListeners();
        }
      });
      _stopTimer = Timer(Duration(minutes: mins), () {
        _stopOnComplete = false;
        _startSleepTimer = false;
        _switchValue = 0;
        AudioService.stop();
        notifyListeners();
        // AudioService.disconnect();
      });
    } else if (_sleepTimerMode == SleepTimerMode.endOfEpisode) {
      _stopOnComplete = true;
      _switchValue = 1;
      notifyListeners();
      if (_queue.playlist.length > 1 && _autoPlay) {
        AudioService.customAction('stopAtEnd');
      }
    }
  }

//Cancel sleep timer
  cancelTimer() {
    if (_sleepTimerMode == SleepTimerMode.timer) {
      _stopTimer.cancel();
      _timeLeft = 0;
      _startSleepTimer = false;
      _switchValue = 0;
      notifyListeners();
    } else if (_sleepTimerMode == SleepTimerMode.endOfEpisode) {
      AudioService.customAction('cancelStopAtEnd');
      _switchValue = 0;
      _stopOnComplete = false;
      notifyListeners();
    }
  }

  @override
  void dispose() async {
    // await AudioService.stop();
    await AudioService.disconnect();
    //_playerRunning = false;
    super.dispose();
  }
}

class AudioPlayerTask extends BackgroundAudioTask {
  KeyValueStorage cacheStorage = KeyValueStorage(cacheMaxKey);

  final List<MediaItem> _queue = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioProcessingState _skipState;
  bool _playing;
  bool _interrupted = false;
  bool _stopAtEnd;
  int _cacheMax;
  bool get hasNext => _queue.length > 0;

  MediaItem get mediaItem => _queue.length > 0 ? _queue.first : null;

  StreamSubscription<AudioPlaybackState> _playerStateSubscription;
  StreamSubscription<AudioPlaybackEvent> _eventSubscription;

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    _stopAtEnd = false;
    _playerStateSubscription = _audioPlayer.playbackStateStream
        .where((state) => state == AudioPlaybackState.completed)
        .listen((state) {
      _handlePlaybackCompleted();
    });

    _eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      if (event.playbackError != null) {
        _playing = false;
        _setState(processingState: _skipState ?? AudioProcessingState.error);
      }
      final bufferingState =
          event.buffering ? AudioProcessingState.buffering : null;
      switch (event.state) {
        case AudioPlaybackState.paused:
          _setState(
            processingState: bufferingState ?? AudioProcessingState.ready,
            position: event.position,
          );
          break;
        case AudioPlaybackState.playing:
          _setState(
            processingState: bufferingState ?? AudioProcessingState.ready,
            position: event.position,
          );
          break;
        case AudioPlaybackState.connecting:
          _setState(
            processingState: _skipState ?? AudioProcessingState.connecting,
            position: event.position,
          );
          break;
        default:
          break;
      }
    });
  }

  void _handlePlaybackCompleted() async {
    if (hasNext) {
      onSkipToNext();
    } else {
      _audioPlayer.stop();
      _queue.removeAt(0);
      await AudioServiceBackground.setQueue(_queue);
      onStop();
    }
  }

  void playPause() {
    if (AudioServiceBackground.state.playing) {
      onPause();
    } else {
      onPlay();
    }
  }

  @override
  Future<void> onSkipToNext() async {
    _skipState = AudioProcessingState.skippingToNext;
    _playing = false;
    await _audioPlayer.stop();
    if (_queue.length > 0) {
      AudioServiceBackground.sendCustomEvent(_queue.first.title);
      _queue.removeAt(0);
    }
    await AudioServiceBackground.setQueue(_queue);
    if (_queue.length == 0 || _stopAtEnd) {
      _skipState = null;
      onStop();
    } else {
      await AudioServiceBackground.setQueue(_queue);
      await AudioServiceBackground.setMediaItem(mediaItem);
      await _audioPlayer.setUrl(mediaItem.id, cacheMax: _cacheMax);
      var duration = await _audioPlayer.durationFuture;
      if (duration != null) {
        await AudioServiceBackground.setMediaItem(
            mediaItem.copyWith(duration: duration));
      }
      _skipState = null;
      // Resume playback if we were playing
      // if (_playing) {
      //onPlay();
      playFromStart();
      // } else {
      //   _setState(state: BasicPlaybackState.paused);
      //  }
    }
  }

  @override
  void onPlay() async {
    if (_skipState == null) {
      if (_playing == null) {
        _playing = true;
        _cacheMax = await cacheStorage.getInt(
            defaultValue: (200 * 1024 * 1024).toInt());
        if (_cacheMax == 0) {
          await cacheStorage.saveInt((200 * 1024 * 1024).toInt());
          _cacheMax = 200 * 1024 * 1024;
        }
        await _audioPlayer.setUrl(mediaItem.id, cacheMax: _cacheMax);
        var duration = await _audioPlayer.durationFuture;
        if (duration != null) {
          await AudioServiceBackground.setMediaItem(
              mediaItem.copyWith(duration: duration));
        }
        playFromStart();
      } else {
        _playing = true;
        if (_audioPlayer.playbackEvent.state != AudioPlaybackState.connecting ||
            _audioPlayer.playbackEvent.state != AudioPlaybackState.none) {
          _audioPlayer.play();
        }
      }
    }
  }

  playFromStart() async {
    _playing = true;
    if (_audioPlayer.playbackEvent.state != AudioPlaybackState.connecting ||
        _audioPlayer.playbackEvent.state != AudioPlaybackState.none) {
      try {
        _audioPlayer.play();
      } catch (e) {
        _setState(processingState: AudioProcessingState.error);
      }
    }
    if (mediaItem.extras['skip'] > 0) {
      _audioPlayer.seek(Duration(seconds: mediaItem.extras['skip']));
    }
  }

  @override
  void onPause() {
    if (_skipState == null) {
      if (_playing == null) {
      } else if (_playing) {
        _playing = false;
        _audioPlayer.pause();
      }
    }
  }

  @override
  void onSeekTo(Duration position) {
    if (_audioPlayer.playbackEvent.state != AudioPlaybackState.connecting ||
        _audioPlayer.playbackEvent.state != AudioPlaybackState.none) {
      _audioPlayer.seek(position);
    }
  }

  @override
  void onClick(MediaButton button) {
    if (button == MediaButton.media) {
      playPause();
    } else if (button == MediaButton.next) {
      _seekRelative(fastForwardInterval);
    } else if (button == MediaButton.previous) _seekRelative(-rewindInterval);
  }

  Future<void> _seekRelative(Duration offset) async {
    var newPosition = _audioPlayer.playbackEvent.position + offset;
    //  if (newPosition < Duration.zero) newPosition = Duration.zero;
    //  if (newPosition > mediaItem.duration) newPosition = mediaItem.duration;
    onSeekTo(newPosition);
  }

  @override
  Future<void> onStop() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    _playing = false;
    _playerStateSubscription.cancel();
    _eventSubscription.cancel();
    await _setState(processingState: AudioProcessingState.none);
    AudioServiceBackground.sendCustomEvent({'playerRunning': false});
    await super.onStop();
  }

  @override
  void onAddQueueItem(MediaItem mediaItem) async {
    _queue.add(mediaItem);
    await AudioServiceBackground.setQueue(_queue);
  }

  @override
  void onRemoveQueueItem(MediaItem mediaItem) async {
    _queue.removeWhere((item) => item.id == mediaItem.id);
    await AudioServiceBackground.setQueue(_queue);
  }

  @override
  void onAddQueueItemAt(MediaItem mediaItem, int index) async {
    if (index == 0) {
      await _audioPlayer.stop();
      _queue.removeAt(0);
      _queue.removeWhere((item) => item.id == mediaItem.id);
      _queue.insert(0, mediaItem);
      await AudioServiceBackground.setQueue(_queue);
      await AudioServiceBackground.setMediaItem(mediaItem);
      await _audioPlayer.setUrl(mediaItem.id, cacheMax: _cacheMax);
      var duration = await _audioPlayer.durationFuture ?? Duration.zero;
      AudioServiceBackground.setMediaItem(
          mediaItem.copyWith(duration: duration));
      playFromStart();
      //onPlay();
    } else {
      _queue.insert(index, mediaItem);
      await AudioServiceBackground.setQueue(_queue);
    }
  }

  @override
  void onFastForward() async {
    await _seekRelative(fastForwardInterval);
  }

  @override
  void onRewind() async {
    await _seekRelative(-rewindInterval);
  }

  @override
  void onAudioFocusLost(AudioInterruption interruption) {
    if (_playing) _interrupted = true;
    switch (interruption) {
      case AudioInterruption.pause:
      case AudioInterruption.temporaryPause:
      case AudioInterruption.unknownPause:
        onPause();
        break;
      case AudioInterruption.temporaryDuck:
        _audioPlayer.setVolume(0.5);
        break;
    }
  }

  @override
  void onAudioBecomingNoisy() {
    if (_skipState == null) {
      if (_playing == null) {
      } else if (_audioPlayer.playbackEvent.state ==
          AudioPlaybackState.playing) {
        _playing = false;
        _audioPlayer.pause();
      }
    }
  }

  @override
  void onAudioFocusGained(AudioInterruption interruption) {
    switch (interruption) {
      case AudioInterruption.temporaryPause:
        if (!_playing && _interrupted) onPlay();
        break;
      case AudioInterruption.temporaryDuck:
        _audioPlayer.setVolume(1.0);
        break;
      default:
        break;
    }
    _interrupted = false;
  }

  @override
  Future onCustomAction(funtion, argument) async {
    switch (funtion) {
      case 'stopAtEnd':
        _stopAtEnd = true;
        break;
      case 'cancelStopAtEnd':
        _stopAtEnd = false;
        break;
      case 'setSpeed':
        await _audioPlayer.setSpeed(argument);
        break;
      case 'setSkipSilence':
        await _setSkipSilence(argument);
        break;
      case 'setBoostVolume':
        await _setBoostVolume(argument[0], argument[1]);
        break;
    }
  }

  Future _setSkipSilence(bool boo) async {
    await _audioPlayer.setSkipSilence(boo);
    var duration = await _audioPlayer.durationFuture ?? Duration.zero;
    AudioServiceBackground.setMediaItem(mediaItem.copyWith(duration: duration));
  }

  Future _setBoostVolume(bool boo, int gain) async {
    await _audioPlayer.setBoostVolume(boo, gain: gain);
  }

  Future<void> _setState({
    AudioProcessingState processingState,
    Duration position,
    Duration bufferedPosition,
  }) async {
    if (position == null) {
      position = _audioPlayer.playbackEvent.position;
    }
    await AudioServiceBackground.setState(
      controls: getControls(),
      systemActions: [MediaAction.seekTo],
      processingState:
          processingState ?? AudioServiceBackground.state.processingState,
      playing: _playing ?? false,
      position: position,
      bufferedPosition: bufferedPosition ?? position,
      speed: _audioPlayer.speed,
    );
  }

  List<MediaControl> getControls() {
    if (_playing) {
      return [pauseControl, forward, skipToNextControl, stopControl];
    } else {
      return [playControl, forward, skipToNextControl, stopControl];
    }
  }
}
