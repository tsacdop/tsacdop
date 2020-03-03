import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
         statusBarColor: Theme.of(context).primaryColor,
      ),
      child: SafeArea(
              child: Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            appBar: AppBar(
              title: Text('About'),
            ),
            body: Container(
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
                        Text('Version: 0.1.1'),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    height: 50,
                    child: Text(
                      'Tsacdop is a podcast client developed with flutter, a simple, beautiful, and easy-use player.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      top: 20.0,
                      bottom: 10.0
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(color: Theme.of(context).accentColor, width: 1),
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
                        _listItem(
                            context,
                            'GitHub',
                            FontAwesomeIcons.githubSquare,
                            'https://github.com/stonaga/tsacdop'),
                        _listItem(
                            context,
                            'Twitter',
                            FontAwesomeIcons.twitterSquare,
                            'https://twitter.com'),
                        _listItem(
                            context,
                            'Gmail',
                            FontAwesomeIcons.envelopeSquare,
                            'mailto:<xijieyin@gmail.com>?subject=Tsacdop Feedback'),
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
            )),
      ),
    );
  }
}
