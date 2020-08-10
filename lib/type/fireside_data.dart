import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/parser.dart';

import '../local_storage/sqflite_localpodcast.dart';

class FiresideData {
  final String id;
  final String link;

  String _background;
  String get background => _background;
  List<PodcastHost> _hosts;
  List<PodcastHost> get hosts => _hosts;
  FiresideData(this.id, this.link);

  DBHelper dbHelper = DBHelper();

  String parseLink(String link) {
    if (link == "http://www.shengfm.cn/") {
      return "https://guiguzaozhidao.fireside.fm/";
    } else {
      return link;
    }
  }

  Future fatchData() async {
    var response = await Dio().get(parseLink(link));
    if (response.statusCode == 200) {
      var doc = parse(response.data);
      var reg = RegExp(r'https(.+)jpg');
      var backgroundImage = reg.stringMatch(doc.body
          .getElementsByClassName('hero-background')
          .first
          .attributes
          .toString());
      var ul = doc.body.getElementsByClassName('episode-hosts').first.children;
      var hosts = <PodcastHost>[];
      for (var element in ul) {
        PodcastHost host;
        var name = element.text.trim();
        var image = element.children.first.children.first.attributes.toString();
        host = PodcastHost(
            name,
            reg.stringMatch(image) ??
                'https://fireside.fm/assets/default/avatar_small'
                    '-170afdc2be97fc6148b283083942d82c101d4c1061f6b28f87c8958b52664af9.jpg');

        hosts.add(host);
      }
      var data = <String>[
        id,
        backgroundImage,
        json.encode({'hosts': hosts.map((host) => host.toJson()).toList()})
      ];
      await dbHelper.saveFiresideData(data);
    }
  }

  Future getData() async {
    var data = await dbHelper.getFiresideData(id);
    _background = data[0];
    if (data[1] != '') {
      _hosts = json
          .decode(data[1])['hosts']
          .cast<Map<String, Object>>()
          .map<PodcastHost>(PodcastHost.fromJson)
          .toList();
    } else {
      _hosts = null;
    }
  }
}

class PodcastHost {
  final String image;
  final String name;
  PodcastHost(this.name, this.image);

  Map<String, Object> toJson() {
    return {'name': name, 'image': image};
  }

  static PodcastHost fromJson(Map<String, Object> json) {
    return PodcastHost(json['name'] as String, json['image'] as String);
  }
}
