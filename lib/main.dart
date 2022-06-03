import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'generated/l10n.dart';
import 'home/home.dart';
import 'intro_slider/app_intro.dart';
import 'playlists/playlist_home.dart';
import 'state/audio_state.dart';
import 'state/download_state.dart';
import 'state/podcast_group.dart';
import 'state/refresh_podcast.dart';
import 'state/search_state.dart';
import 'state/setting_state.dart';

///Initial theme settings
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
        ChangeNotifierProvider(create: (_) => SearchState()),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => DownloadState(),
        )
      ],
      child: MyApp(),
    ),
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<SettingState, Tuple3<ThemeMode?, ThemeData, ThemeData>>(
      selector: (_, setting) =>
          Tuple3(setting.theme, setting.lightTheme, setting.darkTheme),
      builder: (_, data, child) {
        return FeatureDiscovery(
          child: MaterialApp(
            themeMode: data.item1,
            debugShowCheckedModeBanner: false,
            title: 'Tsacdop',
            theme: data.item2,
            darkTheme: data.item3,
            localizationsDelegates: [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: context.read<SettingState>().showIntro!
                ? SlideIntro(goto: Goto.home)
                : context.read<SettingState>().openPlaylistDefault!
                    ? PlaylistHome()
                    : Home(),
          ),
        );
      },
    );
  }
}
