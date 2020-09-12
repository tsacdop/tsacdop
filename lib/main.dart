import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';
import 'home/home.dart';
import 'intro_slider/app_intro.dart';
import 'state/audio_state.dart';
import 'state/download_state.dart';
import 'state/podcast_group.dart';
import 'state/refresh_podcast.dart';
import 'state/setting_state.dart';

final SettingState themeSetting = SettingState();
Future main() async {
  timeDilation = 1.0;
  WidgetsFlutterBinding.ensureInitialized();
  await themeSetting.initData();
  await FlutterDownloader.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => themeSetting,
        ),
        ChangeNotifierProvider(create: (_) => AudioPlayerNotifier()),
        ChangeNotifierProvider(create: (_) => GroupList()),
        ChangeNotifierProvider(create: (_) => RefreshWorker()),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => DownloadState(),
        )
      ],
      child: MyApp(),
    ),
  );
  var systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent);
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingState>(
      builder: (_, setting, __) {
        return FeatureDiscovery(
          child: MaterialApp(
            themeMode: setting.theme,
            debugShowCheckedModeBanner: false,
            title: 'Tsacdop',
            theme: lightTheme.copyWith(
                accentColor: setting.accentSetColor,
                cursorColor: setting.accentSetColor,
                textSelectionHandleColor: setting.accentSetColor,
                toggleableActiveColor: setting.accentSetColor,
                buttonTheme: ButtonThemeData(
                    hoverColor: setting.accentSetColor.withAlpha(70),
                    splashColor: setting.accentSetColor.withAlpha(70))),
            darkTheme: ThemeData.dark().copyWith(
                accentColor: setting.accentSetColor,
                primaryColorDark: Colors.grey[800],
                scaffoldBackgroundColor:
                    setting.realDark ? Colors.black87 : Color(0XFF212121),
                primaryColor:
                    setting.realDark ? Colors.black : Color(0XFF1B1B1B),
                popupMenuTheme: PopupMenuThemeData().copyWith(
                    color: setting.realDark ? Colors.grey[900] : null),
                appBarTheme: AppBarTheme(elevation: 0),
                buttonTheme: ButtonThemeData(height: 32),
                dialogBackgroundColor:
                    setting.realDark ? Colors.grey[900] : null,
                cursorColor: setting.accentSetColor),
            localizationsDelegates: [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: setting.showIntro ? SlideIntro(goto: Goto.home) : Home(),
          ),
        );
      },
    );
  }
}
