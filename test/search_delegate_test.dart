import 'package:flutter/material.dart' hide SearchDelegate, showSearch;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsacdop/widgets/custom_search_delegate.dart';

class _TestSearchDelegate extends SearchDelegate<void> {
  final searches = <String>[];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  List<Widget> buildActions(BuildContext context) => [];

  @override
  Widget buildSuggestions(BuildContext context) => const Text('Suggestions');

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) return const Text('No query');
    return _SearchResults(query: query, onSearch: searches.add);
  }
}

class _SearchResults extends StatefulWidget {
  const _SearchResults({required this.query, required this.onSearch});

  final String query;
  final ValueChanged<String> onSearch;

  @override
  State<_SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<_SearchResults> {
  late final String requestedQuery;

  @override
  void initState() {
    super.initState();
    requestedQuery = widget.query;
    widget.onSearch(requestedQuery);
  }

  @override
  Widget build(BuildContext context) => Text('Results: $requestedQuery');
}

Future<_TestSearchDelegate> _openSearch(WidgetTester tester) async {
  final delegate = _TestSearchDelegate();
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: TargetPlatform.android),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showSearch(context: context, delegate: delegate),
            child: const Text('Search'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Search'));
  await tester.pumpAndSettle();
  return delegate;
}

Future<void> _shortcut(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyDownEvent(
    LogicalKeyboardKey.controlLeft,
    platform: 'android',
  );
  await tester.sendKeyEvent(key, platform: 'android');
  await tester.sendKeyUpEvent(
    LogicalKeyboardKey.controlLeft,
    platform: 'android',
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('typing submits the complete query without premature searches', (
    tester,
  ) async {
    final delegate = await _openSearch(tester);
    const query = 'cyberwire daily';
    for (var length = 1; length <= query.length; length++) {
      await tester.enterText(
        find.byType(TextField),
        query.substring(0, length),
      );
      await tester.pump();
    }

    expect(delegate.searches, isEmpty);
    expect(find.text('Suggestions'), findsOneWidget);

    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(delegate.searches, [query]);
    expect(find.text('Results: $query'), findsOneWidget);
  });

  testWidgets('a second submission searches the new query', (tester) async {
    final delegate = await _openSearch(tester);
    await tester.enterText(find.byType(TextField), 'first podcast');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'second podcast');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(delegate.searches, ['first podcast', 'second podcast']);
    expect(find.text('Results: second podcast'), findsOneWidget);
    expect(find.text('Results: first podcast'), findsNothing);
  });

  testWidgets('updating a visible results query refreshes the results', (
    tester,
  ) async {
    final delegate = await _openSearch(tester);
    await tester.enterText(find.byType(TextField), 'first podcast');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    delegate.query = 'second podcast';
    await tester.pumpAndSettle();

    expect(delegate.searches, ['first podcast', 'second podcast']);
    expect(find.text('Results: second podcast'), findsOneWidget);
  });

  testWidgets('IME composition stays intact until search is submitted', (
    tester,
  ) async {
    final delegate = await _openSearch(tester);
    const editingValue = TextEditingValue(
      text: '播客',
      selection: TextSelection.collapsed(offset: 2),
      composing: TextRange(start: 0, end: 2),
    );
    tester.testTextInput.updateEditingValue(editingValue);
    await tester.pump();

    final controller = tester
        .widget<TextField>(find.byType(TextField))
        .controller!;
    expect(controller.value, editingValue);
    expect(delegate.searches, isEmpty);

    tester.testTextInput.updateEditingValue(
      editingValue.copyWith(composing: TextRange.empty),
    );
    await tester.pump();
    expect(controller.value.composing, TextRange.empty);
    expect(delegate.searches, isEmpty);

    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(delegate.searches, ['播客']);
  });

  testWidgets(
    'Android search supports paste, select all, and arrow selection',
    (tester) async {
      const url = 'https://feeds.megaphone.fm/cyberwire-daily-podcast';
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async => switch (call.method) {
          'Clipboard.getData' => {'text': url},
          'Clipboard.hasStrings' => {'value': true},
          _ => null,
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      final delegate = await _openSearch(tester);
      await _shortcut(tester, LogicalKeyboardKey.keyV);

      final controller = tester
          .widget<TextField>(find.byType(TextField))
          .controller!;
      expect(controller.text, url);
      expect(
        controller.selection,
        const TextSelection.collapsed(offset: url.length),
      );

      await _shortcut(tester, LogicalKeyboardKey.keyA);
      expect(controller.selection.start, 0);
      expect(controller.selection.end, url.length);

      await tester.sendKeyEvent(
        LogicalKeyboardKey.arrowRight,
        platform: 'android',
      );
      await tester.pump();
      expect(
        controller.selection,
        const TextSelection.collapsed(offset: url.length),
      );

      await tester.sendKeyDownEvent(
        LogicalKeyboardKey.shiftLeft,
        platform: 'android',
      );
      await tester.sendKeyEvent(
        LogicalKeyboardKey.arrowLeft,
        platform: 'android',
      );
      await tester.sendKeyUpEvent(
        LogicalKeyboardKey.shiftLeft,
        platform: 'android',
      );
      await tester.pump();
      expect(controller.selection.baseOffset, url.length);
      expect(controller.selection.extentOffset, url.length - 1);

      await tester.sendKeyEvent(
        LogicalKeyboardKey.arrowLeft,
        platform: 'android',
      );
      await tester.pump();
      expect(
        controller.selection,
        const TextSelection.collapsed(offset: url.length - 1),
      );
      expect(delegate.searches, isEmpty);
    },
  );
}
