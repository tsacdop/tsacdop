import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:line_icons/line_icons.dart';
import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';

class DownloadsManage extends StatefulWidget {
  @override
  _DownloadsManageState createState() => _DownloadsManageState();
}

class _DownloadsManageState extends State<DownloadsManage> {
  //Downloaded size
  int _size;
  //Downloaded files
  int _fileNum;
  bool _loadEpisodes;
  bool _clearing;
  List<EpisodeBrief> _selectedList;
  List<EpisodeBrief> _episodes = [];

  _getDownloadedRssItem() async {
    _episodes = [];
    final tasks = await FlutterDownloader.loadTasksWithRawQuery(
        query: "SELECT * FROM task WHERE status = 3");
    var dbHelper = DBHelper();
    await Future.forEach(tasks, (task) async {
      EpisodeBrief episode = await dbHelper.getRssItemWithUrl(task.url);
      _episodes.add(episode);
    });
    setState(() {
      _loadEpisodes = true;
    });
  }

  _getStorageSize() async {
    _size = 0;
    _fileNum = 0;
    var dir = await getExternalStorageDirectory();
    dir.list().forEach((d) {
      var fileDir = Directory(d.path);
      fileDir.list().forEach((file) async {
        await File(file.path).stat().then((value) {
          _size += value.size;
          _fileNum += 1;
          setState(() {});
        });
      });
    });
  }

  _delSelectedEpisodes() async {
    setState(() => _clearing = true);
    await Future.forEach(_selectedList, (EpisodeBrief episode) async {
      print(episode.downloaded);
      await FlutterDownloader.remove(
          taskId: episode.downloaded, shouldDeleteContent: true);
      var dbHelper = DBHelper();
      await dbHelper.delDownloaded(episode.enclosureUrl);
      setState(() =>
          _episodes.removeWhere((e) => e.enclosureUrl == episode.enclosureUrl));
    });
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _clearing = false;
    });
    await Future.delayed(Duration(seconds: 1));
    setState(() => _selectedList = []);
    _getStorageSize();
  }

  int sumSelected() {
    int sum = 0;
    if (_selectedList.length == 0) {
      return sum;
    } else {
      _selectedList.forEach((episode) {
        sum += episode.enclosureLength;
      });
      return sum;
    }
  }

  @override
  void initState() {
    super.initState();
    _clearing = false;
    _loadEpisodes = false;
    _selectedList = [];
    _getStorageSize();
    _getDownloadedRssItem();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Downloads'),
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                  ),
                  Container(
                    height: 100.0,
                    padding: EdgeInsets.only(bottom: 40, left: 60),
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        text: 'Total  ',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 20,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: _fileNum.toString(),
                              style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: _fileNum < 2 ? ' episode' : ' episodes ',
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 20,
                              )),
                          TextSpan(
                              text: (_size ~/ 1000000).toString(),
                              style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: ' Mb',
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 20,
                              )),
                        ],
                      ),
                    ),
                  ),
                  _loadEpisodes
                      ? Expanded(
                          child: ListView.builder(
                              itemCount: _episodes.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: <Widget>[
                                    ListTile(
                                      onTap: () {
                                        if (_selectedList
                                            .contains(_episodes[index])) {
                                          setState(() => _selectedList
                                              .removeWhere((episode) =>
                                                  episode.enclosureUrl ==
                                                  _episodes[index]
                                                      .enclosureUrl));
                                        } else {
                                          setState(() => _selectedList
                                              .add(_episodes[index]));
                                        }
                                      },
                                      leading: CircleAvatar(
                                        backgroundImage: FileImage(File(
                                            "${_episodes[index].imagePath}")),
                                      ),
                                      title: Text(
                                        _episodes[index].title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: _episodes[index]
                                                  .enclosureLength !=
                                              0
                                          ? Text(((_episodes[index]
                                                          .enclosureLength) ~/
                                                      1000000)
                                                  .toString() +
                                              ' Mb')
                                          : Center(),
                                      trailing: Checkbox(
                                        value: _selectedList
                                            .contains(_episodes[index]),
                                        onChanged: (bool boo) {
                                          print(boo);
                                          if (boo) {
                                            setState(() => _selectedList
                                                .add(_episodes[index]));
                                          } else {
                                            setState(() => _selectedList
                                                .removeWhere((episode) =>
                                                    episode.enclosureUrl ==
                                                    _episodes[index]
                                                        .enclosureUrl));
                                          }
                                        },
                                      ),
                                    ),
                                    Divider(
                                      height: 2,
                                    ),
                                  ],
                                );
                              }),
                        )
                      : CircularProgressIndicator(),
                ],
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 800),
                curve: Curves.elasticInOut,
                left: MediaQuery.of(context).size.width / 2 - 50,
                bottom: _selectedList.length == 0 ? -100 : 30,
                child: InkWell(
                    onTap: () => _delSelectedEpisodes(),
                    child: Stack(
                      alignment: _clearing
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          width: 100,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                            color: Theme.of(context).accentColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Icon(
                                LineIcons.trash_alt_solid,
                                color: Colors.white,
                              ),
                              Text((sumSelected() ~/ 1000000).toString() + 'Mb',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            alignment: Alignment.center,
                            width: _clearing ? 100 : 0,
                            height: _clearing ? 40 : 0,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              color: Colors.red.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
