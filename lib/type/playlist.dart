import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

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

class Playlist extends Equatable {
  /// Playlist name. the default playlist is named "Playlist".
  final String name;

  /// Unique id for playlist.
  final String id;

  /// Episode url list for playlist.
  final List<String> episodeList;

  /// Eposides in playlist.
  final List<EpisodeBrief> episodes;

  bool get isEmpty => episodeList.isEmpty;

  Playlist(this.name,
      {String id, List<String> episodeList, List<EpisodeBrief> episodes})
      : id = id ?? Uuid().v4(),
        episodeList = episodeList ?? [],
        episodes = episodes ?? [];

  PlaylistEntity toEntity() {
    return PlaylistEntity(name, id, episodeList.toSet().toList());
  }

  static Playlist fromEntity(PlaylistEntity entity) {
    return Playlist(
      entity.name,
      id: entity.id,
      episodeList: entity.episodeList,
    );
  }

  final DBHelper _dbHelper = DBHelper();
//  final KeyValueStorage _playlistStorage = KeyValueStorage(playlistKey);

  Future<void> getPlaylist() async {
    episodes.clear();
    if (episodeList.isNotEmpty) {
      for (var url in episodeList) {
        print(url);
        var episode = await _dbHelper.getRssItemWithUrl(url);
        if (episode != null) episodes.add(episode);
      }
    }
  }

// Future<void> savePlaylist() async {
//    var urls = <String>[];
//    urls.addAll(_playlist.map((e) => e.enclosureUrl));
//    await _playlistStorage.saveStringList(urls.toSet().toList());
//  }

  void addToPlayList(EpisodeBrief episodeBrief) {
    if (!episodes.contains(episodeBrief)) {
      episodes.add(episodeBrief);
      episodeList.add(episodeBrief.enclosureUrl);
    }
  }

  void addToPlayListAt(EpisodeBrief episodeBrief, int index,
      {bool existed = true}) {
    if (existed) {
      episodes.removeWhere((episode) => episode == episodeBrief);
      episodeList.removeWhere((url) => url == episodeBrief.enclosureUrl);
    }
    episodes.insert(index, episodeBrief);
    episodeList.insert(index, episodeBrief.enclosureUrl);
  }

  void updateEpisode(EpisodeBrief episode) {
    var index = episodes.indexOf(episode);
    if (index != -1) episodes[index] = episode;
  }

  int delFromPlaylist(EpisodeBrief episodeBrief) {
    var index = episodes.indexOf(episodeBrief);
    episodes.removeWhere(
        (episode) => episode.enclosureUrl == episodeBrief.enclosureUrl);
    episodeList.removeWhere((url) => url == episodeBrief.enclosureUrl);
    return index;
  }

  void reorderPlaylist(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final episode = episodes.removeAt(oldIndex);
    episodes.insert(newIndex, episode);
    episodeList.removeAt(oldIndex);
    episodeList.insert(newIndex, episode.enclosureUrl);
  }

  void clear() {
    episodeList.clear();
    episodes.clear();
  }

  @override
  List<Object> get props => [id, name];
}
