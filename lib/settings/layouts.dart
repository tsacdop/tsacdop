import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../util/context_extension.dart';
import '../util/episodegrid.dart';
import '../util/custompaint.dart';
import '../local_storage/key_value_storage.dart';

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
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0),
        child: InkWell(
          onTap: () async {
            KeyValueStorage storage = KeyValueStorage(key);
            await storage.saveInt(option.index);
            print(option.index);
            setState(() {});
          },
          child: Container(
            height: 30,
            width: 50,
            color: layout == option ? context.accentColor : Colors.transparent,
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
                  padding: EdgeInsets.symmetric(horizontal: 80),
                  alignment: Alignment.centerLeft,
                  child: Text('Default grid view',
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
                        contentPadding:
                            EdgeInsets.only(left: 80.0, right: 20, bottom: 10),
                        //  leading: Icon(Icons.colorize),
                        title: Text(
                          'Podcast page',
                        ),
                        subtitle:
                            _setDefaultGrid(context, key: podcastLayoutKey),
                      ),
                      ListTile(
                        contentPadding:
                            EdgeInsets.only(left: 80.0, right: 20, bottom: 10),
                        //  leading: Icon(Icons.colorize),
                        title: Text(
                          'Recent tab in homepage',
                        ),
                        subtitle:
                            _setDefaultGrid(context, key: recentLayoutKey),
                      ),
                      ListTile(
                        contentPadding:
                            EdgeInsets.only(left: 80.0, right: 20, bottom: 10),
                        //  leading: Icon(Icons.colorize),
                        title: Text(
                          'Favorite tab in homepage',
                        ),
                        subtitle: _setDefaultGrid(context, key: favLayoutKey),
                      ),
                      ListTile(
                        contentPadding:
                            EdgeInsets.only(left: 80.0, right: 20, bottom: 10),
                        //  leading: Icon(Icons.colorize),
                        title: Text(
                          'Download tab in homepage',
                        ),
                        subtitle: _setDefaultGrid(context, key: downloadLayoutKey),
                      ),
                      Divider(height: 2),
                    ]),
              ],
            ),
          )),
    );
  }
}
