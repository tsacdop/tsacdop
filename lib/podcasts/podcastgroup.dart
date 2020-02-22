import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tsacdop/class/podcast_group.dart';
import 'package:tsacdop/class/podcastlocal.dart';
import 'package:tsacdop/podcasts/podcastdetail.dart';
import 'package:tsacdop/util/pageroute.dart';

class PodcastGroupList extends StatefulWidget {
  final PodcastGroup group;
  PodcastGroupList({this.group, Key key}) : super(key: key);
  @override
  _PodcastGroupListState createState() => _PodcastGroupListState();
}

class _PodcastGroupListState extends State<PodcastGroupList> {
  bool _loadSave;

  @override
  void initState() {
    super.initState();
    _loadSave = false;
  }

  Widget _saveButton(BuildContext context) {
    var podcastList = widget.group.podcasts;
    var _groupList = Provider.of<GroupList>(context);
    return Container(
      child: InkWell(
        child: AnimatedContainer(
            duration: Duration(milliseconds: 800),
            width: _loadSave ? 70 : 0,
            height: 60,
            decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[700],
                    blurRadius: 5,
                    offset: Offset(1, 1),
                  ),
                ]),
            alignment: Alignment.center,
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
              maxLines: 1,
            )),
        onTap: () async {
          await _groupList.saveOrder(widget.group, podcastList);
          Fluttertoast.showToast(
            msg: 'Setting Saved',
            gravity: ToastGravity.BOTTOM,
          );
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
        ? Container(
            color: Theme.of(context).primaryColor,
          )
        : Container(
            color: Theme.of(context).primaryColor,
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
                  children: widget.group.podcasts
                      .map<Widget>((PodcastLocal podcastLocal) {
                    return Container(
                      decoration:
                          BoxDecoration(color: Theme.of(context).primaryColor),
                      key: ObjectKey(podcastLocal.title),
                      child: PodcastCard(
                        podcastLocal: podcastLocal,
                        group: widget.group,
                      ),
                    );
                  }).toList(),
                ),
                AnimatedPositioned(
                  duration: Duration(seconds: 1),
                  bottom: 30,
                  right: _loadSave ? 50 : 0,
                  child: _saveButton(context),
                ),
              ],
            ),
          );
  }
}

class PodcastCard extends StatefulWidget {
  final PodcastLocal podcastLocal;
  final PodcastGroup group;
  PodcastCard({this.podcastLocal, this.group, Key key}) : super(key: key);
  @override
  _PodcastCardState createState() => _PodcastCardState();
}

class _PodcastCardState extends State<PodcastCard> {
  bool _loadMenu;
  bool _addGroup;
  List<PodcastGroup> _selectedGroups;
  List<PodcastGroup> _belongGroups;
  Color _c;

  @override
  void initState() {
    super.initState();
    _loadMenu = false;
    _addGroup = false;
    _selectedGroups = [widget.group];
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
    if (Theme.of(context).brightness == Brightness.light) {
      (color[0] > 200 && color[1] > 200 && color[2] > 200)
          ? _c = Color.fromRGBO(
              (255 - color[0]), 255 - color[1], 255 - color[2], 1.0)
          : _c = Color.fromRGBO(color[0], color[1], color[2], 1.0);
    } else {
      (color[0] < 50 && color[1] < 50 && color[2] < 50)
          ? _c = Color.fromRGBO(
              (255 - color[0]), 255 - color[1], 255 - color[2], 1.0)
          : _c = Color.fromRGBO(color[0], color[1], color[2], 1.0);
    }
    double _width = MediaQuery.of(context).size.width;
    var _groupList = Provider.of<GroupList>(context);
    _belongGroups = _groupList.getPodcastGroup(widget.podcastLocal.id);

    return Column(
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
                    child: Image.file(File("${widget.podcastLocal.imagePath}")),
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
                      Row(
                        children: _belongGroups.map((group) {
                          return Container(
                              padding: EdgeInsets.only(right: 5.0),
                              child: Text(group.name));
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
                      child: AnnotatedRegion<SystemUiOverlayStyle>(
                        value: SystemUiOverlayStyle(
                          systemNavigationBarColor:
                              Colors.black.withOpacity(0.5),
                          statusBarColor: Colors.red,
                        ),
                        child: AlertDialog(
                          elevation: 2.0,
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
                                _groupList
                                    .removePodcast(widget.podcastLocal.id);
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'CONFIRM',
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          ],
                        ),
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
                      color: Theme.of(context).primaryColor,
                      border: Border(
                          bottom: BorderSide(
                              color: Theme.of(context).primaryColorDark),
                          top: BorderSide(
                              color: Theme.of(context).primaryColorDark))),
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
                                child: Row(
                                    children: _groupList.groups
                                        .map<Widget>((PodcastGroup group) {
                                  return Container(
                                    padding: EdgeInsets.only(left: 5.0),
                                    child: FilterChip(
                                      key: ValueKey<String>(group.id),
                                      label: Text(group.name),
                                      selected: _selectedGroups.contains(group),
                                      onSelected: (bool value) {
                                        setState(() {
                                          if (!value) {
                                            _selectedGroups.remove(group);
                                            print(group.name);
                                          } else {
                                            _selectedGroups.add(group);
                                          }
                                        });
                                      },
                                    ),
                                  );
                                }).toList()),
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
                                        Fluttertoast.showToast(
                                          msg: 'Setting Saved',
                                          gravity: ToastGravity.BOTTOM,
                                        );
                                      } else
                                        Fluttertoast.showToast(
                                          msg: 'At least select one group',
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _buttonOnMenu(
                                Icon(Icons.fullscreen),
                                () => Navigator.push(
                                      context,
                                      ScaleRoute(
                                          page: PodcastDetail(
                                        podcastLocal: widget.podcastLocal,
                                      )),
                                    )),
                            _buttonOnMenu(Icon(Icons.add), () {
                              setState(() {
                                _addGroup = true;
                              });
                            }),
                            _buttonOnMenu(Icon(Icons.notifications), () {})
                          ],
                        ),
                ),
              ),
      ],
    );
  }
}
