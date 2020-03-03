import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:dio/dio.dart';
import 'package:tsacdop/class/podcastlocal.dart';
import 'package:tsacdop/class/audiostate.dart';
import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/webfeed/webfeed.dart';

class DBHelper {
  static Database _db;
  Future<Database> get database async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    var documentsDirectory = await getDatabasesPath();
    String path = join(documentsDirectory, "podcasts.db");
    Database theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    await db
        .execute("""CREATE TABLE PodcastLocal(id TEXT PRIMARY KEY,title TEXT, 
        imageUrl TEXT,rssUrl TEXT UNIQUE,primaryColor TEXT,author TEXT, 
        description TEXT, add_date INTEGER, imagePath TEXT, provider TEXT, link TEXT, 
        background_image TEXT DEFAULT '',hosts TEXT DEFAULT '')""");
    await db
        .execute("""CREATE TABLE Episodes(id INTEGER PRIMARY KEY,title TEXT, 
        enclosure_url TEXT UNIQUE, enclosure_length INTEGER, pubDate TEXT, 
        description TEXT, feed_id TEXT, feed_link TEXT, milliseconds INTEGER, 
        duration INTEGER DEFAULT 0, explicit INTEGER DEFAULT 0, liked INTEGER DEFAULT 0, 
        downloaded TEXT DEFAULT 'ND', download_date INTEGER DEFAULT 0)""");
    await db.execute(
        """CREATE TABLE PlayHistory(id INTEGER PRIMARY KEY, title TEXT, enclosure_url TEXT UNIQUE,
        seconds REAL, seek_value REAL, add_date INTEGER)""");
  }

  Future<List<PodcastLocal>> getPodcastLocal(List<String> podcasts) async {
    var dbClient = await database;
    List<PodcastLocal> podcastLocal = List();
    await Future.forEach(podcasts, (s) async {
      List<Map> list;
      list = await dbClient.rawQuery(
          'SELECT id, title, imageUrl, rssUrl, primaryColor, author, imagePath , provider, link FROM PodcastLocal WHERE id = ?',
          [s]);
      podcastLocal.add(PodcastLocal(
          list.first['title'],
          list.first['imageUrl'],
          list.first['rssUrl'],
          list.first['primaryColor'],
          list.first['author'],
          list.first['id'],
          list.first['imagePath'],
          list.first['provider'],
          list.first['link']));
    });
    return podcastLocal;
  }

  Future<List<PodcastLocal>> getPodcastLocalAll() async {
    var dbClient = await database;
    List<Map> list = await dbClient.rawQuery(
        'SELECT id, title, imageUrl, rssUrl, primaryColor, author, imagePath, provider, link FROM PodcastLocal ORDER BY add_date DESC');

    List<PodcastLocal> podcastLocal = List();

    for (int i = 0; i < list.length; i++) {
      podcastLocal.add(PodcastLocal(
          list[i]['title'],
          list[i]['imageUrl'],
          list[i]['rssUrl'],
          list[i]['primaryColor'],
          list[i]['author'],
          list[i]['id'],
          list[i]['imagePath'],
          list.first['provider'],
          list.first['link']));
    }
    return podcastLocal;
  }

  Future<bool> checkPodcast(String url) async {
    var dbClient = await database;
    List<Map> list = await dbClient
        .rawQuery('SELECT id FROM PodcastLocal WHERE rssUrl = ?', [url]);
    return list.length == 0;
  }

  Future savePodcastLocal(PodcastLocal podcastLocal) async {
    print('podcast saved in sqllite');
    int _milliseconds = DateTime.now().millisecondsSinceEpoch;
    var dbClient = await database;
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
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
    });
  }

  Future<int> saveFiresideData(List<String> list) async {
    var dbClient = await database;
    int result = await dbClient.rawUpdate(
        'UPDATE PodcastLocal SET background_image = ? , hosts = ? WHERE id = ?',
        [list[1], list[2], list[0]]);
    print('Fireside data save in sqllite');
    return result;
  }

  Future<List<String>> getFiresideData(String id) async {
    var dbClient = await database;
    List<Map> list = await dbClient.rawQuery(
        'SELECT background_image, hosts FROM PodcastLocal WHERE id = ?', [id]);
    List<String> data = [list.first['background_image'], list.first['hosts']];
    return data;
  }

  Future delPodcastLocal(String id) async {
    var dbClient = await database;
    await dbClient.rawDelete('DELETE FROM PodcastLocal WHERE id =?', [id]);
    List<Map> list = await dbClient.rawQuery(
        """SELECT downloaded FROM Episodes WHERE downloaded != 'ND' AND feed_id = ?""",
        [id]);
    for (int i = 0; i < list.length; i++) {
      if (list[i] != null)
        FlutterDownloader.remove(
            taskId: list[i]['downloaded'], shouldDeleteContent: true);
      print('Removed all download tasks');
    }
    await dbClient.rawDelete('DELETE FROM Episodes WHERE feed_id=?', [id]);
  }

  Future<int> saveHistory(PlayHistory history) async {
    var dbClient = await database;
    int _milliseconds = DateTime.now().millisecondsSinceEpoch;
    int result = await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          """REPLACE INTO PlayHistory (title, enclosure_url, seconds, seek_value, add_date)
       VALUES (?, ?, ?, ?, ?) """,
          [
            history.title,
            history.url,
            history.seconds,
            history.seekValue,
            _milliseconds
          ]);
    });
    return result;
  }

  Future<List<PlayHistory>> getPlayHistory() async {
    var dbClient = await database;
    List<Map> list = await dbClient.rawQuery(
        """SELECT title, enclosure_url, seconds, seek_value, add_date FROM PlayHistory
         ORDER BY add_date DESC 
     """);
    List<PlayHistory> playHistory = [];
    list.forEach((record) {
      playHistory.add(PlayHistory(
        record['title'],
        record['enclosure_url'],
        record['seconds'],
        record['seek_value'],
      ));
    });
    return playHistory;
  }

  Future<int> getPosition(EpisodeBrief episodeBrief) async {
    var dbClient = await database;
    List<Map> list = await dbClient.rawQuery(
        "SELECT seconds FROM PlayHistory Where enclosure_url = ?",
        [episodeBrief.enclosureUrl]);
    return list.length > 0 ? list.first['seconds'] : 0;
  }

  DateTime _parsePubDate(String pubDate) {
    if (pubDate == null) return DateTime.now();
    print(pubDate);
    DateTime date;
    RegExp yyyy = RegExp(r'[1-2][0-9]{3}');
    RegExp hhmm = RegExp(r'[0-2][0-9]\:[0-5][0-9]');
    RegExp ddmmm = RegExp(r'[0-3][0-9]\s[A-Z][a-z]{2}');
    RegExp mmDd = RegExp(r'([0-1]|\s)[0-9]\-[0-3][0-9]');
    try {
      date = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US').parse(pubDate);
    } catch (e) {
      try {
        date = DateFormat('dd MMM yyyy HH:mm:ss Z', 'en_US').parse(pubDate);
      } catch (e) {
        try {
          date = DateFormat('EEE, dd MMM yyyy HH:mm Z', 'en_US').parse(pubDate);
        } catch (e) {
          //parse date using regex, bug in parse maonth/day
          String year = yyyy.stringMatch(pubDate);
          String time = hhmm.stringMatch(pubDate);
          String month = ddmmm.stringMatch(pubDate);
          if (year != null && time != null && month != null) {
            date = DateFormat('dd MMM yyyy HH:mm', 'en_US')
                .parse(month + year + time);
          } else if (year != null && time != null && month == null) {
            String month = mmDd.stringMatch(pubDate);
            date = DateFormat('mm-dd yyyy HH:mm', 'en_US')
                .parse(month + ' ' + year + ' ' + time);
          } else {
            date = DateTime.now();
          }
        }
      }
    }
    return date;
  }

  int getExplicit(bool b) {
    int result;
    if (b == true) {
      result = 1;
      return result;
    } else {
      result = 0;
      return result;
    }
  }

  bool isXimalaya(String input) {
    RegExp ximalaya = RegExp(r"ximalaya.com");
    return ximalaya.hasMatch(input);
  }

  Future<int> savePodcastRss(RssFeed _p, String id) async {
    int _result = _p.items.length;
    var dbClient = await database;
    String _description, _url;
    for (int i = 0; i < _result; i++) {
      print(_p.items[i].title);
      if (_p.items[i].itunes.summary != null) {
        _p.items[i].itunes.summary.contains('<')
            ? _description = _p.items[i].itunes.summary
            : _description = _p.items[i].description;
      } else {
        _description = _p.items[i].description;
      }

      isXimalaya(_p.items[i].enclosure.url)
          ? _url = _p.items[i].enclosure.url.split('=').last
          : _url = _p.items[i].enclosure.url;

      final _title = _p.items[i].itunes.title ?? _p.items[i].title;
      final _length = _p.items[i].enclosure.length;
      final _pubDate = _p.items[i].pubDate;
      print(_pubDate);
      final _date = _parsePubDate(_pubDate);
      final _milliseconds = _date.millisecondsSinceEpoch;
      final _duration = _p.items[i].itunes.duration?.inMinutes ?? 0;
      final _explicit = getExplicit(_p.items[i].itunes.explicit);

      if (_url != null) {
        await dbClient.transaction((txn) {
          return txn.rawInsert(
              """INSERT OR IGNORE INTO Episodes(title, enclosure_url, enclosure_length, pubDate, 
                description, feed_id, milliseconds, duration, explicit) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)""",
              [
                _title,
                _url,
                _length,
                _pubDate,
                _description,
                id,
                _milliseconds,
                _duration,
                _explicit,
              ]);
        });
      }
    }
    return _result;
  }

  Future<int> updatePodcastRss(PodcastLocal podcastLocal) async {
    Response response = await Dio().get(podcastLocal.rssUrl);
    var _p = RssFeed.parse(response.data);
    String _url, _description;
    int _result = _p.items.length;
    var dbClient = await database;
    int _count = Sqflite.firstIntValue(await dbClient.rawQuery(
        'SELECT COUNT(*) FROM Episodes WHERE feed_id = ?', [podcastLocal.id]));
    print(_count);
    if (_count == _result) {
      _result = 0;
      return _result;
    } else {
      for (int i = 0; i < (_result - _count); i++) {
        print(_p.items[i].title);
        if (_p.items[i].itunes.summary != null) {
          _p.items[i].itunes.summary.contains('<')
              ? _description = _p.items[i].itunes.summary
              : _description = _p.items[i].description;
        } else {
          _description = _p.items[i].description;
        }

        isXimalaya(_p.items[i].enclosure.url)
            ? _url = _p.items[i].enclosure.url.split('=').last
            : _url = _p.items[i].enclosure.url;

        final _title = _p.items[i].itunes.title ?? _p.items[i].title;
        final _length = _p.items[i].enclosure.length;
        final _pubDate = _p.items[i].pubDate;
        final _date = _parsePubDate(_pubDate);
        final _milliseconds = _date.millisecondsSinceEpoch;
        final _duration = _p.items[i].itunes.duration?.inMinutes ?? 0;
        final _explicit = getExplicit(_p.items[i].itunes.explicit);

        if (_url != null) {
          await dbClient.transaction((txn) {
            return txn.rawInsert(
                """INSERT OR IGNORE INTO Episodes(title, enclosure_url, enclosure_length, pubDate, 
                description, feed_id, milliseconds, duration, explicit) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                [
                  _title,
                  _url,
                  _length,
                  _pubDate,
                  _description,
                  podcastLocal.id,
                  _milliseconds,
                  _duration,
                  _explicit,
                ]);
          });
        }
      }
      return _result - _count;
    }
  }

  Future<List<EpisodeBrief>> getRssItem(String id) async {
    var dbClient = await database;
    List<EpisodeBrief> episodes = [];
    List<Map> list = await dbClient
        .rawQuery("""SELECT E.title, E.enclosure_url, E.enclosure_length, 
        E.milliseconds, P.imagePath, P.title as feedTitle, E.duration, E.explicit, E.liked, 
        E.downloaded,  P.primaryColor 
        FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        WHERE P.id = ? ORDER BY E.milliseconds DESC""", [id]);
    for (int x = 0; x < list.length; x++) {
      episodes.add(EpisodeBrief(
          list[x]['title'],
          list[x]['enclosure_url'],
          list[x]['enclosure_length'],
          list[x]['milliseconds'],
          list[x]['feedTitle'],
          list[x]['primaryColor'],
          list[x]['liked'],
          list[x]['downloaded'],
          list[x]['duration'],
          list[x]['explicit'],
          list[x]['imagePath']));
    }
    return episodes;
  }

  Future<List<EpisodeBrief>> getRssItemTop(String id) async {
    var dbClient = await database;
    List<EpisodeBrief> episodes = List();
    List<Map> list = await dbClient
        .rawQuery("""SELECT E.title, E.enclosure_url, E.enclosure_length, 
        E.milliseconds, P.imagePath, P.title as feed_title, E.duration, E.explicit, E.liked, 
        E.downloaded, P.primaryColor 
        FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id 
        where E.feed_id = ? ORDER BY E.milliseconds DESC LIMIT 3""", [id]);
    for (int x = 0; x < list.length; x++) {
      episodes.add(EpisodeBrief(
          list[x]['title'],
          list[x]['enclosure_url'],
          list[x]['enclosure_length'],
          list[x]['milliseconds'],
          list[x]['feed_title'],
          list[x]['primaryColor'],
          list[x]['liked'],
          list[x]['downloaded'],
          list[x]['duration'],
          list[x]['explicit'],
          list[x]['imagePath']));
    }
    return episodes;
  }

  Future<EpisodeBrief> getRssItemDownload(String url) async {
    var dbClient = await database;
    EpisodeBrief episode;
    List<Map> list = await dbClient.rawQuery(
        """SELECT E.title, E.enclosure_url, E.enclosure_length, 
        E.milliseconds, P.imagePath, P.title as feed_title, E.duration, E.explicit, E.liked, 
        E.downloaded,  P.primaryColor 
        FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        where E.enclosure_url = ? ORDER BY E.milliseconds DESC LIMIT 3""",
        [url]);

    if (list != null)
      episode = EpisodeBrief(
          list.first['title'],
          list.first['enclosure_url'],
          list.first['enclosure_length'],
          list.first['milliseconds'],
          list.first['feed_title'],
          list.first['primaryColor'],
          list.first['liked'],
          list.first['downloaded'],
          list.first['duration'],
          list.first['explicit'],
          list.first['imagePath']);
    return episode;
  }

  Future<List<EpisodeBrief>> getRecentRssItem() async {
    var dbClient = await database;
    List<EpisodeBrief> episodes = List();
    List<Map> list = await dbClient
        .rawQuery("""SELECT E.title, E.enclosure_url, E.enclosure_length, 
        E.milliseconds, P.title as feed_title, E.duration, E.explicit, E.liked, 
        E.downloaded, P.imagePath, P.primaryColor 
        FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        ORDER BY E.milliseconds DESC LIMIT 99""");
    for (int x = 0; x < list.length; x++) {
      episodes.add(EpisodeBrief(
          list[x]['title'],
          list[x]['enclosure_url'],
          list[x]['enclosure_length'],
          list[x]['milliseconds'],
          list[x]['feed_title'],
          list[x]['primaryColor'],
          list[x]['liked'],
          list[x]['doanloaded'],
          list[x]['duration'],
          list[x]['explicit'],
          list[x]['imagePath']));
    }
    return episodes;
  }

  Future<List<EpisodeBrief>> getLikedRssItem() async {
    var dbClient = await database;
    List<EpisodeBrief> episodes = List();
    List<Map> list = await dbClient.rawQuery(
        """SELECT E.title, E.enclosure_url, E.enclosure_length, E.milliseconds, P.imagePath,
        P.title as feed_title, E.duration, E.explicit, E.liked, E.downloaded, 
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        WHERE E.liked = 1 ORDER BY E.milliseconds DESC LIMIT 99""");
    for (int x = 0; x < list.length; x++) {
      episodes.add(EpisodeBrief(
          list[x]['title'],
          list[x]['enclosure_url'],
          list[x]['enclosure_length'],
          list[x]['milliseconds'],
          list[x]['feed_title'],
          list[x]['primaryColor'],
          list[x]['liked'],
          list[x]['downloaded'],
          list[x]['duration'],
          list[x]['explicit'],
          list[x]['imagePath']));
    }
    return episodes;
  }

  Future<int> setLiked(String url) async {
    var dbClient = await database;
    int count = await dbClient.rawUpdate(
        "UPDATE Episodes SET liked = 1 WHERE enclosure_url= ?", [url]);
    print('liked');
    return count;
  }

  Future<int> setUniked(String url) async {
    var dbClient = await database;
    int count = await dbClient.rawUpdate(
        "UPDATE Episodes SET liked = 0 WHERE enclosure_url = ?", [url]);
    print('unliked');
    return count;
  }

  Future<int> saveDownloaded(String url, String id) async {
    var dbClient = await database;
    int _milliseconds = DateTime.now().millisecondsSinceEpoch;
    int count = await dbClient.rawUpdate(
        "UPDATE Episodes SET downloaded = ?, download_date = ? WHERE enclosure_url = ?",
        [id, _milliseconds, url]);
    return count;
  }

  Future<int> delDownloaded(String url) async {
    var dbClient = await database;
    int count = await dbClient.rawUpdate(
        "UPDATE Episodes SET downloaded = 'ND' WHERE enclosure_url = ?", [url]);
    print('Deleted ' + url);
    return count;
  }

  Future<List<EpisodeBrief>> getDownloadedRssItem() async {
    var dbClient = await database;
    List<EpisodeBrief> episodes = List();
    List<Map> list = await dbClient.rawQuery(
        """SELECT E.title, E.enclosure_url, E.enclosure_length, E.milliseconds, P.imagePath,
        P.title as feed_title, E.duration, E.explicit, E.liked, E.downloaded,  
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id
        WHERE E.downloaded != 'ND' ORDER BY E.download_date DESC LIMIT 99""");
    for (int x = 0; x < list.length; x++) {
      episodes.add(EpisodeBrief(
          list[x]['title'],
          list[x]['enclosure_url'],
          list[x]['enclosure_length'],
          list[x]['milliseconds'],
          list[x]['feed_title'],
          list[x]['primaryColor'],
          list[x]['liked'],
          list[x]['downloaded'],
          list[x]['duration'],
          list[x]['explicit'],
          list[x]['imagePath']));
    }
    return episodes;
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
        P.title as feed_title, E.duration, E.explicit, E.liked, E.downloaded,  
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_id = P.id 
        WHERE E.enclosure_url = ?""", [url]);
    episode = EpisodeBrief(
        list.first['title'],
        list.first['enclosure_url'],
        list.first['enclosure_length'],
        list.first['milliseconds'],
        list.first['feed_title'],
        list.first['primaryColor'],
        list.first['liked'],
        list.first['downloaded'],
        list.first['duration'],
        list.first['explicit'],
        list.first['imagePath']);
    return episode;
  }
}
