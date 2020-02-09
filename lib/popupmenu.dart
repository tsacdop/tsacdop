import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:xml/xml.dart' as xml;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'about.dart';
import 'class/podcastlocal.dart';
import 'class/sqflite_localpodcast.dart';
import 'class/importompl.dart';
import 'webfeed/webfeed.dart';

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

  Future<int> saveOmpl(String rss) async {
    var dbHelper = DBHelper();
    try {
      Response response = await Dio().get(rss);
      var _p = RssFeed.parse(response.data);
      String _primaryColor = '[100,100,100]';
      PodcastLocal podcastLocal = PodcastLocal(_p.title, _p.itunes.image.href,
          rss, _primaryColor, _p.author);
          podcastLocal.description = _p.description;
      int total = await dbHelper.savePodcastLocal(podcastLocal);
      return total;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final importOmpl = Provider.of<ImportOmpl>(context);

    void _saveOmpl(String path) async {
      File file = File(path);
      String opml = file.readAsStringSync();
      try {
        var content = xml.parse(opml);
        importOmpl.importState = ImportState.import;
        var total = content
            .findAllElements('outline')
            .map((ele) => OmplOutline.parse(ele))
            .toList();
        for (int i = 0; i < total.length; i++) {
          if (total[i].xmlUrl != null)
             await saveOmpl(total[i].xmlUrl);
          importOmpl.rssTitle = total[i].text;
          print(total[i].text);
        }
        importOmpl.importState = ImportState.complete;
        print('Import fisnished');
      } catch (e) {
        print(e);
        importOmpl.importState = ImportState.error;
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
      elevation: 2,
      tooltip: 'Menu',
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Text('Impoer OMPL'),
        ),
        PopupMenuItem(
          value: 2,
          child: Text('About'),
        ),
      ],
      onSelected: (value) {
        if (value == 2) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AboutApp()));
        } else if (value == 1) {
          _getFilePath();
        }
      },
    );
  }
}
