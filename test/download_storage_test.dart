import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tsacdop/local_storage/download_storage.dart';

void main() {
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('tsacdop-storage-test-');
  });
  tearDown(() async => directory.delete(recursive: true));

  test('counts only files across nested podcast folders', () async {
    await Directory('${directory.path}/podcast/season').create(recursive: true);
    await File('${directory.path}/podcast/episode.mp3').writeAsBytes([1, 2, 3]);
    await File('${directory.path}/podcast/season/episode.mp3')
        .writeAsBytes([4, 5]);
    await File('${directory.path}/root.mp3').writeAsBytes([6]);

    expect(await measureDownloadStorage([directory]), (bytes: 6, files: 3));
  });

  test(
    'repeated scans after deletion return the actual remaining size',
    () async {
      final first = await File('${directory.path}/first.mp3')
          .writeAsBytes([1, 2, 3]);
      await File('${directory.path}/second.mp3').writeAsBytes([4, 5]);
      expect(await measureDownloadStorage([directory]), (bytes: 5, files: 2));
      await first.delete();

      final scans = await Future.wait([
        measureDownloadStorage([directory]),
        measureDownloadStorage([directory]),
      ]);
      expect(scans, [(bytes: 2, files: 1), (bytes: 2, files: 1)]);
    },
  );

  test(
    'ignores missing directories and does not follow directory links',
    () async {
      final source = await Directory('${directory.path}/source').create();
      await File('${source.path}/episode.mp3').writeAsBytes([1, 2]);
      await Link('${directory.path}/duplicate').create(source.path);

      expect(
        await measureDownloadStorage([
          directory,
          Directory('${directory.path}/missing'),
        ]),
        (bytes: 2, files: 1),
      );
    },
  );
}
