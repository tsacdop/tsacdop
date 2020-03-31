import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:line_icons/line_icons.dart';
import 'package:tsacdop/class/podcastlocal.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

import 'package:tsacdop/class/audiostate.dart';
import 'package:tsacdop/util/ompl_build.dart';
import 'package:tsacdop/util/context_extension.dart';
import 'theme.dart';
import 'storage.dart';
import 'history.dart';
import 'syncing.dart';
import 'libries.dart';

class Settings extends StatelessWidget {
  _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _exportOmpl() async {
    var dbHelper = DBHelper();
    List<PodcastLocal> podcastList = await dbHelper.getPodcastLocalAll();
    var ompl = omplBuilder(podcastList);
    var tempdir = await getTemporaryDirectory();
    var file = File(join(tempdir.path, 'tsacdop_ompl.xml'));
    print(file.path);
    await file.writeAsString(ompl.toString());
    final params = SaveFileDialogParams(sourceFilePath: file.path);
    final filePath = await FlutterFileDialog.saveFile(params: params);
    print(filePath);
    print(ompl.toString());
  }

  @override
  Widget build(BuildContext context) {
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          elevation: 0,
          backgroundColor: context.primaryColor,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            //physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                    ),
                    Container(
                      height: 30.0,
                      padding: EdgeInsets.symmetric(horizontal: 80),
                      alignment: Alignment.centerLeft,
                      child: Text('Prefrence',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: context.accentColor)),
                    ),
                    ListView(
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        ListTile(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ThemeSetting())),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading: Icon(LineIcons.adjust_solid),
                          title: Text('Appearance'),
                          subtitle: Text('Colors and themes'),
                        ),
                        Divider(height: 2),
                        ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading: Icon(LineIcons.play_circle),
                          title: Text('AutoPlay'),
                          subtitle: Text('Autoplay next episode in playlist'),
                          trailing: Selector<AudioPlayerNotifier, bool>(
                            selector: (_, audio) => audio.autoPlay,
                            builder: (_, data, __) => Switch(
                                value: data,
                                onChanged: (boo) => audio.autoPlaySwitch = boo),
                          ),
                        ),
                        Divider(height: 2),
                        ListTile(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SyncingSetting())),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading: Icon(LineIcons.cloud_download_alt_solid),
                          title: Text('Syncing'),
                          subtitle: Text('Refresh podcasts in the background'),
                        ),
                        Divider(height: 2),
                        ListTile(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StorageSetting())),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading: Icon(LineIcons.save),
                          title: Text('Storage'),
                          subtitle: Text('Manage cache and download storage'),
                        ),
                        Divider(height: 2),
                        ListTile(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PlayedHistory())),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading: Icon(Icons.update),
                          title: Text('History'),
                          subtitle: Text('Listen data'),
                        ),
                        Divider(height: 2),
                        ListTile(
                          onTap: () {
                            _exportOmpl();
                          },
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading: Icon(LineIcons.file_code_solid),
                          title: Text('Export'),
                          subtitle: Text('Export ompl file'),
                        ),
                        Divider(height: 2),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: 30.0,
                      padding: EdgeInsets.symmetric(horizontal: 80),
                      alignment: Alignment.centerLeft,
                      child: Text('Info',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: Theme.of(context).accentColor)),
                    ),
                    ListView(
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        ListTile(
                          onTap: () => _launchUrl(
                              'https://github.com/stonega/tsacdop/releases'),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading: Icon(LineIcons.map_signs_solid),
                          title: Text('Changelog'),
                          subtitle: Text('List of chagnes'),
                        ),
                        Divider(height: 2),
                        ListTile(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Libries())),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading: Icon(LineIcons.book_open_solid),
                          title: Text('Libraries'),
                          subtitle:
                              Text('Open source libraries in application'),
                        ),
                        Divider(height: 2),
                        ListTile(
                          onTap: () => _launchUrl(
                              'mailto:<xijieyin@gmail.com>?subject=Tsacdop Feedback'),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading: Icon(LineIcons.bug_solid),
                          title: Text('Feedback'),
                          subtitle: Text('Bugs and feature requests'),
                        ),
                        Divider(height: 2),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
