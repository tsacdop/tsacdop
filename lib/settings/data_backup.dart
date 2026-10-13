import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../service/opml_build.dart';
import '../state/podcast_group.dart';
import '../state/setting_state.dart';
import '../type/settings_backup.dart';
import '../util/extension_helper.dart';
import '../widgets/custom_widget.dart';

class DataBackup extends StatefulWidget {
  const DataBackup({super.key});

  @override
  _DataBackupState createState() => _DataBackupState();
}

class _DataBackupState extends State<DataBackup> {
  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: context.iconBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness: context.brightness,
      ),
      child: Scaffold(
        backgroundColor: context.background,
        appBar: AppBar(
          elevation: 0,
          title: Text(s.settingsBackup),
          leading: CustomBackButton(),
          backgroundColor: context.primaryColor,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Container(
              height: 30.0,
              padding: EdgeInsets.fromLTRB(70, 0, 70, 0),
              alignment: Alignment.centerLeft,
              child: Text(
                s.subscribe,
                style: context.textTheme.bodyLarge!.copyWith(
                  color: context.accentColor,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 70.0,
                right: 20,
                top: 10,
                bottom: 10,
              ),
              child: Text(s.subscribeExportDes),
            ),
            Padding(
              padding: EdgeInsets.only(left: 70.0, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ButtonTheme(
                    height: 32,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green[700]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LineIcons.save,
                            color: Colors.green[700],
                            size: context.textTheme.titleLarge!.fontSize,
                          ),
                          SizedBox(width: 10),
                          Text(
                            s.save,
                            style: TextStyle(color: Colors.green[700]),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        final file = await _exportOmpl(context);
                        await _saveFile(file);
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  ButtonTheme(
                    height: 32,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue[700]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.share,
                            size: context.textTheme.titleLarge!.fontSize,
                            color: Colors.blue[700],
                          ),
                          SizedBox(width: 10),
                          Text(
                            s.share,
                            style: TextStyle(color: Colors.blue[700]),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        var file = await _exportOmpl(context);
                        await _shareFile(file);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Divider(height: 1),
            ),
            Container(
              height: 30.0,
              padding: EdgeInsets.symmetric(horizontal: 70),
              alignment: Alignment.centerLeft,
              child: Text(
                s.settings,
                style: context.textTheme.bodyLarge!.copyWith(
                  color: context.accentColor,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 70.0,
                right: 20,
                top: 10,
                bottom: 10,
              ),
              child: Text(s.settingsExportDes),
            ),
            Padding(
              padding: EdgeInsets.only(left: 70.0, right: 10),
              child: Wrap(
                children: [
                  ButtonTheme(
                    height: 32,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green[700]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LineIcons.save,
                            color: Colors.green[700],
                            size: context.textTheme.titleLarge!.fontSize,
                          ),
                          SizedBox(width: 10),
                          Text(
                            s.save,
                            style: TextStyle(color: Colors.green[700]),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        var file = await _exportSetting(context);
                        await _saveFile(file);
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  ButtonTheme(
                    height: 32,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue[700]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.share,
                            size: context.textTheme.titleLarge!.fontSize,
                            color: Colors.blue[700],
                          ),
                          SizedBox(width: 10),
                          Text(
                            s.share,
                            style: TextStyle(color: Colors.blue[700]),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        var file = await _exportSetting(context);
                        await _shareFile(file);
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  ButtonTheme(
                    height: 32,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red[700]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LineIcons.paperclip,
                            size: context.textTheme.titleLarge!.fontSize,
                            color: Colors.red[700],
                          ),
                          SizedBox(width: 10),
                          Text(
                            s.import,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ],
                      ),
                      onPressed: () {
                        _getFilePath(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Divider(height: 1),
            ),
          ],
        ),
      ),
    );
  }

  Future<File> _exportOmpl(BuildContext context) async {
    final groups = context.read<GroupList>().groups;
    final opml = PodcastsBackup(groups).omplBuilder();
    final tempdir = await getTemporaryDirectory();
    final now = DateTime.now();
    final datePlus =
        now.year.toString() +
        now.month.toString() +
        now.day.toString() +
        now.second.toString();
    final file = File(path.join(tempdir.path, 'tsacdop_opml_$datePlus.xml'));
    await file.writeAsString(opml.toXmlString());
    return file;
  }

  Future<void> _saveFile(File file) async {
    final params = SaveFileDialogParams(sourceFilePath: file.path);
    await FlutterFileDialog.saveFile(params: params);
  }

  Future<void> _shareFile(File file) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/plain')],
        fileNameOverrides: [file.path.split('/').last],
      ),
    );
  }

  Future<File> _exportSetting(BuildContext context) async {
    var settings = context.read<SettingState>();
    var settingsBack = await settings.backup();
    var json = settingsBack.toJson();
    var tempdir = await getTemporaryDirectory();
    var now = DateTime.now();
    var datePlus =
        now.year.toString() +
        now.month.toString() +
        now.day.toString() +
        now.second.toString();
    var file = File(path.join(tempdir.path, 'tsacdop_settings_$datePlus.json'));
    await file.writeAsString(jsonEncode(json));
    return file;
  }

  Future<void> _importSetting(String path, BuildContext context) async {
    final s = context.s;
    var settings = context.read<SettingState>();
    var file = File(path);
    try {
      var json = file.readAsStringSync();
      var backup = SettingsBackup.fromJson(jsonDecode(json));
      await settings.restore(backup);
      Fluttertoast.showToast(
        msg: s.toastImportSettingsSuccess,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      developer.log(e.toString(), name: 'Import settings');
      Fluttertoast.showToast(
        msg: s.toastFileError,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _getFilePath(BuildContext context) async {
    final s = context.s;
    try {
      final pickedFiles = await FilePicker.pickFiles(type: FileType.any);
      if (pickedFiles.isEmpty) {
        return;
      }
      Fluttertoast.showToast(
        msg: s.toastReadFile,
        gravity: ToastGravity.BOTTOM,
      );
      final filePath = pickedFiles.first.path!;
      _importSetting(filePath, context);
    } on PlatformException catch (e) {
      developer.log(e.toString(), name: 'Get file path');
    }
  }
}
