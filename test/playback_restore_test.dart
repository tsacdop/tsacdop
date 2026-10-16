import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsacdop/local_storage/key_value_storage.dart';
import 'package:tsacdop/state/audio_state.dart';
import 'package:tsacdop/type/episodebrief.dart';

import 'support/playback_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TestEpisodeDatabase database;
  late TestAudioHandler handler;
  late AudioPlayerNotifier audio;
  int initializations = 0;
  Completer<void>? initializationGate;

  setUp(() {
    SharedPreferences.setMockInitialValues(preferences());
    database = TestEpisodeDatabase();
    handler = TestAudioHandler();
    initializations = 0;
    initializationGate = null;
    audio = AudioPlayerNotifier(
      dbHelper: database,
      createHandler: (config, cacheMax) async {
        initializations++;
        await initializationGate?.future;
        return handler;
      },
    );
  });
  tearDown(() async {
    audio.dispose();
    if (initializationGate != null && !initializationGate!.isCompleted) {
      initializationGate!.complete();
    }
    await Future<void>.delayed(Duration.zero);
    await handler.mediaItem.close();
    await handler.playbackState.close();
    await handler.customEvent.close();
    await handler.queue.close();
  });

  test('cold restart restores the saved URL after new episodes were added ahead of it', () async {
    await audio.initPlaylist();
    expect(audio.episode!.enclosureUrl, paused.enclosureUrl);
    expect(audio.lastPosition, 123456);
    expect(audio.canResume, isTrue);
    expect(audio.playerRunning, isFalse);
    expect(handler.plays, 0);
    expect(database.histories, isEmpty);
  });

  test('listeners receive restoration while audio initialization is pending and init runs once', () async {
    initializationGate = Completer<void>();
    var notifications = 0;
    audio.addListener(() => notifications++);
    audio.addListener(() => notifications++);
    await audio.initPlaylist();
    expect(notifications, greaterThanOrEqualTo(2));
    initializationGate!.complete();
    await audio.initialize();
    expect(initializations, 1);
  });

  test(
    'queue resume starts the saved episode once at its saved position',
    () async {
      await audio.initPlaylist();
      await Future.wait([
        audio.playFromLastPosition(),
        audio.playFromLastPosition(),
      ]);
      expect(handler.plays, 1);
      expect(handler.preparations.single['position'], 123456);
      expect(handler.preparations.single['index'], 0);
      expect(handler.queue.value.map((item) => item.id), [
        paused.mediaId,
        first.mediaId,
      ]);
      expect(audio.queue.episodeList, [
        paused.enclosureUrl,
        first.enclosureUrl,
      ]);
      expect(audio.canResume, isFalse);
    },
  );

  test(
    'custom playlist resumes its actual index without changing playlist order',
    () async {
      SharedPreferences.setMockInitialValues(preferences(playlist: 'custom'));
      await audio.playFromLastPosition();
      expect(handler.preparations.single['index'], 1);
      expect(handler.preparations.single['position'], 123456);
      expect(handler.mediaItem.value!.id, paused.mediaId);
      expect(audio.playlist!.episodeList, [
        first.enclosureUrl,
        paused.enclosureUrl,
      ]);
      expect(handler.plays, 1);
    },
  );

  test('disabled autoplay prepares only the saved episode', () async {
    SharedPreferences.setMockInitialValues(
      preferences(playlist: 'custom', autoPlay: false),
    );
    await audio.playFromLastPosition();
    expect(handler.queue.value.map((item) => item.id), [paused.mediaId]);
    expect(handler.preparations.single['index'], 0);
    expect(handler.preparations.single['position'], 123456);
  });

  test(
    'pause writes the exact current position and a fresh notifier restores it',
    () async {
      await audio.playFromLastPosition();
      handler.progress(654321);
      await audio.pauseAduio();
      final stored = await SharedPreferences.getInstance();
      expect(stored.getStringList(playerStateKey), [
        'queue',
        paused.enclosureUrl,
        '654321',
      ]);

      final reopened = AudioPlayerNotifier(
        dbHelper: database,
        createHandler: (_, cacheMax) async => handler,
      );
      addTearDown(reopened.dispose);
      await reopened.initPlaylist();
      expect(reopened.episode!.enclosureUrl, paused.enclosureUrl);
      expect(reopened.lastPosition, 654321);
      expect(reopened.canResume, isTrue);
      expect(handler.plays, 1);
    },
  );

  test(
    'stopping and clearing native position cannot erase the saved progress',
    () async {
      await audio.playFromLastPosition();
      handler.progress(654321);
      await Future<void>.delayed(Duration.zero);
      await handler.stop();
      await Future<void>.delayed(Duration.zero);
      final stored = await SharedPreferences.getInstance();
      expect(stored.getStringList(playerStateKey), [
        'queue',
        paused.enclosureUrl,
        '654321',
      ]);
      expect(audio.lastPosition, 654321);
      expect(audio.canResume, isTrue);
    },
  );

  test('a missing saved episode is not replaced by a resume offer for another episode', () async {
    database.episodes.remove(paused.enclosureUrl);
    await audio.initPlaylist();
    expect(audio.canResume, isFalse);
    expect(audio.lastPosition, 0);
    expect(handler.plays, 0);
  });

  test(
    'an episode deleted after restoration is not replaced by unwanted playback',
    () async {
      await audio.initPlaylist();
      database.episodes.remove(paused.enclosureUrl);
      await audio.playFromLastPosition();
      expect(audio.canResume, isFalse);
      expect(audio.playerRunning, isFalse);
      expect(handler.plays, 0);
    },
  );

  test(
    'failed playback retains a usable resume offer and can be retried',
    () async {
      await audio.initPlaylist();
      handler.fail = true;
      await expectLater(audio.playFromLastPosition(), throwsStateError);
      expect(audio.canResume, isTrue);
      expect(audio.lastPosition, 123456);
      handler.fail = false;
      await audio.playFromLastPosition();
      expect(handler.plays, 1);
      expect(handler.preparations.single['position'], 123456);
    },
  );

  for (final invalid in ['not a number', '-100']) {
    test('invalid position $invalid does not crash restoration', () async {
      SharedPreferences.setMockInitialValues(
        preferences(state: ['queue', paused.enclosureUrl, invalid]),
      );
      await audio.initPlaylist();
      expect(audio.lastPosition, 0);
      expect(audio.canResume, isTrue);
    });
  }

  test(
    'missing or truncated player state does not offer unrelated playback',
    () async {
      SharedPreferences.setMockInitialValues(preferences(state: ['queue']));
      await audio.initPlaylist();
      expect(audio.canResume, isFalse);
      expect(handler.plays, 0);
    },
  );
  test(
    'periodic position checkpoints survive a restart without a pause callback',
    () async {
      await audio.playFromLastPosition();
      handler.progress(654321);
      await Future<void>.delayed(Duration.zero);
      final stored = await SharedPreferences.getInstance();
      expect(stored.getStringList(playerStateKey), [
        'queue',
        paused.enclosureUrl,
        '654321',
      ]);
      handler.progress(655000);
      await Future<void>.delayed(Duration.zero);
      expect(stored.getStringList(playerStateKey)!.last, '654321');
      handler.progress(660000);
      await Future<void>.delayed(Duration.zero);
      expect(stored.getStringList(playerStateKey)!.last, '660000');
    },
  );

  test(
    'episodes without a published duration retain their resume position',
    () async {
      database.episodes[paused.enclosureUrl] = EpisodeBrief(
        paused.title,
        paused.enclosureUrl,
        0,
        0,
        'Podcast',
        null,
        null,
        0,
        '',
        0,
        mediaId: paused.mediaId,
        skipSecondsStart: 0,
        skipSecondsEnd: 0,
      );
      await audio.initPlaylist();
      expect(audio.lastPosition, 123456);
      expect(database.histories, isEmpty);
      await audio.playFromLastPosition();
      expect(handler.preparations.single['position'], 123456);
      expect(handler.plays, 1);
    },
  );
}
