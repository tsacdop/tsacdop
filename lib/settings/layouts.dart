import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../util/context_extension.dart';
import '../util/episodegrid.dart';
import '../util/custompaint.dart';
import '../local_storage/key_value_storage.dart';
import 'popup_menu.dart';

class LayoutSetting extends StatefulWidget {
  const LayoutSetting({Key key}) : super(key: key);

  @override
  _LayoutSettingState createState() => _LayoutSettingState();
}

class _LayoutSettingState extends State<LayoutSetting> {
  Future<Layout> _getLayout(String key) async {
    KeyValueStorage keyValueStorage = KeyValueStorage(key);
    int layout = await keyValueStorage.getInt();
    return Layout.values[layout];
  }

  Widget _gridOptions(BuildContext context,
          {String key, Layout layout, Layout option, double scale}) =>
      Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: InkWell(
          onTap: () async {
            KeyValueStorage storage = KeyValueStorage(key);
            await storage.saveInt(option.index);
            setState(() {});
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 400),
            height: 30,
            width: 50,
            color: layout == option
                ? context.accentColor
                : context.primaryColorDark,
            alignment: Alignment.center,
            child: SizedBox(
              height: 10,
              width: 30,
              child: CustomPaint(
                painter: LayoutPainter(
                    scale,
                    layout == option
                        ? Colors.white
                        : context.textTheme.bodyText1.color),
              ),
            ),
          ),
        ),
      );

  Widget _setDefaultGrid(BuildContext context, {String key}) {
    return FutureBuilder<Layout>(
        future: _getLayout(key),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _gridOptions(context,
                        key: key,
                        layout: snapshot.data,
                        option: Layout.one,
                        scale: 4),
                    _gridOptions(context,
                        key: key,
                        layout: snapshot.data,
                        option: Layout.two,
                        scale: 1),
                    _gridOptions(context,
                        key: key,
                        layout: snapshot.data,
                        option: Layout.three,
                        scale: 0),
                  ],
                )
              : Center();
        });
  }

  Widget _setDefaultGridView(BuildContext context, {String text, String key}) {
    return Padding(
      padding: EdgeInsets.only(left: 80.0, right: 20, bottom: 10),
      child: context.width > 360
          ? Row(
              children: [
                Text(
                  text,
                ),
                Spacer(),
                _setDefaultGrid(context, key: key),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                ),
                _setDefaultGrid(context, key: key),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: context.primaryColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
      ),
      child: Scaffold(
          appBar: AppBar(
            title: Text('Layout'),
            elevation: 0,
            backgroundColor: context.primaryColor,
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                ),
                Container(
                  height: 30.0,
                  padding: EdgeInsets.symmetric(horizontal: 70),
                  alignment: Alignment.centerLeft,
                  child: Text('Episode popup menu',
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
                                builder: (context) => PopupMenuSetting())),
                        contentPadding: EdgeInsets.only(left: 80.0, right: 20),
                        title: Text('Episode popup menu'),
                        subtitle: Text('Change the menu when long tap episode'),
                      ),
                      Divider(height: 2),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                      ),
                      Container(
                        height: 30.0,
                        padding: EdgeInsets.symmetric(horizontal: 70),
                        alignment: Alignment.centerLeft,
                        child: Text('Default grid view',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(
                                    color: Theme.of(context).accentColor)),
                      ),
                      ListView(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          children: <Widget>[
                            _setDefaultGridView(context,
                                text: 'Podcast page', key: podcastLayoutKey),
                            _setDefaultGridView(context,
                                text: 'Recent tab', key: recentLayoutKey),
                            _setDefaultGridView(context,
                                text: 'Favorite tab', key: favLayoutKey),
                            _setDefaultGridView(context,
                                text: 'Downlaod tab', key: downloadLayoutKey),
                          ]),
                      Divider(height: 2)
                    ]),
              ],
            ),
          )),
    );
  }
}
