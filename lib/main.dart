import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:workmanager/workmanager.dart';

import 'package:tsacdop/class/podcastlocal.dart';
import 'package:tsacdop/class/podcast_group.dart';
import 'package:tsacdop/home/appbar/addpodcast.dart';
import 'package:tsacdop/class/audiostate.dart';
import 'package:tsacdop/class/importompl.dart';
import 'package:tsacdop/class/settingstate.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    var dbHelper = DBHelper();
    print('Start task');
    List<PodcastLocal> podcastList = await dbHelper.getPodcastLocalAll();
    await Future.forEach(podcastList, (podcastLocal) async {
      await dbHelper.updatePodcastRss(podcastLocal);
      print('Refresh ' + podcastLocal.title);
    });
    return Future.value(true);
  });
}

final SettingState themeSetting = SettingState();
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await themeSetting.initData();
  await FlutterDownloader.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeSetting),
        ChangeNotifierProvider(create: (_) => AudioPlayerNotifier()),
        ChangeNotifierProvider(create: (_) => GroupList()),
        ChangeNotifierProvider(create: (_) => ImportOmpl()),
      ],
      child: MyApp(),
    ),
  );
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}

class MyApp extends StatelessWidget {
  void setWorkManager() {
    Workmanager.initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    
    Workmanager.registerPeriodicTask("1", "update_podcasts",
        frequency: Duration(hours: 12),
        initialDelay: Duration(seconds: 5),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ));
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingState>(
      builder: (_, setting, __) {
        if (setting.autoUpdate) setWorkManager();
        return MaterialApp(
          themeMode: setting.theme,
          debugShowCheckedModeBanner: false,
          title: 'Tsacdop',
          theme: ThemeData(
            accentColorBrightness: Brightness.dark,
            primaryColor: Colors.grey[100],
            accentColor: setting.accentSetColor,
            primaryColorLight: Colors.white,
            primaryColorDark: Colors.grey[300],
            dialogBackgroundColor: Colors.white,
            backgroundColor: Colors.grey[100],
            appBarTheme: AppBarTheme(
              color: Colors.grey[100],
              elevation: 0,
            ),
            textTheme: TextTheme(
              bodyText2:
                  TextStyle(fontSize: 15.0, fontWeight: FontWeight.normal),
            ),
            tabBarTheme: TabBarTheme(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[400],
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            accentColor: setting.accentSetColor,
            appBarTheme: AppBarTheme(elevation: 0),
          ),
          home: MyHomePage(),
        );
      },
    );
  }
}
