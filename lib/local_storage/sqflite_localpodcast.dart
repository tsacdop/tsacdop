import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:webfeed/webfeed.dart';

import '../type/episodebrief.dart';
import '../type/play_histroy.dart';
import '../type/podcastlocal.dart';
import '../type/sub_history.dart';

enum Filter { downloaded, liked, search, all }

class DBHelper {
  static Database _db;
  Future<Database> get database async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    var documentsDirectory = await getDatabasesPath();
    var path = join(documentsDirectory, "podcasts.db");
    var theDb = await openDatabase(path,
        version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    await db
        .execute("""CREATE TABLE PodcastLocal(id TEXT PRIMARY KEY,title TEXT, 
        imageUrl TEXT,rssUrl TEXT UNIQUE, primaryColor TEXT, author TEXT, 
        description TEXT, add_date INTEGER, imagePath TEXT, provider TEXT, link TEXT, 
        background_image TEXT DEFAULT '', hosts TEXT DEFAULT '',update_count INTEGER DEFAULT 0,
        episode_count INTEGER DEFAULT 0, skip_seconds INTEGER DEFAULT 0, auto_download INTEGER DEFAULT 0)""");
    await db
        .execute("""CREATE TABLE Episodes(id INTEGER PRIMARY KEY,title TEXT, 
        enclosure_url TEXT UNIQUE, enclosure_length INTEGER, pubDate TEXT, 
        description TEXT, feed_id TEXT, feed_link TEXT, milliseconds INTEGER, 
        duration INTEGER DEFAULT 0, explicit INTEGER DEFAULT 0, liked INTEGER DEFAULT 0, 
        liked_date INTEGER DEFAULT 0, downloaded TEXT DEFAULT 'ND', download_date INTEGER DEFAULT 0, media_id TEXT, 
        is_new INTEGER DEFAULT 0)""");
    await db.execute(
        """CREATE TABLE PlayHistory(id INTEGER PRIMARY KEY, title TEXT, enclosure_url TEXT,
        seconds REAL, seek_value REAL, add_date INTEGER, listen_time INTEGER DEFAULT 0)""");
    await db.execute(
        """CREATE TABLE SubscribeHistory(id TEXT PRIMARY KEY, title TEXT, rss_url TEXT UNIQUE, 
        add_date INTEGER, remove_date INTEGER DEFAULT 0, status INTEGER DEFAULT 0)""");
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 1) {
      await db.execute(
          "ALTER TABLE PodcastLocal ADD skip_seconds INTEGER DEFAULT 0 ");
      await db.execute(
          "ALTER TABLE PodcastLocal ADD auto_download INTEGER DEFAULT 0");
    } else if (oldVersion == 2) {
      await db.execute(
          "ALTER TABLE PodcastLocal ADD auto_download INTEGER DEFAULT 0");
    }
  }

  Future<List<PodcastLocal>> getPodcastLocal(List<String> podcasts) async {
    var dbClient = await database;
    var podcastLocal = <PodcastLocal>[];

    for (var s in podcasts) {
      List<Map> list;
      list = await dbClient.rawQuery(
          """SELECT id, title, imageUrl, rssUrl, primaryColor, author, imagePath , provider, 
          link ,update_count, episode_count FROM PodcastLocal WHERE id = ?""",
          [s]);
      if (list.length > 0) {
        podcastLocal.add(PodcastLocal(
            list.first['title'],
            list.first['imageUrl'],
            list.first['rssUrl'],
            list.first['primaryColor'],
            list.first['author'],
            list.first['id'],
            list.first['imagePath'],
            list.first['provider'],
            list.first['link'],
            upateCount: list.first['update_count'],
            episodeCount: list.first['episode_count']));
      }
    }
    return podcastLocal;
  }

  Future<List<PodcastLocal>> getPodcastLocalAll() async {
    var dbClient = await database;
    List<Map> list = await dbClient.rawQuery(
        'SELECT id, title, imageUrl, rssUrl, primaryColor, author, imagePath, provider, link FROM PodcastLocal ORDER BY add_date DESC');

    var podcastLocal = <PodcastLocal>[];

    for (var i in list) {
      podcastLocal.add(PodcastLocal(
          i['title'],
          i['imageUrl'],
          i['rssUrl'],
          i['primaryColor'],
          i['author'],
          i['id'],
          i['imagePath'],
          list.first['provider'],
          list.first['link']));
    }
    return podcastLocal;
  }

  Future<int> getPodcastCounts(String id) async {
    var dbClient = await database;
    List<Map> list = await dbClient
        .rawQuery('SELECT episode_count FROM PodcastLocal WHERE id = ?', [id]);
    return list.first['episode_count'];
  }

  Future<int> getPodcastUpdateCounts(String id) async {
    var dbClient = await database;
    List<Map> list = await dbClient.rawQuery(
        'SELECt count(*) as count FROM Episodes WHERE feed_id = ? AND is_new = 1',
        [id]);
    return list.first['count'];
  }

  Future<int> getSkipSeconds(String id) async {
    var dbClient = await database;
    List<Map> list = await dbClient
        .rawQuery('SELECT skip_seconds FROM PodcastLocal WHERE id = ?', [id]);
    return list.first['skip_seconds'];
  }

  Future<int> saveSkipSeconds(String id, int seconds) async {
    var dbClient = await database;
    return await dbClient.rawUpdate(
        "UPDATE PodcastLocal SET skip_seconds = ? WHERE id = ?", [seconds, id]);
  }

  Future<bool> getAutoDownload(String id) async {
    var dbClient = await database;
    List<Map> list = await dbClient
        .rawQuery('SELECT auto_download FROM PodcastLocal WHERE id = ?', [id]);
    return list.first['auto_download'] == 1;
  }

  Future<int> saveAutoDownload(String id, {bool boo}) async {
    var dbClient = await database;
    return await dbClient.rawUpdate(
        "UPDATE PodcastLocal SET auto_download = ? WHERE id = ?",
        [boo ? 1 : 0, id]);
  }

  Future<String> checkPodcast(String url) async {
    var dbClient = await database;
    List<Map> list = await dbClient
        .rawQuery('SELECT id FROM PodcastLocal WHERE rssUrl = ?', [url]);
    if (list.isEmpty) return '';
    return list.first['id'];
  }

  Future savePodcastLocal(PodcastLocal podcastLocal) async {
    var _milliseconds = DateTime.now().millisecondsSinceEpoch;
    var dbClient = await database;
    await dbClient.transaction((txn) async {
      await txn.rawInsert(
          """INSERT OR IGNORE INTO PodcastLocal (id, title, imageUrl, rssUrl, 
          primaryColor, author, description, add_date, imagePath, provider, link) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
          [
            podcastLocal.id,
            podcastLocal.title,
            podcastLocal.imageUrl,
            podcastLocal.rssUrl,
            podcastLocal.primaryColor,
            podcastLocal.author,
            podcastLocal.description,
            _milliseconds,
            podcastLocal.imagePath,
            podcastLocal.provider,
            podcastLocal.link
          ]);
      await txn.rawInsert(
          """REPLACE INTO SubscribeHistory(id, title, rss_url, add_date) VALUES (?, ?, ?, ?)""",
          [
            podcastLocal.id,
            podcastLocal.title,
            podcastLocal.rssUrl,
            _milliseconds
          ]);
    });
  }

  Future<int> saveFiresideData(List<String> list) async {
    var dbClient = await database;
    var result = await dbClient.rawUpdate(
        'UPDATE PodcastLocal SET background_image = ? , hosts = ? WHERE id = ?',
        [list[1], list[2], list[0]]);
    print('Fireside data save in sqllite');
    return result;
  }

  Future<List<String>> getFiresideData(String id) async {
    var dbClient = await database;
    List<Map> list = await dbClient.rawQuery(
        'SELECT background_image, hosts FROM PodcastLocal WHERE id = ?', [id]);
    if (list.length > 0) {
      var data = <String>[list.first['background_image'], list.first['hosts']];
      return data;
    }
    return ['', ''];
  }

  Future delPodcastLocal(String id) async {
    var dbClient = await database;
    await dbClient.rawDelete('DELETE FROM PodcastLocal WHERE id =?', [id]);
    List<Map> list = await dbClient.rawQuery(
        """SELECT downloaded FROM Episodes WHERE downloaded != 'ND' AND feed_id = ?""",
        [id]);
    for (var i in list) {
      if (i != null) {
        await FlutterDownloader.remove(
            taskId: i['downloaded'], shouldDeleteContent: true);
      }
      print('Removed all download tasks');
    }
    await dbClient.rawDelete('DELETE FROM Episodes WHERE feed_id=?', [id]);
    var _milliseconds = DateTime.now().millisecondsSinceEpoch;
    await dbClient.rawUpdate(
        """UPDATE SubscribeHistory SET remove_date = ? , status = ? WHERE id = ?""",
        [_milliseconds, 1, id]);
  }

  Future<int> saveHistory(PlayHistory history) async {
    var dbClient = await database;
    var _milliseconds = DateTime.now().millisecondsSinceEpoch;
    var recent = await getPlayHistory(1);
    if (recent.length == 1) {
      if (recent.first.url == history.url) {
        await dbClient.rawDelete("DELETE FROM PlayHistory WHERE add_date = ?",
            [recent.first.playdate.millisecondsSinceEpoch]);
      }
    }
    var result = await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          """REPLACE INTO PlayHistory (title, enclosure_url, seconds, seek_value, add_date, listen_time)
       VALUES (?, ?, ?, ?, ?, ?) """,
          [
            history.title,
            history.url,
            history.seconds,
            history.seekValue,
            _milliseconds,
            history.seekValue > 0.95 ? 1 : 0
          ]);
    });
    return result;
  }

  Future<List<PlayHistory>> getPlayHistory(int top) async {
    var dbClient = await database;
    List<Map> list = await dbClient.rawQuery(
        """SELECT title, enclosure_url, seconds, seek_value, add_date FROM PlayHistory
         ORDER BY add_date DESC LIMIT ?
     """, [top]);
    var playHistory = <PlayHistory>[];
    for (var record in list) {
      playHistory.add(PlayHistory(record['title'], record['enclosure_url'],
          (record['seconds']).toInt(), record['seek_value'],
          playdate: DateTime.fromMillisecondsSinceEpoch(record['add_date'])));
    }
    return playHistory;
  }

  Future<int> isListened(String url) async {
    var dbClient = await database;
    var i = 0;
    List<Map> list = await dbClient.rawQuery(
        "SELECT listen_time FROM PlayHistory WHERE enclosure_url = ?", [url]);
    if (list.length == 0) {
      return 0;
    } else {
      for (var element in list) {
        i += element['listen_time'];
      }
      return i;
    }
  }

  Future<List<SubHistory>> getSubHistory() async {
    var dbClient = await database;
    List<Map> list = await dbClient.rawQuery(
        """SELECT title, rss_url, add_date, remove_date, status FROM SubscribeHistory
      ORDER BY add_date DESC""");
    return list
        .map((record) => SubHistory(
            record['status'] == 0 ? true : false,
            DateTime.fromMillisecondsSinceEpoch(record['remove_date']),
            DateTime.fromMillisecondsSinceEpoch(record['add_date']),
            record['rss_url'],
            record['title']))
        .toList();
  }

  Future<double> listenMins(int day) async {
    var dbClient = await database;
    var now = DateTime.now();
    var start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: day))
        .millisecondsSinceEpoch;
    var end = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: (day - 1)))
        .millisecondsSinceEpoch;
    List<Map> list = await dbClient.rawQuery(
        "SELECT seconds FROM PlayHistory WHERE add_date > ? AND add_date < ?",
        [start, end]);
    var sum = 0.0;
    if (list.isEmpty) {
      sum = 0.0;
    } else {
      for (var record in list) {
        sum += record['seconds'];
      }
    }
    return (sum ~/ 60).toDouble();
  }

  Future<PlayHistory> getPosition(EpisodeBrief episodeBrief) async {
    var dbClient = await database;
    List<Map> list = await dbClient.rawQuery(
        """SELECT title, enclosure_url, seconds, seek_value, add_date FROM PlayHistory 
        WHERE enclosure_url = ? ORDER BY add_date DESC LIMIT 1""",
        [episodeBrief.enclosureUrl]);
    return list.isNotEmpty
        ? PlayHistory(list.first['title'], list.first['enclosure_url'],
            (list.first['seconds']).toInt(), list.first['seek_value'],
            playdate:
                DateTime.fromMillisecondsSinceEpoch(list.first['add_date']))
        : PlayHistory(episodeBrief.title, episodeBrief.enclosureUrl, 0, 0);
  }

  /// Check if episode was marked listend.
  Future<bool> checkMarked(EpisodeBrief episodeBrief) async {
    var dbClient = await database;
    List<Map> list = await dbClient.rawQuery(
        """SELECT title, enclosure_url, seconds, seek_value, add_date FROM PlayHistory 
        WHERE enclosure_url = ? AND seek_value = 1 ORDER BY add_date DESC LIMIT 1""",
        [episodeBrief.enclosureUrl]);
    return list.isNotEmpty;
  }

  DateTime _parsePubDate(String pubDate) {
    if (pubDate == null) return DateTime.now();
    DateTime date;
    var yyyy = RegExp(r'[1-2][0-9]{3}');
    var hhmm = RegExp(r'[0-2][0-9]\:[0-5][0-9]');
    var ddmmm = RegExp(r'[0-3][0-9]\s[A-Z][a-z]{2}');
    var mmDd = RegExp(r'([1-2][0-9]{3}\-[0-1]|\s)[0-9]\-[0-3][0-9]');
    // RegExp timezone
    var z = RegExp(r'(\+|\-)[0-1][0-9]00');
    var timezone = z.stringMatch(pubDate);
    var timezoneInt = 0;
    if (timezone != null) {
      if (timezone.substring(0, 1) == '-') {
        timezoneInt = int.parse(timezone.substring(1, 2));
      } else {
        timezoneInt = -int.parse(timezone.substring(1, 2));
      }
    }
    try {
      date = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US').parse(pubDate);
    } catch (e) {
      try {
        date = DateFormat('dd MMM yyyy HH:mm:ss Z', 'en_US').parse(pubDate);
      } catch (e) {
        try {
          date = DateFormat('EEE, dd MMM yyyy HH:mm Z', 'en_US').parse(pubDate);
        } catch (e) {
          //parse date using regex, still have issue in parse maonth/day
          var year = yyyy.stringMatch(pubDate);
          var time = hhmm.stringMatch(pubDate);
          var month = ddmmm.stringMatch(pubDate);
          if (year != null && time != null && month != null) {
            date = DateFormat('dd MMM yyyy HH:mm', 'en_US')
                .parse(month + year + time);
          } else if (year != null && time != null && month == null) {
            var month = mmDd.stringMatch(pubDate);
            date =
                DateFormat('yyyy-MM-dd HH:mm', 'en_US').parse('$month $time');
            print(date.toString());
          } else {
            date = DateTime.now();
          }
        }
      }
    }
    var result = date
        .add(Duration(hours: timezoneInt))
        .add(DateTime.now().timeZoneOffset);
    return result;
  }

  int _getExplicit(bool b) {
    int result;
    if (b == true) {
      result = 1;
      return result;
    } else {
      result = 0;
      return result;
    }
  }

  bool _isXimalaya(String input) {
    var ximalaya = RegExp(r"ximalaya.com");
    return ximalaya.hasMatch(input);
  }

  String _getDescription(String content, String description, String summary) {
    if (content.length >= description.length) {
      if (content.length >= summary.length) {
        return content;
      } else {
        return summary;
      }
    } else if (description.length >= summary.length) {
      return description;
    } else {
      return summary;
    }
  }

  Future<int> savePodcastRss(RssFeed feed, String id) async {
    feed.items.removeWhere((item) => item == null);
    var result = feed.items.length;
    var dbClient = await database;
    String description, url;
    for (var i = 0; i < result; i++) {
      print(feed.items[i].title);
      description = _getDescription(feed.items[i]?.content?.value ?? '',
          feed.items[i].description ?? '', feed.items[i].itunes.summary ?? '');
      if (feed.items[i].enclosure != null) {
        _isXimalaya(feed.items[i].enclosure.url)
            ? url = feed.items[i].enclosure.url.split('=').last
            : url = feed.items[i].enclosure.url;
      }

      final title = feed.items[i].itunes.title ?? feed.items[i].title;
      final length = feed.items[i]?.enclosure?.length;
      final pubDate = feed.items[i].pubDate;
      final date = _parsePubDate(pubDate);
      print(date);
      final milliseconds = date.millisecondsSinceEpoch;
      final duration = feed.items[i].itunes.duration?.inSeconds ?? 0;
      final explicit = _getExplicit(feed.items[i].itunes.explicit);

      if (url != null) {
        await dbClient.transaction((txn) {
          return txn.rawInsert(
              """INSERT OR IGNORE INTO Episodes(title, enclosure_url, enclosure_length, pubDate, 
                description, feed_id, milliseconds, duration, explicit, media_id) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
              [
                title,
                url,
                length,
                pubDate,
                description,
                id,
                milliseconds,
                duration,
                explicit,
                url
              ]);
        });
      }
    }
    var countUpdate = Sqflite.firstIntValue(await dbClient
        .rawQuery('SELECT COUNT(*) FROM Episodes WHERE feed_id = ?', [id]));

    await dbClient.rawUpdate(
        """UPDATE PodcastLocal SET episode_count = ? WHERE id = ?""",
        [countUpdate, id]);
    return result;
  }

  Future<int> updatePodcastRss(PodcastLocal podcastLocal,
      {int removeMark = 0}) async {
    var options = BaseOptions(
      connectTimeout: 20000,
      receiveTimeout: 20000,
    );
    try {
      var response = await Dio(options).get(podcastLocal.rssUrl);
      if (response.statusCode == 200) {
        var feed = RssFeed.parse(response.data);
        String url, description;
        feed.items.removeWhere((item) => item == null);

        var dbClient = await database;
        var count = Sqflite.firstIntValue(await dbClient.rawQuery(
            'SELECT COUNT(*) FROM Episodes WHERE feed_id = ?',
            [podcastLocal.id]));
        if (removeMark == 0) {
          await dbClient.rawUpdate(
              "UPDATE Episodes SET is_new = 0 WHERE feed_id = ?",
              [podcastLocal.id]);
        }
        for (var item in feed.items) {
          print(item.title);
          description = _getDescription(item.content.value ?? '',
              item.description ?? '', item.itunes.summary ?? '');

          if (item.enclosure?.url != null) {
            _isXimalaya(item.enclosure.url)
                ? url = item.enclosure.url.split('=').last
                : url = item.enclosure.url;
          }

          final title = item.itunes.title ?? item.title;
          final length = item?.enclosure?.length ?? 0;
          final pubDate = item.pubDate;
          final date = _parsePubDate(pubDate);
          final milliseconds = date.millisecondsSinceEpoch;
          final duration = item.itunes.duration?.inSeconds ?? 0;
          final explicit = _getExplicit(item.itunes.explicit);

          if (url != null) {
            await dbClient.transaction((txn) async {
              await txn.rawInsert(
                  """INSERT OR IGNORE INTO Episodes(title, enclosure_url, enclosure_length, pubDate, 
                description, feed_id, milliseconds, duration, explicit, media_id, is_new) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)""",
                  [
                    title,
                    url,
                    length,
                    pubDate,
                    description,
                    podcastLocal.id,
                    milliseconds,
                    duration,
                    explicit,
                    url,
                  ]);
            });
          }
        }
        var countUpdate = Sqflite.firstIntValue(await dbClient.rawQuery(
            'SELECT COUNT(*) FROM Episodes WHERE feed_id = ?',
            [podcastLocal.id]));

        await dbClient.rawUpdate(
            """UPDATE PodcastLocal SET update_count = ?, episode_count = ? WHERE id = ?""",
            [countUpdate - count, countUpdate, podcastLocal.id]);
        return countUpdate - count;
      }
      return 0;
    } catch (e) {
      print(e);
      return -1;
    }
  }

  Future<List<EpisodeBrief>> getRssItem(String id, int count,
      {bool reverse,
      Filter filter = Filter.all,
      String query = '',
      bool hideListened = false}) async {
    var dbClient = await database;
    var episodes = <EpisodeBrief>[];
    var list = <Map>[];
    if (count == -1) {
      switch (filter) {
        case Filter.all:
          list = await dbClient
              .rawQuery("""SELECT E.title, E.enclosure_url, E.enclosure_length, 
        E.milliseconds, P.imagePath, P.title as feedTitle, E.duration, E.explicit, 
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        WHERE P.id = ? ORDER BY E.milliseconds ASC""", [id]);
          break;
        case Filter.liked:
          list = await dbClient
              .rawQuery("""SELECT E.title, E.enclosure_url, E.enclosure_length, 
        E.milliseconds, P.imagePath, P.title as feedTitle, E.duration, E.explicit, 
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        WHERE P.id = ? AND E.liked = 1 ORDER BY E.milliseconds ASC""", [id]);
          break;
        case Filter.downloaded:
          list = await dbClient.rawQuery(
              """SELECT E.title, E.enclosure_url, E.enclosure_length, 
        E.milliseconds, P.imagePath, P.title as feedTitle, E.duration, E.explicit, 
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        WHERE P.id = ? AND E.media_id != E.enclosure_url ORDER BY E.milliseconds ASC""",
              [id]);
          break;
        case Filter.search:
          list = await dbClient.rawQuery(
              """SELECT E.title, E.enclosure_url, E.enclosure_length, 
        E.milliseconds, P.imagePath, P.title as feedTitle, E.duration, E.explicit, 
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        WHERE P.id = ? AND E.title LIKE ? ORDER BY E.milliseconds ASC""",
              [id, '%$query%']);
          break;
        default:
      }
    } else if (reverse) {
      switch (filter) {
        case Filter.all:
          list = await dbClient
              .rawQuery("""SELECT E.title, E.enclosure_url, E.enclosure_length, 
        E.milliseconds, P.imagePath, P.title as feedTitle, E.duration, E.explicit, 
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        WHERE P.id = ? ORDER BY E.milliseconds ASC LIMIT ?""", [id, count]);
          break;
        case Filter.liked:
          list = await dbClient.rawQuery(
              """SELECT E.title, E.enclosure_url, E.enclosure_length, 
        E.milliseconds, P.imagePath, P.title as feedTitle, E.duration, E.explicit, 
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        WHERE P.id = ? AND E.liked = 1 ORDER BY E.milliseconds ASC LIMIT ?""",
              [id, count]);
          break;
        case Filter.downloaded:
          list = await dbClient.rawQuery(
              """SELECT E.title, E.enclosure_url, E.enclosure_length, 
        E.milliseconds, P.imagePath, P.title as feedTitle, E.duration, E.explicit, 
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        WHERE P.id = ? AND E.enclosure_url != E.media_id ORDER BY E.milliseconds ASC LIMIT ?""",
              [id, count]);
          break;
        case Filter.search:
          list = await dbClient.rawQuery(
              """SELECT E.title, E.enclosure_url, E.enclosure_length, 
        E.milliseconds, P.imagePath, P.title as feedTitle, E.duration, E.explicit, 
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        WHERE P.id = ? AND E.title LIKE ? ORDER BY E.milliseconds ASC LIMIT ?""",
              [id, '%$query%', count]);
          break;
        default:
      }
    } else {
      switch (filter) {
        case Filter.all:
          list = await dbClient.rawQuery(
              """SELECT E.title, E.enclosure_url, E.enclosure_length, E.is_new,
        E.milliseconds, P.imagePath, P.title as feedTitle, E.duration, E.explicit, 
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        WHERE P.id = ? ORDER BY E.milliseconds DESC LIMIT ?""", [id, count]);
          break;
        case Filter.liked:
          list = await dbClient.rawQuery(
              """SELECT E.title, E.enclosure_url, E.enclosure_length, E.is_new,
        E.milliseconds, P.imagePath, P.title as feedTitle, E.duration, E.explicit, 
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        WHERE P.id = ? AND E.liked = 1 ORDER BY E.milliseconds DESC LIMIT ?""",
              [id, count]);
          break;
        case Filter.downloaded:
          list = await dbClient.rawQuery(
              """SELECT E.title, E.enclosure_url, E.enclosure_length, E.is_new,
        E.milliseconds, P.imagePath, P.title as feedTitle, E.duration, E.explicit, 
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        WHERE P.id = ? AND E.enclosure_url != E.media_id ORDER BY E.milliseconds DESC LIMIT ?""",
              [id, count]);
          break;
        case Filter.search:
          list = await dbClient.rawQuery(
              """SELECT E.title, E.enclosure_url, E.enclosure_length, E.is_new,
        E.milliseconds, P.imagePath, P.title as feedTitle, E.duration, E.explicit, 
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        WHERE P.id = ? AND  E.title LIKE ? ORDER BY E.milliseconds DESC LIMIT ?""",
              [id, '%$query%', count]);
          break;
        default:
      }
    }
    if (list.isNotEmpty) {
      if (!hideListened) {
        for (var i in list) {
          episodes.add(EpisodeBrief(
              i['title'],
              i['enclosure_url'],
              i['enclosure_length'],
              i['milliseconds'],
              i['feedTitle'],
              i['primaryColor'],
              i['duration'],
              i['explicit'],
              i['imagePath'],
              i['is_new']));
        }
      } else {
        for (var i in list) {
          var listened = await isListened(i['enclosure_url']);
          if (listened == 0) {
            episodes.add(EpisodeBrief(
                i['title'],
                i['enclosure_url'],
                i['enclosure_length'],
                i['milliseconds'],
                i['feedTitle'],
                i['primaryColor'],
                i['duration'],
                i['explicit'],
                i['imagePath'],
                i['is_new']));
          }
        }
      }
    }
    return episodes;
  }

  Future<List<EpisodeBrief>> getNewEpisodes(String id) async {
    var dbClient = await database;
    var episodes = <EpisodeBrief>[];
    List<Map> list;
    if (id == 'all') {
      list = await dbClient.rawQuery(
        """SELECT E.title, E.enclosure_url, E.enclosure_length, E.is_new,
        E.milliseconds, P.imagePath, P.title as feed_title, E.duration, E.explicit, 
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id 
        WHERE E.is_new = 1 AND E.downloaded = 'ND' AND P.auto_download = 1 ORDER BY E.milliseconds ASC""",
      );
    } else {
      list = await dbClient.rawQuery(
          """SELECT E.title, E.enclosure_url, E.enclosure_length, E.is_new,
        E.milliseconds, P.imagePath, P.title as feed_title, E.duration, E.explicit, 
       P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id 
        WHERE E.is_new = 1 AND E.downloaded = 'ND' AND E.feed_id = ? ORDER BY E.milliseconds ASC""",
          [id]);
    }
    if (list.isNotEmpty) {
      for (var i in list) {
        episodes.add(EpisodeBrief(
            i['title'],
            i['enclosure_url'],
            i['enclosure_length'],
            i['milliseconds'],
            i['feed_title'],
            i['primaryColor'],
            i['duration'],
            i['explicit'],
            i['imagePath'],
            i['is_new']));
      }
    }
    return episodes;
  }

  Future<List<EpisodeBrief>> getRssItemTop(String id) async {
    var dbClient = await database;
    var episodes = <EpisodeBrief>[];
    List<Map> list = await dbClient.rawQuery(
        """SELECT E.title, E.enclosure_url, E.enclosure_length, E.is_new,
        E.milliseconds, P.imagePath, P.title as feed_title, E.duration, E.explicit, 
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id 
        where E.feed_id = ? ORDER BY E.milliseconds DESC LIMIT 2""", [id]);
    for (var i in list) {
      episodes.add(EpisodeBrief(
          i['title'],
          i['enclosure_url'],
          i['enclosure_length'],
          i['milliseconds'],
          i['feed_title'],
          i['primaryColor'],
          i['duration'],
          i['explicit'],
          i['imagePath'],
          i['is_new']));
    }
    return episodes;
  }

  Future<List<EpisodeBrief>> getRecentRssItem(int top) async {
    var dbClient = await database;
    var episodes = <EpisodeBrief>[];
    List<Map> list = await dbClient.rawQuery(
        """SELECT E.title, E.enclosure_url, E.enclosure_length, E.is_new,
        E.milliseconds, P.title as feed_title, E.duration, E.explicit, 
        P.imagePath, P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        ORDER BY E.milliseconds DESC LIMIT ? """, [top]);
    for (var i in list) {
      episodes.add(EpisodeBrief(
          i['title'],
          i['enclosure_url'],
          i['enclosure_length'],
          i['milliseconds'],
          i['feed_title'],
          i['primaryColor'],
          i['duration'],
          i['explicit'],
          i['imagePath'],
          i['is_new']));
    }
    return episodes;
  }

  Future<List<EpisodeBrief>> getGroupRssItem(
      int top, List<String> group) async {
    var dbClient = await database;
    var episodes = <EpisodeBrief>[];
    if (group.length > 0) {
      var s = group.map<String>((e) => "'$e'").toList();
      List<Map> list = await dbClient.rawQuery(
          """SELECT E.title, E.enclosure_url, E.enclosure_length, E.is_new,
        E.milliseconds, P.title as feed_title, E.duration, E.explicit, 
        P.imagePath, P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id 
        WHERE P.id in (${s.join(',')})
        ORDER BY E.milliseconds DESC LIMIT ? """, [top]);
      for (var i in list) {
        episodes.add(EpisodeBrief(
            i['title'],
            i['enclosure_url'],
            i['enclosure_length'],
            i['milliseconds'],
            i['feed_title'],
            i['primaryColor'],
            i['duration'],
            i['explicit'],
            i['imagePath'],
            i['is_new']));
      }
    }
    return episodes;
  }

  Future<List<EpisodeBrief>> getRecentNewRssItem() async {
    var dbClient = await database;
    var episodes = <EpisodeBrief>[];
    List<Map> list = await dbClient.rawQuery(
      """SELECT E.title, E.enclosure_url, E.enclosure_length, E.is_new, E.media_id,
        E.milliseconds, P.title as feed_title, E.duration, E.explicit, 
        P.imagePath, P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        WHERE is_new = 1 ORDER BY E.milliseconds DESC  """,
    );
    for (var i in list) {
      episodes.add(EpisodeBrief(
          i['title'],
          i['enclosure_url'],
          i['enclosure_length'],
          i['milliseconds'],
          i['feed_title'],
          i['primaryColor'],
          i['duration'],
          i['explicit'],
          i['imagePath'],
          i['is_new'],
          mediaId: i['media_id']));
    }
    return episodes;
  }

  Future<List<EpisodeBrief>> getOutdatedEpisode(int deadline) async {
    var dbClient = await database;
    var episodes = <EpisodeBrief>[];
    List<Map> list = await dbClient.rawQuery(
        """SELECT E.title, E.enclosure_url, E.enclosure_length, E.is_new,
        E.milliseconds, P.title as feed_title, E.duration, E.explicit, 
        P.imagePath, P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id 
        WHERE E.download_date < ? AND E.enclosure_url != E.media_id
        ORDER BY E.milliseconds DESC""", [deadline]);
    for (var i in list) {
      episodes.add(EpisodeBrief(
          i['title'],
          i['enclosure_url'],
          i['enclosure_length'],
          i['milliseconds'],
          i['feed_title'],
          i['primaryColor'],
          i['duration'],
          i['explicit'],
          i['imagePath'],
          i['is_new']));
    }
    return episodes;
  }

  Future<List<EpisodeBrief>> getDownloadedEpisode(int mode) async {
    var dbClient = await database;
    var episodes = <EpisodeBrief>[];
    List<Map> list;
    //Ordered by date
    if (mode == 0) {
      list = await dbClient.rawQuery(
        """SELECT E.title, E.enclosure_url, E.enclosure_length, E.download_date, E.is_new,
        E.milliseconds, P.title as feed_title, E.duration, E.explicit, 
        P.imagePath, P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id 
        WHERE E.enclosure_url != E.media_id
        ORDER BY E.download_date DESC""",
      );
    } else if (mode == 1) {
      list = await dbClient.rawQuery(
        """SELECT E.title, E.enclosure_url, E.enclosure_length, E.download_date,E.is_new,
        E.milliseconds, P.title as feed_title, E.duration, E.explicit, 
        P.imagePath, P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id 
        WHERE E.enclosure_url != E.media_id
        ORDER BY E.download_date ASC""",
      );
    } else if (mode == 2) {
      list = await dbClient.rawQuery(
        """SELECT E.title, E.enclosure_url, E.enclosure_length, E.download_date,E.is_new,
        E.milliseconds, P.title as feed_title, E.duration, E.explicit, 
        P.imagePath, P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id 
        WHERE E.enclosure_url != E.media_id
        ORDER BY E.enclosure_length DESC""",
      );
    }
    for (var i in list) {
      episodes.add(
        EpisodeBrief(
            i['title'],
            i['enclosure_url'],
            i['enclosure_length'],
            i['milliseconds'],
            i['feed_title'],
            i['primaryColor'],
            i['duration'],
            i['explicit'],
            i['imagePath'],
            i['is_new'],
            downloadDate: i['download_date']),
      );
    }
    return episodes;
  }

  removeAllNewMark() async {
    var dbClient = await database;
    await dbClient.transaction((txn) async {
      await txn.rawUpdate("UPDATE Episodes SET is_new = 0 ");
    });
  }

  Future<List<EpisodeBrief>> getGroupNewRssItem(List<String> group) async {
    var dbClient = await database;
    var episodes = <EpisodeBrief>[];
    if (group.length > 0) {
      var s = group.map<String>((e) => "'$e'").toList();
      List<Map> list = await dbClient.rawQuery(
        """SELECT E.title, E.enclosure_url, E.enclosure_length, E.is_new, E.media_id,
        E.milliseconds, P.title as feed_title, E.duration, E.explicit, 
        P.imagePath, P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id 
        WHERE P.id in (${s.join(',')}) AND is_new = 1
        ORDER BY E.milliseconds DESC""",
      );
      for (var i in list) {
        episodes.add(EpisodeBrief(
            i['title'],
            i['enclosure_url'],
            i['enclosure_length'],
            i['milliseconds'],
            i['feed_title'],
            i['primaryColor'],
            i['duration'],
            i['explicit'],
            i['imagePath'],
            i['is_new'],
            mediaId: i['media_id']));
      }
    }
    return episodes;
  }

  removeGroupNewMark(List<String> group) async {
    var dbClient = await database;
    if (group.length > 0) {
      var s = group.map<String>((e) => "'$e'").toList();
      await dbClient.transaction((txn) async {
        await txn.rawUpdate(
            "UPDATE Episodes SET is_new = 0 WHERE feed_id in (${s.join(',')})");
      });
    }
  }

  removeEpisodeNewMark(String url) async {
    var dbClient = await database;
    await dbClient.transaction((txn) async {
      await txn.rawUpdate(
          "UPDATE Episodes SET is_new = 0 WHERE enclosure_url = ?", [url]);
    });
    print('remove new episode');
  }

  Future<List<EpisodeBrief>> getLikedRssItem(int i, int sortBy) async {
    var dbClient = await database;
    var episodes = <EpisodeBrief>[];
    if (sortBy == 0) {
      List<Map> list = await dbClient.rawQuery(
          """SELECT E.title, E.enclosure_url, E.enclosure_length, E.milliseconds, P.imagePath,
        P.title as feed_title, E.duration, E.explicit, P.primaryColor, E.is_new
         FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        WHERE E.liked = 1 ORDER BY E.milliseconds DESC LIMIT ?""", [i]);
      for (var i in list) {
        episodes.add(EpisodeBrief(
            i['title'],
            i['enclosure_url'],
            i['enclosure_length'],
            i['milliseconds'],
            i['feed_title'],
            i['primaryColor'],
            i['duration'],
            i['explicit'],
            i['imagePath'],
            i['is_new']));
      }
    } else {
      List<Map> list = await dbClient.rawQuery(
          """SELECT E.title, E.enclosure_url, E.enclosure_length, E.milliseconds, P.imagePath,
        P.title as feed_title, E.duration, E.explicit, P.primaryColor, E.is_new
        FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        WHERE E.liked = 1 ORDER BY E.liked_date DESC LIMIT ?""", [i]);
      for (var i in list) {
        episodes.add(EpisodeBrief(
            i['title'],
            i['enclosure_url'],
            i['enclosure_length'],
            i['milliseconds'],
            i['feed_title'],
            i['primaryColor'],
            i['duration'],
            i['explicit'],
            i['imagePath'],
            i['is_new']));
      }
    }
    return episodes;
  }

  setLiked(String url) async {
    var dbClient = await database;
    var milliseconds = DateTime.now().millisecondsSinceEpoch;
    await dbClient.transaction((txn) async {
      await txn.rawUpdate(
          "UPDATE Episodes SET liked = 1, liked_date = ? WHERE enclosure_url= ?",
          [milliseconds, url]);
    });
  }

  setUniked(String url) async {
    var dbClient = await database;
    await dbClient.transaction((txn) async {
      await txn.rawUpdate(
          "UPDATE Episodes SET liked = 0 WHERE enclosure_url = ?", [url]);
    });
  }

  Future<bool> isLiked(String url) async {
    var dbClient = await database;
    List<Map> list = await dbClient
        .rawQuery("SELECT liked FROM Episodes WHERE enclosure_url = ?", [url]);
    return list.first['liked'] == 0 ? false : true;
  }

  Future<bool> isDownloaded(String url) async {
    var dbClient = await database;
    List<Map> list = await dbClient.rawQuery(
        "SELECT id FROM Episodes WHERE enclosure_url = ? AND enclosure_url != media_id",
        [url]);
    return list.isNotEmpty;
  }

  Future<int> saveDownloaded(String url, String id) async {
    var dbClient = await database;
    var milliseconds = DateTime.now().millisecondsSinceEpoch;
    int count;
    await dbClient.transaction((txn) async {
      count = await txn.rawUpdate(
          "UPDATE Episodes SET downloaded = ?, download_date = ? WHERE enclosure_url = ?",
          [id, milliseconds, url]);
    });
    return count;
  }

  Future<int> saveMediaId(String url, String path, String id, int size) async {
    var dbClient = await database;
    var milliseconds = DateTime.now().millisecondsSinceEpoch;
    int count;
    await dbClient.transaction((txn) async {
      count = await txn.rawUpdate(
          "UPDATE Episodes SET enclosure_length = ?, media_id = ?, download_date = ?, downloaded = ? WHERE enclosure_url = ?",
          [size, path, milliseconds, id, url]);
    });
    return count;
  }

  Future<int> delDownloaded(String url) async {
    var dbClient = await database;
    int count;
    await dbClient.transaction((txn) async {
      count = await txn.rawUpdate(
          "UPDATE Episodes SET downloaded = 'ND', media_id = ? WHERE enclosure_url = ?",
          [url, url]);
    });
    print('Deleted $url');
    return count;
  }

  Future<String> getDescription(String url) async {
    var dbClient = await database;
    List<Map> list = await dbClient.rawQuery(
        'SELECT description FROM Episodes WHERE enclosure_url = ?', [url]);
    String description = list[0]['description'];
    return description;
  }

  Future<String> getFeedDescription(String id) async {
    var dbClient = await database;
    List<Map> list = await dbClient
        .rawQuery('SELECT description FROM PodcastLocal WHERE id = ?', [id]);
    String description = list[0]['description'];
    return description;
  }

  Future<EpisodeBrief> getRssItemWithUrl(String url) async {
    var dbClient = await database;
    EpisodeBrief episode;
    List<Map> list = await dbClient.rawQuery(
        """SELECT E.title, E.enclosure_url, E.enclosure_length, E.milliseconds, P.imagePath,
        P.title as feed_title, E.duration, E.explicit, P.skip_seconds,E.is_new,
        P.primaryColor, E.media_id FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id 
        WHERE E.enclosure_url = ?""", [url]);
    if (list.isEmpty) {
      return null;
    } else {
      episode = EpisodeBrief(
          list.first['title'],
          list.first['enclosure_url'],
          list.first['enclosure_length'],
          list.first['milliseconds'],
          list.first['feed_title'],
          list.first['primaryColor'],
          list.first['duration'],
          list.first['explicit'],
          list.first['imagePath'],
          list.first['is_new'],
          mediaId: list.first['media_id'],
          skipSeconds: list.first['skip_seconds']);
      return episode;
    }
  }

  Future<EpisodeBrief> getRssItemWithMediaId(String id) async {
    var dbClient = await database;
    EpisodeBrief episode;
    List<Map> list = await dbClient.rawQuery(
        """SELECT E.title, E.enclosure_url, E.enclosure_length, E.milliseconds, P.imagePath,
        P.title as feed_title, E.duration, E.explicit, P.skip_seconds,E.is_new,
        P.primaryColor, E.media_id FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id 
        WHERE E.media_id = ?""", [id]);
    if (list.isEmpty) {
      return null;
    } else {
      episode = EpisodeBrief(
          list.first['title'],
          list.first['enclosure_url'],
          list.first['enclosure_length'],
          list.first['milliseconds'],
          list.first['feed_title'],
          list.first['primaryColor'],
          list.first['duration'],
          list.first['explicit'],
          list.first['imagePath'],
          list.first['is_new'],
          mediaId: list.first['media_id'],
          skipSeconds: list.first['skip_seconds']);
      return episode;
    }
  }

  Future<String> getImageUrl(String url) async {
    var dbClient = await database;
    List<Map> list = await dbClient.rawQuery(
        """SELECT P.imageUrl FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id 
        WHERE E.enclosure_url = ?""", [url]);
    if (list.isEmpty) return null;
    return list.first["imageUrl"];
  }
}
