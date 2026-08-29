import 'package:dynamic_color/dynamic_color.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:material_ui/material_ui.dart' as material_ui;
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

ColorScheme _toFlutterColorScheme(material_ui.ColorScheme scheme) {
  return ColorScheme.fromSeed(
    seedColor: scheme.primary,
    brightness: scheme.brightness,
  ).copyWith(
    primary: scheme.primary,
    onPrimary: scheme.onPrimary,
    primaryContainer: scheme.primaryContainer,
    onPrimaryContainer: scheme.onPrimaryContainer,
    primaryFixed: scheme.primaryFixed,
    primaryFixedDim: scheme.primaryFixedDim,
    onPrimaryFixed: scheme.onPrimaryFixed,
    onPrimaryFixedVariant: scheme.onPrimaryFixedVariant,
    secondary: scheme.secondary,
    onSecondary: scheme.onSecondary,
    secondaryContainer: scheme.secondaryContainer,
    onSecondaryContainer: scheme.onSecondaryContainer,
    secondaryFixed: scheme.secondaryFixed,
    secondaryFixedDim: scheme.secondaryFixedDim,
    onSecondaryFixed: scheme.onSecondaryFixed,
    onSecondaryFixedVariant: scheme.onSecondaryFixedVariant,
    tertiary: scheme.tertiary,
    onTertiary: scheme.onTertiary,
    tertiaryContainer: scheme.tertiaryContainer,
    onTertiaryContainer: scheme.onTertiaryContainer,
    tertiaryFixed: scheme.tertiaryFixed,
    tertiaryFixedDim: scheme.tertiaryFixedDim,
    onTertiaryFixed: scheme.onTertiaryFixed,
    onTertiaryFixedVariant: scheme.onTertiaryFixedVariant,
    error: scheme.error,
    onError: scheme.onError,
    errorContainer: scheme.errorContainer,
    onErrorContainer: scheme.onErrorContainer,
    surface: scheme.surface,
    onSurface: scheme.onSurface,
    surfaceDim: scheme.surfaceDim,
    surfaceBright: scheme.surfaceBright,
    surfaceContainerLowest: scheme.surfaceContainerLowest,
    surfaceContainerLow: scheme.surfaceContainerLow,
    surfaceContainer: scheme.surfaceContainer,
    surfaceContainerHigh: scheme.surfaceContainerHigh,
    surfaceContainerHighest: scheme.surfaceContainerHighest,
    onSurfaceVariant: scheme.onSurfaceVariant,
    outline: scheme.outline,
    outlineVariant: scheme.outlineVariant,
    shadow: scheme.shadow,
    scrim: scheme.scrim,
    inverseSurface: scheme.inverseSurface,
    onInverseSurface: scheme.onInverseSurface,
    inversePrimary: scheme.inversePrimary,
    surfaceTint: scheme.surfaceTint,
  );
}

Future main() async {
  timeDilation = 1.0;
  WidgetsFlutterBinding.ensureInitialized();
  await themeSetting.initData();
  await FlutterDownloader.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeSetting),
        ChangeNotifierProvider(create: (_) => AudioPlayerNotifier()),
        ChangeNotifierProvider(create: (_) => GroupList()),
        ChangeNotifierProvider(create: (_) => RefreshWorker()),
        ChangeNotifierProvider(create: (_) => SearchState()),
        ChangeNotifierProvider(lazy: false, create: (_) => DownloadState()),
      ],
      child: MyApp(),
    ),
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<
      SettingState,
      Tuple4<ThemeMode?, ThemeData, ThemeData, bool?>
    >(
      selector: (_, setting) => Tuple4(
        setting.theme,
        setting.lightTheme,
        setting.darkTheme,
        setting.useWallpaperTheme,
      ),
      builder: (_, data, child) {
        return FeatureDiscovery(
          child: DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) {
              final lightTheme = data.item4! && lightDynamic != null
                  ? data.item2.copyWith(
                      colorScheme: _toFlutterColorScheme(lightDynamic),
                    )
                  : data.item2;
              final darkTheme = data.item4! && darkDynamic != null
                  ? data.item3.copyWith(
                      colorScheme: _toFlutterColorScheme(darkDynamic),
                    )
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
            },
          ),
        );
      },
    );
  }
}
