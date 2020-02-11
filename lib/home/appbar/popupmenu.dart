import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:xml/xml.dart' as xml;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:color_thief_flutter/color_thief_flutter.dart';
import 'package:image/image.dart' as img;

import 'about.dart';
import 'package:tsacdop/class/podcastlocal.dart';
import 'package:tsacdop/class/sqflite_localpodcast.dart';
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
    final importOmpl = Provider.of<ImportOmpl>(context);

    saveOmpl(String rss) async {
      var dbHelper = DBHelper();
      try {
        importOmpl.importState = ImportState.import;
        Response response = await Dio().get(rss);

        var _p = RssFeed.parse(response.data);
        var dir = await getApplicationDocumentsDirectory();

        Response<List<int>> imageResponse = await Dio().get<List<int>>(
            _p.itunes.image.href,
            options: Options(responseType: ResponseType.bytes));
        img.Image image = img.decodeImage(imageResponse.data);
        img.Image thumbnail = img.copyResize(image, width: 300);
        File("${dir.path}/${_p.title}.png")
          ..writeAsBytesSync(img.encodePng(thumbnail));

        String _primaryColor =
            await getColor(File("${dir.path}/${_p.title}.png"));

        PodcastLocal podcastLocal = PodcastLocal(
            _p.title, _p.itunes.image.href, rss, _primaryColor, _p.author);

        podcastLocal.description = _p.description;
        print('_p.description');
        await dbHelper.savePodcastLocal(podcastLocal);

        importOmpl.importState = ImportState.parse;

        await dbHelper.savePodcastRss(response.data);
      } catch (e) {
        print(e);
      }
    }

    void _saveOmpl(String path) async {
      File file = File(path);
      String opml = file.readAsStringSync();
      try {
        var content = xml.parse(opml);
        var total = content
            .findAllElements('outline')
            .map((ele) => OmplOutline.parse(ele))
            .toList();
        for (int i = 0; i < total.length; i++) {
          if (total[i].xmlUrl != null) {
            importOmpl.rssTitle = total[i].text;
            await saveOmpl(total[i].xmlUrl);
            print(total[i].text);
          }
        }
        importOmpl.importState = ImportState.complete;
        importOmpl.importState = ImportState.stop;
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
