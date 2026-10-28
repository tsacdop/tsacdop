import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsacdop/episodes/episode_download.dart';
import 'package:tsacdop/generated/l10n.dart';
import 'package:tsacdop/local_storage/key_value_storage.dart';
import 'package:tsacdop/state/audio_state.dart';
import 'package:tsacdop/state/download_state.dart';
import 'package:tsacdop/type/episode_task.dart';
import 'package:tsacdop/type/episodebrief.dart';
import 'package:tsacdop/widgets/muiliselect_bar.dart';

const _episode = EpisodeBrief(
  'Episode',
  'https://example.com/episode.mp3',
  100,
  1000,
  'Podcast',
  null,
  0,
  0,
  '',
  0,
);
const _otherEpisode = EpisodeBrief(
  'Other episode',
  'https://example.com/other.mp3',
  100,
  1000,
  'Podcast',
  null,
  0,
  0,
  '',
  0,
);

class _RecordingDownloads extends ChangeNotifier implements DownloadState {
  final started = <EpisodeBrief>[];

  @override
  EpisodeTask episodeToTask(EpisodeBrief? episode) => EpisodeTask(episode, '');

  @override
  Future<void> startTask(
    EpisodeBrief episode, {
    bool showNotification = true,
  }) async {
    started.add(episode);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Audio extends ChangeNotifier implements AudioPlayerNotifier {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );
  const connectivityChannel = MethodChannel(
    'dev.fluttercommunity.plus/connectivity',
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late _RecordingDownloads downloads;
  late _Audio audio;
  late List<String> network;
  late List<MethodCall> permissionCalls;

  setUp(() {
    SharedPreferences.setMockInitialValues({downloadUsingDataKey: 0});
    downloads = _RecordingDownloads();
    audio = _Audio();
    network = ['wifi'];
    permissionCalls = [];
    // Modern Android denies the legacy storage permission. Downloads into the
    // app's own directory must work without checking or requesting it.
    messenger.setMockMethodCallHandler(permissionChannel, (call) async {
      permissionCalls.add(call);
      if (call.method == 'checkPermissionStatus') return 0;
      if (call.method == 'requestPermissions') {
        return {for (final permission in call.arguments as List) permission: 0};
      }
      throw StateError('Unexpected permission call: ${call.method}');
    });
    messenger.setMockMethodCallHandler(
      connectivityChannel,
      (_) async => network,
    );
  });

  tearDown(() {
    downloads.dispose();
    audio.dispose();
    messenger.setMockMethodCallHandler(permissionChannel, null);
    messenger.setMockMethodCallHandler(connectivityChannel, null);
    expect(permissionCalls, isEmpty);
  });

  Future<void> showDownload(WidgetTester tester, {required bool bulk}) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<DownloadState>.value(value: downloads),
          ChangeNotifierProvider<AudioPlayerNotifier>.value(value: audio),
        ],
        child: MaterialApp(
          localizationsDelegates: const [S.delegate],
          home: Scaffold(
            body: bulk
                ? MultiSelectMenuBar(
                    selectedList: const [_episode, _otherEpisode],
                    hideFavorite: true,
                    onClose: (_) {},
                  )
                : const DownloadButton(episode: _episode),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
  }

  for (final bulk in [false, true]) {
    final name = bulk ? 'bulk download' : 'episode download';
    final expected = bulk ? [_episode, _otherEpisode] : [_episode];

    testWidgets('$name starts on Wi-Fi with storage permission denied', (
      tester,
    ) async {
      await showDownload(tester, bulk: bulk);

      expect(downloads.started, expected);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('$name waits for cellular confirmation', (tester) async {
      network = ['mobile'];
      await showDownload(tester, bulk: bulk);

      expect(downloads.started, isEmpty);
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text(S.current.confirm));
      await tester.pumpAndSettle();

      expect(downloads.started, expected);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('$name respects cancellation on cellular', (tester) async {
      network = ['mobile'];
      await showDownload(tester, bulk: bulk);

      await tester.tap(find.text(S.current.cancel));
      await tester.pumpAndSettle();

      expect(downloads.started, isEmpty);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('$name honors the preference to allow cellular downloads', (
      tester,
    ) async {
      network = ['mobile'];
      SharedPreferences.setMockInitialValues({downloadUsingDataKey: 1});
      await showDownload(tester, bulk: bulk);

      expect(downloads.started, expected);
      expect(find.byType(AlertDialog), findsNothing);
    });
  }
}
