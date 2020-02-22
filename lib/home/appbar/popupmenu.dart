import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:tsacdop/class/podcast_group.dart';
import 'package:tsacdop/class/settingstate.dart';
import 'package:xml/xml.dart' as xml;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:color_thief_flutter/color_thief_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

class PopupMenu extends StatelessWidget {
  Future<String> getColor(File file) async {
    final imageProvider = FileImage(file);
    var colorImage = await getImageFromProvider(imageProvider);
    var color = await getColorFromImage(colorImage);
    String primaryColor = color.toString();
    return primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    ImportOmpl importOmpl = Provider.of<ImportOmpl>(context, listen: false);
    GroupList groupList = Provider.of<GroupList>(context, listen: false);
    SettingState setting = Provider.of<SettingState>(context);
    _refreshAll() async {
      var dbHelper = DBHelper();
      List<PodcastLocal> podcastList = await dbHelper.getPodcastLocalAll();
      await Future.forEach(podcastList, (podcastLocal) async {
        importOmpl.rssTitle = podcastLocal.title;
        importOmpl.importState = ImportState.parse;
        await dbHelper.updatePodcastRss(podcastLocal);
        print('Refresh ' + podcastLocal.title);
      });
      importOmpl.importState = ImportState.complete;
    }

    saveOmpl(String rss) async {
      var dbHelper = DBHelper();
      importOmpl.importState = ImportState.import;

      Response response = await Dio().get(rss);
      if (response.statusCode == 200) {
        var _p = RssFeed.parse(response.data);
        var dir = await getApplicationDocumentsDirectory();

        Response<List<int>> imageResponse = await Dio().get<List<int>>(
            _p.itunes.image.href,
            options: Options(responseType: ResponseType.bytes));
        img.Image image = img.decodeImage(imageResponse.data);
        img.Image thumbnail = img.copyResize(image, width: 300);
        String _uuid = Uuid().v4();
        String _realUrl =
            response.isRedirect ? response.realUri.toString() : rss;
        print(_realUrl);

        bool _checkUrl = await dbHelper.checkPodcast(_realUrl);
        if (_checkUrl) {
          File("${dir.path}/$_uuid.png")
            ..writeAsBytesSync(img.encodePng(thumbnail));
          String _imagePath = "${dir.path}/$_uuid.png";
          String _primaryColor = await getColor(File("${dir.path}/$_uuid.png"));

          PodcastLocal podcastLocal = PodcastLocal(
              _p.title,
              _p.itunes.image.href,
              _realUrl,
              _primaryColor,
              _p.author,
              _uuid,
              _imagePath);

          podcastLocal.description = _p.description;

          groupList.subscribe(podcastLocal);

          importOmpl.importState = ImportState.parse;

          await dbHelper.savePodcastRss(_p, _uuid);

          importOmpl.importState = ImportState.complete;
        } else {
          importOmpl.importState = ImportState.error;

          Fluttertoast.showToast(
            msg: 'Podcast Subscribed Already',
            gravity: ToastGravity.TOP,
          );
          await Future.delayed(Duration(seconds: 5));
          importOmpl.importState = ImportState.stop;
        }
      } else {
        importOmpl.importState = ImportState.error;

        Fluttertoast.showToast(
          msg: 'Network error, Subscribe failed',
          gravity: ToastGravity.TOP,
        );
        await Future.delayed(Duration(seconds: 5));
        importOmpl.importState = ImportState.stop;
      }
    }

    void _saveOmpl(String path) async {
      File file = File(path);
      String opml = file.readAsStringSync();

      var content = xml.parse(opml);
      var total = content
          .findAllElements('outline')
          .map((ele) => OmplOutline.parse(ele))
          .toList();
      if (total.length == 0) {
        Fluttertoast.showToast(
          msg: 'File Not Valid',
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        for (int i = 0; i < total.length; i++) {
          if (total[i].xmlUrl != null) {
            importOmpl.rssTitle = total[i].text;
            try {
              await saveOmpl(total[i].xmlUrl);
            } catch (e) {
              print(e.toString());
            }
            print(total[i].text);
          }
        }
        print('Import fisnished');
      }
    }

    void _getFilePath() async {
      try {
        String filePath = await FilePicker.getFilePath(type: FileType.ANY);
        if (filePath == '') {
          return;
        }
        print('File Path' + filePath);
        importOmpl.importState = ImportState.start;
        _saveOmpl(filePath);
      } on PlatformException catch (e) {
        print(e.toString());
      }
    }

    return PopupMenuButton<int>(
      elevation: 3,
      tooltip: 'Menu',
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Text('Refresh All'),
        ),
        PopupMenuItem(
          value: 2,
          child: Text('Impoer OMPL'),
        ),
        PopupMenuItem(
          value: 3,
          child: setting.theme != 2 ? Text('Night Mode') : Text('Light Mode'),
        ),
        PopupMenuItem(
          value: 4,
          child: Text('About'),
        ),
      ],
      onSelected: (value) {
        if (value == 4) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AboutApp()));
        } else if (value == 2) {
          _getFilePath();
        } else if (value == 1) {
          _refreshAll();
        } else if (value == 3) {
          setting.theme != 2 ? setting.setTheme(2) : setting.setTheme(1);
        }
      },
    );
  }
}
