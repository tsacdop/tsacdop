import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsacdop/generated/l10n.dart';
import 'package:tsacdop/home/about.dart';
import 'package:tsacdop/local_storage/key_value_storage.dart';
import 'package:tsacdop/main.dart';
import 'package:tsacdop/podcasts/custom_tabview.dart';
import 'package:tsacdop/state/setting_state.dart';
import 'package:tsacdop/type/search_api/searchpodcast.dart';
import 'package:tsacdop/util/extension_helper.dart';

class _TestSettingState extends SettingState {
  @override
  ThemeMode get theme => ThemeMode.light;

  @override
  ThemeData get lightTheme => ThemeData.light();

  @override
  ThemeData get darkTheme => ThemeData.dark();

  @override
  bool get useWallpaperTheme => false;

  @override
  bool get showIntro => true;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

void main() {
  testWidgets('about page uses the installed app version and normal app bar', (
    tester,
  ) async {
    PackageInfo.setMockInitialValues(
      appName: 'Tsacdop',
      packageName: 'com.stonegate.tsacdop',
      version: '1.0.1',
      buildNumber: '50',
      buildSignature: '',
      installerStore: null,
      installTime: null,
      updateTime: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [S.delegate],
        home: MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(top: 24)),
          child: const AboutApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Version: 1.0.1'), findsOneWidget);
    expect(tester.getTopLeft(find.byType(AppBar)).dy, 0);
  });

  test('falls back safely for missing or malformed image colors', () {
    expect(''.colorizedark(), const Color(0xFF009688));
    expect('not json'.colorizeLight(), const Color(0xFF649688));
  });

  test('handles incomplete podcast interval metadata', () {
    expect(OnlinePodcast(count: 0).interval, isNull);
    expect(OnlinePodcast(count: 4, latestPubDate: 100).interval, isNull);
    expect(
      OnlinePodcast(
        count: 4,
        earliestPubDate: 100,
        latestPubDate: 500,
      ).interval,
      100,
    );
  });

  test('repairs an invalid persisted accent color', () async {
    SharedPreferences.setMockInitialValues({accentsKey: 'FFA: 1.0'});
    final setting = SettingState();
    addTearDown(setting.dispose);

    await setting.initData();

    expect(setting.accentSetColor, Colors.teal[500]);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(accentsKey), '009688');
  });

  test('loads a legacy six-digit accent color', () async {
    SharedPreferences.setMockInitialValues({accentsKey: 'FF0000'});
    final setting = SettingState();
    addTearDown(setting.dispose);

    await setting.initData();

    expect(setting.accentSetColor, const Color(0xFFFF0000));
  });

  testWidgets('group tabs have no horizontal inset or bottom divider', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomTabView(
            itemCount: 2,
            tabBuilder: (_, index) => Tab(text: 'Group $index'),
            pageBuilder: (_, index) => Text('Page $index'),
          ),
        ),
      ),
    );

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.dividerHeight, 0);
    expect(tabBar.tabAlignment, TabAlignment.start);
    expect(tabBar.splashFactory, NoSplash.splashFactory);
    expect(tabBar.overlayColor?.resolve(<WidgetState>{}), Colors.transparent);

    final tabContainer = tester.widget<Container>(
      find.byWidgetPredicate(
        (widget) => widget is Container && widget.child is TabBar,
      ),
    );
    expect(tabContainer.padding, const EdgeInsets.symmetric(vertical: 10));
  });

  testWidgets('renders the localized introduction screen', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider<SettingState>.value(
        value: _TestSettingState(),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });
}
