import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:provider/provider.dart';
import 'package:tsacdop/type/settings_backup.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

import '../state/podcast_group.dart';
import '../state/setting_state.dart';
import '../util/extension_helper.dart';
import '../service/ompl_build.dart';

class DataBackup extends StatefulWidget {
  @override
  _DataBackupState createState() => _DataBackupState();
}

class _DataBackupState extends State<DataBackup> {
  Future<File> _exportOmpl(BuildContext context) async {
    var groups = context.read<GroupList>().groups;
    var ompl = PodcastsBackup(groups).omplBuilder();
    var tempdir = await getTemporaryDirectory();
    DateTime now = DateTime.now();
    String datePlus = now.year.toString() +
        now.month.toString() +
        now.day.toString() +
        now.second.toString();
    var file = File(join(tempdir.path, 'tsacdop_ompl_$datePlus.xml'));
    await file.writeAsString(ompl.toString());
    return file;
  }

  Future<void> _saveFile(File file) async {
    final params = SaveFileDialogParams(sourceFilePath: file.path);
    await FlutterFileDialog.saveFile(params: params);
  }

  Future<void> _shareFile(File file) async {
    final Uint8List bytes = await file.readAsBytes();
    await WcFlutterShare.share(
        sharePopupTitle: 'share Clip',
        fileName: file.path.split('/').last,
        mimeType: 'text/plain',
        bytesOfFile: bytes.buffer.asUint8List());
  }

  Future<File> _exportSetting(BuildContext context) async {
    var settings = context.read<SettingState>();
    SettingsBackup settingsBack = await settings.backup();
    var json = settingsBack.toJson();
    var tempdir = await getTemporaryDirectory();
    DateTime now = DateTime.now();
    String datePlus = now.year.toString() +
        now.month.toString() +
        now.day.toString() +
        now.second.toString();
    var file = File(join(tempdir.path, 'tsacdop_settings_$datePlus.json'));
    await file.writeAsString(jsonEncode(json));
    return file;
  }

  Future _importSetting(String path, BuildContext context) async {
    final s = context.s;
    var settings = context.read<SettingState>();
    File file = File(path);
    try {
      String json = file.readAsStringSync();
      SettingsBackup backup = SettingsBackup.fromJson(jsonDecode(json));
      await settings.restore(backup);
      Fluttertoast.showToast(
        msg: s.toastImportSettingsSuccess,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: s.toastFileError,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _getFilePath(BuildContext context) async {
    final s = context.s;
    try {
      String filePath = await FilePicker.getFilePath(type: FileType.any);
      if (filePath == '') {
        return;
      }
      print('File Path' + filePath);
      Fluttertoast.showToast(
        msg: s.toastReadFile,
        gravity: ToastGravity.BOTTOM,
      );
      _importSetting(filePath, context);
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
      ),
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text(s.settingsBackup),
            backgroundColor: context.primaryColor,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(10.0),
              ),
              Container(
                height: 30.0,
                padding: EdgeInsets.symmetric(horizontal: 70),
                alignment: Alignment.centerLeft,
                child: Text(s.subscribe,
                    style: context.textTheme.bodyText1
                        .copyWith(color: Theme.of(context).accentColor)),
              ),
              Padding(
                padding:
                    EdgeInsets.only(left: 70.0, right: 20, top: 10, bottom: 10),
                child: Text(s.subscribeExportDes),
              ),
              Padding(
                padding: EdgeInsets.only(left: 70.0, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    OutlineButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0),
                            side: BorderSide(color: Colors.green[700])),
                        highlightedBorderColor: Colors.green[700],
                        child: Row(
                          children: [
                            Icon(
                              LineIcons.save,
                              color: Colors.green[700],
                              size: context.textTheme.headline6.fontSize,
                            ),
                            SizedBox(width: 10),
                            Text(s.save,
                                style: TextStyle(color: Colors.green[700])),
                          ],
                        ),
                        onPressed: () async {
                          File file = await _exportOmpl(context);
                          await _saveFile(file);
                        }),
                    SizedBox(width: 10),
                    OutlineButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0),
                            side: BorderSide(color: Colors.blue[700])),
                        highlightedBorderColor: Colors.blue[700],
                        child: Row(
                          children: [
                            Icon(
                              Icons.share,
                              size: context.textTheme.headline6.fontSize,
                              color: Colors.blue[700],
                            ),
                            SizedBox(width: 10),
                            Text(s.share,
                                style: TextStyle(color: Colors.blue[700])),
                          ],
                        ),
                        onPressed: () async {
                          File file = await _exportOmpl(context);
                          await _shareFile(file);
                        })
                  ],
                ),
              ),
              Divider(),
              Container(
                height: 30.0,
                padding: EdgeInsets.symmetric(horizontal: 70),
                alignment: Alignment.centerLeft,
                child: Text(s.settings,
                    style: context.textTheme.bodyText1
                        .copyWith(color: Theme.of(context).accentColor)),
              ),
              Padding(
                padding:
                    EdgeInsets.only(left: 70.0, right: 20, top: 10, bottom: 10),
                child: Text(s.settingsExportDes),
              ),
              Padding(
                padding: EdgeInsets.only(left: 70.0, right: 10),
                child: Wrap(children: [
                  OutlineButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          side: BorderSide(color: Colors.green[700])),
                      highlightedBorderColor: Colors.green[700],
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LineIcons.save,
                            color: Colors.green[700],
                            size: context.textTheme.headline6.fontSize,
                          ),
                          SizedBox(width: 10),
                          Text(s.save,
                              style: TextStyle(color: Colors.green[700])),
                        ],
                      ),
                      onPressed: () async {
                        File file = await _exportSetting(context);
                        await _saveFile(file);
                      }),
                  SizedBox(width: 10),
                  OutlineButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          side: BorderSide(color: Colors.blue[700])),
                      highlightedBorderColor: Colors.blue[700],
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.share,
                            size: context.textTheme.headline6.fontSize,
                            color: Colors.blue[700],
                          ),
                          SizedBox(width: 10),
                          Text(s.share,
                              style: TextStyle(color: Colors.blue[700])),
                        ],
                      ),
                      onPressed: () async {
                        File file = await _exportSetting(context);
                        await _shareFile(file);
                      }),
                  SizedBox(width: 10),
                  OutlineButton(
                      highlightedBorderColor: Colors.red[700],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          side: BorderSide(color: Colors.red[700])),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LineIcons.paperclip_solid,
                            size: context.textTheme.headline6.fontSize,
                            color: Colors.red[700],
                          ),
                          SizedBox(width: 10),
                          Text(s.import,
                              style: TextStyle(color: Colors.red[700])),
                        ],
                      ),
                      onPressed: () {
                        _getFilePath(context);
                      }),
                ]),
              ),
              Divider()
            ],
          )),
    );
  }
}
