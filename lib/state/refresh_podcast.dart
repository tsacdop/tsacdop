import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:connectivity/connectivity.dart';

import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../type/podcastlocal.dart';
import '../type/episodebrief.dart';
import 'download_state.dart';

enum RefreshState { none, fetch, error }

class RefreshItem {
  String title;
  RefreshState refreshState;
  RefreshItem(this.title, this.refreshState);
}

class RefreshWorker extends ChangeNotifier {
  FlutterIsolate refreshIsolate;
  ReceivePort receivePort;
  SendPort refreshSendPort;

  RefreshItem _currentRefreshItem = RefreshItem('', RefreshState.none);
  bool _complete = false;
  RefreshItem get currentRefreshItem => _currentRefreshItem;
  bool get complete => _complete;

  bool _created = false;

  Future<void> _createIsolate() async {
    receivePort = ReceivePort();
    refreshIsolate = await FlutterIsolate.spawn(
        refreshIsolateEntryPoint, receivePort.sendPort);
  }

  void _listen() {
    receivePort.distinct().listen((message) {
      if (message is List) {
        _currentRefreshItem =
            RefreshItem(message[0], RefreshState.values[message[1]]);
        notifyListeners();
      } else if (message is String && message == "done") {
        _currentRefreshItem = RefreshItem('', RefreshState.none);
        _complete = true;
        notifyListeners();
        refreshIsolate?.kill();
        refreshIsolate = null;
        _created = false;
      }
    });
  }

  Future<void> start() async {
    if (!_created) {
      _complete = false;
      _createIsolate();
      _listen();
      _created = true;
    }
  }

  void dispose() {
    refreshIsolate?.kill();
    refreshIsolate = null;
    super.dispose();
  }
}

Future<void> refreshIsolateEntryPoint(SendPort sendPort) async {
  KeyValueStorage refreshstorage = KeyValueStorage(refreshdateKey);
  KeyValueStorage autoDownloadStorage = KeyValueStorage(autoDownloadNetworkKey);
  await refreshstorage.saveInt(DateTime.now().millisecondsSinceEpoch);
  var dbHelper = DBHelper();
  List<PodcastLocal> podcastList = await dbHelper.getPodcastLocalAll();
  //int i = 0;
  await Future.forEach<PodcastLocal>(podcastList, (podcastLocal) async {
    sendPort.send([podcastLocal.title, 1]);
    int updateCount = await dbHelper.updatePodcastRss(podcastLocal);
    bool autoDownload = await dbHelper.getAutoDownload(podcastLocal.id);
    if (autoDownload && updateCount > 0) {
      var result = await Connectivity().checkConnectivity();
      int autoDownloadNetwork = await autoDownloadStorage.getInt();
      if (autoDownloadNetwork == 1) {
        List<EpisodeBrief> episodes =
            await dbHelper.getNewEpisodes(podcastLocal.id);
        episodes.forEach((episode) {
          DownloadState().startTask(episode, showNotification: false);
        });
      } else if (result == ConnectivityResult.wifi) {
        List<EpisodeBrief> episodes =
            await dbHelper.getNewEpisodes(podcastLocal.id);
        episodes.forEach((episode) {
          DownloadState().startTask(episode, showNotification: false);
        });
      }
    }
    print('Refresh ' + podcastLocal.title);
  });
  // KeyValueStorage refreshcountstorage = KeyValueStorage('refreshcount');
  //  await refreshcountstorage.saveInt(i);
  sendPort.send("done");
}
