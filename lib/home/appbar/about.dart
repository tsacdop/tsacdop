import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:line_icons/line_icons.dart';

const String version = '0.2.0';

class AboutApp extends StatelessWidget {
  _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _listItem(
          BuildContext context, String text, IconData icons, String url) =>
      InkWell(
        onTap: () => _launchUrl(url),
        child: Container(
          height: 50.0,
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border: Border(
              bottom: Divider.createBorderSide(context),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icons, color: Theme.of(context).accentColor),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
              ),
              Text(text),
            ],
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
          backgroundColor: Theme.of(context).primaryColor,
          appBar: AppBar(
            title: Text('About'),
          ),
          body: SafeArea(
            child: Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.topLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    height: 200.0,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image(
                          image: AssetImage('assets/logo.png'),
                          height: 80,
                        ),
                        Text('Version: $version'),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: Text(
                      'Tsacdop is a podcast player developed in flutter, a clean, simply beautiful and friendly app.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                          color: Theme.of(context).accentColor, width: 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Developer',
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                          ),
                        ),
                        _listItem(context, 'GitHub', LineIcons.github,
                            'https://github.com/stonaga/'),
                        _listItem(context, 'Twitter', LineIcons.twitter,
                            'https://twitter.com/shimenmen'),
                        _listItem(context, 'Medium', LineIcons.medium,
                            'https://medium.com/@stonegate'),
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/text.png',
                          height: 25,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                        ),
                        Icon(
                          Icons.favorite,
                          color: Colors.blue,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                        ),
                        FlutterLogo(
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
