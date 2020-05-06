import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../state/podcast_group.dart';
import '../type/podcastlocal.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../podcasts/podcastdetail.dart';
import '../util/pageroute.dart';
import '../util/colorize.dart';
import '../util/duraiton_picker.dart';
import '../util/context_extension.dart';

class PodcastGroupList extends StatefulWidget {
  final PodcastGroup group;
  PodcastGroupList({this.group, Key key}) : super(key: key);
  @override
  _PodcastGroupListState createState() => _PodcastGroupListState();
}

class _PodcastGroupListState extends State<PodcastGroupList> {
  @override
  Widget build(BuildContext context) {
    var groupList = Provider.of<GroupList>(context, listen: false);
    return widget.group.podcastList.length == 0
        ? Container(
            color: Theme.of(context).primaryColor,
          )
        : Container(
            color: Theme.of(context).primaryColor,
            child: ReorderableListView(
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final PodcastLocal podcast =
                      widget.group.podcasts.removeAt(oldIndex);
                  widget.group.podcasts.insert(newIndex, podcast);
                });
                widget.group.setOrderedPodcasts = widget.group.podcasts;
                groupList.addToOrderChanged(widget.group);
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

class _PodcastCardState extends State<PodcastCard>
    with SingleTickerProviderStateMixin {
  bool _loadMenu;
  bool _addGroup;
  List<PodcastGroup> _selectedGroups;
  List<PodcastGroup> _belongGroups;
  AnimationController _controller;
  Animation _animation;
  double _value;
  int _seconds;
  int _skipSeconds;

  Future<int> getSkipSecond(String id) async {
    var dbHelper = DBHelper();
    int seconds = await dbHelper.getSkipSeconds(id);
    _skipSeconds = seconds;
    return seconds;
  }

  saveSkipSeconds(String id, int seconds) async {
    var dbHelper = DBHelper();
    await dbHelper.saveSkipSeconds(id, seconds);
  }

  String _stringForSeconds(double seconds) {
    if (seconds == null) return null;
    return '${(seconds ~/ 60)}:${(seconds.truncate() % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _loadMenu = false;
    _addGroup = false;
    _selectedGroups = [widget.group];
    _value = 0;
    _seconds = 0;
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _value = _animation.value;
        });
      });
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
    Color _c = (Theme.of(context).brightness == Brightness.light)
        ? widget.podcastLocal.primaryColor.colorizedark()
        : widget.podcastLocal.primaryColor.colorizeLight();

    double _width = MediaQuery.of(context).size.width;
    var _groupList = Provider.of<GroupList>(context);
    _belongGroups = _groupList.getPodcastGroup(widget.podcastLocal.id);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: Divider.createBorderSide(context),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InkWell(
            onTap: () => setState(
              () {
                _loadMenu = !_loadMenu;
                if (_value == 0)
                  _controller.forward();
                else
                  _controller.reverse();
              },
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              height: 100,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
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
                          child: Image.file(
                              File("${widget.podcastLocal.imagePath}")),
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
                            FutureBuilder<int>(
                              future: getSkipSecond(widget.podcastLocal.id),
                              initialData: 0,
                              builder: (context, snapshot) {
                                return snapshot.data == 0
                                    ? Center()
                                    : Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text('Skip ' +
                                            _stringForSeconds(
                                                snapshot.data.toDouble())),
                                      );
                              },
                            ),
                          ],
                        )),
                    Spacer(),
                    Transform.rotate(
                      angle: math.pi * _value,
                      child: Icon(Icons.keyboard_arrow_down),
                    ),
                    //  Icon(_loadMenu
                    //      ? Icons.keyboard_arrow_up
                    //      : Icons.keyboard_arrow_down),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
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
                                        selected:
                                            _selectedGroups.contains(group),
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
                                  Icon(Icons.fullscreen, size: 20 * _value),
                                  () => Navigator.push(
                                        context,
                                        ScaleRoute(
                                            page: PodcastDetail(
                                          podcastLocal: widget.podcastLocal,
                                        )),
                                      )),
                              _buttonOnMenu(Icon(Icons.add, size: 20 * _value),
                                  () {
                                setState(() {
                                  _addGroup = true;
                                });
                              }),
                              _buttonOnMenu(
                                  Icon(
                                    Icons.fast_forward,
                                    size: 20 * (_value),
                                  ), () {
                                showGeneralDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  barrierLabel:
                                      MaterialLocalizations.of(context)
                                          .modalBarrierDismissLabel,
                                  barrierColor: Colors.black54,
                                  transitionDuration:
                                      const Duration(milliseconds: 200),
                                  pageBuilder: (BuildContext context,
                                          Animation animaiton,
                                          Animation secondaryAnimation) =>
                                      AnnotatedRegion<SystemUiOverlayStyle>(
                                    value: SystemUiOverlayStyle(
                                      statusBarIconBrightness: Brightness.light,
                                      systemNavigationBarColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Color.fromRGBO(113, 113, 113, 1)
                                              : Color.fromRGBO(15, 15, 15, 1),
                                    ),
                                    child: AlertDialog(
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0))),
                                      titlePadding: EdgeInsets.only(
                                          top: 20,
                                          left: 20,
                                          right: 100,
                                          bottom: 20),
                                      title:
                                          Text('Skip seconds at the beginning'),
                                      content: DurationPicker(
                                        duration: Duration(
                                            seconds: _skipSeconds ?? 0),
                                        onChange: (value) =>
                                            _seconds = value.inSeconds,
                                      ),

                                      // content: Text('test'),
                                      actionsPadding: EdgeInsets.all(10),
                                      actions: <Widget>[
                                        FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _seconds = 0;
                                          },
                                          child: Text(
                                            'CANCEL',
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                        ),
                                        FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            saveSkipSeconds(
                                                widget.podcastLocal.id,
                                                _seconds);
                                          },
                                          child: Text(
                                            'CONFIRM',
                                            style: TextStyle(
                                                color: context.accentColor),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              _buttonOnMenu(
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20 * (_value),
                                  ), () {
                                showGeneralDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  barrierLabel:
                                      MaterialLocalizations.of(context)
                                          .modalBarrierDismissLabel,
                                  barrierColor: Colors.black54,
                                  transitionDuration:
                                      const Duration(milliseconds: 200),
                                  pageBuilder: (BuildContext context,
                                          Animation animaiton,
                                          Animation secondaryAnimation) =>
                                      AnnotatedRegion<SystemUiOverlayStyle>(
                                    value: SystemUiOverlayStyle(
                                      statusBarIconBrightness: Brightness.light,
                                      systemNavigationBarColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Color.fromRGBO(113, 113, 113, 1)
                                              : Color.fromRGBO(15, 15, 15, 1),
                                    ),
                                    child: AlertDialog(
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0))),
                                      titlePadding: EdgeInsets.only(
                                          top: 20,
                                          left: 20,
                                          right: 200,
                                          bottom: 20),
                                      title: Text('Remove confirm'),
                                      content: Text(
                                          'Are you sure you want to unsubscribe?'),
                                      actions: <Widget>[
                                        FlatButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text(
                                            'CANCEL',
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                        ),
                                        FlatButton(
                                          onPressed: () {
                                            _groupList.removePodcast(
                                                widget.podcastLocal.id);
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'CONFIRM',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                  ),
                ),
        ],
      ),
    );
  }
}

class RenameGroup extends StatefulWidget {
  final PodcastGroup group;
  RenameGroup({this.group, Key key}) : super(key: key);
  @override
  _RenameGroupState createState() => _RenameGroupState();
}

class _RenameGroupState extends State<RenameGroup> {
  TextEditingController _controller;
  String _newName;
  int _error;

  @override
  void initState() {
    super.initState();
    _error = 0;
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var groupList = Provider.of<GroupList>(context, listen: false);
    List list = groupList.groups.map((e) => e.name).toList();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor:
            Theme.of(context).brightness == Brightness.light
                ? Color.fromRGBO(113, 113, 113, 1)
                : Color.fromRGBO(5, 5, 5, 1),
      ),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        elevation: 1,
        contentPadding: EdgeInsets.symmetric(horizontal: 20),
        titlePadding:
            EdgeInsets.only(top: 20, left: 20, right: 200, bottom: 20),
        actionsPadding: EdgeInsets.all(0),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'CANCEL',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          FlatButton(
            onPressed: () async {
              if (list.contains(_newName)) {
                setState(() => _error = 1);
              } else {
                PodcastGroup newGroup = PodcastGroup(_newName,
                    color: widget.group.color,
                    id: widget.group.id,
                    podcastList: widget.group.podcastList);
                groupList.updateGroup(newGroup);
                Navigator.of(context).pop();
              }
            },
            child: Text('DONE',
                style: TextStyle(color: Theme.of(context).accentColor)),
          )
        ],
        title: Text('Edit group name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                hintText: widget.group.name,
                hintStyle: TextStyle(fontSize: 18),
                filled: true,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).accentColor, width: 2.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).accentColor, width: 2.0),
                ),
              ),
              cursorRadius: Radius.circular(2),
              autofocus: true,
              maxLines: 1,
              controller: _controller,
              onChanged: (value) {
                _newName = value;
              },
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: (_error == 1)
                  ? Text(
                      'Group existed',
                      style: TextStyle(color: Colors.red[400]),
                    )
                  : Center(),
            ),
          ],
        ),
      ),
    );
  }
}
