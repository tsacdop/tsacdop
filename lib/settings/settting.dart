import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsacdop/settings/theme.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        statusBarColor: Theme.of(context).primaryColor,
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Settings'),
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
                    child: Text('Prefrence',
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
                                builder: (context) => ThemeSetting())),
                        contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                        leading: Icon(Icons.colorize),
                        title: Text('Appearance'),
                        subtitle: Text('Colors and themes'),
                      ),
                      Divider(height: 2),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                        leading: Icon(Icons.network_check),
                        title: Text('Network'),
                        subtitle: Text('Download network setting'),
                      ),
                      Divider(height: 2),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                        leading: Icon(Icons.storage),
                        title: Text('Cache'),
                        subtitle: Text('Manage and clear cache'),
                      ),
                      Divider(height: 2),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                        leading: Icon(Icons.update),
                        title: Text('Update'),
                        subtitle: Text('Update in background'),
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
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                        leading: Icon(Icons.colorize),
                        title: Text('Changelog'),
                        subtitle: Text('List of chagnes'),
                      ),
                      Divider(height: 2),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                        leading: Icon(Icons.network_check),
                        title: Text('Credit'),
                        subtitle: Text('Open source libraried in application'),
                      ),
                      Divider(height: 2),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                        leading: Icon(Icons.storage),
                        title: Text('Cache'),
                        subtitle: Text('Manage and clear cache'),
                      ),
                      Divider(height: 2),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                        leading: Icon(Icons.update),
                        title: Text('Update'),
                        subtitle: Text('Update in background'),
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
