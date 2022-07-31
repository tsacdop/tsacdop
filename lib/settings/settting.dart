import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';

import '../intro_slider/app_intro.dart';
import '../util/extension_helper.dart';
import '../widgets/custom_widget.dart';
import '../widgets/feature_discovery.dart';
import '../widgets/general_dialog.dart';
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

class _SettingsState extends State<Settings> {
  late bool _showTitle;
  ScrollController? _controller;
  _scrollListener() {
    if (_controller!.offset > context.textTheme.headline5!.fontSize!) {
      if (!_showTitle) setState(() => _showTitle = true);
    } else if (_showTitle) setState(() => _showTitle = false);
  }

  @override
  void initState() {
    super.initState();
    _showTitle = false;
    _controller = ScrollController();
    _controller!.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  Widget _feedbackItem(IconData icon, String name, String url) => ListTile(
        onTap: () {
          url.launchUrl;
          Navigator.pop(context);
        },
        dense: true,
        title: Row(
          children: [
            Icon(icon, size: 20),
            SizedBox(width: 20),
            Text(
              name,
              maxLines: 2,
              style: context.textTheme.bodyText2,
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: context.brightness,
        systemNavigationBarColor: context.background,
        systemNavigationBarIconBrightness: context.iconBrightness,
      ),
      child: Scaffold(
        backgroundColor: context.background,
        appBar: AppBar(
          title: Text(s.settings),
          leading: CustomBackButton(),
          elevation: _showTitle ? 1 : 0,
          backgroundColor: context.background,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _controller,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
              ),
              Container(
                height: 30.0,
                padding: EdgeInsets.symmetric(horizontal: 70),
                alignment: Alignment.centerLeft,
                child: Text(s.settingsPrefrence,
                    style: context.textTheme.bodyText1!
                        .copyWith(color: context.accentColor)),
              ),
              ListTile(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ThemeSetting())),
                contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                leading: Icon(LineIcons.adjust, color: context.accentColor),
                title: Text(s.settingsAppearance),
                subtitle: Text(s.settingsAppearanceDes),
              ),
              Divider(height: 1),
              ListTile(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LayoutSetting())),
                contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                leading: Icon(LineIcons.stopCircle, color: Colors.blueAccent),
                title: Text(s.settingsLayout),
                subtitle: Text(s.settingsLayoutDes),
              ),
              Divider(height: 1),
              ListTile(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PlaySetting())),
                contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                leading: Icon(LineIcons.playCircle, color: Colors.redAccent),
                title: Text(s.play),
                subtitle: Text(s.settingsPlayDes),
              ),
              Divider(height: 1),
              ListTile(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SyncingSetting())),
                  contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                  leading: Icon(LineIcons.alternateCloudDownload,
                      color: Colors.yellow[700]),
                  title: Text(s.settingsSyncing),
                  subtitle: Text(s.settingsSyncingDes)),
              Divider(height: 1),
              ListTile(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => StorageSetting())),
                contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                leading: Icon(LineIcons.save, color: Colors.green[700]),
                title: Text(s.settingStorage),
                subtitle: Text(s.settingsStorageDes),
              ),
              Divider(height: 1),
              ListTile(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PlayedHistory())),
                contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                leading: Icon(Icons.update, color: Colors.indigo[700]),
                title: Text(s.settingsHistory),
                subtitle: Text(s.settingsHistoryDes),
              ),
              Divider(height: 1),
              ListTile(
                onTap: () => generalSheet(context,
                        title: s.settingsLanguages, child: LanguagesSetting())
                    .then((value) => setState(() {})),
                contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                leading: Icon(LineIcons.language, color: Colors.purpleAccent),
                title: Text(s.settingsLanguages),
                subtitle: Text(s.settingsLanguagesDes),
              ),
              Divider(height: 1),
              ListTile(
                onTap: () {
                  //_exportOmpl(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DataBackup()));
                },
                contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                leading:
                    Icon(LineIcons.codeFile, color: Colors.lightGreen[700]),
                title: Text(s.settingsBackup),
                subtitle: Text(s.settingsBackupDes),
              ),
              Divider(height: 1),
              Padding(
                padding: EdgeInsets.all(10.0),
              ),
              Container(
                height: 30.0,
                padding: EdgeInsets.symmetric(horizontal: 70),
                alignment: Alignment.centerLeft,
                child: Text(s.settingsInfo,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(color: Theme.of(context).accentColor)),
              ),
              ListTile(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Libries())),
                contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                leading: Icon(LineIcons.bookOpen, color: Colors.purple[700]),
                title: Text(s.settingsLibraries),
                subtitle: Text(s.settingsLibrariesDes),
              ),
              Divider(height: 1),
              ListTile(
                onTap: () => generalSheet(
                  context,
                  title: s.settingsFeedback,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _feedbackItem(LineIcons.github, s.feedbackGithub,
                          'https://github.com/stonega/tsacdop/issues'),
                      _feedbackItem(LineIcons.telegram, s.feedbackTelegram,
                          'https://t.me/joinchat/Bk3LkRpTHy40QYC78PK7Qg'),
                      _feedbackItem(LineIcons.envelopeOpenText, s.feedbackEmail,
                          'mailto:<tsacdop.app@gmail.com>?subject=Tsacdop Feedback'),
                      _feedbackItem(LineIcons.googlePlay, s.feedbackPlay,
                          'https://play.google.com/store/apps/details?id=com.stonegate.tsacdop'),
                    ],
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                leading: Icon(LineIcons.bug, color: Colors.pink[700]),
                title: Text(s.settingsFeedback),
                subtitle: Text(s.settingsFeedbackDes),
              ),
              Divider(
                height: 2,
              ),
              ListTile(
                onTap: () {
                  FeatureDiscovery.clearPreferences(context, <String>{
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
                contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                leading: Icon(LineIcons.capsules, color: Colors.pinkAccent),
                title: Text(s.settingsDiscovery),
              ),
              Divider(height: 1),
              ListTile(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SlideIntro(goto: Goto.settings))),
                contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                leading: Icon(LineIcons.columns, color: Colors.blueGrey),
                title: Text(s.settingsAppIntro),
              ),
              Divider(height: 1),
              Padding(
                padding: EdgeInsets.all(10.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
