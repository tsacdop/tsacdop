import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
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
  final DBHelper _dbHelper;
  final Future<AudioHandler> Function(AudioServiceConfig, int) _createHandler;
  AudioPlayerNotifier({
    DBHelper? dbHelper,
    Future<AudioHandler> Function(AudioServiceConfig, int)? createHandler,
  }) : _dbHelper = dbHelper ?? DBHelper(),
       _createHandler = createHandler ?? _defaultHandler;

  static Future<AudioHandler> _defaultHandler(
    AudioServiceConfig config,
    int cacheMax,
  ) => AudioService.init(
    builder: () => CustomAudioHandler(cacheMax),
    config: config,
  );
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
  final _markListenedAfterSkipStorage = KeyValueStorage(
    markListenedAfterSkipKey,
  );
  final _playlistsStorgae = KeyValueStorage(playlistsAllKey);
  final _playerStateStorage = KeyValueStorage(playerStateKey);
  final cacheStorage = KeyValueStorage(cacheMaxKey);

  /// Playing episdoe.
  EpisodeBrief? _episode;

  /// Playlists include queue and playlists created by user.
  List<Playlist> _playlists = [];

  /// Playing playlist.
  Playlist? _playlist;

  /// Queue is the first playlist by default.
  Playlist get _queue => _playlists.first;

  /// Player state.
  AudioProcessingState _audioState = AudioProcessingState.loading;

  /// Player playing.
  bool _playing = false;

  /// Fastforward second.
  int? _fastForwardSeconds = 0;

  /// Rewind seconds.
  int? _rewindSeconds = 0;

  /// Current episode duration.
  int _backgroundAudioDuration = 0;

  /// Current episode positin.
  int? _backgroundAudioPosition = 0;

  /// Erroe maeesage.
  String? _remoteErrorMessage;

  /// Seekbar value, min 0, max 1.0.
  double _seekSliderValue = 0.0;

  /// Record plyaer position.
  int _lastPosition = 0;

  /// Set true if sleep timer mode is end of episode.
  bool _stopOnComplete = false;

  /// Sleep timer timer.
  late Timer _stopTimer;

  /// Sleep timer time left.
  int _timeLeft = 0;

  /// Start sleep timer.
  bool _startSleepTimer = false;

  /// Control sleep timer anamation.
  double _switchValue = 0;

  /// Sleep timer mode.
  SleepTimerMode _sleepTimerMode = SleepTimerMode.undefined;

  //Auto stop at the end of episode when you start play at scheduled time.
  bool? _autoSleepTimer;

  //set autoplay episode in playlist
  late bool _autoPlay;

  /// Current position.
  late int _currentPosition;

  /// Current speed.
  double? _currentSpeed = 1;

  ///Update episode card when setting changed
  bool _episodeState = false;

  /// Player height.
  PlayerHeight? _playerHeight;

  /// Player skip silence.
  bool? _skipSilence;

  /// Boost volumn
  bool? _boostVolume;

  /// Boost volume gain.
  late int _volumeGain;

  // ignore: prefer_final_fields
  bool _playerRunning = false;

  late bool _markListened;

  // Tmep episode list, playing from search result
  final List<EpisodeBrief?> _playFromSearchList = [];

  late AudioHandler _audioHandler;

  StreamSubscription<MediaItem?>? _mediaitemSubscription;
  StreamSubscription<PlaybackState>? _playbackStateSubscription;
  StreamSubscription<dynamic>? _customEventSubscription;
  Future<void>? _initialization;
  Future<void>? _playlistInitialization;
  Future<void> _stateWrites = Future<void>.value();
  bool _disposed = false;
  bool _hasResumeState = false;
  bool _resuming = false;
  bool _loadingPlayback = false;
  int _session = 0;
  String? _savedEpisode;
  String? _savedPlaylist;
  int _savedPosition = 0;

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    unawaited(
      initialize().catchError((Object error) {
        log('Audio initialization failed', error: error);
      }),
    );
  }

  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    await _initAudioData();
    final cacheMax = await cacheStorage.getInt(
      defaultValue: (1024 * 1024 * 200).toInt(),
    );
    if (_disposed) return;
    _audioHandler = await _createHandler(_config, cacheMax);
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _session++;
    _mediaitemSubscription?.cancel();
    _playbackStateSubscription?.cancel();
    _customEventSubscription?.cancel();
    super.dispose();
  }

  /// Audio service config
  AudioServiceConfig get _config => AudioServiceConfig(
    androidNotificationChannelName: 'Tsacdop',
    androidNotificationIcon: 'drawable/ic_notification',
    // androidEnableQueue: true,
    androidStopForegroundOnPause: true,
    preloadArtwork: false,
    fastForwardInterval: Duration(seconds: _fastForwardSeconds!),
    rewindInterval: Duration(seconds: _rewindSeconds!),
  );

  /// Audio playing state.
  AudioProcessingState get audioState => _audioState;
  int get backgroundAudioDuration => _backgroundAudioDuration;
  int? get backgroundAudioPosition => _backgroundAudioPosition;
  double get seekSliderValue => _seekSliderValue;
  String? get remoteErrorMessage => _remoteErrorMessage;
  bool get playerRunning => _playerRunning;
  bool get canResume =>
      !_playerRunning &&
      _hasResumeState &&
      _episode != null &&
      (_playlist?.episodeList.contains(_episode!.enclosureUrl) ?? false);
  bool get buffering => _audioState != AudioProcessingState.ready;
  EpisodeBrief? get episode => _episode;

  /// Playlist provider.
  int get lastPosition => _lastPosition;
  List<Playlist> get playlists => _playlists;
  Playlist get queue => _playlists.first;
  bool get playing => _playing;
  Playlist? get playlist => _playlist;

  /// Player control.
  bool get stopOnComplete => _stopOnComplete;
  bool get startSleepTimer => _startSleepTimer;
  SleepTimerMode get sleepTimerMode => _sleepTimerMode;
  int get timeLeft => _timeLeft;
  double get switchValue => _switchValue;
  double? get currentSpeed => _currentSpeed;
  bool get episodeState => _episodeState;
  bool? get autoSleepTimer => _autoSleepTimer;
  int? get fastForwardSeconds => _fastForwardSeconds;
  int? get rewindSeconds => _rewindSeconds;
  PlayerHeight? get playerHeight => _playerHeight;
  bool? get skipSilence => _skipSilence;
  bool? get boostVolume => _boostVolume;
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
    _fastForwardSeconds = await _fastForwardSecondsStorage.getInt(
      defaultValue: 30,
    );
    _rewindSeconds = await _rewindSecondsStorage.getInt(defaultValue: 30);
  }

  Future _savePlayerHeight() async {
    await _playerHeightStorage.saveInt(_playerHeight!.index);
  }

  Future _getAutoPlay() async {
    var i = await _autoPlayStorage.getInt();
    _autoPlay = i == 0;
  }

  Future _getAutoSleepTimer() async {
    var i = await _autoSleepTimerStorage.getInt();
    _autoSleepTimer = i == 1;
  }

  Future<void> initPlaylist() => _playlistInitialization ??= _restorePlaylist();

  Future<void> _restorePlaylist() async {
    final entities = await _playlistsStorgae.getPlaylists();
    _playlists = [
      for (final entity in entities ?? <PlaylistEntity>[])
        Playlist.fromEntity(entity, dbHelper: _dbHelper),
    ];
    if (_playlists.isEmpty) {
      _playlists.add(Playlist('Queue', dbHelper: _dbHelper));
    }
    await _playlists.first.getPlaylist();
    await _getAutoPlay();
    final state = await _playerStateStorage.getPlayerState();
    final playlistId = state.isNotEmpty ? state[0] : '';
    final episodeUrl = state.length > 1 ? state[1] : '';
    _playlist = _playlists.firstWhere(
      (playlist) => playlist.id == playlistId,
      orElse: () => _playlists.first,
    );
    if (_playlist != _playlists.first) await _playlist!.getPlaylist();
    _episode = _playlist!.episodes.isNotEmpty
        ? _playlist!.episodes.first
        : null;
    _lastPosition = 0;
    _hasResumeState = false;
    if (_playlist!.id == playlistId && episodeUrl.isNotEmpty) {
      for (final episode in _playlist!.episodes) {
        if (episode?.enclosureUrl == episodeUrl) {
          _episode = episode;
          final position = int.tryParse(state.length > 2 ? state[2] : '') ?? 0;
          _lastPosition = position < 0 ? 0 : position;
          _hasResumeState = true;
          break;
        }
      }
    }
    if (!_disposed) notifyListeners();
    await KeyValueStorage(lastWorkKey).saveInt(0);
  }

  Future<void> playFromLastPosition() async {
    if (_resuming || _playerRunning) return;
    _resuming = true;
    try {
      await initPlaylist();
      await initialize();
      if (_disposed) return;
      final playlist = _playlist!;
      final episodeUrl = _episode?.enclosureUrl;
      await playlist.getPlaylist();
      final index = playlist.episodes.indexWhere(
        (episode) => episode?.enclosureUrl == episodeUrl,
      );
      if (index < 0) {
        _hasResumeState = false;
        _lastPosition = 0;
        _episode = playlist.episodes.isNotEmpty
            ? playlist.episodes.first
            : null;
        await _playerStateStorage.savePlayerState('', '', 0);
        notifyListeners();
        return;
      }
      _episode = playlist.episodes[index];
      // The queue consumes its first item. Move the resumed episode to the
      // front while keeping the remaining episodes in their relative order.
      if (playlist.isQueue && index > 0) {
        playlist.addToPlayListAt(_episode!, 0);
        await updatePlaylist(playlist, updateEpisodes: false);
      }
      _audioState = AudioProcessingState.loading;
      _remoteErrorMessage = null;
      _backgroundAudioDuration = (_episode!.duration ?? 0) * 1000;
      _backgroundAudioPosition = _lastPosition;
      _seekSliderValue = _backgroundAudioDuration > 0
          ? (_lastPosition / _backgroundAudioDuration).clamp(0.0, 1.0)
          : 0;
      _playerRunning = true;
      notifyListeners();
      await _startAudioService(
        playlist,
        position: _lastPosition,
        index: playlist.episodes.indexOf(_episode),
      );
    } catch (error) {
      log('Could not resume playback', error: error);
      _loadingPlayback = false;
      _playerRunning = false;
      _remoteErrorMessage = 'Playback failed';
      if (!_disposed) notifyListeners();
      rethrow;
    } finally {
      _resuming = false;
    }
  }

  Future<void> _savePlaybackState({bool force = false}) {
    if (_loadingPlayback || _episode == null || _playlist == null) {
      return _stateWrites;
    }
    final mediaId = _audioHandler.mediaItem.value?.id;
    if (mediaId != null && mediaId != _episode!.mediaId) return _stateWrites;
    final episode = _episode!.enclosureUrl;
    final playlist = _playlist!.id;
    final position = _lastPosition;
    if (!force &&
        episode == _savedEpisode &&
        playlist == _savedPlaylist &&
        (position - _savedPosition).abs() < 5000) {
      return _stateWrites;
    }
    _savedEpisode = episode;
    _savedPlaylist = playlist;
    _savedPosition = position;
    _stateWrites = _stateWrites.then((_) async {
      try {
        await _playerStateStorage.savePlayerState(playlist, episode, position);
      } catch (error) {
        log('Could not save playback state', error: error);
      }
    });
    return _stateWrites;
  }

  Future<void> playlistLoad(Playlist playlist) async {
    await initialize();
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
          'queue': [for (var e in p.episodes) e!.toMediaItem()],
        });
      } else {
        _backgroundAudioDuration = 0;
        _backgroundAudioPosition = 0;
        _seekSliderValue = 0;
        _episode = playlist.episodes.first;
        _audioState = AudioProcessingState.loading;
        _playerRunning = true;
        notifyListeners();
        _startAudioService(_playlist!, position: 0, index: 0);
      }
    }
  }

  Future<void> episodeLoad(
    EpisodeBrief? episode, {
    int startPosition = 0,
    bool fromSearch = false,
  }) async {
    if (episode == null) {
      return;
    }
    await initialize();
    EpisodeBrief? episodeNew;
    if (fromSearch) {
      episodeNew = episode;
      _playFromSearchList.add(episode);
    } else {
      episodeNew = await _dbHelper.getRssItemWithUrl(episode.enclosureUrl);
    }
    if (episodeNew == null) {
      return;
    }
    // @TODO  load episode from last position when player running
    if (playerRunning) {
      if (_playFromSearchList.contains(_episode)) {
        _queue.delFromPlaylist(_episode);
      } else {
        final history = PlayHistory(
          _episode!.title,
          _episode!.enclosureUrl,
          backgroundAudioPosition! ~/ 1000,
          seekSliderValue,
        );
        await _dbHelper.saveHistory(history);
      }
      _queue.addToPlayListAt(episodeNew, 0);
      await updatePlaylist(_queue, updateEpisodes: !fromSearch);
      if (_playlist!.isQueue) {
        _audioHandler.customAction('setIsQueue', {'isQueue': true});
        _audioHandler.customAction('changeQueue', {
          'queue': [for (var e in _queue.episodes) e!.toMediaItem()],
        });
        _playlist = _queue;
      }
      await _audioHandler.customAction('addQueueItemAt', {
        'mediaItem': episodeNew.toMediaItem(),
        'index': 0,
      });
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

  Future<void> loadEpisodeFromPlaylist(EpisodeBrief? episode) async {
    if (_playlist!.episodes.contains(episode)) {
      var index = _playlist!.episodes.indexOf(episode);
      await _audioHandler.customAction('changeIndex', {'index': index});
    }
  }

  Future<void> _startAudioService(
    Playlist playlist, {
    int index = 0,
    int position = 0,
  }) async {
    await initialize();
    if (_disposed) return;
    final session = ++_session;
    _loadingPlayback = true;
    await _mediaitemSubscription?.cancel();
    await _playbackStateSubscription?.cancel();
    await _customEventSubscription?.cancel();
    _stopOnComplete = false;
    _sleepTimerMode = SleepTimerMode.undefined;
    _switchValue = 0;

    /// Get fastword and rewind seconds.
    _fastForwardSeconds = await _fastForwardSecondsStorage.getInt(
      defaultValue: 30,
    );
    _rewindSeconds = await _rewindSecondsStorage.getInt(defaultValue: 10);

    /// Get if auto mark listened after skip
    _markListened = await _markListenedAfterSkipStorage.getBool(
      defaultValue: false,
    );

    /// Start audio service.

    //Check autoplay setting, if true only add one episode, else add playlist.
    await _getAutoPlay();
    await _audioHandler.customAction('setIsQueue', {
      'isQueue': playlist.isQueue,
    });
    await _audioHandler.customAction('preparePlayback', {
      'queue': _autoPlay
          ? [for (var episode in playlist.episodes) episode!.toMediaItem()]
          : [playlist.episodes[index]!.toMediaItem()],
      'index': _autoPlay ? index : 0,
      'position': position,
    });
    //Check auto sleep timer setting
    await _getAutoSleepTimer();
    if (_autoSleepTimer!) {
      final startTime = await (_autoSleepTimerStartStorage.getInt(
        defaultValue: 1380,
      ));
      final endTime = await (_autoSleepTimerEndStorage.getInt(
        defaultValue: 360,
      ));
      final currentTime = DateTime.now().hour * 60 + DateTime.now().minute;
      if ((startTime > endTime &&
              (currentTime > startTime || currentTime < endTime)) ||
          ((startTime < endTime) &&
              (currentTime > startTime && currentTime < endTime))) {
        final mode = await (_autoSleepTimerModeStorage.getInt());
        _sleepTimerMode = SleepTimerMode.values[mode];
        final defaultTimer = await _defaultSleepTimerStorage.getInt(
          defaultValue: 30,
        );
        sleepTimer(defaultTimer);
      }
    }

    /// Set player speed.
    if (_currentSpeed != 1.0) {
      await _audioHandler.customAction('setSpeed', {'speed': _currentSpeed});
    }

    /// Set slipsilence.
    if (_skipSilence!) {
      await _audioHandler.customAction('setSkipSilence', {
        'skipSilence': skipSilence,
      });
    }

    /// Set boostValome.
    if (_boostVolume!) {
      await _audioHandler.customAction('setBoostVolume', {
        'boostVolume': _boostVolume,
        'gain': _volumeGain,
      });
    }

    _mediaitemSubscription = _audioHandler.mediaItem
        .where((event) => event != null)
        .listen((item) async {
          if (_disposed || session != _session) return;
          var episode = await _dbHelper.getRssItemWithMediaId(item!.id);
          episode ??= _playFromSearchList.firstWhere(
            (e) => e!.mediaId == item.id,
            orElse: () => null,
          );
          if (_disposed || session != _session) return;
          if (episode != null) {
            if (!_loadingPlayback &&
                _episode?.enclosureUrl != episode.enclosureUrl) {
              _lastPosition = 0;
              _backgroundAudioPosition = 0;
            }
            _episode = episode;
            final mediaDuration = item.duration?.inMilliseconds ?? 0;
            _backgroundAudioDuration = mediaDuration > 0
                ? mediaDuration
                : (episode.duration ?? 0) * 1000;
            _hasResumeState = true;
            unawaited(_savePlaybackState());
            notifyListeners();
          } else {
            _audioHandler.skipToNext();
          }
        });

    _playbackStateSubscription = _audioHandler.playbackState.listen((
      event,
    ) async {
      if (_disposed || session != _session) return;
      final wasPlaying = _playing;
      _audioState = event.processingState;
      _playing = event.playing;
      _currentSpeed = event.speed;
      _currentPosition = event.updatePosition.inMilliseconds;
      if (!_loadingPlayback && _playerRunning) {
        _lastPosition = _currentPosition < 0 ? 0 : _currentPosition;
        _backgroundAudioPosition = _lastPosition;
        await _savePlaybackState(force: !event.playing);
        if (wasPlaying && !event.playing && _episode != null) {
          final progress = _backgroundAudioDuration > 0
              ? (_lastPosition / _backgroundAudioDuration).clamp(0.0, 1.0)
              : 0.0;
          await _dbHelper.saveHistory(
            PlayHistory(
              _episode!.title,
              _episode!.enclosureUrl,
              _lastPosition ~/ 1000,
              progress,
            ),
          );
        }
      }
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
      if (_disposed || session != _session) return;
      notifyListeners();
    });

    _customEventSubscription = _audioHandler.customEvent.distinct().listen((
      event,
    ) async {
      if (_disposed || session != _session) return;
      if (event is Map && event['playerStopping'] == true) {
        _lastPosition = (event['position'] as Duration).inMilliseconds;
        _backgroundAudioPosition = _lastPosition;
        unawaited(_savePlaybackState(force: true));
        _loadingPlayback = true;
      }
      if (event is Map && event['removePlayed'] != null) {
        log(event.toString());
        final firstQueuedEpisode = _queue.isNotEmpty
            ? _queue.episodes.first
            : null;
        if (_playlist?.isQueue == true &&
            firstQueuedEpisode?.title == event['removePlayed']) {
          log(event['removePlayed']);
          _queue.delFromPlaylist(_episode);
          updatePlaylist(_queue, updateEpisodes: false);
        }
        _lastPosition = 0;
        notifyListeners();
        // await _positionStorage.saveInt(_lastPostion);
        await _savePlaybackState(force: true);
        PlayHistory history;
        if (_markListened) {
          history = PlayHistory(
            _episode!.title,
            _episode!.enclosureUrl,
            _backgroundAudioPosition! ~/ 1000,
            1,
          );
        } else {
          history = PlayHistory(
            _episode!.title,
            _episode!.enclosureUrl,
            _backgroundAudioPosition! ~/ 1000,
            _seekSliderValue,
          );
        }
        await _dbHelper.saveHistory(history);
      }
      if (event is Map && event['playerRunning'] == false && _playerRunning) {
        _loadingPlayback = false;
        _playerRunning = false;
        await _savePlaybackState(force: true);
        if (_disposed || session != _session) return;
        if (_lastPosition > 0) {
          final history = PlayHistory(
            _episode!.title,
            _episode!.enclosureUrl,
            _lastPosition ~/ 1000,
            _seekSliderValue,
          );
          await _dbHelper.saveHistory(history);
        }
        if (_playlist!.isEmpty) {
          _episode = null;
          _backgroundAudioDuration = 0;
          _backgroundAudioPosition = 0;
        }
        if (_disposed || session != _session) return;
        notifyListeners();
      }
      if (event is Map &&
          event['position'] != null &&
          !_loadingPlayback &&
          _playerRunning) {
        _backgroundAudioPosition = event['position'].inMilliseconds;
        _lastPosition = _backgroundAudioPosition! < 0
            ? 0
            : _backgroundAudioPosition!;
        unawaited(_savePlaybackState());
        if (_backgroundAudioDuration != 0 && _backgroundAudioPosition != null) {
          _seekSliderValue =
              _backgroundAudioPosition! / _backgroundAudioDuration;
        } else {
          _seekSliderValue = 0;
        }
        notifyListeners();
      }
    });
    _lastPosition = position;
    _backgroundAudioPosition = position;
    _hasResumeState = true;
    _loadingPlayback = false;
    await _savePlaybackState(force: true);
    await _audioHandler.play();
  }

  /// Queue management
  Future<void> addToPlaylist(EpisodeBrief episode) async {
    final episodeNew = await (_dbHelper.getRssItemWithUrl(
      episode.enclosureUrl,
    ) as FutureOr<EpisodeBrief>);
    if (episodeNew.isNew == 1) {
      await _dbHelper.removeEpisodeNewMark(episodeNew.enclosureUrl);
    }
    if (!_queue.episodes.contains(episodeNew)) {
      if (playerRunning && _playlist!.isQueue) {
        await _audioHandler.addQueueItem(episodeNew.toMediaItem());
      }
      if (_playlist!.isQueue && _queue.isEmpty) _episode = episodeNew;
      _queue.addToPlayList(episodeNew);
      await updatePlaylist(_queue, updateEpisodes: false);
    }
  }

  Future<void> addToPlaylistAt(EpisodeBrief episode, int index) async {
    final episodeNew = await (_dbHelper.getRssItemWithUrl(
      episode.enclosureUrl,
    ) as FutureOr<EpisodeBrief>);
    if (episodeNew.isNew == 1) {
      await _dbHelper.removeEpisodeNewMark(episodeNew.enclosureUrl);
    }
    if (_playerRunning && _playlist!.isQueue) {
      await _audioHandler.customAction('addQueueItemAt', {
        'mediaItem': episodeNew.toMediaItem(),
        'index': index,
      });
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
    if (newEpisodes.isNotEmpty && newEpisodes.length < 100) {
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
        _playlist!.contains(episode)) {
      var episodeNew = await _dbHelper.getRssItemWithUrl(episode.enclosureUrl);
      _playlist!.updateEpisode(episodeNew);
      if (_playerRunning) {
        await _audioHandler.updateMediaItem(episodeNew!.toMediaItem());
      }
    }
  }

  Future<int> delFromPlaylist(EpisodeBrief episode) async {
    final episodeNew = await _dbHelper.getRssItemWithUrl(episode.enclosureUrl);
    if (playerRunning && _playlist!.isQueue) {
      await _audioHandler.removeQueueItem(episodeNew!.toMediaItem());
    }
    final index = _queue.delFromPlaylist(episodeNew);
    if (index == 0) {
      _lastPosition = 0;
      await _positionStorage.saveInt(0);
    }
    updatePlaylist(_queue, updateEpisodes: false);
    return index;
  }

  Future reorderPlaylist(int oldIndex, int newIndex) async {
    final episode = _queue.episodes[oldIndex]!;
    _queue.addToPlayListAt(episode, newIndex);
    updatePlaylist(_queue, updateEpisodes: false);
    if (playerRunning && _playlist!.name == 'Queue') {
      await _audioHandler.removeQueueItem(episode.toMediaItem());
      await _audioHandler.customAction('addQueueItemAt', {
        'mediaItem': episode.toMediaItem(),
        'index': newIndex,
      });
    }
    if (newIndex == 0) {
      _lastPosition = 0;
      await _positionStorage.saveInt(0);
    }
  }

  Future<bool> moveToTop(EpisodeBrief episode) async {
    await delFromPlaylist(episode);
    final episodeNew = await _dbHelper.getRssItemWithUrl(episode.enclosureUrl);
    if (_playerRunning && _playlist!.isQueue) {
      await _audioHandler.customAction('', {
        'mediaItem': episodeNew!.toMediaItem(),
        'index': 1,
      });
      _queue.addToPlayListAt(episode, 1, existed: false);
    } else {
      _queue.addToPlayListAt(episode, 0, existed: false);
      if (_playlist!.isQueue) {
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
        if (p != playlist) p,
    ];
    if (_playlist == playlist && !_playerRunning) {
      _playlist = _queue;
      _episode = _playlist!.isNotEmpty ? _queue.episodes.first : null;
      _hasResumeState = false;
      _lastPosition = 0;
    }
    notifyListeners();
    _savePlaylists();
    if (playlist.isLocal!) {
      _dbHelper.deleteLocalEpisodes(playlist.episodeList);
    }
  }

  void addEpisodesToPlaylist(
    Playlist playlist, {
    required List<EpisodeBrief> episodes,
  }) {
    for (var e in episodes) {
      playlist.addToPlayList(e);
      if (playerRunning && playlist == _playlist) {
        _audioHandler.addQueueItem(e.toMediaItem());
      }
    }
    updatePlaylist(playlist, updateEpisodes: false);
  }

  void removeEpisodeFromPlaylist(
    Playlist playlist, {
    required List<EpisodeBrief> episodes,
  }) {
    for (var e in episodes) {
      playlist.delFromPlaylist(e);
      if (playerRunning && playlist == _playlist) {
        _audioHandler.removeQueueItem(e.toMediaItem());
      }
    }
    updatePlaylist(playlist, updateEpisodes: false);
  }

  void reorderEpisodesInPlaylist(
    Playlist playlist, {
    required int oldIndex,
    required int newIndex,
  }) async {
    playlist.reorderPlaylist(oldIndex, newIndex);

    if (playerRunning && playlist == _playlist) {
      await _audioHandler.removeQueueItem(episode!.toMediaItem());
      await _audioHandler.customAction('addQueueItemAt', {
        'mediaItem': episode!.toMediaItem(),
        'index': newIndex,
      });
    }
    updatePlaylist(playlist, updateEpisodes: false);
  }

  void clearPlaylist(Playlist playlist) {
    if (_playerRunning && _playlist!.isQueue && playlist.isQueue) {
      for (var e in playlist.episodes) {
        if (e != _episode) {
          delFromPlaylist(e!);
        }
      }
    } else {
      playlist.clear();
      if (_playlist!.isQueue) _episode = null;
    }
    updatePlaylist(playlist, updateEpisodes: false);
  }

  Future<void> updatePlaylist(
    Playlist playlist, {
    bool updateEpisodes = true,
  }) async {
    if (updateEpisodes) await playlist.getPlaylist();
    _playlists = [for (var p in _playlists) p.id == playlist.id ? playlist : p];
    if (_playlist!.id == playlist.id) {
      if (playlist.isQueue) {
        _playlist = _queue;
      } else if (!_playerRunning) {
        _playlist = _playlists.firstWhere((e) => e.id == _playlist!.id);
      }
      notifyListeners();
    }
    await _savePlaylists();
  }

  bool playlistExisted(String? name) {
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
    await _playlistsStorgae.savePlaylists([
      for (var p in _playlists) p.toEntity(),
    ]);
  }

  /// Audio control.
  Future<void> pauseAduio() async {
    await _audioHandler.pause();
    await _savePlaybackState(force: true);
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
    if (_playlist!.isQueue && _queue.isNotEmpty) {
      _queue.delFromPlaylist(_episode);
      updatePlaylist(_queue, updateEpisodes: false);
    }
    await _audioHandler.skipToNext();
    notifyListeners();
  }

  Future<void> forwardAudio(int s) async {
    var pos = _backgroundAudioPosition! + s * 1000;
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
      _seekSliderValue = val;
      notifyListeners();
      _currentPosition = (val * _backgroundAudioDuration).toInt();
      await _audioHandler.seek(Duration(milliseconds: _currentPosition));
    }
  }

  /// Set player speed.
  Future<void> setSpeed(double speed) async {
    await _audioHandler.customAction('setSpeed', {'speed': speed});
    _currentSpeed = speed;
    await _speedStorage.saveDouble(_currentSpeed!);
    notifyListeners();
  }

  // Set skip silence.
  Future<void> setSkipSilence({required bool skipSilence}) async {
    await _audioHandler.customAction('setSkipSilence', {
      'skipSilence': skipSilence,
    });
    _skipSilence = skipSilence;
    await _skipSilenceStorage.saveBool(_skipSilence);
    notifyListeners();
  }

  set setVolumeGain(int volumeGain) {
    _volumeGain = volumeGain;
    if (_playerRunning && _boostVolume!) {
      setBoostVolume(boostVolume: _boostVolume!, gain: _volumeGain);
    }
    notifyListeners();
    _volumeGainStorage.saveInt(volumeGain);
  }

  Future<void> setBoostVolume({required bool boostVolume, int? gain}) async {
    await _audioHandler.customAction('setBoostVolume', {
      'boostVolume': boostVolume,
      'gain': _volumeGain,
    });
    _boostVolume = boostVolume;
    notifyListeners();
    await _boostVolumeStorage.saveBool(boostVolume);
  }

  //Set sleep timer
  void sleepTimer(int? mins) {
    if (_sleepTimerMode == SleepTimerMode.timer) {
      _startSleepTimer = true;
      _switchValue = 1;
      notifyListeners();
      _timeLeft = mins! * 60;
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
      _audioHandler.customAction('stopAtEnd', {});
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
  final _equalizer = AndroidEqualizer();
  final _loudnessEnhancer = AndroidLoudnessEnhancer();
  late final AudioPlayer _player = AudioPlayer(
    handleInterruptions: false,
    audioPipeline: AudioPipeline(
      androidAudioEffects: [_loudnessEnhancer, _equalizer],
    ),
  );
  late final Future<void> _audioSessionReady;
  bool _interrupted = false;
  int? _layoutIndex;
  int? _previousIndex;
  bool _stopAtEnd = false;
  bool? _isQueue = false;
  bool _autoSkip = true;

  bool get hasNext => queue.value.isNotEmpty;
  MediaItem? get currentMediaItem => mediaItem.value;
  bool get playing => playbackState.value.playing;

  @override
  PublishSubject<Map<String, dynamic>> customEvent = PublishSubject()..add({});

  CustomAudioHandler(int cacheMax) {
    // _player.cacheMax = cacheMax;
    _audioSessionReady = _configureAudioSession();
    _player.currentIndexStream.listen((index) {
      if (index == null) {
        _previousIndex = null;
        return;
      }
      final previousIndex = _previousIndex;
      if (_stopAtEnd && previousIndex != null && index > previousIndex) {
        _stopAtEnd = false;
        unawaited(stop());
        return;
      }
      if (queue.value.isNotEmpty && index < queue.value.length) {
        final item = queue.value[index];
        final duration = _player.duration;
        mediaItem.add(
          duration == null ? item : item.copyWith(duration: duration),
        );
      }
      if (_isQueue == true &&
          _autoSkip &&
          previousIndex != null &&
          index > previousIndex &&
          previousIndex < queue.value.length) {
        customEvent.add({'removePlayed': queue.value[previousIndex].title});
      }
      _previousIndex = index;
      _autoSkip = true;
    });
    _player.playbackEventStream.listen((event) async {
      _layoutIndex ??= await layoutStorage.getInt();
      playbackState.add(
        playbackState.value.copyWith(
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
          }[_player.processingState]!,
          playing: _player.playing,
          updatePosition: _player.position,
          queueIndex: _player.currentIndex ?? 0,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
        ),
      );
    });

    _player.positionStream.listen((event) {
      customEvent.add({'position': event});
    });

    _player.sequenceStream.listen((event) {
      log(event.toString());
    });

    _player.durationStream.listen((duration) {
      final currentItem = mediaItem.value;
      if (currentItem == null || duration == null) return;
      mediaItem.add(currentItem.copyWith(duration: duration));
    });
  }

  @override
  Future<void> addQueueItems(List<MediaItem> items) async {
    queue.add(items);
    final duration = await _player.setAudioSources([
      for (var item in items) _itemToSource(item),
    ], shuffleOrder: DefaultShuffleOrder());
    final index = _player.currentIndex;
    if (duration != null && index != null && index < queue.value.length) {
      mediaItem.add(queue.value[index].copyWith(duration: duration));
    }
  }

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    // Let the car reduce the output volume without pausing playback.
    await session.configure(
      const AudioSessionConfiguration.speech().copyWith(
        androidWillPauseWhenDucked: false,
      ),
    );
    session.interruptionEventStream.listen((event) {
      if (event.type == AudioInterruptionType.duck) {
        return;
      }
      if (event.begin) {
        if (_player.playing) {
          _interrupted = true;
          unawaited(_player.pause());
        }
      } else {
        if (event.type == AudioInterruptionType.pause && _interrupted) {
          unawaited(play());
        }
        _interrupted = false;
      }
    });
    session.becomingNoisyEventStream.listen((_) {
      if (_player.playing) unawaited(pause());
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
    if (queue.value.length == 1 || _stopAtEnd) {
      await Future.delayed(Duration(milliseconds: 200));
      await stop();
    } else {
      _autoSkip = false;
      await super.skipToNext();
      _player.seekToNext();
      if (_isQueue!) {
        removeQueueItemAt(0);
      }
    }
  }

  @override
  Future<void> play() async {
    await _audioSessionReady;
    _interrupted = false;
    final wasPlaying = playing;
    await super.play();
    if (wasPlaying) {
      unawaited(_player.play());
      await _seekRelative(Duration(seconds: -3));
    } else {
      // just_audio's play Future completes only when playback finishes,
      // pauses, or stops. AudioHandler commands must return immediately so
      // the UI can subscribe to playback state and position updates.
      unawaited(_player.play());
    }
  }

  @override
  Future<void> addQueueItem(MediaItem item) async {
    await _addQueueItemAt(item, queue.value.length);
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    queue.add(queue.value..removeAt(index));
    await _player.removeAudioSourceAt(index);
    super.removeQueueItemAt(index);
  }

  @override
  Future<void> pause() async {
    _interrupted = false;
    await _player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    super.seek(position);
  }

  @override
  Future<void> fastForward() async {
    _seekRelative(AudioService.config.fastForwardInterval);
  }

  @override
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

  @override
  Future<void> stop() async {
    _stopAtEnd = false;
    _interrupted = false;
    customEvent.add({'playerStopping': true, 'position': _player.position});
    await _player.stop();
    // await _player.dispose();
    await _player.clearAudioSources();
    customEvent.add({'playerRunning': false});
    await super.stop();
  }

  Future<void> taskRemoved() async {
    await stop();
  }

  Future<void> _addQueueItemAt(MediaItem item, int index) async {
    log('$index: $item');
    if (index == 0 && _isQueue!) {
      queue.add(queue.value..removeWhere((i) => i.id == item.id));
      queue.add(queue.value..insert(index, item));
      skipToNext();
    } else {
      queue.add(queue.value..insert(index, item));
    }
    await _player.insertAudioSource(index, _itemToSource(item));
  }

  @override
  Future<dynamic> customAction(function, [argument]) async {
    switch (function) {
      case 'preparePlayback':
        _previousIndex = null;
        _autoSkip = false;
        final items = List<MediaItem>.from(argument!['queue']);
        queue.add(items);
        final duration = await _player.setAudioSources(
          [for (final item in items) _itemToSource(item)],
          initialIndex: argument['index'],
          initialPosition: Duration(milliseconds: argument['position']),
          shuffleOrder: DefaultShuffleOrder(),
        );
        final index = _player.currentIndex;
        if (index != null && index < items.length) {
          mediaItem.add(
            duration == null
                ? items[index]
                : items[index].copyWith(duration: duration),
          );
        }
        break;
      case 'stopAtEnd':
        _stopAtEnd = true;
        break;
      case 'cancelStopAtEnd':
        _stopAtEnd = false;
        break;
      case 'setSpeed':
        log('Argument${argument!['speed']}');
        await _player.setSpeed(argument['speed']);
        break;
      case 'setSkipSilence':
        await _setSkipSilence(argument!['skipSilence']);
        break;
      case 'setBoostVolume':
        await _setBoostVolume(argument!['boostVolume'], argument['gain']);
        break;
      case 'setIsQueue':
        log('Argument${argument!['isQueue']}');
        _isQueue = argument['isQueue'];
        break;
      case 'changeQueue':
        await _changeQueue(argument!['queue']);
        break;
      case 'changeIndex':
        await _changeIndex(argument!['index']);
        break;
      case 'addQueueItemAt':
        await _addQueueItemAt(argument!['mediaItem'], argument['index']);
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
    await _player.setSkipSilenceEnabled(boo);
  }

  Future _setBoostVolume(bool enabled, int gain) async {
    await _loudnessEnhancer.setEnabled(enabled);
    await _loudnessEnhancer.setTargetGain(gain / 2000);
  }

  List<MediaControl> _getControls(int? index) {
    switch (index) {
      case 0:
        return [
          playing ? pauseControl : playControl,
          forwardControl,
          skipToNextControl,
          stopControl,
        ];
      case 1:
        return [
          playing ? pauseControl : playControl,
          rewindControl,
          skipToNextControl,
          stopControl,
        ];
      case 2:
        return [
          rewindControl,
          playing ? pauseControl : playControl,
          forwardControl,
          stopControl,
        ];

      default:
        return [
          playing ? pauseControl : playControl,
          forwardControl,
          skipToNextControl,
          stopControl,
        ];
    }
  }

  static AudioSource _itemToSource(MediaItem item) {
    return ClippingAudioSource(
      start: Duration(seconds: item.extras!['skipSecondsStart']),
      // end: Duration(seconds: item.extras['skipSecondsEnd']),
      child: AudioSource.uri(Uri.parse(item.id)),
    );
  }
}
