import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
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
  // list of urls
  //List<String> _urls;
  //list of episodes
  List<EpisodeBrief> _playlist;
  //list of miediaitem

  List<EpisodeBrief> get playlist => _playlist;
  KeyValueStorage storage = KeyValueStorage('playlist');

  getPlaylist() async {
    List<String> urls = await storage.getStringList();
    print(urls);
    if (urls.length == 0) {
      _playlist = [];
    } else {
      _playlist = [];
      await Future.forEach(urls, (url) async {
        EpisodeBrief episode = await dbHelper.getRssItemWithUrl(url);
        print(episode.title);
        _playlist.add(episode);
      });
    }
    print('Playlist: ' + _playlist.length.toString());
  }

  savePlaylist() async {
    List<String> urls = [];
    urls.addAll(_playlist.map((e) => e.enclosureUrl));
    print(urls);
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

  delFromPlaylist(EpisodeBrief episodeBrief) async {
    _playlist
        .removeWhere((item) => item.enclosureUrl == episodeBrief.enclosureUrl);
    await savePlaylist();
  }
}

class AudioPlayerNotifier extends ChangeNotifier {
  DBHelper dbHelper = DBHelper();
  KeyValueStorage storage = KeyValueStorage('audioposition');
  EpisodeBrief _episode;
  Playlist _queue = Playlist();
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
  //Show stopwatch after user setting timer.
  bool _showStopWatch = false;
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
  EpisodeBrief get episode => _episode;
  bool get stopOnComplete => _stopOnComplete;
  bool get showStopWatch => _showStopWatch;
  bool get autoPlay => _autoPlay;

  set setStopOnComplete(bool boo) {
    _stopOnComplete = boo;
  }

  set autoPlaySwitch(bool boo) {
    _autoPlay = boo;
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) async {
    super.addListener(listener);
    await AudioService.connect();
  }

  loadPlaylist() async {
    await _queue.getPlaylist();
    _lastPostion = await storage.getInt();
  }

  episodeLoad(EpisodeBrief episode) async {
    if (_playerRunning) {
      PlayHistory history = PlayHistory(_episode.title, _episode.enclosureUrl,
          backgroundAudioPosition / 1000, seekSliderValue);
      await dbHelper.saveHistory(history);
      AudioService.addQueueItemAt(episode.toMediaItem(), 0);
      _queue.playlist
          .removeWhere((item) => item.enclosureUrl == episode.enclosureUrl);
      _queue.playlist.insert(0, episode);
      notifyListeners();
      await _queue.savePlaylist();
    } else {
      await _queue.getPlaylist();
      _queue.playlist
          .removeWhere((item) => item.enclosureUrl == episode.enclosureUrl);
      _queue.playlist.insert(0, episode);
      _queue.savePlaylist();
      _backgroundAudioDuration = 0;
      _backgroundAudioPosition = 0;
      _seekSliderValue = 0;
      _episode = episode;
      _playerRunning = true;
      notifyListeners();
      await _queue.savePlaylist();
      _startAudioService(0);
    }
  }

  _startAudioService(int position) async {
    if (!AudioService.connected) {
      await AudioService.connect();
    }
    await AudioService.start(
      backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
      androidNotificationChannelName: 'Tsacdop',
      notificationColor: 0xFF2196f3,
      androidNotificationIcon: 'mipmap/ic_launcher',
      enableQueue: true,
      androidStopOnRemoveTask: true,
    );
    _playerRunning = true;
    if (autoPlay) {
      await Future.forEach(_queue.playlist, (episode) async {
        await AudioService.addQueueItem(episode.toMediaItem());
      });
    } else {
      await AudioService.addQueueItem(_queue.playlist.first.toMediaItem());
    }
    await AudioService.play();
    AudioService.currentMediaItemStream.listen((item) async {
      print(position);
      print(_backgroundAudioDuration);
      if (item != null) {
        _episode = await dbHelper.getRssItemWithMediaId(item.id);
        _backgroundAudioDuration = item?.duration ?? 0;
        if (position > 0 && _backgroundAudioDuration > 0) {
          AudioService.seekTo(position);
          position = 0;
        }
        // _playerRunning = true;
      }
      notifyListeners();
    });
    AudioService.playbackStateStream.listen((event) async {
      _current = DateTime.now();
      _audioState = event?.basicState;
      if (_audioState == BasicPlaybackState.skippingToNext &&
          _episode != null) {
        _queue.delFromPlaylist(_episode);
      }
      if (_audioState == BasicPlaybackState.paused ||
          _audioState == BasicPlaybackState.skippingToNext &&
              _episode != null) {
        PlayHistory history = PlayHistory(_episode.title, _episode.enclosureUrl,
            backgroundAudioPosition / 1000, seekSliderValue);
        await dbHelper.saveHistory(history);
      }
      if (_audioState == BasicPlaybackState.stopped) {
        _playerRunning = false;
      }
      _currentPosition = event?.currentPosition ?? 0;
      notifyListeners();
    });
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (_noSlide) {
        _audioState == BasicPlaybackState.playing
            ? (_backgroundAudioPosition < _backgroundAudioDuration)
                ? _backgroundAudioPosition = _currentPosition +
                    DateTime.now().difference(_current).inMilliseconds
                : _backgroundAudioPosition = _backgroundAudioDuration
            : _backgroundAudioPosition = _currentPosition;

        if (_backgroundAudioDuration != null &&
            _backgroundAudioDuration != 0 &&
            _backgroundAudioPosition != null) {
          _seekSliderValue =
              _backgroundAudioPosition / _backgroundAudioDuration ?? 0;
        }
        if (_backgroundAudioPosition > 0) {
          _lastPostion = _backgroundAudioPosition;
          storage.saveInt(_lastPostion);
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
    print('add to playlist when not rnnning');
    await _queue.addToPlayList(episode);
    notifyListeners();
  }

  addToPlaylistAt(EpisodeBrief episode, int index) async {
    if (_playerRunning) {
      await AudioService.addQueueItemAt(episode.toMediaItem(), index);
    }
    print('add to playlist when not rnnning');
    await _queue.addToPlayListAt(episode, index);
    notifyListeners();
  }

  updateMediaItem(EpisodeBrief episode) async {
    int index = _queue.playlist
        .indexWhere((item) => item.enclosureUrl == episode.enclosureUrl);
    if (index > 0) {
      await delFromPlaylist(episode);
      await addToPlaylistAt(episode, index);
    }
  }

  delFromPlaylist(EpisodeBrief episode) async {
    if (_playerRunning) {
      await AudioService.removeQueueItem(episode.toMediaItem());
    }
    await _queue.delFromPlaylist(episode);
    notifyListeners();
  }

  pauseAduio() async {
    AudioService.pause();
  }

  resumeAudio() async {
    AudioService.play();
  }

  forwardAudio(int s) {
    int pos = _backgroundAudioPosition + s * 1000;
    AudioService.seekTo(pos);
  }

  sliderSeek(double val) async {
    print(val.toString());
    _noSlide = false;
    _seekSliderValue = val;
    notifyListeners();
    _currentPosition = (val * _backgroundAudioDuration).toInt();
    await AudioService.seekTo(_currentPosition);
    _noSlide = true;
  }

  //Set sleep time
  sleepTimer(int mins) {
    _showStopWatch = true;
    notifyListeners();
    _stopTimer = Timer(Duration(minutes: mins), () {
      _stopOnComplete = false;
      _showStopWatch = false;
      AudioService.stop();
      notifyListeners();
    });
  }

//Cancel sleep timer
  cancelTimer() {
    _stopTimer.cancel();
    _showStopWatch = false;
    notifyListeners();
  }

  @override
  void dispose() async {
    await AudioService.stop();
    await AudioService.disconnect();
    super.dispose();
  }
}

class AudioPlayerTask extends BackgroundAudioTask {
  List<MediaItem> _queue = [];
  AudioPlayer _audioPlayer = AudioPlayer();
  Completer _completer = Completer();
  BasicPlaybackState _skipState;
  bool _playing;

  bool get hasNext => _queue.length > 0;

  MediaItem get mediaItem => _queue.first;

  BasicPlaybackState _stateToBasicState(AudioPlaybackState state) {
    switch (state) {
      case AudioPlaybackState.none:
        return BasicPlaybackState.none;
      case AudioPlaybackState.stopped:
        return BasicPlaybackState.stopped;
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
    print('start background task');
    var playerStateSubscription = _audioPlayer.playbackStateStream
        .where((state) => state == AudioPlaybackState.completed)
        .listen((state) {
      _handlePlaybackCompleted();
    });
    var eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      BasicPlaybackState state;
      if (event.buffering) {
        state = BasicPlaybackState.buffering;
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

  void _handlePlaybackCompleted() {
    if (hasNext) {
      onSkipToNext();
    } else {
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
    if (_playing == null) {
      // First time, we want to start playing
      _playing = true;
    } else {
      // Stop current item
      await _audioPlayer.stop();
      _queue.removeAt(0);
    }
    AudioServiceBackground.setQueue(_queue);
    AudioServiceBackground.setMediaItem(mediaItem);
    _skipState = BasicPlaybackState.skippingToNext;
    await _audioPlayer.setUrl(mediaItem.id);
    print(mediaItem.id);
    Duration duration = await _audioPlayer.durationFuture;
    AudioServiceBackground.setMediaItem(
        mediaItem.copyWith(duration: duration.inMilliseconds));
    _skipState = null;
    // Resume playback if we were playing
    if (_playing) {
      onPlay();
    } else {
      _setState(state: BasicPlaybackState.paused);
    }
  }

  @override
  void onPlay() async {
    if (_skipState == null) {
      if (_playing == null) {
        _playing = true;
        AudioServiceBackground.setQueue(_queue);
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
    AudioServiceBackground.setQueue(_queue);
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
      AudioServiceBackground.setQueue(_queue);
      AudioServiceBackground.setMediaItem(mediaItem);
      await _audioPlayer.setUrl(mediaItem.id);
      Duration duration = await _audioPlayer.durationFuture;
      AudioServiceBackground.setMediaItem(
          mediaItem.copyWith(duration: duration.inMilliseconds));
      onPlay();
    } else {
      _queue.insert(index, mediaItem);
      AudioServiceBackground.setQueue(_queue);
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
      if (_playing == null) {}
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
      case 'addQueue':
        break;
      case 'updateMedia':
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
