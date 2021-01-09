import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../state/download_state.dart';
import '../state/podcast_group.dart';
import '../state/refresh_podcast.dart';
import '../util/extension_helper.dart';

class Import extends StatelessWidget {
  Widget importColumn(String text, BuildContext context) {
    return Container(
      color: context.primaryColorDark,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 2.0, child: LinearProgressIndicator()),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              height: 20.0,
              alignment: Alignment.centerLeft,
              child: Text(text),
            ),
          ]),
    );
  }

  _autoDownloadNew(BuildContext context) async {
    final dbHelper = DBHelper();
    var downloader = Provider.of<DownloadState>(context, listen: false);
    var result = await Connectivity().checkConnectivity();
    var autoDownloadStorage = KeyValueStorage(autoDownloadNetworkKey);
    var autoDownloadNetwork = await autoDownloadStorage.getInt();
    if (autoDownloadNetwork == 1) {
      var episodes = await dbHelper.getNewEpisodes('all');
      // For safety
      if (episodes.length < 100 && episodes.length > 0) {
        for (var episode in episodes) {
          await downloader.startTask(episode, showNotification: true);
        }
      }
    } else if (result == ConnectivityResult.wifi) {
      var episodes = await dbHelper.getNewEpisodes('all');
      //For safety
      if (episodes.length < 100 && episodes.length > 0) {
        for (var episode in episodes) {
          await downloader.startTask(episode, showNotification: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    var groupList = Provider.of<GroupList>(context, listen: false);
    return Column(
      children: <Widget>[
        Consumer<GroupList>(
          builder: (_, subscribeWorker, __) {
            var item = subscribeWorker.currentSubscribeItem;
            switch (item.subscribeState) {
              case SubscribeState.start:
                return importColumn(
                    s.notificationSubscribe(item.title), context);
              case SubscribeState.subscribe:
                return importColumn(s.notificaitonFatch(item.title), context);
              case SubscribeState.fetch:
                return importColumn(s.notificationSuccess(item.title), context);
              case SubscribeState.exist:
                return importColumn(
                    s.notificationSubscribeExisted(item.title), context);
              case SubscribeState.error:
                return importColumn(
                    s.notificationNetworkError(item.title), context);
              default:
                return Center();
            }
          },
        ),
        Consumer<RefreshWorker>(
          builder: (context, refreshWorker, child) {
            var item = refreshWorker.currentRefreshItem;
            if (refreshWorker.complete) {
              groupList.updateGroups();
              _autoDownloadNew(context);
            }
            switch (item.refreshState) {
              case RefreshState.fetch:
                return importColumn(s.notificationUpdate(item.title), context);
              case RefreshState.error:
                return importColumn(
                    s.notificationUpdateError(item.title), context);
              default:
                return Center();
            }
          },
        )
      ],
    );
  }
}
