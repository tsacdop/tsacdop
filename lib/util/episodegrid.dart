import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:line_icons/line_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tsacdop/class/audiostate.dart';
import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/episodes/episodedetail.dart';
import 'package:tsacdop/util/pageroute.dart';
import 'package:tsacdop/util/colorize.dart';

class EpisodeGrid extends StatelessWidget {
  final List<EpisodeBrief> podcast;
  final bool showFavorite;
  final bool showDownload;
  final bool showNumber;
  final String heroTag;
  EpisodeGrid(
      {Key key,
      this.podcast,
      this.showDownload,
      this.showFavorite,
      this.showNumber,
      this.heroTag})
      : super(key: key);
  Offset offset;
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;

    _showPopupMenu(Offset offset, EpisodeBrief episode, BuildContext context,
        bool isPlaying, bool isInPlaylist) async {
      var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
      double left = offset.dx;
      double top = offset.dy;
      await showMenu<int>(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        context: context,
        position: RelativeRect.fromLTRB(left, top, _width - left, 0),
        
        items: <PopupMenuEntry<int>>[
          PopupMenuItem(
            value: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Icon(
                  LineIcons.play_circle_solid,
                  color: Theme.of(context).accentColor,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                ),
                !isPlaying ? Text('Play') : Text('Playing'),
              ],
            ),
          ),
          PopupMenuItem(
              value: 1,
              child: Row(
                children: <Widget>[
                  Icon(
                    LineIcons.clock_solid,
                    color: Colors.red,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                  ),
                  !isInPlaylist ? Text('Later') : Text('Remove')
                ],
              )),
        ],
        elevation: 5.0,
      ).then((value) {
        if (value == 0) {
          if (!isPlaying) audio.episodeLoad(episode);
        } else if (value == 1) {
         if (isInPlaylist) {
            audio.addToPlaylist(episode);
            Fluttertoast.showToast(
              msg: 'Added to playlist',
              gravity: ToastGravity.BOTTOM,
            );
          } else {
            audio.delFromPlaylist(episode);
            Fluttertoast.showToast(
              msg: 'Removed from playlist',
              gravity: ToastGravity.BOTTOM,
            );
          } 
        }
      });
    }

    return SliverPadding(
      padding: const EdgeInsets.all(5.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1.0,
          crossAxisCount: 3,
          mainAxisSpacing: 6.0,
          crossAxisSpacing: 6.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            Color _c = (Theme.of(context).brightness == Brightness.light)
                ? podcast[index].primaryColor.colorizedark()
                : podcast[index].primaryColor.colorizeLight();
            return Selector<AudioPlayerNotifier,
                Tuple2<EpisodeBrief, List<String>>>(
              selector: (_, audio) => Tuple2(audio?.episode,
                  audio.queue.playlist.map((e) => e.enclosureUrl).toList()),
              builder: (_, data, __) => Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor,
                        blurRadius: 0.5,
                        spreadRadius: 0.5,
                      ),
                    ]),
                alignment: Alignment.center,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    onTapDown: (details) => offset = Offset(
                        details.globalPosition.dx, details.globalPosition.dy),
                    onLongPress: () => _showPopupMenu(
                        offset,
                        podcast[index],
                        context,
                        data.item1 == podcast[index],
                        data.item2.contains(podcast[index].enclosureUrl)),
                    onTap: () {
                      Navigator.push(
                        context,
                        ScaleRoute(
                            page: EpisodeDetail(
                          episodeItem: podcast[index],
                          heroTag: heroTag,
                        )),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        border: Border.all(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).scaffoldBackgroundColor,
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Hero(
                                  tag: podcast[index].enclosureUrl + heroTag,
                                  child: Container(
                                    height: _width / 16,
                                    width: _width / 16,
                                    child: CircleAvatar(
                                      backgroundColor: _c.withOpacity(0.5),
                                      backgroundImage: FileImage(
                                          File("${podcast[index].imagePath}")),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                showNumber
                                    ? Container(
                                        alignment: Alignment.topRight,
                                        child: Text(
                                          (podcast.length - index).toString(),
                                          style: GoogleFonts.teko(
                                            textStyle: TextStyle(
                                              fontSize: _width / 24,
                                              color: _c,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Center(),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              alignment: Alignment.topLeft,
                              padding: EdgeInsets.only(top: 2.0),
                              child: Text(
                                podcast[index].title,
                                style: TextStyle(
                                  fontSize: _width / 32,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    podcast[index].dateToString(),
                                    style: TextStyle(
                                        fontSize: _width / 35,
                                        color: _c,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                                Spacer(),
                                showDownload
                                    ? DownloadIcon(episodeBrief: podcast[index])
                                    : Center(),
                                Padding(
                                  padding: EdgeInsets.all(1),
                                ),
                                showFavorite
                                    ? Container(
                                        alignment: Alignment.bottomRight,
                                        child: (podcast[index].liked == 0)
                                            ? Center()
                                            : IconTheme(
                                                data: IconThemeData(size: 15),
                                                child: Icon(
                                                  Icons.favorite,
                                                  color: Colors.red,
                                                ),
                                              ),
                                      )
                                    : Center(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: podcast.length,
        ),
      ),
    );
  }
}

class DownloadIcon extends StatefulWidget {
  final EpisodeBrief episodeBrief;
  DownloadIcon({this.episodeBrief, Key key}) : super(key: key);
  @override
  _DownloadIconState createState() => _DownloadIconState();
}

class _DownloadIconState extends State<DownloadIcon> {
  _TaskInfo _task;
  bool _isLoading;
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);

    _isLoading = true;
    _prepare();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }

    _port.listen((dynamic data) {
      print('UI isolate callback: $data');
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      if (_task.taskId == id) {
        setState(() {
          _task.status = status;
          _task.progress = progress;
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    print('Background callback task in $id  status ($status) $progress');
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

    _task = _TaskInfo(
        name: widget.episodeBrief.title,
        link: widget.episodeBrief.enclosureUrl);

    tasks?.forEach((task) {
      if (_task.link == task.url) {
        _task.taskId = task.taskId;
        _task.status = task.status;
        _task.progress = task.progress;
      }
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _downloadButton(_task);
  }

  Widget _downloadButton(_TaskInfo task) {
    if (_isLoading)
      return Center();
    else if (task.status == DownloadTaskStatus.running) {
      return SizedBox(
        height: 12,
        width: 12,
        child: CircularProgressIndicator(
          backgroundColor: Colors.grey[200],
          strokeWidth: 1,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          value: task.progress / 100,
        ),
      );
    } else if (task.status == DownloadTaskStatus.paused) {
      return SizedBox(
        height: 12,
        width: 12,
        child: CircularProgressIndicator(
          backgroundColor: Colors.grey[200],
          strokeWidth: 1,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          value: task.progress / 100,
        ),
      );
    } else if (task.status == DownloadTaskStatus.complete) {
      return IconTheme(
        data: IconThemeData(size: 15),
        child: Icon(
          Icons.done_all,
          color: Colors.blue,
        ),
      );
    } else if (task.status == DownloadTaskStatus.failed) {
      return IconTheme(
        data: IconThemeData(size: 15),
        child: Icon(Icons.refresh, color: Colors.red),
      );
    }
    return Center();
  }
}

class _TaskInfo {
  final String name;
  final String link;

  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link});
}
