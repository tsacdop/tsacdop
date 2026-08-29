# flutter_file_dialog

Dialogs for picking and saving files and for picking directories in Android and in iOS.

## Features

- Supports Android (API level 24 or later) and iOS (13.0 or later).
- Modern plugin implementation based on Kotlin (Android) and Swift (iOS).
- Pick image files and other documents.
- Save a file to a selected location.
- Pick a directory and save files to the picked directory without further 
dialogs.
- iOS dialog types: document and image.
- iOS source types: camera, photo library, saved photos album.
- Allow user to edit the picked image in iOS.
- Set file extension filter and mime types filter when picking a document.
- Possibility to limit picking a file from the local device only (Android).

## Examples

### Pick an image file

```dart
  final params = OpenFileDialogParams(
    dialogType: OpenFileDialogType.image,
    sourceType: SourceType.photoLibrary,
  );
  final filePath = await FlutterFileDialog.pickFile(params: params);
  print(filePath);
```

### Pick a document

```dart
  final params = OpenFileDialogParams(
    dialogType: OpenFileDialogType,
    sourceType: SourceType.photoLibrary,
  );
  final filePath = await FlutterFileDialog.pickFile(params: params);
  print(filePath);
```

### Save a file

```dart
final params = SaveFileDialogParams(sourceFilePath: "path_of_file_to_save");
final filePath = await FlutterFileDialog.saveFile(params: params);
print(filePath);
```

### Pick a directory and save a file to the picked directory

```dart
if (!await FlutterFileDialog.isPickDirectorySupported()) {
  print("Picking directory not supported");
  return;
}

final pickedDirectory = await FlutterFileDialog.pickDirectory();

if (pickedDirectory != null) {
  final filePath = await FlutterFileDialog.saveFileToDirectory(
    directory: pickedDirectory!,
    data: file.readAsBytesSync(),
    mimeType: "image/jpeg",
    fileName: "fileName.jpeg",
    replace: true,
  );
}
```

### Optimize picked image file using flutter_image_utilities

Use the plugin [flutter_image_utilities](https://pub.dev/packages/flutter_image_utilities) to optimize a picked image file.

```dart
  final params = OpenFileDialogParams(
    dialogType: OpenFileDialogType.image,
    sourceType: SourceType.photoLibrary,
  );
  final filePath = await FlutterFileDialog.pickFile(params: params);
  print(filePath);

  if (filePath != null) {
    final pickedFile = File(filePath)

    // optimize the image file
    final optimizedFile = await FlutterImageUtilities.saveAsJpeg(
      sourceFile: pickedFile,
      quality: 60,
      maxWidth: 1920,
      maxHeight: 1024,
    );
  }
```
