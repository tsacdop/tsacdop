import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsacdop/state/download_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final (name, portName, callback) in [
    ('foreground', 'downloader_send_port', downloadCallback),
    ('automatic', 'auto_downloader_send_port', autoDownloadCallback),
  ]) {
    test('$name callback sends primitive values across Flutter engines', () async {
      final port = ReceivePort();
      expect(
        IsolateNameServer.registerPortWithName(port.sendPort, portName),
        isTrue,
      );
      addTearDown(() {
        IsolateNameServer.removePortNameMapping(portName);
        port.close();
      });

      // A separate FlutterEngine cannot send enum instances to the UI isolate.
      // The wire format must contain only the ID and integer status/progress.
      callback('download-id', DownloadTaskStatus.complete.index, 100);

      expect(await port.first.timeout(const Duration(seconds: 5)), [
        'download-id',
        DownloadTaskStatus.complete.index,
        100,
      ]);
    });
  }
}
