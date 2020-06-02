import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

import '../util/ompl_build.dart';
import '../util/context_extension.dart';
import '../intro_slider/app_intro.dart';
import '../type/podcastlocal.dart';
import '../local_storage/sqflite_localpodcast.dart';
import 'theme.dart';
import 'storage.dart';
import 'history.dart';
import 'syncing.dart';
import 'libries.dart';
import 'play_setting.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings>
    with SingleTickerProviderStateMixin {
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
    var ompl = omplBuilder(podcastList.reversed.toList());
    var tempdir = await getTemporaryDirectory();
    var file = File(join(tempdir.path, 'tsacdop_ompl.xml'));
    print(file.path);
    await file.writeAsString(ompl.toString());
    final params = SaveFileDialogParams(sourceFilePath: file.path);
    final filePath = await FlutterFileDialog.saveFile(params: params);
    print(filePath);
    print(ompl.toString());
  }

  bool _showFeedback;
  Animation _animation;
  AnimationController _controller;
  double _value;
  @override
  void initState() {
    super.initState();
    _showFeedback = false;
    _value = 0;
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _value = _animation.value;
        });
      });
  }

  Widget _feedbackItem(IconData icon, String name, String url) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _launchUrl(url),
          child: Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Icon(
                  icon,
                  size: 20 * _value,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                ),
                Text(
                  name,
                  maxLines: 2,
                )
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
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
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PlaySetting())),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading: Icon(LineIcons.play_circle),
                          title: Text('Play'),
                          subtitle: Text('Playlist and player'),
                          //  trailing: Selector<AudioPlayerNotifier, bool>(
                          //    selector: (_, audio) => audio.autoPlay,
                          //    builder: (_, data, __) => Switch(
                          //        value: data,
                          //        onChanged: (boo) => audio.autoPlaySwitch = boo),
                          //  ),
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
                          subtitle: Text('Export ompl file of all podcasts'),
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
                          subtitle: Text('List of changes'),
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
                          onTap: () async {
                            if (_value == 0) {
                              _showFeedback = !_showFeedback;
                              _controller.forward();
                            } else {
                              await _controller.reverse();
                              _showFeedback = !_showFeedback;
                            }
                          },
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading: Icon(LineIcons.bug_solid),
                          title: Text('Feedback'),
                          subtitle: Text('Bugs and feature request'),
                          trailing: Transform.rotate(
                            angle: math.pi * _value,
                            child: Icon(Icons.keyboard_arrow_down),
                          ),
                        ),
                        _showFeedback
                            ? SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    _feedbackItem(
                                        LineIcons.github,
                                        'Submit issue',
                                        'https://github.com/stonega/tsacdop/issues'),
                                    _feedbackItem(
                                        LineIcons.telegram,
                                        'Join group',
                                        'https://t.me/joinchat/Bk3LkRpTHy40QYC78PK7Qg'),
                                    _feedbackItem(
                                        LineIcons.envelope_open_text_solid,
                                        'Write to me',
                                        'mailto:<tsacdop.app@gmail.com>?subject=Tsacdop Feedback'),
                                    _feedbackItem(
                                        LineIcons.google_play,
                                        'Rate on Play',
                                        'https://play.google.com/store/apps/details?id=com.stonegate.tsacdop')
                                  ],
                                ),
                              )
                            : Center(),
                        Divider(
                          height: 2,
                        ),
                        ListTile(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SlideIntro(goto: Goto.settings))),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading: Icon(LineIcons.columns_solid),
                          title: Text('App Intro'),
                        ),
                        Divider(height: 2),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
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
