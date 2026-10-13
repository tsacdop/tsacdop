import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsacdop/generated/l10n.dart';
import 'package:tsacdop/home/audioplayer.dart';
import 'package:tsacdop/home/resume_playback.dart';
import 'package:tsacdop/state/audio_state.dart';

import 'support/playback_fakes.dart';

void main() {
  Future<void> showBar(
    WidgetTester tester, {
    Future<void> Function()? onResume,
    double bottomPadding = 0,
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [S.delegate],
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(320, 640),
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ResumePlaybackBar(
                episode: paused,
                position: 123456,
                bottomPadding: bottomPadding,
                onResume: onResume ?? () async {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('resume bar identifies the episode, podcast and saved position', (
    tester,
  ) async {
    await showBar(tester);
    expect(find.text('Continue listening'), findsOneWidget);
    expect(find.text('Paused episode'), findsOneWidget);
    expect(find.text('Podcast · 02:03'), findsOneWidget);
    expect(find.byTooltip('Continue listening'), findsOneWidget);
  });

  testWidgets('resume is explicit and rapid taps only invoke one request', (
    tester,
  ) async {
    final completion = Completer<void>();
    var resumes = 0;
    await showBar(
      tester,
      onResume: () async {
        resumes++;
        await completion.future;
      },
    );
    expect(resumes, 0);
    await tester.tap(find.byTooltip('Continue listening'));
    await tester.pump();
    await tester.tap(find.byType(InkWell).first);
    await tester.pump();
    expect(resumes, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    completion.complete();
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('failed resume shows a failure and allows another attempt', (
    tester,
  ) async {
    var attempts = 0;
    await showBar(
      tester,
      onResume: () async {
        attempts++;
        if (attempts == 1) throw StateError('Offline');
      },
    );
    await tester.tap(find.byTooltip('Continue listening'));
    await tester.pumpAndSettle();
    expect(find.text('Play: Failed'), findsOneWidget);
    await tester.tap(find.byTooltip('Continue listening'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
  });

  testWidgets('bar fits narrow screens, large text and the bottom safe area', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await showBar(tester, bottomPadding: 32, textScale: 2);
    expect(tester.takeException(), isNull);
    final playBottom = tester
        .getBottomRight(find.byTooltip('Continue listening'))
        .dy;
    expect(playBottom, lessThanOrEqualTo(640 - 32));
  });

  Future<void> showPlayer(WidgetTester tester, {bool saved = true}) async {
    SharedPreferences.setMockInitialValues(
      preferences(state: saved ? null : ['', '', '0']),
    );
    final handler = TestAudioHandler();
    final audio = AudioPlayerNotifier(
      dbHelper: TestEpisodeDatabase(),
      createHandler: (_, cacheMax) async => handler,
    );
    addTearDown(audio.dispose);
    await audio.initPlaylist();
    await audio.initialize();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: audio,
        child: MaterialApp(
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(body: PlayerWidget()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(handler.plays, 0);
  }

  testWidgets(
    'home player shows a saved episode even when the service is not running',
    (tester) async {
      await showPlayer(tester);
      expect(find.byType(ResumePlaybackBar), findsOneWidget);
      expect(find.text('Paused episode'), findsOneWidget);
      expect(find.text('Podcast · 02:03'), findsOneWidget);
    },
  );

  testWidgets('home player stays hidden without a previous playback session', (
    tester,
  ) async {
    await showPlayer(tester, saved: false);
    expect(find.byType(ResumePlaybackBar), findsNothing);
    expect(find.text('Continue listening'), findsNothing);
  });
}
