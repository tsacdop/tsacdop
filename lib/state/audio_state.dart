import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
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
MediaControl forwardControl = MediaControl(
  androidIcon: 'drawable/baseline_fast_forward_white_24',
  label: 'forward',
  action: MediaAction.fastForward,
);

MediaControl rewindControl = MediaControl(
  androidIcon: 'drawable/baseline_fast_rewind_white_24',
  label: 'rewind',
  action: MediaAction.rewind,
);

void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

/// Sleep timer mode.
enum SleepTimerMode { endOfEpisode, timer, undefined }
enum PlayerHeight { short, mid, tall }

class AudioPlayerNotifier extends ChangeNotifier {
  final _dbHelper = DBHelper();
  final _positionStorage = KeyValueStorage(audioPositionKey);
  final _autoPlayStorage = KeyValueStorage(autoPlayKey);
  final _autoSleepTimerStorage = KeyValueStorage(autoSleepTimerKey);
  final _defaultSleepTimerStorage = KeyValueStorage(defaultSleepTimerKey);
  final _autoSleepTimerModeStorage = KeyValueStorage(autoSleepTimerModeKey);
  final _autoSleepTimerStartStorage = KeyValueStorage(autoSleepTimerStartKey);
  final _autoSleepTimerEndStorage = KeyValueStorage(autoSleepTimerEndKey);
  final _fastForwardSecondsStorage = KeyValueStorage(fastForwardSecondsKey);
  final _rewindSecondsStorage = KeyValueStorage(rewindSecondsKey);
  final _playerHeightStorage = KeyValueStorage(playerHeightKey);
  final _speedStorage = KeyValueStorage(speedKey);
  final _skipSilenceStorage = KeyValueStorage(skipSilenceKey);
  final _boostVolumeStorage = KeyValueStorage(boostVolumeKey);
  final _volumeGainStorage = KeyValueStorage(volumeGainKey);
  final _markListenedAfterSkipStorage =
      KeyValueStorage(markListenedAfterSkipKey);
  final _playlistsStorgae = KeyValueStorage(playlistsAllKey);
  final _playerStateStorage = KeyValueStorage(playerStateKey);

  /// Playing episdoe.
  EpisodeBrief _episode;

  /// Playlists include queue and playlists created by user.
  List<Playlist> _playlists = [];

  /// Playing playlist.
  Playlist _playlist;

  /// Queue is the first playlist by default.
  Playlist get _queue => _playlists.first;

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
  int _lastPosition = 0;

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

  bool _markListened;

  // Tmep episode list, playing from search result
  List<EpisodeBrief> _playFromSearchList = [];

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _initAudioData();
    AudioService.connect();
  }

  @override
  void dispose() async {
    await AudioService.disconnect();
    super.dispose();
  }

  /// Audio playing state.
  AudioProcessingState get audioState => _audioState;
  int get backgroundAudioDuration => _backgroundAudioDuration;
  int get backgroundAudioPosition => _backgroundAudioPosition;
  double get seekSliderValue => _seekSliderValue;
  String get remoteErrorMessage => _remoteErrorMessage;
  bool get playerRunning => _playerRunning;
  bool get buffering => _audioState != AudioProcessingState.ready;
  EpisodeBrief get episode => _episode;

  /// Playlist provider.
  int get lastPosition => _lastPosition;
  List<Playlist> get playlists => _playlists;
  Playlist get queue => _playlists.first;
  bool get playing => _playing;
  Playlist get playlist => _playlist;

  /// Player control.
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

  Future<void> _initAudioData() async {
    var index = await _playerHeightStorage.getInt(defaultValue: 0);
    _playerHeight = PlayerHeight.values[index];
    _currentSpeed = await _speedStorage.getDouble(defaultValue: 1.0);
    _skipSilence = await _skipSilenceStorage.getBool(defaultValue: false);
    _boostVolume = await _boostVolumeStorage.getBool(defaultValue: false);
    _volumeGain = await _volumeGainStorage.getInt(defaultValue: 3000);
  }

  Future _savePlayerHeight() async {
    await _playerHeightStorage.saveInt(_playerHeight.index);
  }

  Future _getAutoPlay() async {
    var i = await _autoPlayStorage.getInt();
    _autoPlay = i == 0;
  }

  Future _getAutoSleepTimer() async {
    var i = await _autoSleepTimerStorage.getInt();
    _autoSleepTimer = i == 1;
  }

  Future<void> initPlaylist() async {
    if (_playlists.isEmpty) {
      var playlistEntities = await _playlistsStorgae.getPlaylists();
      _playlists = [
        for (var entity in playlistEntities) Playlist.fromEntity(entity)
      ];
      await _playlists.first.getPlaylist();
      await _getAutoPlay();

      ///Get playerstate saved in storage.
      var state = await _playerStateStorage.getPlayerState();
      var idList = [for (var p in _playlists) p.id];
      if (idList.contains(state[0])) {
        _playlist = _playlists.firstWhere(
          (p) => p.id == state[0],
        );
        await _playlist.getPlaylist();
        if (state[1] != '') {
          var episode = await _dbHelper.getRssItemWithUrl(state[1]);
          if (episode != null && ((!_playlist.isQueue &&
                  episode != null &&
                  _playlist.contains(episode)) ||
              (_playlist.isQueue &&
                  _queue.isNotEmpty &&
                  _queue.episodes.first.title == episode.title))) {
            _episode = episode;
            _lastPosition = int.parse(state[2] ?? '0');
            if (_lastPosition > 0) {
              {
                final duration = episode.duration * 1000;
                final seekValue =
                    duration != 0 ? _lastPosition / duration : 1.0;
                final history = PlayHistory(episode.title, episode.enclosureUrl,
                    _lastPosition ~/ 1000, seekValue);
                await _dbHelper.saveHistory(history);
              }
            }
          } else {
            _episode = _playlist.isNotEmpty ? _playlist.episodes.first : null;
            _lastPosition = 0;
          }
        } else {
          _episode = _playlist.isNotEmpty ? _playlist.episodes.first : null;
          _lastPosition = 0;
        }
      } else {
        _playlist = _playlists.first;
        _episode = _playlist.isNotEmpty ? _playlist.episodes?.first : null;
        _lastPosition = 0;
      }
      notifyListeners();

      await KeyValueStorage(lastWorkKey).saveInt(0);
    }
  }

  Future<void> playFromLastPosition() async {
    if (_playlist.episodes.isNotEmpty) {
      await _playlist.getPlaylist();
      if (_episode == null || !_playlist.episodes.contains(_episode)) {
        _episode = _playlist.isNotEmpty ? _playlist.episodes.first : null;
      }
      _audioState = AudioProcessingState.none;
      _backgroundAudioDuration = 0;
      _backgroundAudioPosition = 0;
      _seekSliderValue = 0;
      _playerRunning = true;
      notifyListeners();
      _startAudioService(_playlist,
          position: _lastPosition ?? 0,
          index: _playlist.episodes.indexOf(_episode));
    }
  }

  Future<void> playlistLoad(Playlist playlist) async {
    var p = playlist;
    if (playlist.name != 'Queue') {
      await updatePlaylist(p, updateEpisodes: true);
    }
    _playlist = p;
    notifyListeners();
    if (playlist.isNotEmpty) {
      if (playerRunning) {
        AudioService.customAction('setIsQueue', playlist.name == 'Queue');
        AudioService.customAction('changeQueue',
            [for (var e in p.episodes) jsonEncode(e.toMediaItem().toJson())]);
      } else {
        _backgroundAudioDuration = 0;
        _backgroundAudioPosition = 0;
        _seekSliderValue = 0;
        _episode = playlist.episodes.first;
        _audioState = AudioProcessingState.none;
        _playerRunning = true;
        notifyListeners();
        _startAudioService(_playlist, position: 0, index: 0);
      }
    }
  }

  Future<void> episodeLoad(EpisodeBrief episode,
      {int startPosition = 0, bool fromSearch = false}) async {
    var episodeNew;
    if (fromSearch) {
      episodeNew = episode;
      _playFromSearchList.add(episode);
    } else {
      episodeNew = await _dbHelper.getRssItemWithUrl(episode.enclosureUrl);
    }
    //TODO  load episode from last position when player running
    if (playerRunning) {
      if (_playFromSearchList.contains(_episode)) {
        _queue.delFromPlaylist(_episode);
      } else {
        final history = PlayHistory(_episode.title, _episode.enclosureUrl,
            backgroundAudioPosition ~/ 1000, seekSliderValue);
        await _dbHelper.saveHistory(history);
      }
      _queue.addToPlayListAt(episodeNew, 0);
      await updatePlaylist(_queue, updateEpisodes: !fromSearch);
      if (!_playlist.isQueue) {
        AudioService.customAction('setIsQueue', true);
        AudioService.customAction('changeQueue', [
          for (var e in _queue.episodes) jsonEncode(e.toMediaItem().toJson())
        ]);
        _playlist = _queue;
      }
      await AudioService.addQueueItemAt(episodeNew.toMediaItem(), 0);
      if (startPosition > 0) {
        await AudioService.seekTo(Duration(milliseconds: startPosition));
      }
      _remoteErrorMessage = null;
      notifyListeners();
      if (episodeNew.isNew == 1) {
        await _dbHelper.removeEpisodeNewMark(episodeNew.enclosureUrl);
      }
    } else {
      await _queue.getPlaylist();
      _queue.addToPlayListAt(episodeNew, 0);
      updatePlaylist(_queue, updateEpisodes: false);
      _backgroundAudioDuration = 0;
      _backgroundAudioPosition = 0;
      _seekSliderValue = 0;
      _episode = episodeNew;
      _playerRunning = true;
      notifyListeners();
      _startAudioService(_queue, position: startPosition);
    }
  }

  Future<void> loadEpisodeFromPlaylist(EpisodeBrief episode) async {
    if (_playlist.episodes.contains(episode)) {
      var index = _playlist.episodes.indexOf(episode);
      await AudioService.customAction('changeIndex', index);
    }
  }

  Future<void> _startAudioService(Playlist playlist,
      {int index = 0, int position = 0}) async {
    _stopOnComplete = false;
    _sleepTimerMode = SleepTimerMode.undefined;
    _switchValue = 0;

    /// Connect to audio service.
    if (!AudioService.connected) {
      await AudioService.connect();
    }

    /// Get fastword and rewind seconds.
    _fastForwardSeconds =
        await _fastForwardSecondsStorage.getInt(defaultValue: 30);
    _rewindSeconds = await _rewindSecondsStorage.getInt(defaultValue: 10);

    /// Get if auto mark listened after skip
    _markListened =
        await _markListenedAfterSkipStorage.getBool(defaultValue: false);

    /// Start audio service.
    await AudioService.start(
        backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
        params: {'index': index, 'isQueue': playlist.name == 'Queue'},
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
      for (var episode in playlist.episodes) {
        await AudioService.addQueueItem(episode.toMediaItem());
      }
    } else {
      await AudioService.addQueueItem(playlist.episodes[index].toMediaItem());
    }
    //Check auto sleep timer setting
    await _getAutoSleepTimer();
    if (_autoSleepTimer) {
      var startTime =
          await _autoSleepTimerStartStorage.getInt(defaultValue: 1380);
      var endTime = await _autoSleepTimerEndStorage.getInt(defaultValue: 360);
      var currentTime = DateTime.now().hour * 60 + DateTime.now().minute;
      if ((startTime > endTime &&
              (currentTime > startTime || currentTime < endTime)) ||
          ((startTime < endTime) &&
              (currentTime > startTime && currentTime < endTime))) {
        var mode = await _autoSleepTimerModeStorage.getInt();
        _sleepTimerMode = SleepTimerMode.values[mode];
        var defaultTimer =
            await _defaultSleepTimerStorage.getInt(defaultValue: 30);
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
      var episode = await _dbHelper.getRssItemWithMediaId(item.id);
      if (episode == null) {
        episode = _playFromSearchList.firstWhere((e) => e.mediaId == item.id,
            orElse: () => null);
      }
      _backgroundAudioDuration = item.duration?.inMilliseconds ?? 0;
      if (episode != null) {
        _episode = episode;
        _backgroundAudioDuration = item.duration.inMilliseconds ?? 0;
        if (position > 0 &&
            _backgroundAudioDuration > 0 &&
            _episode.enclosureUrl == _playlist.episodeList[index]) {
          await AudioService.seekTo(Duration(milliseconds: position));
          position = 0;
        }
        notifyListeners();
      } else {
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
      if (event is String) {
        if (_playlist.isQueue &&
            _queue.isNotEmpty &&
            _queue.episodes.first.title == event) {
          _queue.delFromPlaylist(_episode);
          updatePlaylist(_queue, updateEpisodes: false);
        }
        _lastPosition = 0;
        notifyListeners();
        // await _positionStorage.saveInt(_lastPostion);
        await _playerStateStorage.savePlayerState(
            _playlist.id, _episode.enclosureUrl, _lastPosition);
        var history;
        if (_markListened) {
          history = PlayHistory(_episode.title, _episode.enclosureUrl,
              _backgroundAudioPosition ~/ 1000, 1);
        } else {
          history = PlayHistory(_episode.title, _episode.enclosureUrl,
              _backgroundAudioPosition ~/ 1000, _seekSliderValue);
        }
        await _dbHelper.saveHistory(history);
      }
      if (event is Map && event['playerRunning'] == false && _playerRunning) {
        _playerRunning = false;
        notifyListeners();
        if (_lastPosition > 0) {
          final history = PlayHistory(_episode.title, _episode.enclosureUrl,
              _lastPosition ~/ 1000, _seekSliderValue);
          await _dbHelper.saveHistory(history);
        }
        //_episode = null;
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
          _lastPosition = _backgroundAudioPosition;
          _playerStateStorage.savePlayerState(
              _playlist.id, _episode.enclosureUrl, _lastPosition);
        }
        notifyListeners();
      }
      if (_audioState == AudioProcessingState.stopped) {
        timer.cancel();
      }
    });
  }

  /// Queue management.
  Future<void> addToPlaylist(EpisodeBrief episode) async {
    var episodeNew = await _dbHelper.getRssItemWithUrl(episode.enclosureUrl);
    if (episodeNew.isNew == 1) {
      await _dbHelper.removeEpisodeNewMark(episodeNew.enclosureUrl);
    }
    if (!_queue.episodes.contains(episodeNew)) {
      if (playerRunning && _playlist.isQueue) {
        await AudioService.addQueueItem(episodeNew.toMediaItem());
      }
      if (_playlist.isQueue && _queue.isEmpty) _episode = episodeNew;
      _queue.addToPlayList(episodeNew);
      await updatePlaylist(_queue, updateEpisodes: false);
    }
  }

  Future<void> addToPlaylistAt(EpisodeBrief episode, int index) async {
    var episodeNew = await _dbHelper.getRssItemWithUrl(episode.enclosureUrl);
    if (episodeNew.isNew == 1) {
      await _dbHelper.removeEpisodeNewMark(episodeNew.enclosureUrl);
    }
    if (_playerRunning && _playlist.isQueue) {
      await AudioService.addQueueItemAt(episodeNew.toMediaItem(), index);
    }
    _queue.addToPlayListAt(episodeNew, index);
    await updatePlaylist(_queue, updateEpisodes: false);
  }

  Future<void> addNewEpisode(List<String> group) async {
    var newEpisodes = <EpisodeBrief>[];
    if (group.isEmpty) {
      newEpisodes = await _dbHelper.getRecentNewRssItem();
    } else {
      newEpisodes = await _dbHelper.getGroupNewRssItem(group);
    }
    if (newEpisodes.length > 0 && newEpisodes.length < 100) {
      for (var episode in newEpisodes) {
        await addToPlaylist(episode);
      }
    }
    if (group.isEmpty) {
      await _dbHelper.removeAllNewMark();
    } else {
      await _dbHelper.removeGroupNewMark(group);
    }
  }

  Future<void> updateMediaItem(EpisodeBrief episode) async {
    if (episode.enclosureUrl == episode.mediaId &&
        _episode != episode &&
        _playlist.contains(episode)) {
      var episodeNew = await _dbHelper.getRssItemWithUrl(episode.enclosureUrl);
      _playlist.updateEpisode(episodeNew);
      if (_playerRunning) {
        await AudioService.updateMediaItem(episodeNew.toMediaItem());
      }
    }
  }

  Future<int> delFromPlaylist(EpisodeBrief episode) async {
    var episodeNew = await _dbHelper.getRssItemWithUrl(episode.enclosureUrl);
    if (playerRunning && _playlist.isQueue) {
      await AudioService.removeQueueItem(episodeNew.toMediaItem());
    }
    var index = _queue.delFromPlaylist(episodeNew);
    if (index == 0) {
      _lastPosition = 0;
      await _positionStorage.saveInt(0);
    }
    updatePlaylist(_queue, updateEpisodes: false);
    return index;
  }

  Future reorderPlaylist(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    var episode = _queue.episodes[oldIndex];
    _queue.addToPlayListAt(episode, newIndex);
    updatePlaylist(_queue, updateEpisodes: false);
    if (playerRunning && _playlist.name == 'Queue') {
      await AudioService.removeQueueItem(episode.toMediaItem());
      await AudioService.addQueueItemAt(episode.toMediaItem(), newIndex);
    }
    if (newIndex == 0) {
      _lastPosition = 0;
      await _positionStorage.saveInt(0);
    }
  }

  Future<bool> moveToTop(EpisodeBrief episode) async {
    await delFromPlaylist(episode);
    final episodeNew = await _dbHelper.getRssItemWithUrl(episode.enclosureUrl);
    if (_playerRunning && _playlist.isQueue) {
      await AudioService.addQueueItemAt(episodeNew.toMediaItem(), 1);
      _queue.addToPlayListAt(episode, 1, existed: false);
    } else {
      _queue.addToPlayListAt(episode, 0, existed: false);
      if (_playlist.isQueue) {
        _lastPosition = 0;
        _positionStorage.saveInt(_lastPosition);
        _episode = episodeNew;
      }
    }
    updatePlaylist(_queue, updateEpisodes: false);
    return true;
  }

  /// Custom playlist management.
  void addPlaylist(Playlist playlist) {
    _playlists = [..._playlists, playlist];
    notifyListeners();
    _savePlaylists();
  }

  void deletePlaylist(Playlist playlist) {
    _playlists = [
      for (var p in _playlists)
        if (p != playlist) p
    ];
    if (_playlist == playlist && !_playerRunning) {
      _playlist = _queue;
      _episode = _playlist.isNotEmpty ? _queue.episodes.first : null;
    }
    notifyListeners();
    _savePlaylists();
  }

  void addEpisodesToPlaylist(Playlist playlist, {List<EpisodeBrief> episodes}) {
    for (var e in episodes) {
      playlist.addToPlayList(e);
      if (playerRunning && playlist == _playlist) {
        AudioService.addQueueItem(e.toMediaItem());
      }
    }
    updatePlaylist(playlist, updateEpisodes: false);
  }

  void removeEpisodeFromPlaylist(Playlist playlist,
      {List<EpisodeBrief> episodes}) {
    for (var e in episodes) {
      playlist.delFromPlaylist(e);
      if (playerRunning && playlist == _playlist) {
        AudioService.removeQueueItem(e.toMediaItem());
      }
    }
    updatePlaylist(playlist, updateEpisodes: false);
  }

  void reorderEpisodesInPlaylist(Playlist playlist,
      {int oldIndex, int newIndex}) async {
    playlist.reorderPlaylist(oldIndex, newIndex);

    if (playerRunning && playlist == _playlist) {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      await AudioService.removeQueueItem(episode.toMediaItem());
      await AudioService.addQueueItemAt(episode.toMediaItem(), newIndex);
    }
    updatePlaylist(playlist, updateEpisodes: false);
  }

  void clearPlaylist(Playlist playlist) {
    if (_playerRunning && _playlist.isQueue && playlist.isQueue) {
      for (var e in playlist.episodes) {
        if (e != _episode) {
          delFromPlaylist(e);
        }
      }
    } else {
      playlist.clear();
      if (_playlist.isQueue) _episode = null;
    }
    updatePlaylist(playlist, updateEpisodes: false);
  }

  Future<void> updatePlaylist(Playlist playlist,
      {bool updateEpisodes = true}) async {
    if (updateEpisodes) await playlist.getPlaylist();
    _playlists = [for (var p in _playlists) p.id == playlist.id ? playlist : p];
    if (_playlist.id == playlist.id) {
      if (playlist.isQueue) {
        _playlist = _queue;
      } else if (!_playerRunning) {
        _playlist = _playlists.firstWhere((e) => e.id == _playlist.id);
      }
      notifyListeners();
    }
    await _savePlaylists();
  }

  bool playlistExisted(String name) {
    for (var p in _playlists) {
      if (p.name == name) return true;
    }
    return false;
  }

  // void _updateAllPlaylists() {
  //   _playlists = [..._playlists];
  //   notifyListeners();
  //   _savePlaylists();
  // }

  Future<void> _savePlaylists() async {
    await _playlistsStorgae
        .savePlaylists([for (var p in _playlists) p.toEntity()]);
  }

  /// Audio control.
  Future<void> pauseAduio() async {
    await AudioService.pause();
  }

  Future<void> resumeAudio() async {
    _remoteErrorMessage = null;
    notifyListeners();
    if (_audioState != AudioProcessingState.connecting &&
        _audioState != AudioProcessingState.none) {
      AudioService.play();
    }
  }

  Future<void> playNext() async {
    _remoteErrorMessage = null;
    await AudioService.skipToNext();
    notifyListeners();
  }

  Future<void> forwardAudio(int s) async {
    var pos = _backgroundAudioPosition + s * 1000;
    await AudioService.seekTo(Duration(milliseconds: pos));
  }

  Future<void> fastForward() async {
    await AudioService.fastForward();
  }

  Future<void> rewind() async {
    await AudioService.rewind();
  }

  Future<void> seekTo(int position) async {
    if (_audioState != AudioProcessingState.connecting &&
        _audioState != AudioProcessingState.none) {
      await AudioService.seekTo(Duration(milliseconds: position));
    }
  }

  Future<void> sliderSeek(double val) async {
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
  Future<void> setSpeed(double speed) async {
    await AudioService.customAction('setSpeed', speed);
    _currentSpeed = speed;
    await _speedStorage.saveDouble(_currentSpeed);
    notifyListeners();
  }

  /// Set skip silence.
  Future<void> setSkipSilence({@required bool skipSilence}) async {
    await AudioService.customAction('setSkipSilence', skipSilence);
    _skipSilence = skipSilence;
    await _skipSilenceStorage.saveBool(_skipSilence);
    notifyListeners();
  }

  set setVolumeGain(int volumeGain) {
    _volumeGain = volumeGain;
    if (_playerRunning && _boostVolume) {
      setBoostVolume(boostVolume: _boostVolume, gain: _volumeGain);
    }
    notifyListeners();
    _volumeGainStorage.saveInt(volumeGain);
  }

  Future<void> setBoostVolume({@required bool boostVolume, int gain}) async {
    await AudioService.customAction(
        'setBoostVolume', [boostVolume, _volumeGain]);
    _boostVolume = boostVolume;
    notifyListeners();
    await _boostVolumeStorage.saveBool(boostVolume);
  }

  //Set sleep timer
  void sleepTimer(int mins) {
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
        if (_playerRunning) {
          AudioService.stop();
        }
        notifyListeners();
        // AudioService.disconnect();
      });
    } else if (_sleepTimerMode == SleepTimerMode.endOfEpisode) {
      _stopOnComplete = true;
      _switchValue = 1;
      notifyListeners();
      if (_queue.episodes.length > 1 && _autoPlay) {
        AudioService.customAction('stopAtEnd');
      }
    }
  }

  set setSleepTimerMode(SleepTimerMode timer) {
    _sleepTimerMode = timer;
    notifyListeners();
  }

//Cancel sleep timer
  void cancelTimer() {
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
}

class AudioPlayerTask extends BackgroundAudioTask {
  final cacheStorage = KeyValueStorage(cacheMaxKey);
  final layoutStorage = KeyValueStorage(notificationLayoutKey);
  final List<MediaItem> _queue = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioSession _session;
  AudioProcessingState _skipState;
  bool _playing;
  bool _interrupted = false;
  bool _stopAtEnd;
  int _cacheMax;
  int _index = 0;
  bool _isQueue;
  bool get hasNext => _queue.length > 0;

  MediaItem get mediaItem => hasNext ? _queue[_index] : null;

  StreamSubscription<AudioPlaybackState> _playerStateSubscription;
  StreamSubscription<AudioPlaybackEvent> _eventSubscription;

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    _stopAtEnd = false;
    _session = await AudioSession.instance;
    _index = params['index'] ?? 0;
    _isQueue = params['isQueue'] ?? true;
    await _session.configure(AudioSessionConfiguration.speech());
    _handleInterruption(_session);
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

  void _handleInterruption(AudioSession session) async {
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.pause:
            if (_playing) {
              onPause();
              _interrupted = true;
            }
            break;
          case AudioInterruptionType.duck:
            if (_playing) {
              onPause();
              _interrupted = true;
            }
            break;
          case AudioInterruptionType.unknown:
            if (_playing) {
              onPause();
              _interrupted = true;
            }
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.pause:
            if (!_playing && _interrupted) {
              onPlay();
            }
            break;
          case AudioInterruptionType.duck:
            if (!_playing && _interrupted) {
              onPlay();
            }
            break;
          case AudioInterruptionType.unknown:
            break;
        }
        _interrupted = false;
      }
    });
    session.becomingNoisyEventStream.listen((_) {
      if (_playing) onPause();
    });
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
    AudioServiceBackground.sendCustomEvent(mediaItem.title);
    if (_isQueue) {
      if (_queue.length > 0) {
        _queue.removeAt(0);
      }
      await AudioServiceBackground.setQueue(_queue);
    } else {
      _index += 1;
    }

    if (_queue.length == 0 || _stopAtEnd) {
      _skipState = null;
      await Future.delayed(Duration(milliseconds: 200));
      await onStop();
    } else {
      // await AudioServiceBackground.setQueue(_queue);
      await AudioServiceBackground.setMediaItem(mediaItem);
      await _audioPlayer.setUrl(mediaItem.id, cacheMax: _cacheMax);
      var duration = await _audioPlayer.durationFuture;
      if (duration != null) {
        await AudioServiceBackground.setMediaItem(
            mediaItem.copyWith(duration: duration));
      }
      _skipState = null;
      _playFromStart();
    }
  }

  @override
  Future<void> onPlay() async {
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
        _playFromStart();
      } else {
        _playing = true;
        _session.setActive(true);
        if (_audioPlayer.playbackEvent.state != AudioPlaybackState.connecting ||
            _audioPlayer.playbackEvent.state != AudioPlaybackState.none) {
          await _audioPlayer.play();
          await _seekRelative(Duration(seconds: -3));
        }
      }
    }
  }

  Future<void> _playFromStart() async {
    _playing = true;
    _session.setActive(true);
    if (mediaItem.extras['skipSecondsStart'] > 0 ||
        mediaItem.extras['skipSecondsEnd'] > 0) {
      _audioPlayer
          .seek(Duration(seconds: mediaItem.extras['skipSecondsStart']));
    }
    if (_audioPlayer.playbackEvent.state != AudioPlaybackState.connecting ||
        _audioPlayer.playbackEvent.state != AudioPlaybackState.none) {
      try {
        _audioPlayer.play();
      } catch (e) {
        _setState(processingState: AudioProcessingState.error);
      }
    }
  }

  @override
  Future<void> onPause() async {
    if (_skipState == null) {
      if (_playing == null) {
      } else if (_playing) {
        _playing = false;
        _audioPlayer.pause();
      }
    }
  }

  @override
  Future<void> onSeekTo(Duration position) async {
    if (_audioPlayer.playbackEvent.state != AudioPlaybackState.connecting ||
        _audioPlayer.playbackEvent.state != AudioPlaybackState.none) {
      await _audioPlayer.seek(position);
    }
  }

  @override
  Future<void> onClick(MediaButton button) async {
    switch (button) {
      case MediaButton.media:
        if (AudioServiceBackground.state?.playing == true) {
          await onPause();
        } else {
          await onPlay();
        }
        break;
      case MediaButton.next:
        await onFastForward();
        break;
      case MediaButton.previous:
        await onRewind();
        break;
    }
  }

  Future<void> _seekRelative(Duration offset) async {
    var newPosition = _audioPlayer.playbackEvent.position + offset;
    if (newPosition < Duration.zero) newPosition = Duration.zero;
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
  Future<void> onTaskRemoved() async {
    await onStop();
  }

  @override
  Future<void> onAddQueueItem(MediaItem mediaItem) async {
    _queue.add(mediaItem);
    await AudioServiceBackground.setQueue(_queue);
  }

  @override
  Future<void> onRemoveQueueItem(MediaItem mediaItem) async {
    var index = _queue.indexOf(mediaItem);
    if (index < _index) _index -= 1;
    _queue.removeWhere((item) => item.id == mediaItem.id);
    await AudioServiceBackground.setQueue(_queue);
  }

  @override
  Future<void> onAddQueueItemAt(MediaItem mediaItem, int index) async {
    if (index == 0 && _isQueue) {
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
      _playFromStart();
      //onPlay();
    } else {
      _queue.insert(index, mediaItem);
      //if (index < _index) _index += 1;
      await AudioServiceBackground.setQueue(_queue);
    }
  }

  @override
  Future<void> onFastForward() async {
    await _seekRelative(fastForwardInterval);
  }

  @override
  Future<void> onRewind() async {
    await _seekRelative(-rewindInterval);
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
      case 'setIsQueue':
        _isQueue = argument;
        break;
      case 'changeQueue':
        await _changeQueue(argument);
        break;
      case 'changeIndex':
        await _changeIndex(argument);
        break;
    }
  }

  Future _changeQueue(List<dynamic> items) async {
    var queue = [for (var i in items) MediaItem.fromJson(json.decode(i))];
    await _audioPlayer.stop();
    AudioServiceBackground.sendCustomEvent(mediaItem.title);
    _queue.clear();
    _queue.addAll(queue);
    _index = 0;
    await AudioServiceBackground.setQueue(_queue);
    await AudioServiceBackground.setMediaItem(mediaItem);
    await _audioPlayer.setUrl(mediaItem.id, cacheMax: _cacheMax);
    var duration = await _audioPlayer.durationFuture ?? Duration.zero;
    AudioServiceBackground.setMediaItem(mediaItem.copyWith(duration: duration));
    _playFromStart();
  }

  Future _changeIndex(int index) async {
    await _audioPlayer.stop();
    AudioServiceBackground.sendCustomEvent(mediaItem.title);
    _index = index;
    await AudioServiceBackground.setMediaItem(mediaItem);
    await _audioPlayer.setUrl(mediaItem.id, cacheMax: _cacheMax);
    var duration = await _audioPlayer.durationFuture ?? Duration.zero;
    AudioServiceBackground.setMediaItem(mediaItem.copyWith(duration: duration));
    _playFromStart();
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
    final index = await layoutStorage.getInt(defaultValue: 0);
    await AudioServiceBackground.setState(
      controls: _getControls(index),
      systemActions: [
        MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      processingState:
          processingState ?? AudioServiceBackground.state.processingState,
      playing: _playing ?? false,
      position: position,
      bufferedPosition: bufferedPosition ?? position,
      speed: _audioPlayer.speed,
    );
  }

  List<MediaControl> _getControls(int index) {
    switch (index) {
      case 0:
        return [
          _playing ? pauseControl : playControl,
          forwardControl,
          skipToNextControl,
          stopControl
        ];
        break;
      case 1:
        return [
          _playing ? pauseControl : playControl,
          rewindControl,
          skipToNextControl,
          stopControl
        ];
        break;
      case 2:
        return [
          rewindControl,
          _playing ? pauseControl : playControl,
          forwardControl,
          stopControl
        ];

        break;
      default:
        return [
          _playing ? pauseControl : playControl,
          forwardControl,
          skipToNextControl,
          stopControl
        ];
        break;
    }
  }
}
