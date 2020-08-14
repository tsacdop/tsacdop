import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import 'episodebrief.dart';

class Playlist {
  String name;
  final DBHelper _dbHelper = DBHelper();
  List<EpisodeBrief> _playlist;
  List<EpisodeBrief> get playlist => _playlist;
  final KeyValueStorage _playlistStorage = KeyValueStorage(playlistKey);

  Future<void> getPlaylist() async {
    var urls = await _playlistStorage.getStringList();
    if (urls.length == 0) {
      _playlist = [];
    } else {
      _playlist = [];
      for (var url in urls) {
        var episode = await _dbHelper.getRssItemWithUrl(url);
        if (episode != null) _playlist.add(episode);
      }
    }
  }

  Future<void> savePlaylist() async {
    var urls = <String>[];
    urls.addAll(_playlist.map((e) => e.enclosureUrl));
    await _playlistStorage.saveStringList(urls.toSet().toList());
  }

  Future<void> addToPlayList(EpisodeBrief episodeBrief) async {
    if (!_playlist.contains(episodeBrief)) {
      _playlist.add(episodeBrief);
      await savePlaylist();
      if (episodeBrief.isNew == 1) {
        await _dbHelper.removeEpisodeNewMark(episodeBrief.enclosureUrl);
      }
    }
  }

  Future<void> addToPlayListAt(EpisodeBrief episodeBrief, int index,
      {bool existed = true}) async {
    if (existed) {
      _playlist.removeWhere(
          (episode) => episode.enclosureUrl == episodeBrief.enclosureUrl);
      if (episodeBrief.isNew == 1) {
        await _dbHelper.removeEpisodeNewMark(episodeBrief.enclosureUrl);
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
