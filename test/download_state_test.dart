import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsacdop/local_storage/key_value_storage.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:tsacdop/state/download_state.dart';
import 'package:tsacdop/type/episode_task.dart';
import 'package:tsacdop/type/episodebrief.dart';

const episode = EpisodeBrief(
  'Episode',
  'https://example.com/episode.mp3',
  100,
  1000,
  'Podcast',
  null,
  0,
  0,
  '',
  0,
);
const otherEpisode = EpisodeBrief(
  'Other',
  'https://example.com/other.mp3',
  100,
  1000,
  'Podcast',
  null,
  0,
  0,
  '',
  0,
);

class _MemoryDB extends DBHelper {
  final Map<String, EpisodeBrief> episodes = {
    episode.enclosureUrl: episode,
    otherEpisode.enclosureUrl: otherEpisode,
  };
  final List<String> deleted = [];

  @override
  Future<bool> isDownloaded(String url) async =>
      episodes[url]?.mediaId?.startsWith('file:') ?? false;

  @override
  Future<int?> saveDownloaded(String url, String? id) async => 1;

  @override
  Future<EpisodeBrief?> getRssItemWithUrl(String? url) async => episodes[url];

  @override
  Future<int?> delDownloaded(String url) async {
    deleted.add(url);
    episodes[url] = episodes[url]!.copyWith(mediaId: url);
    return 1;
  }

  @override
  Future<int?> saveMediaId(
    String url,
    String path,
    String? id,
    int size,
  ) async {
    episodes[url] = episodes[url]!.copyWith(mediaId: path);
    return 1;
  }
}

class _Paths extends PathProviderPlatform {
  final String directory;
  _Paths(this.directory);

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async => [directory];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('vn.hunghd/downloader');
  late Directory directory;
  late _MemoryDB database;
  late DownloadState state;
  late List<Map<String, Object?>> tasks;
  late List<String> removed;
  Completer<void>? loadGate;
  Completer<void>? loadStarted;
  bool removeFails = false;
  bool loadFails = false;
  bool leaveFiles = false;
  bool enqueueFails = false;
  int enqueued = 0;
  bool completeAutoImmediately = false;
  Completer<void>? completionGate;
  Completer<void>? completionStarted;
  late PathProviderPlatform originalPaths;

  Map<String, Object?> task(String id, EpisodeBrief item) => {
    'task_id': id,
    'status': DownloadTaskStatus.complete.index,
    'progress': 100,
    'url': item.enclosureUrl,
    'file_name': '$id.mp3',
    'saved_dir': directory.path,
    'time_created': 1000,
  };

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => null);
    await FlutterDownloader.initialize();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({autoDeleteKey: -1});
    directory = await Directory.systemTemp.createTemp('tsacdop-download-test-');
    database = _MemoryDB();
    originalPaths = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _Paths(directory.path);
    tasks = [];
    removed = [];
    loadGate = null;
    loadStarted = null;
    removeFails = false;
    loadFails = false;
    leaveFiles = false;
    enqueueFails = false;
    enqueued = 0;
    completeAutoImmediately = false;
    completionGate = null;
    completionStarted = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'loadTasks':
              if (loadFails) return null;
              final snapshot = tasks
                  .map((t) => Map<String, Object?>.of(t))
                  .toList();
              loadStarted?.complete();
              loadStarted = null;
              await loadGate?.future;
              return snapshot;
            case 'remove':
              if (removeFails) throw PlatformException(code: 'delete_failed');
              final id = call.arguments['task_id'] as String;
              removed.add(id);
              final matching = tasks.where((t) => t['task_id'] == id).toList();
              if (call.arguments['should_delete_content'] == true &&
                  !leaveFiles) {
                for (final t in matching) {
                  final file = File('${t['saved_dir']}/${t['file_name']}');
                  if (await file.exists()) await file.delete();
                }
              }
              tasks.removeWhere((t) => t['task_id'] == id);
              return null;
            case 'enqueue':
              if (enqueueFails) throw PlatformException(code: 'enqueue_failed');
              final id = 'new-${++enqueued}';
              tasks.add({
                ...task(id, episode),
                'status': DownloadTaskStatus.enqueued.index,
                'file_name': call.arguments['file_name'],
                'saved_dir': call.arguments['saved_dir'],
              });
              if (completeAutoImmediately) {
                final saved = tasks.last;
                await File('${saved['saved_dir']}/${saved['file_name']}')
                    .writeAsString('audio');
                saved['status'] = DownloadTaskStatus.complete.index;
                autoDownloadCallback(
                  id,
                  DownloadTaskStatus.complete.index,
                  100,
                );
              }
              return id;
            case 'loadTasksWithRawQuery':
              final query = call.arguments['query'] as String;
              completionStarted?.complete();
              completionStarted = null;
              final snapshot = tasks
                  .where((t) => query.contains("'${t['task_id']}'"))
                  .toList();
              await completionGate?.future;
              return snapshot;
            default:
              return null;
          }
        });
    state = DownloadState(dbHelper: database);
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() async {
    state.dispose();
    if (loadGate != null && !loadGate!.isCompleted) loadGate!.complete();
    if (completionGate != null && !completionGate!.isCompleted)
      completionGate!.complete();
    PathProviderPlatform.instance = originalPaths;
    await directory.delete(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'deletes persisted downloads before the in-memory list is loaded',
    () async {
      tasks.add(task('saved', episode));
      final file = await File('${directory.path}/saved.mp3')
          .writeAsString('audio');

      await state.delTask(episode);

      expect(removed, ['saved']);
      expect(await file.exists(), isFalse);
      expect(database.deleted, [episode.enclosureUrl]);
    },
  );

  test(
    'deletes every duplicate task and preserves unrelated downloads',
    () async {
      tasks.addAll([
        task('first', episode),
        task('duplicate', episode),
        task('other', otherEpisode),
      ]);
      for (final id in ['first', 'duplicate', 'other']) {
        await File('${directory.path}/$id.mp3').writeAsString('audio');
      }
      state.episodeTasks.addAll([
        EpisodeTask(episode, 'first', status: DownloadTaskStatus.complete),
        EpisodeTask(
          episode.copyWith(mediaId: 'file:///duplicate'),
          'duplicate',
          status: DownloadTaskStatus.complete,
        ),
        EpisodeTask(otherEpisode, 'other', status: DownloadTaskStatus.complete),
      ]);

      await state.delTask(episode);

      expect(removed, ['first', 'duplicate']);
      expect(tasks.single['task_id'], 'other');
      expect(await File('${directory.path}/first.mp3').exists(), isFalse);
      expect(await File('${directory.path}/duplicate.mp3').exists(), isFalse);
      expect(await File('${directory.path}/other.mp3').exists(), isTrue);
      expect(state.episodeTasks.map((t) => t.taskId), ['other']);
    },
  );

  test(
    'deletes an orphan file even when its native task is already missing',
    () async {
      final file = await File('${directory.path}/orphan #1.mp3')
          .writeAsString('audio');
      database.episodes[episode.enclosureUrl] = episode.copyWith(
        mediaId: file.uri.toString(),
      );

      await state.delTask(episode);

      expect(removed, isEmpty);
      expect(await file.exists(), isFalse);
      expect(database.deleted, [episode.enclosureUrl]);
    },
  );

  test(
    'keeps metadata when the native removal fails and allows retry',
    () async {
      tasks.add(task('saved', episode));
      state.episodeTasks.add(EpisodeTask(episode, 'saved'));
      removeFails = true;

      await expectLater(state.delTask(episode), throwsStateError);
      expect(database.deleted, isEmpty);
      expect(state.episodeTasks, hasLength(1));

      removeFails = false;
      loadFails = false;
      leaveFiles = false;
      enqueueFails = false;
      enqueued = 0;
      completeAutoImmediately = false;
      completionGate = null;
      completionStarted = null;
      await state.delTask(episode);
      expect(tasks, isEmpty);
      expect(database.deleted, [episode.enclosureUrl]);
    },
  );

  test('a load already in progress cannot restore a deleted episode', () async {
    tasks.add(task('saved', episode));
    await File('${directory.path}/saved.mp3').writeAsString('audio');
    loadGate = Completer<void>();
    loadStarted = Completer<void>();
    final started = loadStarted!.future;
    state.addListener(() {});
    await started;

    final deletion = state.delTask(episode);
    // Both implementations can now continue; the serialized one finishes the
    // earlier load before deleting, instead of applying a stale load afterward.
    loadGate!.complete();
    loadGate = null;
    await deletion;
    await Future<void>.delayed(Duration.zero);

    expect(tasks, isEmpty);
    expect(state.episodeTasks, isEmpty);
    expect(
      database.episodes[episode.enclosureUrl]!.mediaId,
      episode.enclosureUrl,
    );
  });
  test('removes files left behind by the native plugin', () async {
    tasks.add(task('saved', episode));
    final file = await File('${directory.path}/saved.mp3')
        .writeAsString('audio');
    leaveFiles = true;

    await state.delTask(episode);

    expect(await file.exists(), isFalse);
    expect(database.deleted, [episode.enclosureUrl]);
  });

  test('does not clear metadata when tasks cannot be loaded', () async {
    loadFails = true;
    await expectLater(state.delTask(episode), throwsStateError);
    expect(database.deleted, isEmpty);
    expect(removed, isEmpty);
  });

  test('rapid download requests enqueue the episode only once', () async {
    await Future.wait([
      state.startTask(episode),
      state.startTask(episode),
      state.startTask(episode),
    ]);

    expect(enqueued, 1);
    expect(tasks, hasLength(1));
    expect(state.episodeTasks, hasLength(1));
  });

  test('failed enqueue leaves no phantom task and permits a retry', () async {
    enqueueFails = true;
    await state.startTask(episode);
    expect(state.episodeTasks, isEmpty);

    enqueueFails = false;
    await state.startTask(episode);
    expect(enqueued, 1);
    expect(state.episodeTasks, hasLength(1));
  });

  test(
    'auto download skips an episode already queued by the foreground',
    () async {
      tasks.add(task('saved', episode));
      final autoDownloader = AutoDownloader(dbHelper: database);

      await autoDownloader.startTask([episode, episode]);

      expect(enqueued, 0);
      expect(tasks.single['task_id'], 'saved');
    },
  );

  test(
    'auto download deduplicates a batch and completes a fast download',
    () async {
      completeAutoImmediately = true;
      final autoDownloader = AutoDownloader(dbHelper: database);
      autoDownloader.bindBackgroundIsolate();

      await autoDownloader
          .startTask([episode, episode])
          .timeout(const Duration(seconds: 5));

      expect(enqueued, 1);
      expect(
        database.episodes[episode.enclosureUrl]!.mediaId,
        startsWith('file:'),
      );
    },
  );

  test(
    'completion in progress finishes before deletion and cannot restore it',
    () async {
      tasks.add(task('saved', episode));
      final file = await File('${directory.path}/saved.mp3')
          .writeAsString('audio');
      state.episodeTasks.add(EpisodeTask(episode, 'saved'));
      completionGate = Completer<void>();
      completionStarted = Completer<void>();
      final started = completionStarted!.future;
      downloadCallback('saved', DownloadTaskStatus.complete.index, 100);
      await started;

      final deletion = state.delTask(episode);
      completionGate!.complete();
      completionGate = null;
      await deletion;
      downloadCallback('saved', DownloadTaskStatus.complete.index, 100);
      await Future<void>.delayed(Duration.zero);

      expect(state.episodeTasks, isEmpty);
      expect(
        database.episodes[episode.enclosureUrl]!.mediaId,
        episode.enclosureUrl,
      );
      expect(await file.exists(), isFalse);
    },
  );
}
