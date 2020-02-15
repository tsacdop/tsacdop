import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:tsacdop/home/appbar/addpodcast.dart';
import 'package:tsacdop/class/audiostate.dart';
import 'package:tsacdop/class/importompl.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Urlchange()),
        ChangeNotifierProvider(create: (context) => ImportOmpl()),
      ],
      child: MyApp(),
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await FlutterStatusbarcolor.setStatusBarColor(Colors.grey[100]);
  await FlutterStatusbarcolor.setNavigationBarColor(Colors.grey[100]);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
