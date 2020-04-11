import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/local_storage/key_value_storage.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';

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
MediaControl forward30 = MediaControl(
  androidIcon: 'drawable/ic_stat_forward_30',
  label: 'forward30',
  action: MediaAction.fastForward,
);

void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class PlayHistory {
  DBHelper dbHelper = DBHelper();
  String title;
  String url;
  double seconds;
  double seekValue;
  DateTime playdate;
  PlayHistory(this.title, this.url, this.seconds, this.seekValue,
      {this.playdate});
  EpisodeBrief _episode;
  EpisodeBrief get episode => _episode;

  getEpisode() async {
    _episode = await dbHelper.getRssItemWithUrl(url);
  }
}

class Playlist {
  String name;
  DBHelper dbHelper = DBHelper();

  List<EpisodeBrief> _playlist;

  List<EpisodeBrief> get playlist => _playlist;
  KeyValueStorage storage = KeyValueStorage('playlist');

  getPlaylist() async {
    List<String> urls = await storage.getStringList();
    if (urls.length == 0) {
      _playlist = [];
    } else {
      _playlist = [];
      await Future.forEach(urls, (url) async {
        EpisodeBrief episode = await dbHelper.getRssItemWithUrl(url);
        if (episode != null) _playlist.add(episode);
      });
    }
  }

  savePlaylist() async {
    List<String> urls = [];
    urls.addAll(_playlist.map((e) => e.enclosureUrl));
    await storage.saveStringList(urls);
  }

  addToPlayList(EpisodeBrief episodeBrief) async {
    _playlist.add(episodeBrief);
    await savePlaylist();
  }

  addToPlayListAt(EpisodeBrief episodeBrief, int index) async {
    _playlist.insert(index, episodeBrief);
    await savePlaylist();
  }

  Future<int> delFromPlaylist(EpisodeBrief episodeBrief) async {
    int index = _playlist.indexOf(episodeBrief);
    _playlist
        .removeWhere((item) => item.enclosureUrl == episodeBrief.enclosureUrl);
    await savePlaylist();
    return index;
  }
}

enum SleepTimerMode { endOfEpisode, timer, undefined }

class AudioPlayerNotifier extends ChangeNotifier {
  DBHelper dbHelper = DBHelper();
  KeyValueStorage storage = KeyValueStorage('audioposition');
  EpisodeBrief _episode;
  Playlist _queue = Playlist();
  bool _queueUpdate = false;
  BasicPlaybackState _audioState = BasicPlaybackState.none;
  bool _playerRunning = false;
  bool _noSlide = true;
  int _backgroundAudioDuration = 0;
  int _backgroundAudioPosition = 0;
  String _remoteErrorMessage;

  double _seekSliderValue = 0.0;
  int _lastPostion = 0;
  bool _stopOnComplete = false;
  Timer _stopTimer;
  int _timeLeft = 0;
  bool _startSleepTimer = false;
  double _switchValue = 0;
  SleepTimerMode _sleepTimerMode = SleepTimerMode.undefined;
  bool _autoPlay = true;
  DateTime _current;
  int _currentPosition;

  BasicPlaybackState get audioState => _audioState;

  int get backgroundAudioDuration => _backgroundAudioDuration;
  int get backgroundAudioPosition => _backgroundAudioPosition;
  double get seekSliderValue => _seekSliderValue;
  String get remoteErrorMessage => _remoteErrorMessage;
  bool get playerRunning => _playerRunning;
  int get lastPositin => _lastPostion;
  Playlist get queue => _queue;
  bool get queueUpdate => _queueUpdate;
  EpisodeBrief get episode => _episode;
  bool get stopOnComplete => _stopOnComplete;
  bool get startSleepTimer => _startSleepTimer;
  SleepTimerMode get sleepTimerMode => _sleepTimerMode;
  bool get autoPlay => _autoPlay;
  int get timeLeft => _timeLeft;
  double get switchValue => _switchValue;

  set setSwitchValue(double value) {
    _switchValue = value;
    notifyListeners();
  }

  set autoPlaySwitch(bool boo) {
    _autoPlay = boo;
    notifyListeners();
  }

  set setSleepTimerMode(SleepTimerMode timer) {
    _sleepTimerMode = timer;
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) async {
    super.addListener(listener);
    _queueUpdate = false;
    await AudioService.connect();
    bool running = await AudioService.running;
    if (running) {}
  }

  loadPlaylist() async {
    await _queue.getPlaylist();
    _lastPostion = await storage.getInt();
    if (_lastPostion > 0 && _queue.playlist.length > 0) {
      final EpisodeBrief episode = _queue.playlist.first;
      final int duration = episode.duration * 1000;
      final double seekValue = duration != 0 ? _lastPostion / duration : 1;
      final PlayHistory history = PlayHistory(
          episode.title, episode.enclosureUrl, _lastPostion / 1000, seekValue);
      await dbHelper.saveHistory(history);
    }
  }

  episodeLoad(EpisodeBrief episode) async {
    final EpisodeBrief episodeNew =
        await dbHelper.getRssItemWithUrl(episode.enclosureUrl);
    if (_playerRunning) {
      PlayHistory history = PlayHistory(_episode.title, _episode.enclosureUrl,
          backgroundAudioPosition / 1000, seekSliderValue);
      await dbHelper.saveHistory(history);
      AudioService.addQueueItemAt(episodeNew.toMediaItem(), 0);
      _queue.playlist
          .removeWhere((item) => item.enclosureUrl == episode.enclosureUrl);
      _queue.playlist.insert(0, episodeNew);
      notifyListeners();
      await _queue.savePlaylist();
    } else {
      await _queue.getPlaylist();
      // _queue.playlist
      //     .removeWhere((item) => item.enclosureUrl == episode.enclosureUrl);
      await _queue.delFromPlaylist(episode);
      await _queue.addToPlayListAt(episodeNew, 0);
      _backgroundAudioDuration = 0;
      _backgroundAudioPosition = 0;
      _seekSliderValue = 0;
      _episode = episodeNew;
      _playerRunning = true;
      _audioState = BasicPlaybackState.connecting;
      notifyListeners();
      //await _queue.savePlaylist();
      _startAudioService(0);
    }
  }

  _startAudioService(int position) async {
    _stopOnComplete = false;
    _sleepTimerMode = SleepTimerMode.undefined;
    if (!AudioService.connected) {
      await AudioService.connect();
    }
    await AudioService.start(
        backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
        androidNotificationChannelName: 'Tsacdop',
        notificationColor: 0xFF4d91be,
        androidNotificationIcon: 'drawable/ic_notification',
        enableQueue: true,
        androidStopOnRemoveTask: true,
        androidStopForegroundOnPause: true);

    if (_autoPlay) {
      await Future.forEach(_queue.playlist, (episode) async {
        await AudioService.addQueueItem(episode.toMediaItem());
      });
    } else {
      await AudioService.addQueueItem(_queue.playlist.first.toMediaItem());
    }
    _playerRunning = true;
    await AudioService.play();

    AudioService.currentMediaItemStream
        .where((event) => event != null)
        .listen((item) async {
      _episode = await dbHelper.getRssItemWithMediaId(item.id);
      _backgroundAudioDuration = item?.duration ?? 0;
      if (position > 0 && _backgroundAudioDuration > 0) {
        AudioService.seekTo(position);
        position = 0;
      }
      notifyListeners();
    });
    var queueSubject = BehaviorSubject<List<MediaItem>>();
    queueSubject.addStream(
        AudioService.queueStream.distinct().where((event) => event != null));
    queueSubject.stream.listen((event) {
      print(event.length);
      if (event.length == _queue.playlist.length - 1 &&
          _audioState == BasicPlaybackState.skippingToNext) {
        if (event.length == 0 || _stopOnComplete == true) {
          _queue.delFromPlaylist(_episode);
          _lastPostion = 0;
          storage.saveInt(_lastPostion);
          final PlayHistory history = PlayHistory(
              _episode.title,
              _episode.enclosureUrl,
              backgroundAudioPosition / 1000,
              seekSliderValue);
          dbHelper.saveHistory(history);
        } else if (event.first.id != _episode.mediaId) {
          _queue.delFromPlaylist(_episode);
          final PlayHistory history = PlayHistory(
              _episode.title,
              _episode.enclosureUrl,
              backgroundAudioPosition / 1000,
              seekSliderValue);
          dbHelper.saveHistory(history);
        }
      }
    });

    AudioService.playbackStateStream.listen((event) async {
      _current = DateTime.now();
      _audioState = event?.basicState;
      //  if (_audioState == BasicPlaybackState.skippingToNext &&
      //      _episode != null) {
      //    print(_episode.title);
      //    _queue.delFromPlaylist(_episode);
      //  }
      //  if (_audioState == BasicPlaybackState.skippingToNext &&
      //      _episode != null &&
      //      _backgroundAudioPosition > 0) {
      //    PlayHistory history = PlayHistory(_episode.title, _episode.enclosureUrl,
      //        _backgroundAudioPosition / 1000, _seekSliderValue);
      //    await dbHelper.saveHistory(history);
      //  }
      if (_audioState == BasicPlaybackState.stopped) _playerRunning = false;

      if (_audioState == BasicPlaybackState.error) {
        _remoteErrorMessage = 'Network Error';
      }
      if (_audioState != BasicPlaybackState.error &&
          _audioState != BasicPlaybackState.paused) {
        _remoteErrorMessage = null;
      }

      _currentPosition = event?.currentPosition ?? 0;
      notifyListeners();
    });

    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (_noSlide) {
        if (_audioState == BasicPlaybackState.playing) {
          if (_backgroundAudioPosition < _backgroundAudioDuration - 500)
            _backgroundAudioPosition = _currentPosition +
                DateTime.now().difference(_current).inMilliseconds;
          else
            _backgroundAudioPosition = _backgroundAudioDuration;
        } else
          _backgroundAudioPosition = _currentPosition;

        if (_backgroundAudioDuration != null &&
            _backgroundAudioDuration != 0 &&
            _backgroundAudioPosition != null) {
          _seekSliderValue =
              _backgroundAudioPosition / _backgroundAudioDuration ?? 0;
        } else
          _seekSliderValue = 0;

        if (_backgroundAudioPosition > 0) {
          _lastPostion = _backgroundAudioPosition;
          storage.saveInt(_lastPostion);
        }

        // if ((_queue.playlist.length == 1 || !_autoPlay) &&
        //     _seekSli;lderValue > 0.9 &&
        //     _episode != null &&
        //     _audioState != BasicPlaybackState.connecting) {
        //   _queue.delFromPlaylist(_episode);
        //   _lastPostion = 0;
        //   storage.saveInt(_lastPostion);
        //   final PlayHistory history = PlayHistory(
        //       _episode.title,
        //       _episode.enclosureUrl,
        //       backgroundAudioPosition / 1000,
        //       seekSliderValue);
        //   dbHelper.saveHistory(history);
        // }
        notifyListeners();
      }
      if (_audioState == BasicPlaybackState.stopped) {
        timer.cancel();
      }
    });
  }

  playlistLoad() async {
    await _queue.getPlaylist();
    _backgroundAudioDuration = 0;
    _backgroundAudioPosition = 0;
    _seekSliderValue = 0;
    _episode = _queue.playlist.first;
    _playerRunning = true;
    _audioState = BasicPlaybackState.connecting;
    _queueUpdate = !_queueUpdate;
    notifyListeners();
    _startAudioService(_lastPostion ?? 0);
  }

  playNext() async {
    AudioService.skipToNext();
  }

  addToPlaylist(EpisodeBrief episode) async {
    if (_playerRunning) {
      await AudioService.addQueueItem(episode.toMediaItem());
    }
    await _queue.addToPlayList(episode);
    notifyListeners();
  }

  addToPlaylistAt(EpisodeBrief episode, int index) async {
    if (_playerRunning) {
      await AudioService.addQueueItemAt(episode.toMediaItem(), index);
    }
    await _queue.addToPlayListAt(episode, index);
    _queueUpdate = !_queueUpdate;
    notifyListeners();
  }

  updateMediaItem(EpisodeBrief episode) async {
    int index = _queue.playlist
        .indexWhere((item) => item.enclosureUrl == episode.enclosureUrl);
    if (index > 0) {
      EpisodeBrief episodeNew =
          await dbHelper.getRssItemWithUrl(episode.enclosureUrl);
      await delFromPlaylist(episode);
      await addToPlaylistAt(episodeNew, index);
    }
  }

  Future<int> delFromPlaylist(EpisodeBrief episode) async {
    if (_playerRunning) {
      await AudioService.removeQueueItem(episode.toMediaItem());
    }
    int index = await _queue.delFromPlaylist(episode);
    _queueUpdate = !_queueUpdate;
    notifyListeners();
    return index;
  }

  moveToTop(EpisodeBrief episode) async {
    await delFromPlaylist(episode);
    if (_playerRunning) {
      await addToPlaylistAt(episode, 1);
    } else {
      await addToPlaylistAt(episode, 0);
      _lastPostion = 0;
      storage.saveInt(_lastPostion);
    }
    notifyListeners();
  }

  pauseAduio() async {
    AudioService.pause();
  }

  resumeAudio() async {
    if (_audioState != BasicPlaybackState.connecting &&
        _audioState != BasicPlaybackState.none) AudioService.play();
  }

  forwardAudio(int s) {
    int pos = _backgroundAudioPosition + s * 1000;
    AudioService.seekTo(pos);
  }

  seekTo(int position) async {
    if (_audioState != BasicPlaybackState.connecting &&
        _audioState != BasicPlaybackState.none)
      await AudioService.seekTo(position);
  }

  sliderSeek(double val) async {
    print(val.toString());
    if (_audioState != BasicPlaybackState.connecting &&
        _audioState != BasicPlaybackState.none) {
      _noSlide = false;
      _seekSliderValue = val;
      notifyListeners();
      _currentPosition = (val * _backgroundAudioDuration).toInt();
      await AudioService.seekTo(_currentPosition);
      _noSlide = true;
    }
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
        _playerRunning = false;
        notifyListeners();
        AudioService.stop();
        AudioService.disconnect();
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
    await AudioService.stop();
    await AudioService.disconnect();
    //_playerRunning = false;
    super.dispose();
  }
}

class AudioPlayerTask extends BackgroundAudioTask {
  List<MediaItem> _queue = [];
  AudioPlayer _audioPlayer = AudioPlayer();
  Completer _completer = Completer();
  BasicPlaybackState _skipState;
  bool _playing;
  bool _stopAtEnd;

  bool get hasNext => _queue.length > 0;

  MediaItem get mediaItem => _queue.first;

  BasicPlaybackState _stateToBasicState(AudioPlaybackState state) {
    switch (state) {
      case AudioPlaybackState.none:
        return BasicPlaybackState.none;
      case AudioPlaybackState.stopped:
        return _skipState ?? BasicPlaybackState.stopped;
      case AudioPlaybackState.paused:
        return BasicPlaybackState.paused;
      case AudioPlaybackState.playing:
        return BasicPlaybackState.playing;
      case AudioPlaybackState.connecting:
        return _skipState ?? BasicPlaybackState.connecting;
      case AudioPlaybackState.completed:
        return BasicPlaybackState.stopped;
      default:
        throw Exception("Illegal state");
    }
  }

  @override
  Future<void> onStart() async {
    _stopAtEnd = false;
    var playerStateSubscription = _audioPlayer.playbackStateStream
        .where((state) => state == AudioPlaybackState.completed)
        .listen((state) {
      _handlePlaybackCompleted();
    });
    var eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      if (event.playbackError != null) {
        _setState(state: BasicPlaybackState.error);
      }
      BasicPlaybackState state;
      if (event.buffering) {
        state = _skipState ?? BasicPlaybackState.buffering;
      } else {
        state = _stateToBasicState(event.state);
      }
      if (state != BasicPlaybackState.stopped) {
        _setState(
          state: state,
          position: event.position.inMilliseconds,
        );
      }
    });
    await _completer.future;
    playerStateSubscription.cancel();
    eventSubscription.cancel();
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
    if (AudioServiceBackground.state.basicState == BasicPlaybackState.playing)
      onPause();
    else
      onPlay();
  }

  @override
  Future<void> onSkipToNext() async {
    _skipState = BasicPlaybackState.skippingToNext;
    await _audioPlayer.stop();
    _queue.removeAt(0);
    await AudioServiceBackground.setQueue(_queue);
    // }
    if (_queue.length == 0 || _stopAtEnd) {
      _skipState = null;
      onStop();
    } else {
      // AudioServiceBackground.setQueue(_queue);
      AudioServiceBackground.setMediaItem(mediaItem);
      await _audioPlayer.setUrl(mediaItem.id);
      Duration duration = await _audioPlayer.durationFuture ?? Duration.zero;
      AudioServiceBackground.setMediaItem(
          mediaItem.copyWith(duration: duration.inMilliseconds));
      _skipState = null;
      // Resume playback if we were playing
      // if (_playing) {
      onPlay();
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
        // await AudioServiceBackground.setQueue(_queue);
        await _audioPlayer.setUrl(mediaItem.id);
        Duration duration = await _audioPlayer.durationFuture;
        AudioServiceBackground.setMediaItem(
            mediaItem.copyWith(duration: duration.inMilliseconds));
      }
      _playing = true;
      _audioPlayer.play();
    }
  }

  @override
  void onPause() {
    if (_skipState == null) {
      if (_playing == null) {}
      _playing = false;
      _audioPlayer.pause();
    }
  }

  @override
  void onSeekTo(int position) {
    _audioPlayer.seek(Duration(milliseconds: position));
  }

  @override
  void onClick(MediaButton button) {
    playPause();
  }

  @override
  void onStop() async {
    await _audioPlayer.stop();
    _setState(state: BasicPlaybackState.stopped);
    _completer.complete();
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
      _queue.removeWhere((item) => item.id == mediaItem.id);
      _queue.insert(0, mediaItem);
      await AudioServiceBackground.setQueue(_queue);
      await AudioServiceBackground.setMediaItem(mediaItem);
      await _audioPlayer.setUrl(mediaItem.id);
      Duration duration = await _audioPlayer.durationFuture ?? Duration.zero;
      AudioServiceBackground.setMediaItem(
          mediaItem.copyWith(duration: duration.inMilliseconds));
      onPlay();
    } else {
      _queue.insert(index, mediaItem);
      await AudioServiceBackground.setQueue(_queue);
    }
  }

  @override
  void onFastForward() {
    _audioPlayer.seek(Duration(
        milliseconds: AudioServiceBackground.state.position + 30 * 1000));
  }

  @override
  void onAudioFocusLost() {
    if (_skipState == null) {
      if (_playing == null ||
          _audioPlayer.playbackState == AudioPlaybackState.none ||
          _audioPlayer.playbackState == AudioPlaybackState.connecting) {}
      _playing = false;
      _audioPlayer.pause();
    }
  }

  @override
  void onAudioBecomingNoisy() {
    if (_skipState == null) {
      if (_playing == null) {}
      _playing = false;
      _audioPlayer.pause();
    }
  }

  @override
  void onAudioFocusGained() {
    if (_skipState == null) {
      if (_playing == null) {}
      _playing = true;
      _audioPlayer.play();
    }
  }

  @override
  void onCustomAction(funtion, argument) {
    switch (funtion) {
      case 'stopAtEnd':
        _stopAtEnd = true;
        break;
      case 'cancelStopAtEnd':
        _stopAtEnd = false;
        break;
    }
  }

  void _setState({@required BasicPlaybackState state, int position}) {
    if (position == null) {
      position = _audioPlayer.playbackEvent.position.inMilliseconds;
    }
    AudioServiceBackground.setState(
      controls: getControls(state),
      systemActions: [MediaAction.seekTo],
      basicState: state,
      position: position,
    );
  }

  List<MediaControl> getControls(BasicPlaybackState state) {
    if (_playing) {
      return [pauseControl, forward30, skipToNextControl, stopControl];
    } else {
      return [playControl, forward30, skipToNextControl, stopControl];
    }
  }
}
