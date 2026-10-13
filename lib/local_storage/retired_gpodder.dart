import 'dart:developer' as developer;
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _legacyKeys = [
  'gpodderApiKey',
  'gpodderAddKey',
  'gpodderRemoveKey',
  'gpodderSyncStatusKey',
  'gpodderSyncDateTimeKey',
  'gpodderRemoteAddKey',
  'gpodderRemoteRemoveKey',
];

/// Retires the old account-sync task and its local data after an upgrade.
Future<void> retireGpodderIntegration({
  required Future<void> Function(String uniqueName) cancelSyncWork,
  Future<Directory> Function()? documentsDirectory,
}) async {
  final preferences = await SharedPreferences.getInstance();
  if (!_legacyKeys.any(preferences.containsKey)) return;

  try {
    await cancelSyncWork('2');
    final directory =
        await (documentsDirectory ?? getApplicationDocumentsDirectory)();
    final cookies = Directory(path.join(directory.path, '.cookies'));
    if (await cookies.exists()) await cookies.delete(recursive: true);
    for (final key in _legacyKeys) {
      await preferences.remove(key);
    }
  } catch (error, stackTrace) {
    // Keep the legacy keys so cleanup can retry on the next launch.
    developer.log(
      'Could not retire account sync; cleanup will retry on the next launch.',
      name: 'retired_gpodder',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
