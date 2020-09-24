import 'dart:convert';
import 'dart:developer' as developer;

import 'package:cookie_jar/cookie_jar.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';

enum GpodderSyncStatus { none, success, fail, authError }

class Gpodder {
  final _dio = Dio(BaseOptions(
    connectTimeout: 30000,
    receiveTimeout: 90000,
    sendTimeout: 90000,
  ));
  final _storage = KeyValueStorage(gpodderApiKey);
  final _addStorage = KeyValueStorage(gpodderAddKey);
  final _removeStorage = KeyValueStorage(gpodderRemoveKey);
  final _remoteAddStorage = KeyValueStorage(gpodderRemoteAddKey);
  final _remoteRemoveStorage = KeyValueStorage(gpodderRemoteRemoveKey);
  final _dateTimeStorage = KeyValueStorage(gpodderSyncDateTimeKey);
  final _statusStorage = KeyValueStorage(gpodderSyncStatusKey);

  final _baseUrl = "https://gpodder.net";

  Future<void> _initDio() async {
    final dir = await getApplicationDocumentsDirectory();
    var cookieJar = PersistCookieJar(dir: "${dir.path}/.cookies/");
    _dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<int> login({String username, String password}) async {
    final dir = await getApplicationDocumentsDirectory();
    var cookieJar = PersistCookieJar(dir: "${dir.path}/.cookies/");
    cookieJar.delete(Uri.parse(_baseUrl));
    _dio.interceptors.add(CookieManager(cookieJar));
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    var status;
    Response response;
    try {
      response = await _dio.post('$_baseUrl/api/2/auth/$username/login.json',
          options:
              Options(headers: <String, String>{'authorization': basicAuth}));
      status = response.statusCode;
    } catch (e) {
      developer.log(e.toString(), name: 'gpoderr login error');
      return 0;
    }
    return status;
  }

  Future<int> logout() async {
    final loginInfo = await _storage.getStringList();
    final username = loginInfo[0];
    await _initDio();
    var status;
    try {
      var response = await _dio.post(
        '$_baseUrl/api/2/auth/$username/logout.json',
      );
      status = response.statusCode;
    } catch (e) {
      developer.log(e.toString(), name: 'gpoderr logout error');
      if (status == 400) {
        await _initService();
      }
      return 0;
    }
    if (status == 200) {
      await _initService();
    }
    return status;
  }

  Future<void> _initService() async {
    final dir = await getApplicationDocumentsDirectory();
    var cookieJar = PersistCookieJar(dir: "${dir.path}/.cookies/");
    cookieJar.delete(Uri.parse(_baseUrl));
    await _storage.clearList();
    await _addStorage.clearList();
    await _remoteAddStorage.clearList();
    await _removeStorage.clearList();
    await _remoteAddStorage.clearList();
    await _statusStorage.saveInt(0);
    await _dateTimeStorage.saveInt(0);
  }

  Future<int> checkLogin(String username) async {
    await _initDio();
    var response = await _dio.post(
      '$_baseUrl/api/2/auth/$username/login.json',
    );
    final status = response.statusCode;
    return status;
  }

  Future<int> updateDevice(String username) async {
    await _initDio();
    final deviceId = Uuid().v1();
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    var status = 0;
    try {
      var response = await _dio
          .post("$_baseUrl/api/2/devices/$username/$deviceId.json", data: {
        "caption": "Tsacdop on ${androidInfo.model}",
        "type": "mobile"
      });
      status = response.statusCode;
    } catch (e) {
      developer.log(e.toString(), name: 'gpodder update device error');
      return 0;
    }
    if (status == 200) {
      await _storage.saveStringList([username, deviceId]);
    }
    return status;
  }

  Future<String> getAllPodcast() async {
    final loginInfo = await _storage.getStringList();
    final username = loginInfo[0];
    Response response;
    await _initDio();
    try {
      response = await _dio.get(
        '$_baseUrl/subscriptions/$username.opml',
      );
    } catch (e) {
      developer.log(e.toString(), name: 'gpodder update podcasts error');
      return '';
    }
    return response.data;
  }

  Future<int> uploadSubscriptions() async {
    final syncDataTime = DateTime.now().millisecondsSinceEpoch;
    await _dateTimeStorage.saveInt(syncDataTime);
    final loginInfo = await _storage.getStringList();
    final username = loginInfo[0];
    final deviceId = loginInfo[1];
    await _initDio();
    final dbHelper = DBHelper();
    final podcasts = await dbHelper.getPodcastLocalAll();
    var subscriptions = '';
    for (var podcast in podcasts) {
      subscriptions += '${podcast.rssUrl}\n';
    }
    var status;
    try {
      final response = await _dio.put(
          '$_baseUrl/subscriptions/$username/$deviceId.txt',
          data: subscriptions);
      status = response.statusCode;
    } catch (e) {
      developer.log(e.toString(), name: 'gpodder update podcasts error');
      return 0;
    }
    return status;
  }

  Future<int> getChanges() async {
    final loginInfo = await _storage.getStringList();
    final username = loginInfo[0];
    final deviceId = loginInfo[1];
    final syncDataTime = DateTime.now().millisecondsSinceEpoch;
    await _dateTimeStorage.saveInt(syncDataTime);
    final timeStamp = loginInfo.length == 3 ? int.parse(loginInfo[2]) : 0;
    var status;
    Response response;
    await _initDio();
    try {
      response = await _dio.get(
          "$_baseUrl/api/2/subscriptions/$username/$deviceId.json",
          queryParameters: {'since': timeStamp});
      status = response.statusCode;
    } catch (e) {
      developer.log(e.toString(), name: 'gpodder update podcasts error');
      if (status == 401) {
        _statusStorage.saveInt(3);
      } else {
        _statusStorage.saveInt(2);
      }
      return 0;
    }
    if (status == 200) {
      Map changes = jsonDecode(response.toString());
      final timeStamp = changes['timestamp'];
      final addList = changes['add'].cast<String>();
      final removeList = changes['remove'].cast<String>();
      await _storage.saveStringList([username, deviceId, timeStamp.toString()]);
      await _remoteAddStorage.addList(addList);
      await _remoteRemoveStorage.addList(removeList);
    }
    return status;
  }

  Future<int> updateChange() async {
    final loginInfo = await _storage.getStringList();
    final addList = await _addStorage.getStringList();
    final removeList = await _removeStorage.getStringList();
    final username = loginInfo[0];
    final deviceId = loginInfo[1];
    await _initDio();
    var status;
    Response response;
    try {
      response = await _dio.post(
          '$_baseUrl/api/2/subscriptions/$username/$deviceId.json',
          data: {'add': addList, 'remove': removeList});
      status = response.statusCode;
    } catch (e) {
      if (status == 401) {
        _statusStorage.saveInt(3);
      } else {
        _statusStorage.saveInt(2);
      }
      developer.log(e.toString(), name: 'gpodder update podcasts error');
      return 0;
    }
    if (status == 200) {
      await _addStorage.clearList();
      await _removeStorage.clearList();
      await _statusStorage.saveInt(1);
      Map changes = jsonDecode(response.toString());
      final timeStamp = changes['timestamp'] as int;
      await _storage
          .saveStringList([username, deviceId, (timeStamp + 1).toString()]);
    }
    return status;
  }
}
