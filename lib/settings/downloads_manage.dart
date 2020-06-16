import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../type/episodebrief.dart';
import '../util/context_extension.dart';
import '../state/download_state.dart';
import '../local_storage/sqflite_localpodcast.dart';

class DownloadsManage extends StatefulWidget {
  @override
  _DownloadsManageState createState() => _DownloadsManageState();
}

class _DownloadsManageState extends State<DownloadsManage> {
  //Downloaded size
  int _size;
  int _mode;
  //Downloaded files
  int _fileNum;
  bool _clearing;
  bool _onlyListened;
  List<EpisodeBrief> _selectedList;

  Future<List<EpisodeBrief>> _getDownloadedEpisode(int mode) async {
    List<EpisodeBrief> episodes = [];
    var dbHelper = DBHelper();
    episodes = await dbHelper.getDownloadedEpisode(mode);
    return episodes;
  }

  Future<int> _isListened(EpisodeBrief episode) async {
    DBHelper dbHelper = DBHelper();
    return await dbHelper.isListened(episode.enclosureUrl);
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
          if (mounted) setState(() {});
        });
      });
    });
  }

  _delSelectedEpisodes() async {
    setState(() => _clearing = true);
    await Future.forEach(_selectedList, (EpisodeBrief episode) async {
      var downloader = Provider.of<DownloadState>(context, listen: false);
      await downloader.delTask(episode);
      if (mounted) setState(() {});
    });
    await Future.delayed(Duration(seconds: 1));
    if (mounted)
      setState(() {
        _clearing = false;
      });
    await Future.delayed(Duration(seconds: 1));
    if (mounted) setState(() => _selectedList = []);
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
    _selectedList = [];
    _mode = 0;
    _onlyListened = false;
    _getStorageSize();
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
          elevation: 0,
          backgroundColor: context.primaryColor,
        ),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 140.0,
                    color: context.primaryColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: RichText(
                            text: TextSpan(
                              text: 'Total ',
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 20,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: _fileNum.toString(),
                                  style: GoogleFonts.cairo(
                                      textStyle: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontSize: 40,
                                  )),
                                ),
                                TextSpan(
                                    text: _fileNum < 2
                                        ? ' episode'
                                        : ' episodes ',
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: 20,
                                    )),
                                TextSpan(
                                  text: (_size ~/ 1000000) < 1000
                                      ? (_size ~/ 1000000).toString()
                                      : (_size / 1000000000).toStringAsFixed(1),
                                  style: GoogleFonts.cairo(
                                      textStyle: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontSize: 50,
                                  )),
                                ),
                                TextSpan(
                                    text: (_size ~/ 1000000) < 1000
                                        ? 'Mb'
                                        : 'Gb',
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: 20,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        Spacer(),
                        SizedBox(
                          height: 40,
                          child: Row(
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: PopupMenuButton<int>(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  elevation: 1,
                                  tooltip: 'Sort By',
                                  child: Container(
                                      height: 40,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text('Sory by'),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5),
                                          ),
                                          Icon(
                                            _mode == 0
                                                ? LineIcons
                                                    .hourglass_start_solid
                                                : _mode == 1
                                                    ? LineIcons
                                                        .hourglass_half_solid
                                                    : LineIcons.save,
                                            size: 18,
                                          )
                                        ],
                                      )),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 0,
                                      child: Text('Newest first'),
                                    ),
                                    PopupMenuItem(
                                      value: 1,
                                      child: Text('Oldest first'),
                                    ),
                                    PopupMenuItem(
                                      value: 2,
                                      child: Text('Size'),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 0)
                                      setState(() => _mode = 0);
                                    else if (value == 1)
                                      setState(() => _mode = 1);
                                    else if (value == 2)
                                      setState(() => _mode = 2);
                                  },
                                ),
                              ),
                              //Spacer(),

                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => setState(() {
                                    _onlyListened = !_onlyListened;
                                  }),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 5),
                                      ),
                                      Text('Listened Only'),
                                      Transform.scale(
                                        scale: 0.8,
                                        child: Checkbox(
                                            value: _onlyListened,
                                            onChanged: (value) {
                                              setState(() {
                                                _onlyListened = value;
                                              });
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<EpisodeBrief>>(
                      future: _getDownloadedEpisode(_mode),
                      initialData: [],
                      builder: (context, snapshot) {
                        var _episodes = snapshot.data;
                        return ListView.builder(
                            itemCount: _episodes.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              return FutureBuilder(
                                  future: _isListened(_episodes[index]),
                                  initialData: 0,
                                  builder: (context, snapshot) {
                                    return (_onlyListened && snapshot.data == 0)
                                        ? Center()
                                        : Column(
                                            children: <Widget>[
                                              ListTile(
                                                onTap: () {
                                                  if (_selectedList.contains(
                                                      _episodes[index])) {
                                                    setState(() => _selectedList
                                                        .removeWhere((episode) =>
                                                            episode
                                                                .enclosureUrl ==
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                subtitle: Row(
                                                  children: [
                                                    Text(_episodes[index]
                                                        .downloadDateToString()),
                                                    SizedBox(width: 20),
                                                    _episodes[index]
                                                                .enclosureLength !=
                                                            0
                                                        ? Text(((_episodes[index]
                                                                        .enclosureLength) ~/
                                                                    1000000)
                                                                .toString() +
                                                            ' Mb')
                                                        : SizedBox(
                                                            width: 1,
                                                          ),
                                                  ],
                                                ),
                                                trailing: Checkbox(
                                                  value: _selectedList.contains(
                                                      _episodes[index]),
                                                  onChanged: (bool boo) {
                                                    if (boo) {
                                                      setState(() =>
                                                          _selectedList.add(
                                                              _episodes[
                                                                  index]));
                                                    } else {
                                                      setState(() => _selectedList
                                                          .removeWhere((episode) =>
                                                              episode
                                                                  .enclosureUrl ==
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
                                  });
                            });
                      },
                    ),
                  )
                ],
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 800),
                curve: Curves.elasticInOut,
                left: context.width / 2 - 50,
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
