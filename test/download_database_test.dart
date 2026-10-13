import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';

class _DatabaseHelper extends DBHelper {
  final Database db;
  _DatabaseHelper(this.db);

  @override
  Future<Database> get database async => db;
}

void main() {
  sqfliteFfiInit();
  late Database database;
  late DBHelper helper;
  const url = 'https://example.com/episode.mp3';

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    helper = _DatabaseHelper(database);
    await database.execute("""CREATE TABLE Episodes (
      enclosure_url TEXT, media_id TEXT, downloaded TEXT DEFAULT 'ND',
      download_date INTEGER DEFAULT 0, enclosure_length INTEGER,
      title TEXT, milliseconds INTEGER, feed_id TEXT, duration INTEGER,
      explicit INTEGER, is_new INTEGER, liked INTEGER
    )""");
    await database.execute("""CREATE TABLE PodcastLocal (
      id TEXT, title TEXT, imagePath TEXT, primaryColor TEXT
    )""");
    await database.execute(
      'CREATE TABLE PlayHistory (enclosure_url TEXT, listen_time INTEGER)',
    );
    await database.insert('PodcastLocal', {
      'id': 'podcast',
      'title': 'Podcast',
    });
    await database.insert('Episodes', {
      'enclosure_url': url,
      'media_id': url,
      'enclosure_length': 100,
      'title': 'Episode',
      'milliseconds': 1000,
      'feed_id': 'podcast',
      'duration': 60,
      'explicit': 0,
      'is_new': 1,
      'liked': 1,
    });
  });
  tearDown(() async => database.close());

  test(
    'deletion clears download metadata and preserves episode metadata',
    () async {
      await helper.saveDownloaded(url, 'task');
      await helper.saveMediaId(url, 'file:///episode.mp3', 'task', 200);
      expect(await helper.getDownloadedEpisode(0), hasLength(1));

      await helper.delDownloaded(url);

      final row = (await database.query('Episodes')).single;
      expect(row['downloaded'], 'ND');
      expect(row['media_id'], url);
      expect(row['download_date'], 0);
      expect(row['milliseconds'], 1000);
      expect(row['liked'], 1);
      expect(row['is_new'], 1);
      expect(await helper.getDownloadedEpisode(0), isEmpty);
    },
  );

  test('a late completion cannot restore a deleted download', () async {
    await helper.saveDownloaded(url, 'old-task');
    await helper.delDownloaded(url);

    expect(
      await helper.saveMediaId(url, 'file:///old.mp3', 'old-task', 200),
      0,
    );
    expect(await helper.getDownloadedEpisode(0), isEmpty);
    final row = (await database.query('Episodes')).single;
    expect(row['media_id'], url);
    expect(row['download_date'], 0);
  });

  test('an old completion cannot overwrite a new download task', () async {
    await helper.saveDownloaded(url, 'new-task');

    expect(
      await helper.saveMediaId(url, 'file:///old.mp3', 'old-task', 200),
      0,
    );
    expect(
      await helper.saveMediaId(url, 'file:///new.mp3', 'new-task', 300),
      1,
    );
    final row = (await database.query('Episodes')).single;
    expect(row['downloaded'], 'new-task');
    expect(row['media_id'], 'file:///new.mp3');
    expect(row['enclosure_length'], 300);
  });
  Future<void> seedSortEpisodes() async {
    for (final (id, title) in [('alpha', 'Alpha'), ('zulu', 'zulu')]) {
      await database.insert('PodcastLocal', {'id': id, 'title': title});
    }
    for (final (id, title, feed, date, size) in [
      ('a', 'zebra', 'alpha', 100, 80),
      ('b', 'Apple', 'zulu', 300, 40),
      ('c', 'banana', 'alpha', 200, 20),
      ('d', 'aardvark', 'zulu', 200, 100),
    ]) {
      await database.insert('Episodes', {
        'enclosure_url': 'https://example.com/$id.mp3',
        'media_id': 'file:///$id.mp3',
        'downloaded': id,
        'download_date': date,
        'enclosure_length': size,
        'title': title,
        'milliseconds': 1000 - date,
        'feed_id': feed,
        'duration': 60,
        'explicit': 0,
        'is_new': 0,
      });
    }
  }

  Future<List<String>> sortedIds(
    int? mode, {
    bool hideListened = false,
  }) async =>
      (await helper.getDownloadedEpisode(mode, hideListened: hideListened))
          .map(
            (episode) => episode.enclosureUrl.split('/').last.split('.').first,
          )
          .toList();

  test('sorts newest and oldest by download date with stable ties', () async {
    await seedSortEpisodes();
    expect(await sortedIds(0), ['b', 'c', 'd', 'a']);
    expect(await sortedIds(1), ['a', 'c', 'd', 'b']);
  });

  test('sorts episode titles without ASCII case affecting the order', () async {
    await seedSortEpisodes();
    expect(await sortedIds(3), ['d', 'b', 'c', 'a']);
  });

  test(
    'groups podcasts alphabetically with newest downloads within each',
    () async {
      await seedSortEpisodes();
      expect(await sortedIds(4), ['c', 'a', 'b', 'd']);
    },
  );

  test(
    'preserves the storage size sort and defaults invalid modes to newest',
    () async {
      await seedSortEpisodes();
      expect(await sortedIds(2), ['d', 'a', 'b', 'c']);
      for (final mode in [null, -1, 99]) {
        expect(await sortedIds(mode), ['b', 'c', 'd', 'a']);
      }
    },
  );

  test(
    'every sort excludes listened episodes without duplicating history joins',
    () async {
      await seedSortEpisodes();
      for (final (id, listened) in [('b', 12), ('b', 80), ('c', 0)]) {
        await database.insert('PlayHistory', {
          'enclosure_url': 'https://example.com/$id.mp3',
          'listen_time': listened,
        });
      }
      final expected = [
        ['c', 'd', 'a'],
        ['a', 'c', 'd'],
        ['d', 'a', 'c'],
        ['d', 'c', 'a'],
        ['c', 'a', 'd'],
      ];
      for (var mode = 0; mode < expected.length; mode++) {
        expect(await sortedIds(mode, hideListened: true), expected[mode]);
      }
      expect(await sortedIds(0), ['b', 'c', 'd', 'a']);
    },
  );
}
