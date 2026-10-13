import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsacdop/local_storage/retired_gpodder.dart';

const _legacyData = <String, Object>{
  'gpodderApiKey': ['test-user', 'test-device'],
  'gpodderAddKey': ['https://example.com/local.xml'],
  'gpodderRemoveKey': ['https://example.com/removed.xml'],
  'gpodderRemoteAddKey': ['https://example.com/remote.xml'],
  'gpodderRemoteRemoveKey': ['https://example.com/local.xml'],
  'gpodderSyncStatusKey': 1,
  'gpodderSyncDateTimeKey': 123,
};

Future<Directory> _documents() async {
  final directory = await Directory.systemTemp.createTemp(
    'tsacdop-retired-sync-',
  );
  addTearDown(() async => directory.delete(recursive: true));
  final cookies = await Directory('${directory.path}/.cookies').create();
  await File('${cookies.path}/session').writeAsString('expired-test-session');
  await File('${directory.path}/episode.mp3')
      .writeAsString('downloaded episode');
  return directory;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'retires only account sync and preserves local podcasts and downloads',
    () async {
      const groups =
          '{"groups":[{"id":"home","podcastList":["local-podcast"]}]}';
      SharedPreferences.setMockInitialValues({
        ..._legacyData,
        'groups': groups,
        'playlist': ['local-episode'],
        'accents': '009688',
        'updateInterval': 24,
      });
      final documents = await _documents();
      final cancelled = <String>[];

      await retireGpodderIntegration(
        cancelSyncWork: (uniqueName) async => cancelled.add(uniqueName),
        documentsDirectory: () async => documents,
      );

      final preferences = await SharedPreferences.getInstance();
      expect(cancelled, ['2']);
      expect(_legacyData.keys.any(preferences.containsKey), isFalse);
      expect(preferences.getString('groups'), groups);
      expect(preferences.getStringList('playlist'), ['local-episode']);
      expect(preferences.getString('accents'), '009688');
      expect(preferences.getInt('updateInterval'), 24);
      expect(await Directory('${documents.path}/.cookies').exists(), isFalse);
      expect(
        await File('${documents.path}/episode.mp3').readAsString(),
        'downloaded episode',
      );

      await retireGpodderIntegration(
        cancelSyncWork: (uniqueName) async => cancelled.add(uniqueName),
        documentsDirectory: () async => documents,
      );
      expect(cancelled, ['2']);
    },
  );

  test(
    'new installations do not cancel work or access cookie storage',
    () async {
      SharedPreferences.setMockInitialValues({'groups': 'local groups'});
      var cancellations = 0;
      var filesystemAccesses = 0;

      await retireGpodderIntegration(
        cancelSyncWork: (_) async => cancellations++,
        documentsDirectory: () async {
          filesystemAccesses++;
          throw StateError('Unexpected filesystem access');
        },
      );

      expect(cancellations, 0);
      expect(filesystemAccesses, 0);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('groups'), 'local groups');
    },
  );

  test(
    'failed cancellation leaves cleanup data available for a later retry',
    () async {
      SharedPreferences.setMockInitialValues(_legacyData);
      final documents = await _documents();

      await retireGpodderIntegration(
        cancelSyncWork: (_) async => throw StateError('Scheduler unavailable'),
        documentsDirectory: () async => documents,
      );

      final preferences = await SharedPreferences.getInstance();
      expect(_legacyData.keys.every(preferences.containsKey), isTrue);
      expect(await Directory('${documents.path}/.cookies').exists(), isTrue);

      await retireGpodderIntegration(
        cancelSyncWork: (_) async {},
        documentsDirectory: () async => documents,
      );
      expect(_legacyData.keys.any(preferences.containsKey), isFalse);
      expect(await Directory('${documents.path}/.cookies').exists(), isFalse);
    },
  );

  test(
    'failed cookie cleanup keeps account metadata for the next launch',
    () async {
      SharedPreferences.setMockInitialValues(_legacyData);

      await retireGpodderIntegration(
        cancelSyncWork: (_) async {},
        documentsDirectory: () async =>
            throw const FileSystemException('Storage unavailable'),
      );

      final preferences = await SharedPreferences.getInstance();
      expect(_legacyData.keys.every(preferences.containsKey), isTrue);
    },
  );
}
