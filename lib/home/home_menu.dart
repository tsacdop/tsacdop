import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../local_storage/key_value_storage.dart';
import '../service/opml_build.dart';
import '../settings/settting.dart';
import '../state/podcast_group.dart';
import '../state/refresh_podcast.dart';
import '../util/extension_helper.dart';
import 'about.dart';

class PopupMenu extends StatefulWidget {
  @override
  _PopupMenuState createState() => _PopupMenuState();
}

class _PopupMenuState extends State<PopupMenu> {
  Future<String> _getRefreshDate(BuildContext context) async {
    int refreshDate;
    final s = context.s;
    var refreshstorage = KeyValueStorage('refreshdate');
    var i = await refreshstorage.getInt();
    if (i == 0) {
      var refreshstorage = KeyValueStorage('refreshdate');
      await refreshstorage.saveInt(DateTime.now().millisecondsSinceEpoch);
      refreshDate = DateTime.now().millisecondsSinceEpoch;
    } else {
      refreshDate = i;
    }
    var date = DateTime.fromMillisecondsSinceEpoch(refreshDate);
    var difference = DateTime.now().difference(date);
    if (difference.inSeconds < 60) {
      return s.secondsAgo(difference.inSeconds);
    } else if (difference.inMinutes < 60) {
      return s.minsAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return s.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return s.daysAgo(difference.inDays);
    } else {
      return DateFormat.yMMMd()
          .format(DateTime.fromMillisecondsSinceEpoch(refreshDate));
    }
  }

  void _saveOmpl(String path) async {
    var subscribeWorker = Provider.of<GroupList>(context, listen: false);
    var rssExp = RegExp(r'^(https?):\/\/(.*)');
    final s = context.s;
    var file = File(path);
    try {
      final opml = file.readAsStringSync();
      Map<String, List<OmplOutline>> data = PodcastsBackup.parseOMPL(opml);
      for (var entry in data.entries) {
        var title = entry.key;
        var list = entry.value.reversed;
        for (var rss in list) {
          var rssLink = rssExp.stringMatch(rss.xmlUrl);
          if (rssLink != null) {
            var item = SubscribeItem(rssLink, rss.text, group: title);
            await subscribeWorker.setSubscribeItem(item);
            await Future.delayed(Duration(milliseconds: 200));
          }
        }
      }
    } catch (e) {
      developer.log(e, name: 'OMPL parse error');
      Fluttertoast.showToast(
        msg: s.toastFileError,
        gravity: ToastGravity.TOP,
      );
    }
  }

  void _getFilePath() async {
    final s = context.s;
    try {
      var filePickResult =
          await FilePicker.platform.pickFiles(type: FileType.any);
      if (filePickResult == null) {
        return;
      }
      Fluttertoast.showToast(
        msg: s.toastReadFile,
        gravity: ToastGravity.TOP,
      );
      final filePath = filePickResult.files.first.path;
      _saveOmpl(filePath);
    } on PlatformException catch (e) {
      developer.log(e.toString(), name: 'Get OMPL file');
    }
  }

  @override
  Widget build(BuildContext context) {
    var refreshWorker = Provider.of<RefreshWorker>(context, listen: false);
    final s = context.s;
    return PopupMenuButton<int>(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 1,
      tooltip: s.menu,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Container(
            padding: EdgeInsets.only(left: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(LineIcons.cloud_download_alt_solid),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      s.homeToprightMenuRefreshAll,
                    ),
                    FutureBuilder<String>(
                        future: _getRefreshDate(context),
                        builder: (_, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            );
                          } else {
                            return Center();
                          }
                        })
                  ],
                ),
              ],
            ),
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Container(
            padding: EdgeInsets.only(left: 10),
            child: Row(
              children: <Widget>[
                Icon(LineIcons.paperclip_solid),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                ),
                Text(s.homeToprightMenuImportOMPL),
              ],
            ),
          ),
        ),
        PopupMenuItem(
          value: 4,
          child: Container(
            padding: EdgeInsets.only(left: 10),
            child: Row(
              children: <Widget>[
                Icon(LineIcons.cog_solid),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                ),
                Text(s.settings),
              ],
            ),
          ),
        ),
        PopupMenuItem(
          value: 5,
          child: Container(
            padding: EdgeInsets.only(left: 10),
            child: Row(
              children: <Widget>[
                Icon(LineIcons.info_circle_solid),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                ),
                Text(s.homeToprightMenuAbout),
              ],
            ),
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 5) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AboutApp()));
        } else if (value == 2) {
          _getFilePath();
        } else if (value == 1) {
          //_refreshAll();
          refreshWorker.start();
        } else if (value == 3) {
          //  setting.theme != 2 ? setting.setTheme(2) : setting.setTheme(1);
        } else if (value == 4) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Settings()));
        }
      },
    );
  }
}
