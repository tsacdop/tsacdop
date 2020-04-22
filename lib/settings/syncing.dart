import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:tsacdop/class/settingstate.dart';

class SyncingSetting extends StatelessWidget {
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
          title: Text('Syncing'),
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Selector<SettingState, Tuple2<bool, int>>(
                selector: (_, settings) =>
                    Tuple2(settings.autoUpdate, settings.updateInterval),
                builder: (_, data, __) => Column(
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
                      child: Text('Syncing',
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
                          onTap: () {
                            if (settings.autoUpdate) {
                              settings.autoUpdate = false;
                              settings.cancelWork();
                            } else {
                              settings.autoUpdate = true;
                              settings.setWorkManager(data.item2);
                            }
                          },
                          contentPadding: EdgeInsets.only(
                              left: 80.0, right: 20, bottom: 10),
                          title: Text('Enable syncing'),
                          subtitle: Text(
                              'Refresh all podcasts in the background to get leatest episodes'),
                          trailing: Switch(
                              value: data.item1,
                              onChanged: (boo) async {
                                settings.autoUpdate = boo;
                                if (boo)
                                  settings.setWorkManager(data.item2);
                                else
                                  settings.cancelWork();
                              }),
                        ),
                        Divider(height: 2),
                        ListTile(
                          contentPadding:
                              EdgeInsets.only(left: 80.0, right: 20),
                          title: Text('Update Interval'),
                          subtitle: Text('Default 24 hours'),
                          trailing: DropdownButton(
                              hint: data.item2 == 1
                                  ? Text(data.item2.toString() + ' hour')
                                  : Text(data.item2.toString() + 'hours'),
                              underline: Center(),
                              elevation: 1,
                              value: data.item2,
                              onChanged: data.item1
                                  ? (value) async {
                                      await settings.cancelWork();
                                      settings.setWorkManager(value);
                                    }
                                  : null,
                              items: <int>[1, 2, 4, 8, 24, 48]
                                  .map<DropdownMenuItem<int>>((e) {
                                return DropdownMenuItem<int>(
                                    value: e,
                                    child: e == 1
                                        ? Text(e.toString() + ' hour')
                                        : Text(e.toString() + ' hours'));
                              }).toList()),
                        ),
                        Divider(height: 2),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
