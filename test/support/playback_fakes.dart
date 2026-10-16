import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:tsacdop/local_storage/key_value_storage.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:tsacdop/type/episodebrief.dart';
import 'package:tsacdop/type/play_histroy.dart';

const first = EpisodeBrief(
  'New episode',
  'https://example.com/new.mp3',
  0,
  0,
  'Podcast',
  null,
  3600,
  0,
  '',
  0,
  mediaId: 'https://example.com/new.mp3',
  skipSecondsStart: 0,
  skipSecondsEnd: 0,
);
const paused = EpisodeBrief(
  'Paused episode',
  'https://example.com/paused.mp3',
  0,
  0,
  'Podcast',
  null,
  3600,
  0,
  '',
  0,
  mediaId: 'https://example.com/paused.mp3',
  skipSecondsStart: 0,
  skipSecondsEnd: 0,
);

class TestEpisodeDatabase extends DBHelper {
  final episodes = {first.enclosureUrl: first, paused.enclosureUrl: paused};
  final List<PlayHistory> histories = [];

  @override
  Future<EpisodeBrief?> getRssItemWithUrl(String? url) async => episodes[url];

  @override
  Future<EpisodeBrief?> getRssItemWithMediaId(String id) async {
    for (final episode in episodes.values) {
      if (episode.mediaId == id) return episode;
    }
    return null;
  }

  @override
  Future<void> saveHistory(PlayHistory history) async => histories.add(history);
}

class TestAudioHandler extends BaseAudioHandler {
  int plays = 0;
  final List<Map<String, dynamic>> preparations = [];
  Duration position = Duration.zero;
  bool fail = false;

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    if (name == 'preparePlayback') {
      if (fail) throw StateError('Could not load audio');
      preparations.add(Map.of(extras!));
      final items = List<MediaItem>.from(extras['queue']);
      queue.add(items);
      position = Duration(milliseconds: extras['position']);
      mediaItem.add(
        items[extras['index'] as int].copyWith(
          duration: const Duration(hours: 1),
        ),
      );
      playbackState.add(
        PlaybackState(
          processingState: AudioProcessingState.ready,
          updatePosition: position,
        ),
      );
    }
    return null;
  }

  @override
  Future<void> play() async {
    plays++;
    playbackState.add(
      PlaybackState(
        processingState: AudioProcessingState.ready,
        playing: true,
        updatePosition: position,
      ),
    );
  }

  void progress(int milliseconds) {
    position = Duration(milliseconds: milliseconds);
    customEvent.add({'position': position});
    playbackState.add(
      PlaybackState(
        processingState: AudioProcessingState.ready,
        playing: true,
        updatePosition: position,
      ),
    );
  }

  @override
  Future<void> pause() async {
    playbackState.add(
      PlaybackState(
        processingState: AudioProcessingState.ready,
        playing: false,
        updatePosition: position,
      ),
    );
  }

  @override
  Future<void> stop() async {
    customEvent.add({'playerStopping': true, 'position': position});
    position = Duration.zero;
    customEvent.add({'position': Duration.zero});
    playbackState.add(
      PlaybackState(processingState: AudioProcessingState.idle),
    );
    customEvent.add({'playerRunning': false});
  }
}

Map<String, Object> preferences({
  String playlist = 'queue',
  List<String>? state,
  bool autoPlay = true,
}) => {
  autoPlayKey: autoPlay ? 0 : 1,
  playlistsAllKey: jsonEncode({
    'playlists': [
      {
        'name': 'Queue',
        'id': 'queue',
        'isLocal': false,
        'episodeList': [first.enclosureUrl, paused.enclosureUrl],
      },
      {
        'name': 'Custom',
        'id': 'custom',
        'isLocal': false,
        'episodeList': [first.enclosureUrl, paused.enclosureUrl],
      },
    ],
  }),
  playerStateKey: state ?? [playlist, paused.enclosureUrl, '123456'],
};
