import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:tsacdop/class/fireside_data.dart';
import 'package:tsacdop/class/refresh_podcast.dart';
import 'package:tsacdop/class/subscribe_podcast.dart';
import 'package:tsacdop/local_storage/key_value_storage.dart';
import 'package:xml/xml.dart' as xml;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:color_thief_flutter/color_thief_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';
import 'package:intl/intl.dart';

import 'package:tsacdop/class/podcast_group.dart';
import 'package:tsacdop/settings/settting.dart';
import 'about.dart';
import 'package:tsacdop/class/podcastlocal.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:tsacdop/class/importompl.dart';
import 'package:tsacdop/webfeed/webfeed.dart';

class OmplOutline {
  final String text;
  final String xmlUrl;
  OmplOutline({this.text, this.xmlUrl});

  factory OmplOutline.parse(xml.XmlElement element) {
    if (element == null) return null;
    return OmplOutline(
      text: element.getAttribute("text")?.trim(),
      xmlUrl: element.getAttribute("xmlUrl")?.trim(),
    );
  }
}

class PopupMenu extends StatefulWidget {
  @override
  _PopupMenuState createState() => _PopupMenuState();
}

class _PopupMenuState extends State<PopupMenu> {
  Future<String> _getColor(File file) async {
    final imageProvider = FileImage(file);
    var colorImage = await getImageFromProvider(imageProvider);
    var color = await getColorFromImage(colorImage);
    String primaryColor = color.toString();
    return primaryColor;
  }

  Future<String> _getRefreshDate() async {
    int refreshDate;
    KeyValueStorage refreshstorage = KeyValueStorage('refreshdate');
    int i = await refreshstorage.getInt();
    if (i == 0) {
      KeyValueStorage refreshstorage = KeyValueStorage('refreshdate');
      await refreshstorage.saveInt(DateTime.now().millisecondsSinceEpoch);
      refreshDate = DateTime.now().millisecondsSinceEpoch;
    } else {
      refreshDate = i;
    }
    DateTime date = DateTime.fromMillisecondsSinceEpoch(refreshDate);
    var diffrence = DateTime.now().difference(date);
    if (diffrence.inMinutes < 10) {
      return 'Just now';
    } else if (diffrence.inHours < 1) {
      return '1 hour ago';
    } else if (diffrence.inHours < 24) {
      return '${diffrence.inHours} hours ago';
    } else if (diffrence.inHours == 24) {
      return '1 day ago';
    } else if (diffrence.inDays < 7) {
      return '${diffrence.inDays} days ago';
    } else {
      return DateFormat.yMMMd()
          .format(DateTime.fromMillisecondsSinceEpoch(refreshDate));
    }
  }

  @override
  Widget build(BuildContext context) {
//    ImportOmpl importOmpl = Provider.of<ImportOmpl>(context, listen: false);
//    GroupList groupList = Provider.of<GroupList>(context, listen: false);
    var refreshWorker = Provider.of<RefreshWorker>(context, listen: false);
    var subscribeWorker = Provider.of<SubscribeWorker>(context, listen: false);
//    _refreshAll() async {
//      var dbHelper = DBHelper();
//      List<PodcastLocal> podcastList = await dbHelper.getPodcastLocalAll();
//      int i = 0;
//      await Future.forEach(podcastList, (podcastLocal) async {
//        importOmpl.rssTitle = podcastLocal.title;
//        importOmpl.importState = ImportState.parse;
//        i += await dbHelper.updatePodcastRss(podcastLocal);
//        print('Refresh ' + podcastLocal.title);
//      });
//      KeyValueStorage refreshstorage = KeyValueStorage('refreshdate');
//      await refreshstorage.saveInt(DateTime.now().millisecondsSinceEpoch);
//      KeyValueStorage refreshcountstorage = KeyValueStorage('refreshcount');
//      await refreshcountstorage.saveInt(i);
//      importOmpl.importState = ImportState.complete;
//      groupList.updateGroups();
//    }
//
//    saveOmpl(String rss) async {
//      var dbHelper = DBHelper();
//      importOmpl.importState = ImportState.import;
//      BaseOptions options = new BaseOptions(
//        connectTimeout: 20000,
//        receiveTimeout: 20000,
//      );
//      Response response = await Dio(options).get(rss);
//      if (response.statusCode == 200) {
//        var _p = RssFeed.parse(response.data);
//
//        var dir = await getApplicationDocumentsDirectory();
//
//        String _realUrl =
//            response.redirects.isEmpty ? rss : response.realUri.toString();
//
//        print(_realUrl);
//        bool _checkUrl = await dbHelper.checkPodcast(_realUrl);
//
//        if (_checkUrl) {
//          Response<List<int>> imageResponse = await Dio().get<List<int>>(
//              _p.itunes.image.href,
//              options: Options(responseType: ResponseType.bytes));
//          img.Image image = img.decodeImage(imageResponse.data);
//          img.Image thumbnail = img.copyResize(image, width: 300);
//          String _uuid = Uuid().v4();
//          File("${dir.path}/$_uuid.png")
//            ..writeAsBytesSync(img.encodePng(thumbnail));
//
//          String _imagePath = "${dir.path}/$_uuid.png";
//          String _primaryColor =
//              await _getColor(File("${dir.path}/$_uuid.png"));
//          String _author = _p.itunes.author ?? _p.author ?? '';
//          String _provider = _p.generator ?? '';
//          String _link = _p.link ?? '';
//          PodcastLocal podcastLocal = PodcastLocal(
//              _p.title,
//              _p.itunes.image.href,
//              _realUrl,
//              _primaryColor,
//              _author,
//              _uuid,
//              _imagePath,
//              _provider,
//              _link,
//              description: _p.description);
//
//          await groupList.subscribe(podcastLocal);
//
//          if (_provider.contains('fireside')) {
//            FiresideData data = FiresideData(_uuid, _link);
//            await data.fatchData();
//          }
//
//          importOmpl.importState = ImportState.parse;
//
//          await dbHelper.savePodcastRss(_p, _uuid);
//          groupList.updatePodcast(podcastLocal.id);
//          importOmpl.importState = ImportState.complete;
//        } else {
//          importOmpl.importState = ImportState.error;
//
//          Fluttertoast.showToast(
//            msg: 'Podcast Subscribed Already',
//            gravity: ToastGravity.TOP,
//          );
//          await Future.delayed(Duration(seconds: 5));
//          importOmpl.importState = ImportState.stop;
//        }
//      } else {
//        importOmpl.importState = ImportState.error;
//
//        Fluttertoast.showToast(
//          msg: 'Network error, Subscribe failed',
//          gravity: ToastGravity.TOP,
//        );
//        await Future.delayed(Duration(seconds: 5));
//        importOmpl.importState = ImportState.stop;
//      }
//    }
//
    void _saveOmpl(String path) async {
      File file = File(path);
      try {
        String opml = file.readAsStringSync();

        var content = xml.parse(opml);
        var total = content
            .findAllElements('outline')
            .map((ele) => OmplOutline.parse(ele))
            .toList();
        if (total.length == 0) {
          Fluttertoast.showToast(
            msg: 'File not valid',
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          for (int i = 0; i < total.length; i++) {
            if (total[i].xmlUrl != null) {
              //  importOmpl.rssTitle = total[i].text;
              //await saveOmpl(total[i].xmlUrl);
              SubscribeItem item =
                  SubscribeItem(total[i].xmlUrl, total[i].text);
              await subscribeWorker.setSubscribeItem(item);
              await Future.delayed(Duration(milliseconds: 500));
              print(total[i].text);
            }
          }
          print('Import fisnished');
        }
      } catch (e) {
        print(e);
        Fluttertoast.showToast(
          msg: 'File error, Subscribe failed',
          gravity: ToastGravity.TOP,
        );
        //await Future.delayed(Duration(seconds: 5));
        //  importOmpl.importState = ImportState.stop;
      }
    }

    void _getFilePath() async {
      try {
        String filePath = await FilePicker.getFilePath(type: FileType.any);
        if (filePath == '') {
          return;
        }
        print('File Path' + filePath);
        //importOmpl.importState = ImportState.start;
        Fluttertoast.showToast(
          msg: 'Read file successfully',
          gravity: ToastGravity.TOP,
        );
        _saveOmpl(filePath);
      } on PlatformException catch (e) {
        print(e.toString());
      }
    }

    return PopupMenuButton<int>(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 1,
      tooltip: 'Menu',
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
                      'Refresh All',
                    ),
                    FutureBuilder<String>(
                        future: _getRefreshDate(),
                        builder: (_, snapshot) {
                          if (snapshot.hasData)
                            return Text(
                              snapshot.data,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            );
                          else
                            return Center();
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
                Text('Import OMPL'),
              ],
            ),
          ),
        ),

        //  PopupMenuItem(
        //    value: 3,
        //    child: setting.theme != 2 ? Text('Night Mode') : Text('Light Mode'),
        //  ),
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
                Text('Settings'),
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
                Text('About'),
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
