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
}
