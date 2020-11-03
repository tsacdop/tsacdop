import 'package:state_notifier/state_notifier.dart';

import '../local_storage/key_value_storage.dart';
import '../type/playlist.dart';

class PlaylistProvider extends StateNotifier<List<Playlist>> {
  PlaylistProvider() : super([]);

  Future<void> loadPlaylist() async {
    var storage = KeyValueStorage(playlistsAllKey);
    var playlistEntities = await storage.getPlaylists();
    var initState = [...playlistEntities.map(Playlist.fromEntity).toList()];
    for (var playlist in initState) {
      await playlist.getPlaylist();
    }
    state = initState;
  }
}
