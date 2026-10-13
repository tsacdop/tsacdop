import 'dart:io';

Future<({int bytes, int files})> measureDownloadStorage(
  Iterable<Directory> directories,
) async {
  var bytes = 0;
  var files = 0;
  for (final directory in directories) {
    if (!await directory.exists()) continue;
    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      final stat = await entity.stat();
      if (stat.type != FileSystemEntityType.file) continue;
      bytes += stat.size;
      files++;
    }
  }
  return (bytes: bytes, files: files);
}
