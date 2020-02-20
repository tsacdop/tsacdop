import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tsacdop/class/podcast_group.dart';
import 'package:tsacdop/class/podcastlocal.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:tsacdop/class/settingstate.dart';

class PodcastGroupList extends StatefulWidget {
  final PodcastGroup group;
  PodcastGroupList({this.group, Key key}) : super(key: key);
  @override
  _PodcastGroupListState createState() => _PodcastGroupListState();
}

class _PodcastGroupListState extends State<PodcastGroupList> {
  bool _loading;
  bool _loadSave;
  String dir;

  @override
  void initState() {
    super.initState();
    _loading = false;
    _loadSave = false;
    getApplicationDocumentsDirectory().then((value) {
      dir = value.path;
      setState(() {
        _loading = true;
      });
    });
  }

  Widget _saveButton(BuildContext context) {
    var _settingState = Provider.of<SettingState>(context);
    _saveOrder(List<PodcastLocal> podcastList) async {
      var dbHelper = DBHelper();
      await dbHelper.saveOrder(podcastList);
    }

    var podcastList = widget.group.podcasts;
    return Container(
      child: InkWell(
        child: AnimatedContainer(
            duration: Duration(milliseconds: 800),
            width: _loadSave ? 70 : 0,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            alignment: Alignment.center,
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
              maxLines: 1,
            )),
        onTap: () async {
          await _saveOrder(podcastList);
          Fluttertoast.showToast(
            msg: 'Setting Saved',
            gravity: ToastGravity.BOTTOM,
          );
          _settingState.subscribeUpdate = Update.justupdate;
          setState(() {
            _loadSave = false;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.group.podcastList.length == 0
    ? Center()
    : Container(
      color: Colors.grey[100],
      child: Stack(
        children: <Widget>[
          ReorderableListView(
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final PodcastLocal podcast =
                    widget.group.podcasts.removeAt(oldIndex);
                widget.group.podcasts.insert(newIndex, podcast);
                _loadSave = true;
              });
            },
            children:
                widget.group.podcasts.map<Widget>((PodcastLocal podcastLocal) {
              return Container(
                decoration: BoxDecoration(color: Colors.grey[100]),
                key: ObjectKey(podcastLocal.title),
                child: !_loading
                    ? CircularProgressIndicator()
                    : PodcastCard(
                        path: dir,
                        podcastLocal: podcastLocal,
                        group: widget.group.name,
                      ),
              );
            }).toList(),
          ),
          AnimatedPositioned(
            duration: Duration(seconds: 1),
            bottom: 30,
            right: _loadSave ? 50 : 0,
            child: Center(),
            //_saveButton(context),
          ),
        ],
      ),
    );
  }
}

class PodcastCard extends StatefulWidget {
  final PodcastLocal podcastLocal;
  final String path;
  final String group;
  PodcastCard({this.podcastLocal, this.path, this.group, Key key})
      : super(key: key);
  @override
  _PodcastCardState createState() => _PodcastCardState();
}

class _PodcastCardState extends State<PodcastCard> {
  bool _loadMenu;
  bool _remove;
  bool _addGroup;
  bool _loadGroup;
  List<String> _selectedGroups;
  List<String> _belongGroups;
  Color _c;

  _unSubscribe(String title) async {
    var dbHelper = DBHelper();
    await dbHelper.delPodcastLocal(title);
  }

  @override
  void initState() {
    super.initState();
    _loadMenu = false;
    _remove = false;
    _addGroup = false;
    _loadGroup = false;
  }

  Widget _buttonOnMenu(Widget widget, VoidCallback onTap) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
              height: 50.0,
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: widget),
        ),
      );

  @override
  Widget build(BuildContext context) {
    var color = json.decode(widget.podcastLocal.primaryColor);
    (color[0] > 200 && color[1] > 200 && color[2] > 200)
        ? _c = Color.fromRGBO(
            (255 - color[0]), 255 - color[1], 255 - color[2], 1.0)
        : _c = Color.fromRGBO(color[0], color[1], color[2], 1.0);
    double _width = MediaQuery.of(context).size.width;
    var _settingState = Provider.of<SettingState>(context);
    var _groupList = Provider.of<GroupList>(context);
    _selectedGroups = _groupList.groups.map((e) => e.name).toList();
    _belongGroups = _groupList
        .getPodcastGroup(widget.podcastLocal.id)
        .map((e) => e.name)
        .toList();
    return _remove
        ? Center()
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              InkWell(
                onTap: () => setState(() => _loadMenu = !_loadMenu),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  height: 100,
                  child: Row(children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.unfold_more,
                        color: _c,
                      ),
                    ),
                    Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        child: Container(
                          height: 60,
                          width: 60,
                          child: Image.file(File(
                              "${widget.path}/${widget.podcastLocal.title}.png")),
                        ),
                      ),
                    ),
                    Container(
                        width: _width / 2,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.podcastLocal.title,
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            !_loadGroup
                                ? Center()
                                : Row(
                                    children: _belongGroups.map((group) {
                                      return Container(
                                          padding: EdgeInsets.only(right: 5.0),
                                          child: Text(group));
                                    }).toList(),
                                  ),
                          ],
                        )),
                    Spacer(),
                    Icon(_loadMenu
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                    ),
                    OutlineButton(
                      child: Text('Remove'),
                      onPressed: () {
                        showDialog(
                            context: context,
                            child: AlertDialog(
                              title: Text('Remove confirm'),
                              content: Text(
                                  '${widget.podcastLocal.title} will be removed from device.'),
                              actions: <Widget>[
                                FlatButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('CANCEL'),
                                ),
                                FlatButton(
                                  onPressed: () {
                                    _unSubscribe(widget.podcastLocal.title);
                                    _settingState.subscribeUpdate =
                                        Update.justupdate;
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'CONFIRM',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                )
                              ],
                            ));
                      },
                    ),
                  ]),
                ),
              ),
              !_loadMenu
                  ? Center()
                  : Container(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border(
                                bottom: BorderSide(color: Colors.grey[300]),
                                top: BorderSide(color: Colors.grey[300]))),
                        height: 50,
                        child: _addGroup
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Consumer<GroupList>(
                                        builder: (_, groupList, __) => Row(
                                            children: groupList.groups
                                                .map<Widget>(
                                                    (PodcastGroup group) {
                                          return Container(
                                            padding: EdgeInsets.only(left: 5.0),
                                            child: FilterChip(
                                              key: ValueKey<String>(group.name),
                                              label: Text(group.name),
                                              selected: _belongGroups
                                                      .contains(group.name) &&
                                                  _selectedGroups
                                                      .contains(group.name),
                                              onSelected: (bool value) {
                                                setState(() {
                                                  if (!value) {
                                                    _selectedGroups
                                                        .remove(group.name);
                                                  } else {
                                                    _selectedGroups
                                                        .add(group.name);
                                                  }
                                                });
                                              },
                                            ),
                                          );
                                        }).toList()),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(Icons.clear),
                                          onPressed: () => setState(() {
                                            _addGroup = false;
                                          }),
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            print(_selectedGroups);
                                            if (_selectedGroups.length > 0) {
                                              setState(() {
                                                _addGroup = false;
                                              });
                                              await _groupList.changeGroup(
                                                widget.podcastLocal.id,
                                                _selectedGroups,
                                              );
                                              _settingState.subscribeUpdate =
                                                  Update.justupdate;
                                              Fluttertoast.showToast(
                                                msg: 'Setting Saved',
                                                gravity: ToastGravity.BOTTOM,
                                              );
                                              if (!_selectedGroups
                                                  .contains(widget.group)) {
                                                print(widget.group);
                                                setState(() {
                                                  _remove = true;
                                                });
                                              }
                                            } else
                                              Fluttertoast.showToast(
                                                msg:
                                                    'At least select one group',
                                                gravity: ToastGravity.BOTTOM,
                                              );
                                          },
                                          icon: Icon(Icons.done),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  _buttonOnMenu(Icon(Icons.fullscreen), () {}),
                                  _buttonOnMenu(Icon(Icons.add), () {
                                    setState(() {
                                      _addGroup = true;
                                    });
                                  }),
                                  _buttonOnMenu(
                                      Icon(Icons.notifications), () {})
                                ],
                              ),
                      ),
                    ),
            ],
          );
  }
}
