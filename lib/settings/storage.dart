import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app_settings/app_settings.dart';
import 'package:tsacdop/settings/downloads_manage.dart';
import 'package:tsacdop/class/settingstate.dart';

class StorageSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<SettingState>(context, listen: false);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Storage'),
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: SafeArea(
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
                      child: Text('Network',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: Theme.of(context).accentColor)),
                    ),
                    ListView(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        ListTile(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DownloadsManage())),
                          contentPadding:
                              EdgeInsets.only(left: 80.0, right: 25),
                          title: Text('Ask before using cellular data'),
                          subtitle: Text(
                              'Ask to confirm when using cellular data to download episodes.'),
                          trailing: Selector<SettingState, bool>(
                            selector: (_, settings) =>
                                settings.downloadUsingData,
                            builder: (_, data, __) {
                              return Switch(
                                value: data,
                                onChanged: (value) =>
                                    settings.downloadUsingData = value,
                              );
                            },
                          ),
                        ),
                        Divider(height: 2),
                      ],
                    ),
                  ]),
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
                    child: Text('Storage',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(color: Theme.of(context).accentColor)),
                  ),
                  ListView(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      ListTile(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DownloadsManage())),
                        contentPadding: EdgeInsets.symmetric(horizontal: 80.0),
                        title: Text('Downloads'),
                        subtitle: Text('Manage doanloaded audio files'),
                      ),
                      Divider(height: 2),
                      ListTile(
                        onTap: () => AppSettings.openAppSettings(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 80.0),
                        //  leading: Icon(Icons.colorize),
                        title: Text('Cache'),
                        subtitle: Text('Audio cache'),
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
    );
  }
}
