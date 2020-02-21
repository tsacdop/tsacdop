import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:tsacdop/class/podcast_group.dart';
import 'package:tsacdop/home/appbar/addpodcast.dart';
import 'package:tsacdop/class/audiostate.dart';
import 'package:tsacdop/class/importompl.dart';
import 'package:tsacdop/class/settingstate.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AudioPlay()),
        ChangeNotifierProvider(create: (context) => ImportOmpl()),
        ChangeNotifierProvider(create: (context) => SettingState()),
        ChangeNotifierProvider(create: (context) => GroupList()),
      ],
      child: MyApp(),
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.grey[100]));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TsacDop',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: MyHomePage(),
    );
  }
}
