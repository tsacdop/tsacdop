import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';

import '../util/custom_widget.dart';
import '../util/extension_helper.dart';

const String version = '0.4.18';

class AboutApp extends StatelessWidget {
  Widget _listItem(
          BuildContext context, String text, IconData icons, String url) =>
      InkWell(
        onTap: () => url.launchUrl,
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
  Widget _translatorInfo(BuildContext context, {String name, String flag}) =>
      Container(
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
            Icon(LineIcons.user, color: Theme.of(context).accentColor),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
            ),
            Expanded(
                child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.fade,
            )),
            if (flag != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image(
                  image: AssetImage('assets/$flag.png'),
                  height: 20,
                  width: 30,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    OverlayEntry _createOverlayEntry(TapDownDetails detail) {
      // RenderBox renderBox = context.findRenderObject();
      var offset = detail.globalPosition;
      return OverlayEntry(
        builder: (constext) => Positioned(
          left: offset.dx - 5,
          top: offset.dy - 120,
          child: Container(
              width: 20,
              height: 120,
              color: Colors.transparent,
              alignment: Alignment.topCenter,
              child: HeartSet(height: 120, width: 20)),
        ),
      );
    }

    final s = context.s;
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
          title: Text(s.homeToprightMenuAbout),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    height: 110.0,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image(
                          image: AssetImage('assets/logo.png'),
                          height: 80,
                        ),
                        Text(s.version(version)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Tsacdop is a podcast player built with flutter, a clean, simply beautiful and friendly app.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FlatButton(
                        onPressed: () =>
                            'https://tsacdop.stonegate.me/#/privacy'.launchUrl,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(s.privacyPolicy,
                            style: TextStyle(color: context.accentColor)),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        height: 4,
                        width: 4,
                        decoration: BoxDecoration(
                            color: context.accentColor, shape: BoxShape.circle),
                      ),
                      FlatButton(
                        onPressed: () =>
                            'https://tsacdop.stonegate.me/#/changelog'
                                .launchUrl,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(s.changelog,
                            style: TextStyle(color: context.accentColor)),
                      ),
                    ],
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
                        Text(
                          s.developer,
                          style: TextStyle(
                              color: context.accentColor,
                              fontWeight: FontWeight.bold),
                        ),
                        _listItem(context, 'Twitter', LineIcons.twitter,
                            'https://twitter.com/shimenmen'),
                        _listItem(context, 'GitHub', LineIcons.github_alt,
                            'https://github.com/stonega'),
                        _listItem(context, 'Medium', LineIcons.medium,
                            'https://medium.com/@stonegate'),
                        Center(
                          child: SizedBox(
                            width: 200,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              color: Colors.yellow.withAlpha(70),
                              onPressed: () =>
                                  'https://www.buymeacoffee.com/stonegate'
                                      .launchUrl,
                              child: Container(
                                height: 30.0,
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text('Buy me a coffee',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(width: 10),
                                    Image(
                                      image:
                                          AssetImage('assets/buymeacoffee.png'),
                                      height: 20,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Text(
                            'I need to pay for podcast search API and '
                            'always get headache without caffeine.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(color: context.accentColor, width: 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              s.translators,
                              style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.favorite, color: Colors.red, size: 20),
                          ],
                        ),
                        _translatorInfo(context, name: 'Atrate'),
                        _translatorInfo(context, name: 'ppp', flag: 'fr'),
                        _translatorInfo(context,
                            name: 'Joel Israel', flag: 'mx'),
                        _translatorInfo(context,
                            name: 'Bruno Pinheiro', flag: 'pt'),
                      ],
                    ),
                  ),
                  //Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTapDown: (detail) async {
                        OverlayEntry _overlayEntry;
                        _overlayEntry = _createOverlayEntry(detail);
                        Overlay.of(context).insert(_overlayEntry);
                        await Future.delayed(Duration(seconds: 2));
                        _overlayEntry?.remove();
                      },
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
