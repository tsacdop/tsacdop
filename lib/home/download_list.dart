import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:tsacdop/class/download_state.dart';
import 'package:tsacdop/episodes/episodedetail.dart';
import 'package:tsacdop/util/pageroute.dart';

class DownloadList extends StatefulWidget {
  DownloadList({Key key}) : super(key: key);

  @override
  _DownloadListState createState() => _DownloadListState();
}

Widget _downloadButton(EpisodeTask task, BuildContext context) {
  var downloader = Provider.of<DownloadState>(context, listen: false);
  switch (task.status.value) {
    case 2:
      return IconButton(
        icon: Icon(
          Icons.pause_circle_filled,
        ),
        onPressed: () => downloader.pauseTask(task.episode),
      );
    case 4:
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => downloader.retryTask(task.episode),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => downloader.delTask(task.episode),
          ),
        ],
      );
    case 6:
      return IconButton(
        icon: Icon(Icons.play_circle_filled),
        onPressed: () => downloader.resumeTask(task.episode),
      );
      break;
    default:
      return Center();
  }
}

class _DownloadListState extends State<DownloadList> {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.all(5.0),
      sliver: Consumer<DownloadState>(builder: (_, downloader, __) {
        var tasks = downloader.episodeTasks
            .where((task) => task.status.value != 3)
            .toList();
        return tasks.length > 0
            ? SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return ListTile(
                      onTap: () => Navigator.push(
                        context,
                        ScaleRoute(
                            page: EpisodeDetail(
                          episodeItem: tasks[index].episode,
                        )),
                      ),
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                         Expanded(
                           flex: 5,
                                                      child: Container(
                              child: Text(
                                tasks[index].episode.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      
                          Expanded(
                            flex: 1,
                            child: tasks[index].progress >= 0
                                ? Container(
                                  width: 40.0,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 2),
                                        alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(6)),
                                        color: Colors.red),
                                    child: Text(
                                      tasks[index].progress.toString() + '%',
                                      style: TextStyle(color: Colors.white),
                                    ))
                                : Container(),
                          ),
                        ],
                      ),
                      subtitle: SizedBox(
                        height: 2,
                        child: LinearProgressIndicator(
                          value: tasks[index].progress / 100,
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundImage: FileImage(
                            File("${tasks[index].episode.imagePath}")),
                      ),
                      trailing: _downloadButton(tasks[index], context),
                    );
                  },
                  childCount: tasks.length,
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Center();
                  },
                  childCount: 1,
                ),
              );
      }),
    );
  }
}
