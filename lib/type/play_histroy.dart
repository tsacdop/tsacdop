import '../local_storage/sqflite_localpodcast.dart';
import 'episodebrief.dart';

class PlayHistory {
  DBHelper dbHelper = DBHelper();

  /// Episdoe title.
  String title;

  /// Episode url
  String url;

  /// Play record seconds.
  int seconds;

  /// Play record count,
  double seekValue;

  /// Listened date.
  DateTime playdate;

  PlayHistory(this.title, this.url, this.seconds, this.seekValue,
      {this.playdate});

  EpisodeBrief _episode;
  EpisodeBrief get episode => _episode;

  getEpisode() async {
    _episode = await dbHelper.getRssItemWithUrl(url);
  }
}
