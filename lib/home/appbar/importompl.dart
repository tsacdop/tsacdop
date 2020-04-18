import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../class/podcast_group.dart';
import '../../class/subscribe_podcast.dart';
import '../../class/refresh_podcast.dart';
import '../../util/context_extension.dart';

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

  @override
  Widget build(BuildContext context) {
    GroupList groupList = Provider.of<GroupList>(context, listen: false);
    return Column(
      children: <Widget>[
        Consumer<SubscribeWorker>(
          builder: (_, subscribeWorker, __) {
            SubscribeItem item = subscribeWorker.currentSubscribeItem;
            switch (item.subscribeState) {
              case SubscribeState.start:
                return importColumn("Subscribe: ${item.title}", context);
              case SubscribeState.subscribe:
                groupList.subscribeNewPodcast(item.id);
                return importColumn("Fetch data ${item.title}", context);
              case SubscribeState.fetch:
                groupList.updatePodcast(item.id);
                return importColumn("Subscribe success ${item.title}", context);
              case SubscribeState.exist:
                return importColumn(
                    "Subscribe failed, podcast existed ${item.title}", context);
              case SubscribeState.error:
                return importColumn(
                    "Subscribe failed, network error ${item.title}", context);
              default:
                return Center();
            }
          },
        ),
        Consumer<RefreshWorker>(
          builder: (context, refreshWorker, child) {
            RefreshItem item = refreshWorker.currentRefreshItem;
            if (refreshWorker.complete) groupList.updateGroups();
            switch (item.refreshState) {
              case RefreshState.fetch:
                return importColumn("Fetch data ${item.title}", context);
              case RefreshState.error:
                return importColumn("Update error ${item.title}", context);
              default:
                return Center();
            }
          },
        )
      ],
    );
  }
}
