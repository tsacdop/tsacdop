import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

import '../episodes/episode_detail.dart';
import '../state/download_state.dart';
import '../type/episode_task.dart';
import '../util/pageroute.dart';

class DownloadList extends StatefulWidget {
  DownloadList({Key key}) : super(key: key);

  @override
  _DownloadListState createState() => _DownloadListState();
}

Widget _downloadButton(EpisodeTask task, BuildContext context) {
  var downloader = Provider.of<DownloadState>(context, listen: false);
  switch (task.status.value) {
    case 2:
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.pause_circle_filled,
            ),
            onPressed: () => downloader.pauseTask(task.episode),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => downloader.delTask(task.episode),
          ),
        ],
      );
    case 4:
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.red),
            onPressed: () => downloader.retryTask(task.episode),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => downloader.delTask(task.episode),
          ),
        ],
      );
    case 6:
      return Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          icon: Icon(Icons.play_circle_filled),
          onPressed: () => downloader.resumeTask(task.episode),
        ),
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () => downloader.delTask(task.episode),
        ),
      ]);
      break;
    default:
      return SizedBox(
        width: 10,
        height: 10,
      );
  }
}

class _DownloadListState extends State<DownloadList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadState>(builder: (_, downloader, __) {
      final tasks = downloader.episodeTasks
          .where((task) => task.status.value != 3)
          .toList();
      return tasks.length > 0
          ? SliverPadding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return ListTile(
                      onTap: () => Navigator.push(
                        context,
                        ScaleRoute(
                            page: EpisodeDetail(
                          episodeItem: tasks[index].episode,
                        )),
                      ),
                      title: SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 5,
                              child: Text(
                                tasks[index].episode.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: tasks[index].progress >= 0 &&
                                      tasks[index].status !=
                                          DownloadTaskStatus.failed
                                  ? Container(
                                      width: 40.0,
                                      height: 20.0,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 2),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          color: Colors.red),
                                      child: Text(
                                        '${tasks[index].progress}%',
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        style: TextStyle(color: Colors.white),
                                      ))
                                  : Container(
                                      height: 40,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: SizedBox(
                        height: 2,
                        child: LinearProgressIndicator(
                          value: tasks[index].progress / 100,
                        ),
                      ),
                      leading: CircleAvatar(
                          radius: 20,
                          backgroundImage: tasks[index].episode.avatarImage),
                      trailing: _downloadButton(tasks[index], context),
                    );
                  },
                  childCount: tasks.length,
                ),
              ),
            )
          : SliverToBoxAdapter(
              child: Center(),
            );
    });
  }
}
