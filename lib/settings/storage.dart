import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_settings/app_settings.dart';
import 'package:tsacdop/settings/downloads_manage.dart';

class StorageSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarIconBrightness: Theme.of(context).accentColorBrightness,
          systemNavigationBarColor: Theme.of(context).primaryColor,
          statusBarColor: Theme.of(context).primaryColor),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Storage'),
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: Column(
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
                    child: Text('Storage',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(color: Theme.of(context).accentColor)),
                  ),
                  ListView(
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
