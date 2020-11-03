import 'package:uuid/uuid.dart';

import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import 'episodebrief.dart';

class PlaylistEntity {
  final String name;
  final String id;
  final List<String> episodeList;

  PlaylistEntity(this.name, this.id, this.episodeList);

  Map<String, Object> toJson() {
    return {'name': name, 'id': id, 'episodeList': episodeList};
  }

  static PlaylistEntity fromJson(Map<String, Object> json) {
    var list = List<String>.from(json['episodeList']);
    return PlaylistEntity(json['name'] as String, json['id'] as String, list);
  }
}

class Playlist {
  /// Playlist name. the default playlist is named "Playlist".
  final String name;

  /// Unique id for playlist.
  final String id;

  /// Episode url list for playlist.
  final List<String> episodeList;

  Playlist(this.name, {String id, List<String> episodeList})
      : id = id ?? Uuid().v4(),
        episodeList = episodeList ?? [];

  PlaylistEntity toEntity() {
    return PlaylistEntity(name, id, episodeList);
  }

  static Playlist fromEntity(PlaylistEntity entity) {
    return Playlist(
      entity.name,
      id: entity.id,
      episodeList: entity.episodeList,
    );
  }

  final DBHelper _dbHelper = DBHelper();
  List<EpisodeBrief> _playlist = [];
  List<EpisodeBrief> get playlist => _playlist;
  final KeyValueStorage _playlistStorage = KeyValueStorage(playlistKey);

  Future<void> getPlaylist() async {
    var urls = await _playlistStorage.getStringList();
    episodeList.addAll(urls);
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
