import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:color_thief_flutter/color_thief_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'package:flutter_isolate/flutter_isolate.dart';

import '../webfeed/webfeed.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../type/fireside_data.dart';
import '../type/podcastlocal.dart';

enum SubscribeState { none, start, subscribe, fetch, stop, exist, error }

class SubscribeItem {
  String url;
  String title;
  SubscribeState subscribeState;
  String id;
  String imgUrl;
  SubscribeItem(this.url, this.title,
      {this.subscribeState = SubscribeState.none,
      this.id = '',
      this.imgUrl = ''});
}

class SubscribeWorker extends ChangeNotifier {
  FlutterIsolate subIsolate;
  ReceivePort receivePort;
  SendPort subSendPort;

  SubscribeItem _subscribeItem;
  SubscribeItem _currentSubscribeItem = SubscribeItem('', '');
  bool _created = false;
  bool get created => _created;

  setSubscribeItem(SubscribeItem item) async {
    _subscribeItem = item;
    await _start();
  }

  _setCurrentSubscribeItem(SubscribeItem item) {
    _currentSubscribeItem = item;
    notifyListeners();
  }

  SubscribeItem get currentSubscribeItem => _currentSubscribeItem;

  Future<void> _createIsolate() async {
    receivePort = ReceivePort();
    subIsolate =
        await FlutterIsolate.spawn(subIsolateEntryPoint, receivePort.sendPort);
  }

  void listen() {
    receivePort.distinct().listen((message) {
      if (message is SendPort) {
        subSendPort = message;
        subSendPort.send(
            [_subscribeItem.url, _subscribeItem.title, _subscribeItem.imgUrl]);
      } else if (message is List) {
        _setCurrentSubscribeItem(SubscribeItem(message[1], message[0],
            subscribeState: SubscribeState.values[message[2]],
            id: message.length == 4 ? message[3] : ''));
        print(message[2]);
      } else if (message is String && message == "done") {
        subIsolate.kill();
        subIsolate = null;
        _currentSubscribeItem = SubscribeItem('', '');
        _created = false;
        notifyListeners();
      }
    });
  }

  Future _start() async {
    if (_created == false) {
      await _createIsolate();
      _created = true;
      listen();
    } else
      subSendPort.send(
          [_subscribeItem.url, _subscribeItem.title, _subscribeItem.imgUrl]);
  }

  void dispose() {
    subIsolate?.kill();
    subIsolate = null;
    super.dispose();
  }
}

Future<void> subIsolateEntryPoint(SendPort sendPort) async {
  List<SubscribeItem> items = [];
  bool _running = false;
  ReceivePort subReceivePort = ReceivePort();
  sendPort.send(subReceivePort.sendPort);

  Future<String> _getColor(File file) async {
    final imageProvider = FileImage(file);
    var colorImage = await getImageFromProvider(imageProvider);
    var color = await getColorFromImage(colorImage);
    String primaryColor = color.toString();
    return primaryColor;
  }

  Future<void> _subscribe(SubscribeItem item) async {
    var dbHelper = DBHelper();
    String rss = item.url;
    sendPort.send([item.title, item.url, 1]);
    BaseOptions options = new BaseOptions(
      connectTimeout: 20000,
      receiveTimeout: 20000,
    );
    print(rss);

    try {
      Response response = await Dio(options).get(rss);
      RssFeed p;
      try {
        p = RssFeed.parse(response.data);
      } on ArgumentError catch (e) {
        print(e);
        sendPort.send([item.title, item.url, 6]);
        await Future.delayed(Duration(seconds: 2));
        sendPort.send([item.title, item.url, 4]);
        items.removeWhere((element) => element.url == item.url);
        if (items.length > 0) {
          await _subscribe(items.first);
        } else
          sendPort.send("done");
      }

      var dir = await getApplicationDocumentsDirectory();

      String realUrl =
          response.redirects.isEmpty ? rss : response.realUri.toString();

      bool checkUrl = await dbHelper.checkPodcast(realUrl);

      if (checkUrl) {
        img.Image thumbnail;
        String imageUrl;
        try {
          Response<List<int>> imageResponse = await Dio().get<List<int>>(
              p.itunes.image.href,
              options: Options(responseType: ResponseType.bytes));
          imageUrl = p.itunes.image.href;
          img.Image image = img.decodeImage(imageResponse.data);
          thumbnail = img.copyResize(image, width: 300);
        } catch (e) {
          try {
            Response<List<int>> imageResponse = await Dio().get<List<int>>(
                item.imgUrl,
                options: Options(responseType: ResponseType.bytes));
            imageUrl = item.imgUrl;
            img.Image image = img.decodeImage(imageResponse.data);
            thumbnail = img.copyResize(image, width: 300);
          } catch (e) {
            print(e);
            try {
              Response<List<int>> imageResponse = await Dio().get<List<int>>(
                  "https://ui-avatars.com/api/?size=300&background=4D91BE&color=fff&name=${item.title}&length=2&bold=true",
                  options: Options(responseType: ResponseType.bytes));
              imageUrl =
                  "https://ui-avatars.com/api/?size=300&background=4D91BE&color=fff&name=${item.title}&length=2&bold=true";
              thumbnail = img.decodeImage(imageResponse.data);
            } catch (e) {
              print(e);
              sendPort.send([item.title, item.url, 6]);
              await Future.delayed(Duration(seconds: 2));
              sendPort.send([item.title, item.url, 4]);
              items.removeWhere((element) => element.url == item.url);
              if (items.length > 0) {
                await _subscribe(items.first);
              } else
                sendPort.send("done");
            }
          }
        }
        String uuid = Uuid().v4();
        File("${dir.path}/$uuid.png")
          ..writeAsBytesSync(img.encodePng(thumbnail));

        String imagePath = "${dir.path}/$uuid.png";
        String primaryColor = await _getColor(File("${dir.path}/$uuid.png"));
        String author = p.itunes.author ?? p.author ?? '';
        String provider = p.generator ?? '';
        String link = p.link ?? '';
        PodcastLocal podcastLocal = PodcastLocal(p.title, imageUrl, realUrl,
            primaryColor, author, uuid, imagePath, provider, link,
            description: p.description);

        //   await groupList.subscribe(podcastLocal);
        await dbHelper.savePodcastLocal(podcastLocal);
        sendPort.send([item.title, item.url, 2, uuid]);
        if (provider.contains('fireside')) {
          FiresideData data = FiresideData(uuid, link);
          try {
            await data.fatchData();
          } catch (e) {
            print(e);
          }
        }
        int count = await dbHelper.savePodcastRss(p, uuid);

        sendPort.send([item.title, item.url, 3, uuid]);

        await Future.delayed(Duration(seconds: 2));

        sendPort.send([item.title, item.url, 4]);
        items.removeWhere((element) => element.url == item.url);
        if (items.length > 0) {
          await _subscribe(items.first);
        } else
          sendPort.send("done");
      } else {
        sendPort.send([item.title, item.url, 5]);
        await Future.delayed(Duration(seconds: 2));
        sendPort.send([item.title, item.url, 4]);
        items.removeWhere((element) => element.url == item.url);
        if (items.length > 0) {
          await _subscribe(items.first);
        } else
          sendPort.send("done");
      }
    } on DioError catch (e) {
      print(e);
      sendPort.send([item.title, item.url, 6]);
      await Future.delayed(Duration(seconds: 2));
      sendPort.send([item.title, item.url, 4]);
      items.removeWhere((element) => element.url == item.url);
      if (items.length > 0) {
        await _subscribe(items.first);
      } else
        sendPort.send("done");
    }
  }

  subReceivePort.distinct().listen((message) {
    if (message is List<String>) {
      items.add(SubscribeItem(message[0], message[1], imgUrl: message[2]));
      if (!_running) {
        _subscribe(items.first);
        _running = true;
      }
    }
  });
}
