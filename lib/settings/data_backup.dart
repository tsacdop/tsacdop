import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:provider/provider.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

import '../state/podcast_group.dart';
import '../util/context_extension.dart';
import '../service/ompl_build.dart';

class DataBackup extends StatelessWidget {
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

  Future<void> _saveOmpl(File file) async {
    final params = SaveFileDialogParams(sourceFilePath: file.path);
    await FlutterFileDialog.saveFile(params: params);
  }

  Future<void> _shareOmpl(File file) async {
    final Uint8List bytes = await file.readAsBytes();
    await WcFlutterShare.share(
        sharePopupTitle: 'share Clip',
        fileName: file.path.split('/').last,
        mimeType: 'text/plain',
        bytesOfFile: bytes.buffer.asUint8List());
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
                child: Text(s.settingsExportDes),
              ),
              Padding(
                padding: EdgeInsets.only(left: 70.0, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    OutlineButton(
                        highlightedBorderColor: context.accentColor,
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
                          await _saveOmpl(file);
                        }),
                    SizedBox(width: 50),
                    OutlineButton(
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
                          await _shareOmpl(file);
                        })
                  ],
                ),
              ),
              Divider(),
            ],
          )),
    );
  }
}
