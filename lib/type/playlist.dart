import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import 'episodebrief.dart';

class Playlist {
  String name;
  DBHelper dbHelper = DBHelper();
  List<EpisodeBrief> _playlist;
  List<EpisodeBrief> get playlist => _playlist;
  KeyValueStorage storage = KeyValueStorage('playlist');

  getPlaylist() async {
    var urls = await storage.getStringList();
    if (urls.length == 0) {
      _playlist = [];
    } else {
      _playlist = [];
      for (var url in urls) {
        var episode = await dbHelper.getRssItemWithUrl(url);
        if (episode != null) _playlist.add(episode);
      }
    }
  }

  savePlaylist() async {
    var urls = <String>[];
    urls.addAll(_playlist.map((e) => e.enclosureUrl));
    await storage.saveStringList(urls.toSet().toList());
  }

  Future<void> addToPlayList(EpisodeBrief episodeBrief) async {
    if (!_playlist.contains(episodeBrief)) {
      _playlist.add(episodeBrief);
      await savePlaylist();
      if (episodeBrief.isNew == 1) {
        await dbHelper.removeEpisodeNewMark(episodeBrief.enclosureUrl);
      }
    }
  }

  Future<void> addToPlayListAt(EpisodeBrief episodeBrief, int index,
      {bool existed = true}) async {
    if (existed) {
      _playlist.removeWhere(
          (episode) => episode.enclosureUrl == episodeBrief.enclosureUrl);
      if (episodeBrief.isNew == 1) {
        await dbHelper.removeEpisodeNewMark(episodeBrief.enclosureUrl);
      }
    }
    _playlist.insert(index, episodeBrief);
    await savePlaylist();
  }

  Future<int> delFromPlaylist(EpisodeBrief episodeBrief) async {
    var index = _playlist.indexOf(episodeBrief);
    _playlist.removeWhere(
        (episode) => episode.enclosureUrl == episodeBrief.enclosureUrl);
    await savePlaylist();
    return index;
  }
}
