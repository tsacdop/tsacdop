import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../settings/downloads_manage.dart';
import '../state/setting_state.dart';
import '../local_storage/key_value_storage.dart';
import '../util/context_extension.dart';

class StorageSetting extends StatefulWidget {
  @override
  _StorageSettingState createState() => _StorageSettingState();
}

class _StorageSettingState extends State<StorageSetting>
    with SingleTickerProviderStateMixin {
  final KeyValueStorage cacheStorage = KeyValueStorage(cacheMaxKey);
  AnimationController _controller;
  Animation<double> _animation;
  _getCacheMax() async {
    int cache = await cacheStorage.getInt();
    int value = cache == 0 ? 200 : cache ~/ (1024 * 1024);
    if (value > 100) {
      _controller = AnimationController(
          vsync: this, duration: Duration(milliseconds: value * 2));
      _animation = Tween<double>(begin: 100, end: value.toDouble()).animate(
          CurvedAnimation(curve: Curves.easeOutQuart, parent: _controller))
        ..addListener(() {
          setState(() => _value = _animation.value);
        });
      _controller.forward();
    }
  }

  Future<bool> _getAutoDownloadNetwork() async {
    KeyValueStorage storage = KeyValueStorage(autoDownloadNetworkKey);
    int value = await storage.getInt();
    return value != 0;
  }

  Future<int> _getAutoDeleteDays() async {
    KeyValueStorage storage = KeyValueStorage(autoDeleteKey);
    int days = await storage.getInt();
    if (days == 0) {
      storage.saveInt(30);
      return 30;
    }
    return days;
  }

  _setAutoDeleteDays(int days) async {
    KeyValueStorage storage = KeyValueStorage(autoDeleteKey);
    await storage.saveInt(days);
    setState(() {});
  }

  _setAudtDownloadNetwork(bool boo) async {
    KeyValueStorage storage = KeyValueStorage(autoDownloadNetworkKey);
    await storage.saveInt(boo ? 1 : 0);
  }

  double _value;

  @override
  void initState() {
    super.initState();
    _value = 100;
    _getCacheMax();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
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
          title: Text(s.settingStorage),
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
                      padding: EdgeInsets.symmetric(horizontal: 70),
                      alignment: Alignment.centerLeft,
                      child: Text(s.network,
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
                        Selector<SettingState, bool>(
                          selector: (_, settings) => settings.downloadUsingData,
                          builder: (_, data, __) {
                            return ListTile(
                              onTap: () => settings.downloadUsingData = !data,
                              contentPadding: EdgeInsets.only(
                                  left: 80.0, right: 25, bottom: 10, top: 10),
                              title: Text(s.settingsNetworkCellular),
                              subtitle: Text(s.settingsNetworkCellularDes),
                              trailing: Transform.scale(
                                scale: 0.9,
                                child: Switch(
                                  value: data,
                                  onChanged: (value) =>
                                      settings.downloadUsingData = value,
                                ),
                              ),
                            );
                          },
                        ),
                        Divider(height: 2),
                        FutureBuilder<bool>(
                            future: _getAutoDownloadNetwork(),
                            initialData: false,
                            builder: (context, snapshot) {
                              return ListTile(
                                onTap: () async {
                                  _setAudtDownloadNetwork(!snapshot.data);
                                  setState(() {});
                                },
                                contentPadding: EdgeInsets.only(
                                    left: 80.0, right: 25, bottom: 10, top: 10),
                                title: Text(s.settingsNetworkCellularAuto),
                                subtitle:
                                    Text(s.settingsNetworkCellularAutoDes),
                                trailing: Transform.scale(
                                  scale: 0.9,
                                  child: Switch(
                                    value: snapshot.data,
                                    onChanged: (value) async {
                                      await _setAudtDownloadNetwork(value);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              );
                            }),
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
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    alignment: Alignment.centerLeft,
                    child: Text(s.settingStorage,
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
                        title: Text(s.download),
                        subtitle: Text(s.settingsManageDownloadDes),
                      ),
                      Divider(height: 2),
                      FutureBuilder<int>(
                        future: _getAutoDeleteDays(),
                        initialData: 30,
                        builder: (context, snapshot) {
                          return ListTile(
                            contentPadding:
                                EdgeInsets.only(left: 80.0, right: 20),
                            title: Text(s.settingsAutoDelete),
                            subtitle: Text(s.settingsAutoDeleteDes),
                            trailing: DropdownButton(
                                hint: snapshot.data == -1
                                    ? Text(s.daysCount(0))
                                    : Text(s.daysCount(snapshot.data)),
                                underline: Center(),
                                elevation: 1,
                                value: snapshot.data,
                                onChanged: (value) async {
                                  await _setAutoDeleteDays(value);
                                },
                                items: <int>[-1, 5, 10, 15, 30]
                                    .map<DropdownMenuItem<int>>((e) {
                                  return DropdownMenuItem<int>(
                                      value: e,
                                      child: e == -1
                                          ? Text(s.daysCount(0))
                                          : Text(s.daysCount(e)));
                                }).toList()),
                          );
                        },
                      ),
                      Divider(height: 2),
                      ListTile(
                        contentPadding: EdgeInsets.only(left: 80.0, right: 25),
                        //  leading: Icon(Icons.colorize),
                        title: Text(s.settingsAudioCache),
                        subtitle: Text(s.settingsAudioCacheDes),
                        trailing: Text.rich(TextSpan(
                            text: '${(_value ~/ 100) * 100}',
                            style: GoogleFonts.teko(
                                textStyle: context.textTheme.headline6
                                    .copyWith(color: context.accentColor)),
                            children: [
                              TextSpan(
                                  text: ' Mb',
                                  style: context.textTheme.subtitle2),
                            ])),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 60.0, right: 20.0, bottom: 10.0),
                        child: SliderTheme(
                          data: Theme.of(context).sliderTheme.copyWith(
                              showValueIndicator: ShowValueIndicator.always,
                              trackHeight: 2,
                              thumbShape:
                                  RoundSliderThumbShape(enabledThumbRadius: 6)),
                          child: Slider(
                              label: '${_value ~/ 100 * 100} Mb',
                              activeColor: context.accentColor,
                              inactiveColor: context.primaryColorDark,
                              value: _value,
                              min: 100,
                              max: 1000,
                              divisions: 9,
                              onChanged: (double val) {
                                setState(() {
                                  _value = val;
                                });
                                cacheStorage
                                    .saveInt((val * 1024 * 1024).toInt());
                              }),
                        ),
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
