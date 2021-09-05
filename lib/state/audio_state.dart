import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
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
  final cacheStorage = KeyValueStorage(cacheMaxKey);

  /// Playing episdoe.
  EpisodeBrief _episode;

  /// Playlists include queue and playlists created by user.
  List<Playlist> _playlists = [];

  /// Playing playlist.
  Playlist _playlist;

  /// Queue is the first playlist by default.
  Playlist get _queue => _playlists.first;

  /// Player state.
  AudioProcessingState _audioState = AudioProcessingState.loading;

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

  AudioHandler _audioHandler;

  StreamSubscription<MediaItem> _mediaitemSubscription;
  StreamSubscription<PlaybackState> _playbackStateSubscription;
  StreamSubscription<dynamic> _customEventSubscription;

  @override
  void addListener(VoidCallback listener) async {
    await _initAudioData();
    final cacheMax =
        await cacheStorage.getInt(defaultValue: (1024 * 1024 * 200).toInt());
    _audioHandler = await AudioService.init(
        builder: () => CustomAudioHandler(cacheMax), config: _config);
    super.addListener(listener);
  }

  @override
  void dispose() {
    _mediaitemSubscription?.cancel();
    _playbackStateSubscription?.cancel();
    _customEventSubscription?.cancel();
    super.dispose();
  }

  /// Audio service config
  AudioServiceConfig get _config => AudioServiceConfig(
        androidNotificationChannelName: 'Tsacdop',
        androidNotificationIcon: 'drawable/ic_notification',
        androidEnableQueue: true,
        androidStopForegroundOnPause: true,
        preloadArtwork: false,
        fastForwardInterval: Duration(seconds: _fastForwardSeconds),
        rewindInterval: Duration(seconds: _rewindSeconds),
      );

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
    _fastForwardSeconds =
        await _fastForwardSecondsStorage.getInt(defaultValue: 30);
    _rewindSeconds = await _rewindSecondsStorage.getInt(defaultValue: 30);
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
          if (episode != null &&
              ((!_playlist.isQueue &&
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
      _audioState = AudioProcessingState.loading;
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
        _audioHandler.customAction('setIsQueue', {'isQueue': playlist.isQueue});
        _audioHandler.customAction('changeQueue', {
          'queue': [for (var e in p.episodes) e.toMediaItem()]
        });
      } else {
        _backgroundAudioDuration = 0;
        _backgroundAudioPosition = 0;
        _seekSliderValue = 0;
        _episode = playlist.episodes.first;
        _audioState = AudioProcessingState.loading;
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
    // @TODO  load episode from last position when player running
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
      if (_playlist.isQueue) {
        _audioHandler.customAction('setIsQueue', {'isQueue': true});
        _audioHandler.customAction('changeQueue', {
          'queue': [for (var e in _queue.episodes) e.toMediaItem()]
        });
        _playlist = _queue;
      }
      await _audioHandler.customAction('addQueueItemAt',
          {'mediaItem': episodeNew.toMediaItem(), 'index': 0});
      if (startPosition > 0) {
        await _audioHandler.seek(Duration(milliseconds: startPosition));
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
      _playlist = _queue;
      notifyListeners();
      _startAudioService(_queue, position: startPosition);
    }
  }

  Future<void> loadEpisodeFromPlaylist(EpisodeBrief episode) async {
    if (_playlist.episodes.contains(episode)) {
      var index = _playlist.episodes.indexOf(episode);
      await _audioHandler.customAction('changeIndex', {'index': index});
    }
  }

  Future<void> _startAudioService(Playlist playlist,
      {int index = 0, int position = 0}) async {
    _stopOnComplete = false;
    _sleepTimerMode = SleepTimerMode.undefined;
    _switchValue = 0;

    /// Get fastword and rewind seconds.
    _fastForwardSeconds =
        await _fastForwardSecondsStorage.getInt(defaultValue: 30);
    _rewindSeconds = await _rewindSecondsStorage.getInt(defaultValue: 10);

    /// Get if auto mark listened after skip
    _markListened =
        await _markListenedAfterSkipStorage.getBool(defaultValue: false);

    /// Start audio service.

    //Check autoplay setting, if true only add one episode, else add playlist.
    await _getAutoPlay();
    if (_autoPlay) {
      await _audioHandler.addQueueItems(
          ([for (var episode in playlist.episodes) episode.toMediaItem()]));
    } else {
      await _audioHandler
          .addQueueItems([playlist.episodes[index].toMediaItem()]);
    }

    await _audioHandler.play();
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

    /// Set if playlist is queue.
    await _audioHandler
        .customAction('setIsQueue', {'isQueue': playlist.isQueue});

    /// Set player speed.
    if (_currentSpeed != 1.0) {
      await _audioHandler.customAction('setSpeed', {'speed': _currentSpeed});
    }

    /// Set slipsilence.
    if (_skipSilence) {
      await _audioHandler
          .customAction('setSkipSilence', {'skipSilence': skipSilence});
    }

    /// Set boostValome.
    if (_boostVolume) {
      await _audioHandler.customAction(
          'setBoostVolume', {'boostVolume': _boostVolume, 'gain': _volumeGain});
    }

    _audioHandler.play();

    _mediaitemSubscription =
        _audioHandler.mediaItem.where((event) => event != null).listen(
      (item) async {
        var episode = await _dbHelper.getRssItemWithMediaId(item.id);
        if (episode == null) {
          episode = _playFromSearchList.firstWhere((e) => e.mediaId == item.id,
              orElse: () => null);
        }
        if (episode != null) {
          _episode = episode;
          _backgroundAudioDuration = item.duration?.inMilliseconds ?? 0;
          if (position > 0 &&
              _backgroundAudioDuration > 0 &&
              _episode.enclosureUrl == _playlist.episodeList[index]) {
            await _audioHandler.seek(Duration(milliseconds: position));
            position = 0;
          }
          notifyListeners();
        } else {
          _audioHandler.skipToNext();
        }
      },
    );

    _playbackStateSubscription = _audioHandler.playbackState
        .where((event) => event != null)
        .listen((event) async {
      _current = DateTime.now();
      _audioState = event.processingState;
      _playing = event?.playing;
      _currentSpeed = event.speed;
      _currentPosition = event.updatePosition.inMilliseconds ?? 0;
      if (_audioState == AudioProcessingState.completed) {
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

    _customEventSubscription =
        _audioHandler.customEvent.distinct().listen((event) async {
      if (event is Map && event['removePlayed'] != null) {
        log(event.toString());
        log(_queue.episodes.first.title);
        if (_playlist.isQueue &&
            _queue.isNotEmpty &&
            _queue.episodes.first.title == event['removePlayed']) {
          log(event['removePlayed']);
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
      if (event is Map && event['position'] != null) {
        _backgroundAudioPosition = event['position'].inMilliseconds;
        if (_backgroundAudioDuration != null &&
            _backgroundAudioDuration != 0 &&
            _backgroundAudioPosition != null) {
          _seekSliderValue =
              _backgroundAudioPosition / _backgroundAudioDuration ?? 0;
        } else {
          _seekSliderValue = 0;
        }
        notifyListeners();
      }
    });
  }

  /// Queue management
  Future<void> addToPlaylist(EpisodeBrief episode) async {
    var episodeNew = await _dbHelper.getRssItemWithUrl(episode.enclosureUrl);
    if (episodeNew.isNew == 1) {
      await _dbHelper.removeEpisodeNewMark(episodeNew.enclosureUrl);
    }
    if (!_queue.episodes.contains(episodeNew)) {
      if (playerRunning && _playlist.isQueue) {
        await _audioHandler.addQueueItem(episodeNew.toMediaItem());
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
      await _audioHandler.customAction('addQueueItemAt',
          {'mediaItem': episodeNew.toMediaItem(), 'index': index});
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
        await _audioHandler.updateMediaItem(episodeNew.toMediaItem());
      }
    }
  }

  Future<int> delFromPlaylist(EpisodeBrief episode) async {
    var episodeNew = await _dbHelper.getRssItemWithUrl(episode.enclosureUrl);
    if (playerRunning && _playlist.isQueue) {
      await _audioHandler.removeQueueItem(episodeNew.toMediaItem());
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
      await _audioHandler.removeQueueItem(episode.toMediaItem());
      await _audioHandler.customAction('addQueueItemAt',
          {'mediaItem': episode.toMediaItem(), 'index': newIndex});
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
      await _audioHandler.customAction(
          '', {'mediaItem': episodeNew.toMediaItem(), 'index': 1});
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
    if (playlist.isLocal) {
      _dbHelper.deleteLocalEpisodes(playlist.episodeList);
    }
  }

  void addEpisodesToPlaylist(Playlist playlist, {List<EpisodeBrief> episodes}) {
    for (var e in episodes) {
      playlist.addToPlayList(e);
      if (playerRunning && playlist == _playlist) {
        _audioHandler.addQueueItem(e.toMediaItem());
      }
    }
    updatePlaylist(playlist, updateEpisodes: false);
  }

  void removeEpisodeFromPlaylist(Playlist playlist,
      {List<EpisodeBrief> episodes}) {
    for (var e in episodes) {
      playlist.delFromPlaylist(e);
      if (playerRunning && playlist == _playlist) {
        _audioHandler.removeQueueItem(e.toMediaItem());
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
      await _audioHandler.removeQueueItem(episode.toMediaItem());
      await _audioHandler.customAction('addQueueItemAt',
          {'mediaItem': episode.toMediaItem(), 'index': newIndex});
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
    await _audioHandler.pause();
  }

  Future<void> resumeAudio() async {
    _remoteErrorMessage = null;
    notifyListeners();
    if (_audioState != AudioProcessingState.loading) {
      _audioHandler.play();
    }
  }

  Future<void> playNext() async {
    _remoteErrorMessage = null;
    if (_playlist.isQueue && _queue.isNotEmpty) {
      _queue.delFromPlaylist(_episode);
      updatePlaylist(_queue, updateEpisodes: false);
    }
    await _audioHandler.skipToNext();
    notifyListeners();
  }

  Future<void> forwardAudio(int s) async {
    var pos = _backgroundAudioPosition + s * 1000;
    await _audioHandler.seek(Duration(milliseconds: pos));
  }

  Future<void> fastForward() async {
    await _audioHandler.fastForward();
  }

  Future<void> rewind() async {
    await _audioHandler.rewind();
  }

  Future<void> seekTo(int position) async {
    if (_audioState != AudioProcessingState.loading) {
      await _audioHandler.seek(Duration(milliseconds: position));
    }
  }

  Future<void> sliderSeek(double val) async {
    if (_audioState != AudioProcessingState.loading) {
      _noSlide = false;
      _seekSliderValue = val;
      notifyListeners();
      _currentPosition = (val * _backgroundAudioDuration).toInt();
      await _audioHandler.seek(Duration(milliseconds: _currentPosition));
      _noSlide = true;
    }
  }

  /// Set player speed.
  Future<void> setSpeed(double speed) async {
    await _audioHandler.customAction('setSpeed', {'speed': speed});
    _currentSpeed = speed;
    await _speedStorage.saveDouble(_currentSpeed);
    notifyListeners();
  }

  // Set skip silence.
  Future<void> setSkipSilence({@required bool skipSilence}) async {
    await _audioHandler
        .customAction('setSkipSilence', {'skipSilence': skipSilence});
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
    await _audioHandler.customAction(
        'setBoostVolume', {'boostVolume': boostVolume, 'gain': _volumeGain});
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
          _audioHandler.stop();
        }
        notifyListeners();
        // AudioService.disconnect();
      });
    } else if (_sleepTimerMode == SleepTimerMode.endOfEpisode) {
      _stopOnComplete = true;
      _switchValue = 1;
      notifyListeners();
      if (_queue.episodes.length > 1 && _autoPlay) {
        _audioHandler.customAction('stopAtEnd', {});
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
      _audioHandler.customAction('cancelStopAtEnd', {});
      _switchValue = 0;
      _stopOnComplete = false;
      notifyListeners();
    }
  }
}

class CustomAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final cacheStorage = KeyValueStorage(cacheMaxKey);
  final layoutStorage = KeyValueStorage(notificationLayoutKey);
  final AudioPlayer _player = AudioPlayer();
  bool _interrupted = false;
  int _layoutIndex;
  bool _stopAtEnd = false;
  bool _isQueue = false;
  bool _autoSkip = true;

  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(
    useLazyPreparation: true,
    shuffleOrder: DefaultShuffleOrder(),
    children: [],
  );

  bool get hasNext => queue.value.length > 0;
  MediaItem get currentMediaItem => mediaItem.value;
  bool get playing => playbackState.value.playing;

  PublishSubject<Map<String, dynamic>> customEvent = PublishSubject()..add({});

  CustomAudioHandler(int cacheMax) {
    _player.cacheMax = cacheMax;
    _handleInterruption();
    _player.currentIndexStream.listen(
      (index) {
        if (queue.value.isNotEmpty && index < queue.value.length) {
          mediaItem.add(queue.value[index]);
        }
        if (_isQueue && _autoSkip) {
          customEvent.add({'removePlayed': queue.value.first.title});
        }
        _autoSkip = true;
      },
    );
    _player.playbackEventStream.listen((event) async {
      if (_layoutIndex == null) {
        _layoutIndex = await layoutStorage.getInt();
      }
      playbackState.add(playbackState.value.copyWith(
        controls: _getControls(_layoutIndex),
        androidCompactActionIndices: [0, 1, 2],
        systemActions: {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState],
        playing: _player.playing,
        updatePosition: _player.position,
        queueIndex: _player.currentIndex,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ));
    });

    _player.positionStream.listen((event) {
      customEvent.add({'position': event});
    });

    _player.sequenceStream.listen((event) {
      log(event.toString());
    });

    _player.durationStream.listen((event) {
      mediaItem.add(mediaItem.value.copyWith(duration: _player.duration));
    });
  }

  @override
  Future<void> addQueueItems(List<MediaItem> items) async {
    queue.add(items);
    _setAudioSource(items);
    _player.setAudioSource(_playlist);
  }

  void _setAudioSource(List<MediaItem> items) {
    _playlist.insertAll(
      0,
      [for (var item in items) _itemToSource(item)],
    );
  }

  void _handleInterruption() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.pause:
            if (playing) {
              pause();
              _interrupted = true;
            }
            break;
          case AudioInterruptionType.duck:
            if (playing) {
              pause();
              _interrupted = true;
            }
            break;
          case AudioInterruptionType.unknown:
            if (playing) {
              pause();
              _interrupted = true;
            }
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.pause:
            if (!playing && _interrupted) {
              play();
            }
            break;
          case AudioInterruptionType.duck:
            if (!playing && _interrupted) {
              play();
            }
            break;
          case AudioInterruptionType.unknown:
            break;
        }
        _interrupted = false;
      }
    });
    session.becomingNoisyEventStream.listen((_) {
      if (playing) pause();
    });
  }

  void playPause() {
    if (playbackState.value.playing) {
      pause();
    } else {
      play();
    }
  }

  @override
  Future<void> skipToNext() async {
    if (queue.value.length == 0 || _stopAtEnd) {
      await Future.delayed(Duration(milliseconds: 200));
      await stop();
    } else {
      _autoSkip = false;
      await super.skipToNext();
      _player.seekToNext();
      if (_isQueue && queue.value.isNotEmpty) {
        removeQueueItemAt(0);
      }
    }
  }

  @override
  Future<void> play() async {
    if (playing == null) {
      log('playing');
      await super.play();
      await _player.play();
    } else {
      super.play();
      await _player.play();
      await _seekRelative(Duration(seconds: -3));
    }
  }

  @override
  Future<void> addQueueItem(MediaItem item) async {
    _addQueueItemAt(item, queue.value.length);
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    queue.add(queue.value..removeAt(index));
    _playlist.removeAt(index);
    super.removeQueueItemAt(index);
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    super.seek(position);
  }

  Future<void> fastForward() async {
    _seekRelative(AudioService.config.fastForwardInterval);
  }

  Future<void> rewind() async {
    _seekRelative(-AudioService.config.rewindInterval);
  }

  Future<void> onClick(MediaButton button) async {
    switch (button) {
      case MediaButton.media:
        if (playing) {
          await pause();
        } else {
          await play();
        }
        break;
      case MediaButton.next:
        await fastForward();
        break;
      case MediaButton.previous:
        await rewind();
        break;
    }
  }

  Future<void> _seekRelative(Duration offset) async {
    var newPosition = playbackState.value.position + offset;
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    seek(newPosition);
  }

  Future<void> stop() async {
    await _player.stop();
    await _player.dispose();
    playbackState.add(playbackState.value
        .copyWith(processingState: AudioProcessingState.loading));
    customEvent.add({'playerRunning': false});
    await super.stop();
  }

  Future<void> taskRemoved() async {
    await stop();
  }

  Future<void> _addQueueItemAt(MediaItem item, int index) async {
    log(index.toString() + ': ' + item.toString());
    if (index == 0 && _isQueue) {
      queue.add(queue.value..removeWhere((i) => i.id == item.id));
      queue.add(queue.value..insert(index, item));
      skipToNext();
    } else {
      queue.add(queue.value..insert(index, item));
    }
    _playlist.insert(index, _itemToSource(item));
  }

  @override
  Future<dynamic> customAction(function, [argument]) async {
    switch (function) {
      case 'stopAtEnd':
        _stopAtEnd = true;
        break;
      case 'cancelStopAtEnd':
        _stopAtEnd = false;
        break;
      case 'setSpeed':
        log('Argument' + argument['speed'].toString());
        await _player.setSpeed(argument['speed']);
        break;
      case 'setSkipSilence':
        await _setSkipSilence(argument['skipSilence']);
        break;
      case 'setBoostVolume':
        await _setBoostVolume(argument['boostVolume'], argument['gain']);
        break;
      case 'setIsQueue':
        log('Argument' + argument['isQueue'].toString());
        _isQueue = argument['isQueue'];
        break;
      case 'changeQueue':
        await _changeQueue(argument['queue']);
        break;
      case 'changeIndex':
        await _changeIndex(argument['index']);
        break;
      case 'addQueueItemAt':
        await _addQueueItemAt(argument['mediaItem'], argument['index']);
        break;
      default:
        super.customAction(function, argument);
    }
  }

  Future _changeQueue(List<MediaItem> newQueue) async {
    await _player.stop();
    queue.add(newQueue);
    play();
  }

  Future _changeIndex(int index) async {
    await super.skipToQueueItem(index);
  }

  Future _setSkipSilence(bool boo) async {
    await _player.setSkipSilence(boo);
  }

  Future _setBoostVolume(bool boo, int gain) async {
    await _player.setBoostVolume(boo, gain);
  }

  List<MediaControl> _getControls(int index) {
    switch (index) {
      case 0:
        return [
          playing ? pauseControl : playControl,
          forwardControl,
          skipToNextControl,
          stopControl
        ];
        break;
      case 1:
        return [
          playing ? pauseControl : playControl,
          rewindControl,
          skipToNextControl,
          stopControl
        ];
        break;
      case 2:
        return [
          rewindControl,
          playing ? pauseControl : playControl,
          forwardControl,
          stopControl
        ];

        break;
      default:
        return [
          playing ? pauseControl : playControl,
          forwardControl,
          skipToNextControl,
          stopControl
        ];
        break;
    }
  }

  static AudioSource _itemToSource(MediaItem item) {
    return ClippingAudioSource(
        start: Duration(seconds: item.extras['skipSecondsStart']),
        // end: Duration(seconds: item.extras['skipSecondsEnd']),
        child: AudioSource.uri(Uri.parse(item.id)));
  }
}
