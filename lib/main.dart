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
    var theme = Provider.of<SettingState>(context).theme;
    return MaterialApp(
      themeMode: theme == 0
          ? ThemeMode.system
          : theme == 1 ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      title: 'TsacDop',
      theme: ThemeData(
        accentColorBrightness: Brightness.dark,
        primaryColor: Colors.grey[100],
        accentColor: Colors.blue[400],
        primaryColorLight: Colors.white,
        primaryColorDark: Colors.grey[300],
        dialogBackgroundColor: Colors.white,
        backgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          color: Colors.grey[100],
          elevation: 0,
        ),
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          bodyText2: TextStyle(fontSize: 15.0, fontWeight: FontWeight.normal),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey[400],
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(accentColor: Colors.blue[400],),
      home: MyHomePage(),
    );
  }
}
