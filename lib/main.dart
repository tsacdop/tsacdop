import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:tsacdop/home/appbar/addpodcast.dart';
import 'package:tsacdop/class/audiostate.dart';
import 'package:tsacdop/class/importompl.dart';
import 'package:tsacdop/class/settingstate.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Urlchange()),
        ChangeNotifierProvider(create: (context) => ImportOmpl()),
        ChangeNotifierProvider(create: (context) => SettingState()),
      ],
      child: MyApp(),
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await FlutterStatusbarcolor.setStatusBarColor(Colors.grey[100]);
  if (useWhiteForeground(Colors.grey[100])) {
  FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
} else {
  FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
}
  await FlutterStatusbarcolor.setNavigationBarColor(Colors.grey[100]);
  if (useWhiteForeground(Colors.grey[100])) {
  FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
} else {
  FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
}
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
