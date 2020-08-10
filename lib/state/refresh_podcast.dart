import 'dart:developer' as developer;
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';

import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';

enum RefreshState { none, fetch, error, artwork }

class RefreshItem {
  String title;
  RefreshState refreshState;
  bool artwork;
  RefreshItem(this.title, this.refreshState, {this.artwork = false});
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
  var refreshstorage = KeyValueStorage(refreshdateKey);
  await refreshstorage.saveInt(DateTime.now().millisecondsSinceEpoch);
  var dbHelper = DBHelper();
  var podcastList = await dbHelper.getPodcastLocalAll();
  for (var podcastLocal in podcastList) {
    sendPort.send([podcastLocal.title, 1]);
    var updateCount = await dbHelper.updatePodcastRss(podcastLocal);
    developer.log('Refresh ${podcastLocal.title}$updateCount');
  }
  sendPort.send("done");
}
