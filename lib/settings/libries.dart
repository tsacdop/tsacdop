import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../util/context_extension.dart';
import 'licenses.dart';

class Libries extends StatelessWidget {
  _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

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
          title: Text(context.s.settingsLibraries),
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: SafeArea(
          child: Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
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
                    child: Text('Google',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(color: Theme.of(context).accentColor)),
                  ),
                  Column(
                    children: google.map<Widget>(
                      (e) {
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 80),
                          onTap: () => _launchUrl(e.link),
                          title: Text(e.name),
                          subtitle: Text(e.license),
                        );
                      },
                    ).toList(),
                  ),
                  Container(
                    height: 30.0,
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    alignment: Alignment.centerLeft,
                    child: Text(context.s.fonts,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(color: Theme.of(context).accentColor)),
                  ),
                  Column(
                    children: fonts.map<Widget>(
                      (e) {
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 80),
                          onTap: () => _launchUrl(e.link),
                          title: Text(e.name),
                          subtitle: Text(e.license),
                        );
                      },
                    ).toList(),
                  ),
                  Container(
                    height: 30.0,
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    alignment: Alignment.centerLeft,
                    child: Text(context.s.plugins,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(color: Theme.of(context).accentColor)),
                  ),
                  Container(
                    child: Column(
                      children: plugins.map<Widget>(
                        (e) {
                          return ListTile(
                            onTap: () => _launchUrl(e.link),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 80),
                            title: Text(e.name),
                            subtitle: Text(e.license),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
