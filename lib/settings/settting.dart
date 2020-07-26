import 'dart:math' as math;

import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../home/home.dart';
import '../intro_slider/app_intro.dart';
import '../podcasts/podcast_manage.dart';
import '../util/extension_helper.dart';
import 'data_backup.dart';
import 'history.dart';
import 'languages.dart';
import 'layouts.dart';
import 'libries.dart';
import 'play_setting.dart';
import 'storage.dart';
import 'syncing.dart';
import 'theme.dart';

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
          title: Text(s.settings),
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
                      padding: EdgeInsets.symmetric(horizontal: 70),
                      alignment: Alignment.centerLeft,
                      child: Text(s.settingsPrefrence,
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
                          leading: Icon(LineIcons.adjust_solid,
                              color: context.accentColor),
                          title: Text(s.settingsAppearance),
                          subtitle: Text(s.settingsAppearanceDes),
                        ),
                        Divider(height: 2),
                        ListTile(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LayoutSetting())),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading: Icon(LineIcons.stop_circle_solid,
                              color: Colors.blueAccent),
                          title: Text(s.settingsLayout),
                          subtitle: Text(s.settingsLayoutDes),
                        ),
                        Divider(height: 2),
                        ListTile(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PlaySetting())),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading: Icon(LineIcons.play_circle,
                              color: Colors.redAccent),
                          title: Text(s.play),
                          subtitle: Text(s.settingsPlayDes),
                        ),
                        Divider(height: 2),
                        ListTile(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SyncingSetting())),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 25.0),
                            leading: Icon(LineIcons.cloud_download_alt_solid,
                                color: Colors.yellow[700]),
                            title: Text(s.settingsSyncing),
                            subtitle: Text(s.settingsSyncingDes)),
                        Divider(height: 2),
                        ListTile(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StorageSetting())),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading:
                              Icon(LineIcons.save, color: Colors.green[700]),
                          title: Text(s.settingStorage),
                          subtitle: Text(s.settingsStorageDes),
                        ),
                        Divider(height: 2),
                        ListTile(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PlayedHistory())),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading:
                              Icon(Icons.update, color: Colors.indigo[700]),
                          title: Text(s.settingsHistory),
                          subtitle: Text(s.settingsHistoryDes),
                        ),
                        Divider(height: 2),
                        ListTile(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LanguagesSetting())),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading: Icon(LineIcons.language_solid,
                              color: Colors.purpleAccent),
                          title: Text(s.settingsLanguages),
                          subtitle: Text(s.settingsLanguagesDes),
                        ),
                        Divider(height: 2),
                        ListTile(
                          onTap: () {
                            //_exportOmpl(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DataBackup()));
                          },
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading: Icon(LineIcons.file_code_solid,
                              color: Colors.lightGreen[700]),
                          title: Text(s.settingsBackup),
                          subtitle: Text(s.settingsBackupDes),
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
                      padding: EdgeInsets.symmetric(horizontal: 70),
                      alignment: Alignment.centerLeft,
                      child: Text(s.settingsInfo,
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
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Libries())),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading: Icon(LineIcons.book_open_solid,
                              color: Colors.purple[700]),
                          title: Text(s.settingsLibraries),
                          subtitle: Text(s.settingsLibrariesDes),
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
                          leading: Icon(LineIcons.bug_solid,
                              color: Colors.pink[700]),
                          title: Text(s.settingsFeedback),
                          subtitle: Text(s.settingsFeedbackDes),
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
                                    SizedBox(width: 45),
                                    _feedbackItem(
                                        LineIcons.github,
                                        s.feedbackGithub,
                                        'https://github.com/stonega/tsacdop/issues'),
                                    _feedbackItem(
                                        LineIcons.telegram,
                                        s.feedbackTelegram,
                                        'https://t.me/joinchat/Bk3LkRpTHy40QYC78PK7Qg'),
                                    _feedbackItem(
                                        LineIcons.envelope_open_text_solid,
                                        s.feedbackEmail,
                                        'mailto:<tsacdop.app@gmail.com>?subject=Tsacdop Feedback'),
                                    _feedbackItem(
                                        LineIcons.google_play,
                                        s.feedbackPlay,
                                        'https://play.google.com/store/apps/details?id=com.stonegate.tsacdop')
                                  ],
                                ),
                              )
                            : Center(),
                        Divider(
                          height: 2,
                        ),
                        ListTile(
                          onTap: () {
                            FeatureDiscovery.clearPreferences(
                                context, const <String>{
                              addFeature,
                              menuFeature,
                              playlistFeature,
                              groupsFeature,
                              addGroupFeature,
                              configureGroup,
                              configurePodcast,
                              podcastFeature
                            });
                            Fluttertoast.showToast(
                              msg: s.toastDiscovery,
                              gravity: ToastGravity.BOTTOM,
                            );
                          },
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading: Icon(LineIcons.capsules_solid,
                              color: Colors.pinkAccent),
                          title: Text(s.settingsDiscovery),
                        ),
                        Divider(height: 2),
                        ListTile(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SlideIntro(goto: Goto.settings))),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25.0),
                          leading: Icon(LineIcons.columns_solid,
                              color: Colors.blueGrey),
                          title: Text(s.settingsAppIntro),
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
