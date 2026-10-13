import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsacdop/generated/l10n.dart';
import 'package:tsacdop/home/home.dart';
import 'package:tsacdop/local_storage/key_value_storage.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:tsacdop/state/download_state.dart';
import 'package:tsacdop/type/download_sort.dart';
import 'package:tsacdop/type/episodebrief.dart';
import 'package:tsacdop/widgets/custom_widget.dart';

class _DownloadsDB extends DBHelper {
  final List<(int?, bool)> queries = [];

  @override
  Future<List<EpisodeBrief>> getDownloadedEpisode(
    int? mode, {
    bool hideListened = false,
  }) async {
    queries.add((mode, hideListened));
    return [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('vn.hunghd/downloader');
  late _DownloadsDB database;
  late DownloadState downloads;

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => null);
    await FlutterDownloader.initialize();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({autoDeleteKey: -1});
    database = _DownloadsDB();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (call) async => call.method == 'loadTasks' ? [] : null,
        );
    downloads = DownloadState(dbHelper: database);
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() {
    downloads.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<void> showTab(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: downloads,
        child: MaterialApp(
          locale: locale,
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(body: DownloadsTab(dbHelper: database)),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
  }

  Future<void> chooseSort(WidgetTester tester, String label) async {
    await tester.tap(find.byTooltip('Sort by'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.ancestor(
        of: find.text(label),
        matching: find.byType(CheckedPopupMenuItem<DownloadSort>),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('downloads tab exposes each sort and applies the selection', (
    tester,
  ) async {
    await showTab(tester);
    expect(database.queries.last, (DownloadSort.newest.index, false));
    for (final (label, sort) in [
      ('Oldest first', DownloadSort.oldest),
      ('Episode title (A–Z)', DownloadSort.title),
      ('Podcast name (A–Z)', DownloadSort.podcast),
      ('Newest first', DownloadSort.newest),
    ]) {
      await chooseSort(tester, label);
      expect(database.queries.last, (sort.index, false));
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getInt(downloadSortKey), sort.index);
      await tester.tap(find.byTooltip('Sort by'));
      await tester.pumpAndSettle();
      final selected = tester
          .widgetList<CheckedPopupMenuItem<DownloadSort>>(
            find.byType(CheckedPopupMenuItem<DownloadSort>),
          )
          .where((item) => item.checked);
      expect(selected.single.value, sort);
      await tester.tapAt(const Offset(10, 500));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('restores sorting after recreating the downloads tab', (
    tester,
  ) async {
    await showTab(tester);
    await chooseSort(tester, 'Podcast name (A–Z)');
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();

    await showTab(tester);

    expect(database.queries.last, (DownloadSort.podcast.index, false));
  });

  testWidgets('sort changes preserve the listened filter and layout', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      autoDeleteKey: -1,
      hideListenedKey: 1,
      downloadLayoutKey: 0,
      downloadSortKey: DownloadSort.title.index,
    });
    await showTab(tester);
    expect(database.queries.last, (DownloadSort.title.index, true));
    final layoutBefore = tester
        .widget<LayoutButton>(find.byType(LayoutButton))
        .layout;

    await chooseSort(tester, 'Oldest first');

    expect(database.queries.last, (DownloadSort.oldest.index, true));
    expect(
      tester.widget<LayoutButton>(find.byType(LayoutButton)).layout,
      layoutBefore,
    );
    await tester.tap(
      find.ancestor(
        of: find.byType(HideListened),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(database.queries.last, (DownloadSort.oldest.index, false));
  });

  testWidgets('an invalid saved sort falls back to newest', (tester) async {
    SharedPreferences.setMockInitialValues({
      autoDeleteKey: -1,
      downloadSortKey: 99,
    });
    await showTab(tester);
    expect(database.queries.last, (DownloadSort.newest.index, false));
  });

  testWidgets('sorting controls fit a narrow screen with localized labels', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await showTab(tester, locale: const Locale('fr'));
    await tester.tap(find.byType(PopupMenuButton<DownloadSort>));
    await tester.pumpAndSettle();
    expect(find.text('Nom du podcast (A–Z)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
