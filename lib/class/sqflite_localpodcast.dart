import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'podcastlocal.dart';
import 'episodebrief.dart';
import 'package:tsacdop/webfeed/webfeed.dart';

class DBHelper {
  static Database _db;
  Future<Database> get database async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "podcasts.db");
    Database theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        """CREATE TABLE PodcastLocal(id INTEGER PRIMARY KEY,title TEXT, 
        imageUrl TEXT,rssUrl TEXT UNIQUE,primaryColor TEXT,author TEXT, 
        description TEXT, add_date INTEGER, order_id INTEGER default 0)""");
    await db
        .execute("""CREATE TABLE Episodes(id INTEGER PRIMARY KEY,title TEXT, 
        enclosure_url TEXT UNIQUE, enclosure_length INTEGER, pubDate TEXT, 
        description TEXT, feed_title TEXT, feed_link TEXT, milliseconds INTEGER, 
        duration INTEGER DEFAULT 0, explicit INTEGER DEFAULT 0, liked INTEGER DEFAULT 0, 
        downloaded TEXT DEFAULT 'ND', download_date INTEGER DEFAULT 0)""");
    await db.execute(
        """CREATE TABLE Setting(id INTEGER PRIMARY KEY, setting TEXT, setting_value INTEGER DEFAULT 0)""");
    await db
        .execute("""INSERT INTO Setting (setting) VALUES('podcasts_order') """);
  }

  Future<List<PodcastLocal>> getPodcastLocal() async {
    var dbClient = await database;
    //query podcasts order setting
    List<Map> setting = await dbClient.rawQuery("SELECT setting_value FROM Setting WHERE setting = 'podcasts_order'");
    int podcastsOrder = setting.first['setting_value'];
    List<Map> list;
    if (podcastsOrder == 0)
     { list = await dbClient.rawQuery(
        'SELECT title, imageUrl, rssUrl, primaryColor, author FROM PodcastLocal ORDER BY add_date DESC');
        print('Get podcasts list Ordered by 0');}
    else if (podcastsOrder == 1)
     { list = await dbClient.rawQuery(
        'SELECT title, imageUrl, rssUrl, primaryColor, author FROM PodcastLocal ORDER BY add_date');}
    else if (podcastsOrder ==2)
     { list = await dbClient.rawQuery(
        'SELECT title, imageUrl, rssUrl, primaryColor, author FROM PodcastLocal ORDER BY order_id');
        print('Get podcasts list Ordered by 2');}
   
    List<PodcastLocal> podcastLocal = List();
    for (int i = 0; i < list.length; i++) {
      podcastLocal.add(PodcastLocal(
        list[i]['title'],
        list[i]['imageUrl'],
        list[i]['rssUrl'],
        list[i]['primaryColor'],
        list[i]['author'],
      ));
    }
    return podcastLocal;
  }

  //save podcast order adter user save 
  saveOrder(List<PodcastLocal> podcastList) async {
    var dbClient = await database;
    for (int i = 0; i < podcastList.length; i++){
      await dbClient.rawUpdate(
          "UPDATE OR IGNORE PodcastLocal SET order_id = ? WHERE title = ?",
          [i, podcastList[i].title]);
      print(podcastList[i].title);
    }
    await dbClient.rawUpdate(
        "UPDATE OR IGNORE Setting SET setting_value = 2 WHERE setting = 'podcasts_order' ");
    print('Changed order');
  }
  
  updateOrderSetting(int value) async{
      var dbClient = await database;
      await dbClient.rawUpdate(
        "UPDATE OR IGNORE Setting SET setting_value = ? WHERE setting = 'podcasts_order'",[value]);
      
  }

  Future savePodcastLocal(PodcastLocal podcastLocal) async {
    print('podcast saved in sqllite');
    int _milliseconds = DateTime.now().millisecondsSinceEpoch;
    var dbClient = await database;
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          """INSERT OR IGNORE INTO PodcastLocal (title, imageUrl, rssUrl, 
          primaryColor, author, description, add_date) VALUES(?, ?, ?, ?, ?, ?, ?)""",
          [
            podcastLocal.title,
            podcastLocal.imageUrl,
            podcastLocal.rssUrl,
            podcastLocal.primaryColor,
            podcastLocal.author,
            podcastLocal.description,
            _milliseconds
          ]);
    });
  }

  Future delPodcastLocal(String title) async {
    print('deleted');
    var dbClient = await database;
    await dbClient
        .rawDelete('DELETE FROM PodcastLocal WHERE title =?', [title]);
    List<Map> list = await dbClient.rawQuery(
        """SELECT downloaded FROM Episodes WHERE downloaded != 'ND' AND feed_title = ?""",
        [title]);
    for (int i = 0; i < list.length; i++) {
      if (list[i] != null)
        FlutterDownloader.remove(
            taskId: list[i]['downloaded'], shouldDeleteContent: true);
      print('Removed all download tasks');
    }
    await dbClient
        .rawDelete('DELETE FROM Episodes WHERE feed_title=?', [title]);
  }

  Future getImageUrl(String title) async {
    var dbClient = await database;
    List<Map> list = await dbClient
        .rawQuery('SELECT imageUrl FROM PodcastLocal WHERE title = ?', [title]);
    String url = list[0]['imageUrl'];
    return url;
  }

  DateTime _parsePubDate(String pubDate) {
    if (pubDate == null) return null;
    DateTime date;
    try {
      date = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US').parse(pubDate);
    } catch (e) {
      try {
        print('e');
        date = DateFormat('dd MMM yyyy HH:mm:ss Z', 'en_US').parse(pubDate);
      } catch (e) {
        print('e');
        date = DateTime(0);
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

  Future<int> savePodcastRss(RssFeed _p) async {
    String _title;
    String _url;
    String _description;
    int _duration;
    int _result = _p.items.length;
    var dbClient = await database;
    int _count = Sqflite.firstIntValue(await dbClient.rawQuery(
        'SELECT COUNT(*) FROM Episodes WHERE feed_title = ?', [_p.title]));
    print(_count);
    if (_count == _result) {
      _result = 0;
      return _result;
    } else {
      for (int i = 0; i < (_result - _count); i++) {
        print(_p.items[i].title);
        _p.items[i].itunes.title != null
            ? _title = _p.items[i].itunes.title
            : _title = _p.items[i].title;
        _p.items[i].itunes.summary != null
            ? _description = _p.items[i].itunes.summary
            : _description = _p.items[i].description;
        isXimalaya(_p.items[i].enclosure.url)
            ? _url = _p.items[i].enclosure.url.split('=').last
            : _url = _p.items[i].enclosure.url;
        final _length = _p.items[i].enclosure.length;
        final _pubDate = _p.items[i].pubDate;
        final _date = _parsePubDate(_pubDate);
        final _milliseconds = _date.millisecondsSinceEpoch;
        (_p.items[i].itunes.duration != null)
            ? _duration = _p.items[i].itunes.duration.inMinutes
            : _duration = 0;
        final _explicit = getExplicit(_p.items[i].itunes.explicit);
        if (_p.items[i].enclosure.url != null) {
          await dbClient.transaction((txn) {
            return txn.rawInsert(
                """INSERT OR IGNORE INTO Episodes(title, enclosure_url, enclosure_length, pubDate, 
                description, feed_title, milliseconds, duration, explicit) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                [
                  _title,
                  _url,
                  _length,
                  _pubDate,
                  _description,
                  _p.title,
                  _milliseconds,
                  _duration,
                  _explicit,
                ]);
          });
        }
      }
      _result = 0;
      return _result;
    }
  }

  Future<List<EpisodeBrief>> getRssItem(String title) async {
    var dbClient = await database;
    List<EpisodeBrief> episodes = List();
    List<Map> list = await dbClient
        .rawQuery("""SELECT E.title, E.enclosure_url, E.enclosure_length, 
        E.pubDate,  E.feed_title, E.duration, E.explicit, E.liked, 
        E.downloaded, P.imageUrl, P.primaryColor 
        FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_title = P.title 
        where E.feed_title = ? ORDER BY E.milliseconds DESC""", [title]);
    for (int x = 0; x < list.length; x++) {
      episodes.add(EpisodeBrief(
          list[x]['title'],
          list[x]['enclosure_url'],
          list[x]['enclosure_length'],
          list[x]['pubDate'],
          list[x]['feed_title'],
          list[x]['imageUrl'],
          list[x]['primaryColor'],
          list[x]['liked'],
          list[x]['downloaded'],
          list[x]['duration'],
          list[x]['explicit']));
    }
    print('Loaded' + title);
    return episodes;
  }

  Future<List<EpisodeBrief>> getRssItemTop(String title) async {
    var dbClient = await database;
    List<EpisodeBrief> episodes = List();
    List<Map> list = await dbClient.rawQuery(
        """SELECT E.title, E.enclosure_url, E.enclosure_length, 
        E.pubDate, E.feed_title, E.duration, E.explicit, E.liked, 
        E.downloaded, P.imageUrl, P.primaryColor 
        FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_title = P.title 
        where E.feed_title = ? ORDER BY E.milliseconds DESC LIMIT 3""",
        [title]);
    for (int x = 0; x < list.length; x++) {
      episodes.add(EpisodeBrief(
          list[x]['title'],
          list[x]['enclosure_url'],
          list[x]['enclosure_length'],
          list[x]['pubDate'],
          list[x]['feed_title'],
          list[x]['imageUrl'],
          list[x]['primaryColor'],
          list[x]['liked'],
          list[x]['downloaded'],
          list[x]['duration'],
          list[x]['explicit']));
    }
    print(title);
    return episodes;
  }

  Future<EpisodeBrief> getRssItemDownload(String url) async {
    var dbClient = await database;
    EpisodeBrief episode;
    List<Map> list = await dbClient.rawQuery(
        """SELECT E.title, E.enclosure_url, E.enclosure_length, 
        E.pubDate, E.feed_title, E.duration, E.explicit, E.liked, 
        E.downloaded, P.imageUrl, P.primaryColor 
        FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_title = P.title 
        where E.enclosure_url = ? ORDER BY E.milliseconds DESC LIMIT 3""",
        [url]);

    if (list != null)
      episode = EpisodeBrief(
          list.first['title'],
          list.first['enclosure_url'],
          list.first['enclosure_length'],
          list.first['pubDate'],
          list.first['feed_title'],
          list.first['imageUrl'],
          list.first['primaryColor'],
          list.first['liked'],
          list.first['downloaded'],
          list.first['duration'],
          list.first['explicit']);
    return episode;
  }

  Future<List<EpisodeBrief>> getRecentRssItem() async {
    var dbClient = await database;
    List<EpisodeBrief> episodes = List();
    List<Map> list = await dbClient
        .rawQuery("""SELECT E.title, E.enclosure_url, E.enclosure_length, 
        E.pubDate, E.feed_title, E.duration, E.explicit, E.liked, 
        E.downloaded, P.imageUrl, P.primaryColor 
        FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_title = P.title 
        ORDER BY E.milliseconds DESC LIMIT 99""");
    for (int x = 0; x < list.length; x++) {
      episodes.add(EpisodeBrief(
          list[x]['title'],
          list[x]['enclosure_url'],
          list[x]['enclosure_length'],
          list[x]['pubDate'],
          list[x]['feed_title'],
          list[x]['imageUrl'],
          list[x]['primaryColor'],
          list[x]['liked'],
          list[x]['doanloaded'],
          list[x]['duration'],
          list[x]['explicit']));
    }
    return episodes;
  }

  Future<List<EpisodeBrief>> getLikedRssItem() async {
    var dbClient = await database;
    List<EpisodeBrief> episodes = List();
    List<Map> list = await dbClient.rawQuery(
        """SELECT E.title, E.enclosure_url, E.enclosure_length, E.pubDate, 
        E.feed_title, E.duration, E.explicit, E.liked, E.downloaded, P.imageUrl, 
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_title = P.title 
        WHERE E.liked = 1 ORDER BY E.milliseconds DESC LIMIT 99""");
    for (int x = 0; x < list.length; x++) {
      episodes.add(EpisodeBrief(
          list[x]['title'],
          list[x]['enclosure_url'],
          list[x]['enclosure_length'],
          list[x]['pubDate'],
          list[x]['feed_title'],
          list[x]['imageUrl'],
          list[x]['primaryColor'],
          list[x]['liked'],
          list[x]['downloaded'],
          list[x]['duration'],
          list[x]['explicit']));
    }
    return episodes;
  }

  Future<int> setLiked(String title) async {
    var dbClient = await database;
    int count = await dbClient
        .rawUpdate("UPDATE Episodes SET liked = 1 WHERE title = ?", [title]);
    print('liked');
    return count;
  }

  Future<int> setUniked(String title) async {
    var dbClient = await database;
    int count = await dbClient
        .rawUpdate("UPDATE Episodes SET liked = 0 WHERE title = ?", [title]);
    print('unliked');
    return count;
  }

  Future<int> saveDownloaded(String url, String id) async {
    var dbClient = await database;
    int _milliseconds = DateTime.now().millisecondsSinceEpoch;
    int count = await dbClient.rawUpdate(
        "UPDATE Episodes SET downloaded = ?, download_date = ? WHERE enclosure_url = ?",
        [id, _milliseconds, url]);
    print('Downloaded ' + url);
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
        """SELECT E.title, E.enclosure_url, E.enclosure_length, E.pubDate, 
        E.feed_title, E.duration, E.explicit, E.liked, E.downloaded, P.imageUrl, 
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_title = P.title 
        WHERE E.downloaded != 'ND' ORDER BY E.download_date DESC LIMIT 99""");
    for (int x = 0; x < list.length; x++) {
      episodes.add(EpisodeBrief(
          list[x]['title'],
          list[x]['enclosure_url'],
          list[x]['enclosure_length'],
          list[x]['pubDate'],
          list[x]['feed_title'],
          list[x]['imageUrl'],
          list[x]['primaryColor'],
          list[x]['liked'],
          list[x]['downloaded'],
          list[x]['duration'],
          list[x]['explicit']));
    }
    return episodes;
  }

  Future<String> getDescription(String title) async {
    var dbClient = await database;
    List<Map> list = await dbClient
        .rawQuery('SELECT description FROM Episodes WHERE title = ?', [title]);
    String description = list[0]['description'];
    return description;
  }

  Future<String> getFeedDescription(String title) async {
    var dbClient = await database;
    List<Map> list = await dbClient.rawQuery(
        'SELECT description FROM PodcastLocal WHERE title = ?', [title]);
    String description = list[0]['description'];
    return description;
  }

  Future<EpisodeBrief> getRssItemWithUrl(String url) async {
    var dbClient = await database;
    EpisodeBrief episode;
    List<Map> list = await dbClient.rawQuery(
        """SELECT E.title, E.enclosure_url, E.enclosure_length, E.pubDate, 
        E.feed_title, E.duration, E.explicit, E.liked, E.downloaded, P.imageUrl, 
        P.primaryColor FROM Episodes E INNER JOIN PodcastLocal P ON E.feed_title = P.title 
        WHERE E.enclosure_url = ?""", [url]);
    episode = EpisodeBrief(
        list.first['title'],
        list.first['enclosure_url'],
        list.first['enclosure_length'],
        list.first['pubDate'],
        list.first['feed_title'],
        list.first['imageUrl'],
        list.first['primaryColor'],
        list.first['liked'],
        list.first['downloaded'],
        list.first['duration'],
        list.first['explicit']);
    return episode;
  }
}
