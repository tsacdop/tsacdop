import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../type/episodebrief.dart';
import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../.env.dart';

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

      for (String url in urls) {
        EpisodeBrief episode = await dbHelper.getRssItemWithUrl(url);
        if (episode != null) _playlist.add(episode);
      }
    }
  }

  savePlaylist() async {
    List<String> urls = [];
    urls.addAll(_playlist.map((e) => e.enclosureUrl));
    await storage.saveStringList(urls.toSet().toList());
  }

  addToPlayList(EpisodeBrief episodeBrief) async {
    if (!_playlist.contains(episodeBrief)) {
      _playlist.add(episodeBrief);
      await savePlaylist();
      dbHelper.removeEpisodeNewMark(episodeBrief.enclosureUrl);
    }
  }

  addToPlayListAt(EpisodeBrief episodeBrief, int index) async {
    if (!_playlist.contains(episodeBrief)) {
      _playlist.insert(index, episodeBrief);
      await savePlaylist();
      dbHelper.removeEpisodeNewMark(episodeBrief.enclosureUrl);
    }
  }

  Future<int> delFromPlaylist(EpisodeBrief episodeBrief) async {
    int index = _playlist.indexOf(episodeBrief);
    _playlist.removeWhere(
        (episode) => episode.enclosureUrl == episodeBrief.enclosureUrl);
    print('delete' + episodeBrief.title);
    await savePlaylist();
    return index;
  }
}

enum SleepTimerMode { endOfEpisode, timer, undefined }
enum ShareStatus { generate, download, complete, undefined, error }

class AudioPlayerNotifier extends ChangeNotifier {
  DBHelper dbHelper = DBHelper();
  KeyValueStorage positionStorage = KeyValueStorage(audioPositionKey);
  KeyValueStorage autoPlayStorage = KeyValueStorage(autoPlayKey);
  KeyValueStorage autoSleepTimerStorage = KeyValueStorage(autoSleepTimerKey);
  KeyValueStorage defaultSleepTimerStorage =
      KeyValueStorage(defaultSleepTimerKey);
  KeyValueStorage autoSleepTimerModeStorage =
      KeyValueStorage(autoSleepTimerModeKey);
  KeyValueStorage autoSleepTimerStartStorage =
      KeyValueStorage(autoSleepTimerStartKey);
  KeyValueStorage autoSleepTimerEndStorage =
      KeyValueStorage(autoSleepTimerEndKey);

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
  //Auto stop at the end of episode when you start play at scheduled time.
  bool _autoSleepTimer;
  //Default sleep timer time.
  ShareStatus _shareStatus = ShareStatus.undefined;
  String _shareFile = '';
  //set autoplay episode in playlist
  bool _autoPlay;
  DateTime _current;
  int _currentPosition;
  double _currentSpeed = 1;
  BehaviorSubject<List<MediaItem>> queueSubject;
  //Update episode card when setting changed
  bool _episodeState = false;

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
  ShareStatus get shareStatus => _shareStatus;
  String get shareFile => _shareFile;
  //bool get autoPlay => _autoPlay;
  int get timeLeft => _timeLeft;
  double get switchValue => _switchValue;
  double get currentSpeed => _currentSpeed;
  bool get episodeState => _episodeState;
  bool get autoSleepTimer => _autoSleepTimer;

  set setSwitchValue(double value) {
    _switchValue = value;
    notifyListeners();
  }

  set setShareStatue(ShareStatus status) {
    _shareStatus = status;
    notifyListeners();
  }

  set setEpisodeState(bool boo) {
    _episodeState = !_episodeState;
    notifyListeners();
  }

  Future _getAutoPlay() async {
    int i = await autoPlayStorage.getInt();
    _autoPlay = i == 0;
  }

  Future _getAutoSleepTimer() async {
    int i = await autoSleepTimerStorage.getInt();
    _autoSleepTimer = i == 1;
  }

  set setSleepTimerMode(SleepTimerMode timer) {
    _sleepTimerMode = timer;
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) async {
    super.addListener(listener);
    _queueUpdate = false;
    await _getAutoSleepTimer();
    await AudioService.connect();
    bool running = AudioService.running;
    if (running) {}
  }

  loadPlaylist() async {
    await _queue.getPlaylist();
    await _getAutoPlay();
    //  await _getAutoAdd();
    // await addNewEpisode('all');
    _lastPostion = await positionStorage.getInt();
    if (_lastPostion > 0 && _queue.playlist.length > 0) {
      final EpisodeBrief episode = _queue.playlist.first;
      final int duration = episode.duration * 1000;
      final double seekValue = duration != 0 ? _lastPostion / duration : 1;
      final PlayHistory history = PlayHistory(
          episode.title, episode.enclosureUrl, _lastPostion / 1000, seekValue);
      await dbHelper.saveHistory(history);
    }
    KeyValueStorage lastWorkStorage = KeyValueStorage(lastWorkKey);
    await lastWorkStorage.saveInt(0);
  }

  episodeLoad(EpisodeBrief episode, {int startPosition = 0}) async {
    print(episode.enclosureUrl);
    final EpisodeBrief episodeNew =
        await dbHelper.getRssItemWithUrl(episode.enclosureUrl);
    //TODO  load episode from last position when player running
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
      _startAudioService(startPosition, episodeNew.enclosureUrl);
      if (episodeNew.isNew == 1) {
        await dbHelper.removeEpisodeNewMark(episodeNew.enclosureUrl);
      }
    }
  }

  _startAudioService(int position, String url) async {
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
    //Check autoplay setting
    await _getAutoPlay();
    if (_autoPlay) {
      for (var episode in _queue.playlist)
        await AudioService.addQueueItem(episode.toMediaItem());
    } else {
      await AudioService.addQueueItem(_queue.playlist.first.toMediaItem());
    }
    //Check auto sleep timer setting
    await _getAutoSleepTimer();
    if (_autoSleepTimer) {
      int startTime =
          await autoSleepTimerStartStorage.getInt(defaultValue: 1380);
      int endTime = await autoSleepTimerEndStorage.getInt(defaultValue: 360);
      int currentTime = DateTime.now().hour * 60 + DateTime.now().minute;
      print('CurrentTime' + currentTime.toString());
      if ((startTime > endTime &&
              (currentTime > startTime || currentTime < endTime)) ||
          ((startTime < endTime) &&
              (currentTime > startTime && currentTime < endTime))) {
        int mode = await autoSleepTimerModeStorage.getInt();
        _sleepTimerMode = SleepTimerMode.values[mode];
        int defaultTimer =
            await defaultSleepTimerStorage.getInt(defaultValue: 30);
        sleepTimer(defaultTimer);
      }
    }
    _playerRunning = true;
    await AudioService.play();

    AudioService.currentMediaItemStream
        .where((event) => event != null)
        .listen((item) async {
      EpisodeBrief episode = await dbHelper.getRssItemWithMediaId(item.id);
      if (episode != null) {
        _episode = episode;
        _backgroundAudioDuration = item?.duration ?? 0;
        if (position > 0 &&
            _backgroundAudioDuration > 0 &&
            _episode.enclosureUrl == url) {
          AudioService.seekTo(position);
          position = 0;
        }
        notifyListeners();
      } else {
        _queue.playlist.removeAt(0);
        AudioService.skipToNext();
      }
    });

    queueSubject = BehaviorSubject<List<MediaItem>>();
    queueSubject.addStream(
        AudioService.queueStream.distinct().where((event) => event != null));
    queueSubject.stream.listen((event) {
      if (event.length == _queue.playlist.length - 1 &&
          _audioState == BasicPlaybackState.skippingToNext) {
        if (event.length == 0 || _stopOnComplete) {
          _queue.delFromPlaylist(_episode);
          _lastPostion = 0;
          notifyListeners();
          positionStorage.saveInt(_lastPostion);
          final PlayHistory history = PlayHistory(
              _episode.title,
              _episode.enclosureUrl,
              backgroundAudioPosition / 1000,
              seekSliderValue);
          dbHelper.saveHistory(history);
        } else if (event.first.id != _episode.mediaId) {
          _lastPostion = 0;
          notifyListeners();
          positionStorage.saveInt(_lastPostion);
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
      if (_audioState == BasicPlaybackState.stopped) {
        _playerRunning = false;
        if (_switchValue > 0) _switchValue = 0;
      }

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

    //double s = _currentSpeed ?? 1.0;
    int getPosition = 0;
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      double s = _currentSpeed ?? 1.0;
      if (_noSlide) {
        if (_audioState == BasicPlaybackState.playing) {
          getPosition = _currentPosition +
              ((DateTime.now().difference(_current).inMilliseconds) * s)
                  .toInt();
          _backgroundAudioPosition = getPosition < _backgroundAudioDuration
              ? getPosition
              : _backgroundAudioDuration;
        } else
          _backgroundAudioPosition = _currentPosition ?? 0;

        if (_backgroundAudioDuration != null &&
            _backgroundAudioDuration != 0 &&
            _backgroundAudioPosition != null) {
          _seekSliderValue =
              _backgroundAudioPosition / _backgroundAudioDuration ?? 0;
        } else
          _seekSliderValue = 0;

        if (_backgroundAudioPosition > 0 &&
            _backgroundAudioPosition < _backgroundAudioDuration) {
          _lastPostion = _backgroundAudioPosition;
          positionStorage.saveInt(_lastPostion);
        }
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
    _startAudioService(_lastPostion ?? 0, _queue.playlist.first.enclosureUrl);
  }

  playNext() async {
    await AudioService.skipToNext();
  }

  addToPlaylist(EpisodeBrief episode) async {
    if (!_queue.playlist.contains(episode)) {
      if (_playerRunning) {
        await AudioService.addQueueItem(episode.toMediaItem());
      }
      await _queue.addToPlayList(episode);
      notifyListeners();
    }
  }

  addToPlaylistAt(EpisodeBrief episode, int index) async {
    if (_playerRunning) {
      await AudioService.addQueueItemAt(episode.toMediaItem(), index);
    }
    await _queue.addToPlayListAt(episode, index);
    _queueUpdate = !_queueUpdate;
    notifyListeners();
  }

  addNewEpisode(List<String> group) async {
    List<EpisodeBrief> newEpisodes = [];
    if (group.first == 'All')
      newEpisodes = await dbHelper.getRecentNewRssItem();
    else
      newEpisodes = await dbHelper.getGroupNewRssItem(group);
    if (newEpisodes.length > 0 && newEpisodes.length < 100)
      for (var episode in newEpisodes) await addToPlaylist(episode);
    if (group.first == 'All')
      await dbHelper.removeAllNewMark();
    else
      await dbHelper.removeGroupNewMark(group);
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
      positionStorage.saveInt(_lastPostion);
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

  setSpeed(double speed) async {
    await AudioService.customAction('setSpeed', speed);
    _currentSpeed = speed;
    notifyListeners();
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

  shareClip(int start, int duration) async {
    _shareStatus = ShareStatus.generate;
    notifyListeners();
    int length = math.min(duration, (_backgroundAudioDuration ~/ 1000 - start));
    final BaseOptions options = BaseOptions(
      connectTimeout: 60000,
      receiveTimeout: 120000,
    );
    String imageUrl = await dbHelper.getImageUrl(_episode.enclosureUrl);
    String url = "https://podcastapi.stonegate.me/clip?" +
        "audio_link=${_episode.enclosureUrl}&image_link=$imageUrl&title=${_episode.feedTitle}" +
        "&text=${_episode.title}&start=$start&length=$length";
    String shareKey = environment['shareKey'];
    try {
      Response response = await Dio(options).get(url,
          options: Options(headers: {
            'X-Share-Key': "$shareKey",
          }));
      String shareLink = response.data;
      print(shareLink);
      String fileName = _episode.title + start.toString() + '.mp4';
      _shareStatus = ShareStatus.download;
      notifyListeners();
      Directory dir = await getTemporaryDirectory();
      String shareDir = join(dir.path, 'share', fileName);
      try {
        await Dio().download(shareLink, shareDir);
        _shareFile = shareDir;
        _shareStatus = ShareStatus.complete;
        notifyListeners();
      } on DioError catch (e) {
        print(e);
        _shareStatus = ShareStatus.error;
        notifyListeners();
      }
    } catch (e) {
      print(e);
      _shareStatus = ShareStatus.error;
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
  KeyValueStorage cacheStorage = KeyValueStorage(cacheMaxKey);

  List<MediaItem> _queue = [];
  AudioPlayer _audioPlayer = AudioPlayer();
  Completer _completer = Completer();
  BasicPlaybackState _skipState;
  bool _lostFocus;
  bool _playing;
  bool _stopAtEnd;
  int _cacheMax;
  bool get hasNext => _queue.length > 0;

  MediaItem get mediaItem => _queue.length > 0 ? _queue.first : null;

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
    _lostFocus = false;

    var playerStateSubscription = _audioPlayer.playbackStateStream
        .where((state) => state == AudioPlaybackState.completed)
        .listen((state) {
      _handlePlaybackCompleted();
    });
    var eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      if (event.playbackError != null) {
        _setState(state: _skipState ?? BasicPlaybackState.error);
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
          speed: event.speed,
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
    if (_queue.length > 0) _queue.removeAt(0);
    await AudioServiceBackground.setQueue(_queue);
    // }
    if (_queue.length == 0 || _stopAtEnd) {
      // await Future.delayed(Duration(milliseconds: 300));
      _skipState = null;
      onStop();
    } else {
      await AudioServiceBackground.setQueue(_queue);
      await AudioServiceBackground.setMediaItem(mediaItem);
      await _audioPlayer.setUrl(mediaItem.id, _cacheMax);
      print(mediaItem.title);
      Duration duration = await _audioPlayer.durationFuture;
      if (duration != null)
        await AudioServiceBackground.setMediaItem(
            mediaItem.copyWith(duration: duration.inMilliseconds));
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
        // await AudioServiceBackground.setQueue(_queue);
        if (_cacheMax == 0) {
          await cacheStorage.saveInt((200 * 1024 * 1024).toInt());
          _cacheMax = 200 * 1024 * 1024;
        }
        await _audioPlayer.setUrl(mediaItem.id, _cacheMax);
        var duration = await _audioPlayer.durationFuture;
        if (duration != null)
          await AudioServiceBackground.setMediaItem(
              mediaItem.copyWith(duration: duration.inMilliseconds));
        playFromStart();
      }
      // if (mediaItem.extras['skip'] > 0) {
      //   await _audioPlayer.setClip(
      //       start: Duration(seconds: 60));
      //   print(mediaItem.extras['skip']);
      //   print('set clip success');
      // }
      else {
        _playing = true;
        if (_audioPlayer.playbackEvent.state != AudioPlaybackState.connecting ||
            _audioPlayer.playbackEvent.state != AudioPlaybackState.none)
          _audioPlayer.play();
      }
      // if (mediaItem.extras['skip'] >
      //         _audioPlayer.playbackEvent.position.inSeconds ??
      //     0) {
      //   _audioPlayer.seek(Duration(seconds: mediaItem.extras['skip']));
      // }
    }
  }

  playFromStart() async {
    _playing = true;
    if (_audioPlayer.playbackEvent.state != AudioPlaybackState.connecting ||
        _audioPlayer.playbackEvent.state != AudioPlaybackState.none)
      try {
        _audioPlayer.play();
      } catch (e) {
        _setState(state: BasicPlaybackState.error);
      }
    if (mediaItem.extras['skip'] > 0) {
      _audioPlayer.seek(Duration(seconds: mediaItem.extras['skip']));
    }
  }

  @override
  void onPause() {
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
  void onSeekTo(int position) {
    if (_audioPlayer.playbackEvent.state != AudioPlaybackState.connecting ||
        _audioPlayer.playbackEvent.state != AudioPlaybackState.none)
      _audioPlayer.seek(Duration(milliseconds: position));
  }

  @override
  void onClick(MediaButton button) {
    if (button == MediaButton.media)
      playPause();
    else if (button == MediaButton.next)
      _audioPlayer.seek(Duration(
          milliseconds: AudioServiceBackground.state.position + 30 * 1000));
    else if (button == MediaButton.previous)
      _audioPlayer.seek(Duration(
          milliseconds: AudioServiceBackground.state.position - 10 * 1000));
  }

  @override
  void onStop() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    _setState(state: BasicPlaybackState.stopped);
    await Future.delayed(Duration(milliseconds: 300));
    _completer?.complete();
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
      await _audioPlayer.setUrl(mediaItem.id, _cacheMax);
      Duration duration = await _audioPlayer.durationFuture ?? Duration.zero;
      AudioServiceBackground.setMediaItem(
          mediaItem.copyWith(duration: duration.inMilliseconds));
      playFromStart();
      //onPlay();
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
  void onRewind() {
    _audioPlayer.seek(Duration(
        milliseconds: AudioServiceBackground.state.position - 10 * 1000));
  }

  @override
  void onAudioFocusLost() {
    if (_skipState == null) {
      if (_playing == null) {
      } else if (_audioPlayer.playbackEvent.state ==
          AudioPlaybackState.playing) {
        _playing = false;
        _lostFocus = true;
        _audioPlayer.pause();
      }
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
  void onAudioFocusGained() {
    if (_skipState == null) {
      if (_lostFocus) {
        _lostFocus = false;
        _playing = true;
        _audioPlayer.play();
      }
    }
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
    }
  }

  void _setState(
      {@required BasicPlaybackState state, int position, double speed}) {
    if (position == null) {
      position = _audioPlayer.playbackEvent.position.inMilliseconds;
    }
    if (speed == null) {
      speed = _audioPlayer.playbackEvent.speed;
    }
    AudioServiceBackground.setState(
      controls: getControls(state),
      systemActions: [MediaAction.seekTo],
      basicState: state,
      position: position,
      speed: speed,
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
