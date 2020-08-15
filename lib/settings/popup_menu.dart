import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';

import '../local_storage/key_value_storage.dart';
import '../util/custom_widget.dart';
import '../util/extension_helper.dart';

class PopupMenuSetting extends StatefulWidget {
  const PopupMenuSetting({Key key}) : super(key: key);

  @override
  _PopupMenuSettingState createState() => _PopupMenuSettingState();
}

class _PopupMenuSettingState extends State<PopupMenuSetting> {
  Future<List<int>> _getEpisodeMenu() async {
    var popupMenuStorage = KeyValueStorage(episodePopupMenuKey);
    var list = await popupMenuStorage.getMenu();
    return list;
  }

  Future<bool> _getTapToOpenPopupMenu() async {
    var tapToOpenPopupMenuStorage = KeyValueStorage(tapToOpenPopupMenuKey);
    var boo = await tapToOpenPopupMenuStorage.getBool(defaultValue: false);
    return boo;
  }

  _saveEpisodeMene(List<int> list) async {
    var popupMenuStorage = KeyValueStorage(episodePopupMenuKey);
    await popupMenuStorage.saveMenu(list);
    if (mounted) setState(() {});
  }

  _saveTapToOpenPopupMenu(bool boo) async {
    var tapToOpenPopupMenuStorage = KeyValueStorage(tapToOpenPopupMenuKey);
    await tapToOpenPopupMenuStorage.saveBool(boo);
    if (mounted) setState(() {});
  }

  Widget _popupMenuItem(List<int> menu, int e,
      {Widget icon,
      String text,
      String description = '',
      bool enable = false}) {
    return Padding(
      key: ObjectKey(text),
      padding: EdgeInsets.only(left: 60.0, right: 20),
      child: ListTile(
          leading: icon,
          title: Text(text),
          subtitle: Text(description),
          onTap: e == 0
              ? null
              : () {
                  if (e >= 10) {
                    var index = menu.indexOf(e);
                    menu.remove(e);
                    menu.insert(index, e - 10);
                    _saveEpisodeMene(menu);
                  } else if (e < 10) {
                    var index = menu.indexOf(e);
                    menu.remove(e);
                    menu.insert(index, e + 10);
                    _saveEpisodeMene(menu);
                  }
                },
          trailing: Checkbox(
              value: e < 10,
              onChanged: e == 0
                  ? null
                  : (boo) {
                      if (boo && e >= 10) {
                        var index = menu.indexOf(e);
                        menu.remove(e);
                        menu.insert(index, e - 10);
                        _saveEpisodeMene(menu);
                      } else if (e < 10) {
                        var index = menu.indexOf(e);
                        menu.remove(e);
                        menu.insert(index, e + 10);
                        _saveEpisodeMene(menu);
                      }
                    })),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: context.primaryColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
      ),
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: context.primaryColor,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  color: context.primaryColor,
                  height: 200,
                  // color: Colors.red,
                  child: FlareActor(
                    'assets/longtap.flr',
                    alignment: Alignment.center,
                    animation: 'longtap',
                    fit: BoxFit.cover,
                  )),
              FutureBuilder<List<int>>(
                  future: _getEpisodeMenu(),
                  initialData: [0, 1, 12, 13, 14],
                  builder: (context, snapshot) {
                    var menu = snapshot.data;
                    return Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          Container(
                            height: 30.0,
                            padding: EdgeInsets.symmetric(horizontal: 80),
                            alignment: Alignment.centerLeft,
                            child: Text(s.settingsPopupMenu,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                        color: Theme.of(context).accentColor)),
                          ),
                          FutureBuilder<bool>(
                            future: _getTapToOpenPopupMenu(),
                            initialData: false,
                            builder: (context, snapshot) => ListTile(
                              contentPadding: EdgeInsets.only(
                                  left: 80, top: 10, bottom: 10, right: 30),
                              onTap: () =>
                                  _saveTapToOpenPopupMenu(!snapshot.data),
                              title: Text(s.settingsTapToOpenPopupMenu),
                              subtitle: Text(s.settingsTapToOpenPopupMenuDes),
                              trailing: Transform.scale(
                                scale: 0.9,
                                child: Switch(
                                    value: snapshot.data,
                                    onChanged: _saveTapToOpenPopupMenu),
                              ),
                            ),
                          ),
                          ...menu.map<Widget>((e) {
                            var i = e % 10;
                            switch (i) {
                              case 0:
                                return _popupMenuItem(menu, e,
                                    icon: Icon(
                                      LineIcons.play_circle_solid,
                                      color: context.accentColor,
                                    ),
                                    text: s.play,
                                    description: s.popupMenuPlayDes);
                                break;
                              case 1:
                                return _popupMenuItem(menu, e,
                                    icon: Icon(
                                      LineIcons.clock_solid,
                                      color: Colors.cyan,
                                    ),
                                    text: s.later,
                                    description: s.popupMenuLaterDes);
                                break;
                              case 2:
                                return _popupMenuItem(menu, e,
                                    icon: Icon(LineIcons.heart,
                                        color: Colors.red, size: 21),
                                    text: s.like,
                                    description: s.popupMenuLikeDes);
                                break;
                              case 3:
                                return _popupMenuItem(menu, e,
                                    icon: SizedBox(
                                      width: 23,
                                      height: 23,
                                      child: CustomPaint(
                                          painter: ListenedAllPainter(
                                              Colors.blue,
                                              stroke: 1.5)),
                                    ),
                                    text: s.markListened,
                                    description: s.popupMenuMarkDes);
                                break;
                              case 4:
                                return _popupMenuItem(menu, e,
                                    icon: Icon(
                                      LineIcons.download_solid,
                                      color: Colors.green,
                                    ),
                                    text: s.download,
                                    description: s.popupMenuDownloadDes);
                                break;
                              default:
                                return Text('Text');
                                break;
                            }
                          }).toList(),
                        ],
                      ),
                    );
                  }),
            ],
          )),
    );
  }
}
