import 'package:dynamic_color/dynamic_color.dart';
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
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<SettingState,
        Tuple4<ThemeMode?, ThemeData, ThemeData, bool?>>(
      selector: (_, setting) => Tuple4(setting.theme, setting.lightTheme,
          setting.darkTheme, setting.useWallpaperTheme),
      builder: (_, data, child) {
        return FeatureDiscovery(
          child: DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
            final lightTheme = data.item4!
                ? data.item2.copyWith(colorScheme: lightDynamic)
                : data.item2;
            final darkTheme = data.item4!
                ? data.item3.copyWith(colorScheme: lightDynamic)
                : data.item3;
            return MaterialApp(
              themeMode: data.item1,
              debugShowCheckedModeBanner: false,
              title: 'Tsacdop',
              theme: lightTheme,
              darkTheme: darkTheme,
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
            );
          }),
        );
      },
    );
  }
}
