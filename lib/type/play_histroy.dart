import '../local_storage/sqflite_localpodcast.dart';
import 'episodebrief.dart';

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
