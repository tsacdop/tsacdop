import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:tsacdop/class/podcast_group.dart';
import 'package:tsacdop/class/podcastlocal.dart';
import 'package:tsacdop/podcasts/podcastdetail.dart';
import 'package:tsacdop/util/pageroute.dart';
import 'package:tsacdop/util/colorize.dart';

class PodcastGroupList extends StatefulWidget {
  final PodcastGroup group;
  PodcastGroupList({this.group, Key key}) : super(key: key);
  @override
  _PodcastGroupListState createState() => _PodcastGroupListState();
}

class _PodcastGroupListState extends State<PodcastGroupList>
    with SingleTickerProviderStateMixin {
  bool _showSetting;
  AnimationController _controller;
  Animation _animation;
  double _fraction;

  @override
  void initState() {
    super.initState();
    _showSetting = false;
    _fraction = 0;
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        if (mounted)
          setState(() {
            _fraction = _animation.value;
          });
      });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.stop();
      } else if (status == AnimationStatus.dismissed) {
        _controller.stop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _saveButton(BuildContext context) {
    var podcastList = widget.group.podcasts;
    var _groupList = Provider.of<GroupList>(context, listen: false);
    return Transform(
      alignment: FractionalOffset(0.5, 0.5),
      transform: Matrix4.rotationY(math.pi * _fraction),
      child: Container(
        child: InkWell(
          child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: _fraction > 0.5 ? Colors.red : widget.group.getColor(),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[700],
                      blurRadius: 5,
                      offset: Offset(1, 1),
                    ),
                  ]),
              alignment: Alignment.center,
              child: Icon(
                _fraction > 0.5 ? Icons.save : Icons.settings,
                color: Colors.white,
              )),
          onTap: () async {
            if (_fraction == 0) {
              setState(() {
                _showSetting = true;
              });
            } else {
              await _groupList.saveOrder(widget.group, podcastList);
              Fluttertoast.showToast(
                msg: 'Setting Saved',
                gravity: ToastGravity.BOTTOM,
              );
              _controller.reverse();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var groupList = Provider.of<GroupList>(context, listen: false);
    return widget.group.podcastList.length == 0
        ? Container(
            color: Theme.of(context).primaryColor,
          )
        : Stack(
            children: <Widget>[
              Container(
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
                          _controller.forward();
                        });
                      },
                      children: widget.group.podcasts
                          .map<Widget>((PodcastLocal podcastLocal) {
                        return Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor),
                          key: ObjectKey(podcastLocal.title),
                          child: PodcastCard(
                            podcastLocal: podcastLocal,
                            group: widget.group,
                          ),
                        );
                      }).toList(),
                    ),
                    Positioned(
                      bottom: 30,
                      right: 30,
                      child: _saveButton(context),
                    ),
                  ],
                ),
              ),
              _showSetting
                  ? Positioned.fill(
                      child: GestureDetector(
                        onTap: () => setState(() => _showSetting = false),
                        child: Container(
                          color: Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.5),
                        ),
                      ),
                    )
                  : Center(),
              _showSetting
                  ? Container(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 150.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, -1),
                              blurRadius: 4,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey[400]
                                  : Colors.grey[800],
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Container(
                            height: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //  mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() => _showSetting = false);
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
                                                  Animation
                                                      secondaryAnimation) =>
                                              AnnotatedRegion<
                                                      SystemUiOverlayStyle>(
                                                  value: SystemUiOverlayStyle(
                                                    statusBarIconBrightness:
                                                        Brightness.light,
                                                    systemNavigationBarColor:
                                                        Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.light
                                                            ? Color.fromRGBO(
                                                                113,
                                                                113,
                                                                113,
                                                                1)
                                                            : Color.fromRGBO(
                                                                15, 15, 15, 1),
                                                    statusBarColor: Theme.of(
                                                                    context)
                                                                .brightness ==
                                                            Brightness.light
                                                        ? Color.fromRGBO(
                                                            113, 113, 113, 1)
                                                        : Color.fromRGBO(
                                                            5, 5, 5, 1),
                                                  ),
                                                  child: SafeArea(
                                                      child: AlertDialog(
                                                    elevation: 1,
                                                    titlePadding:
                                                        EdgeInsets.only(
                                                            top: 20,
                                                            left: 40,
                                                            right: 200,
                                                            bottom: 20),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.0))),
                                                    title:
                                                        Text('Choose a color'),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: MaterialPicker(
                                                        onColorChanged:
                                                            (value) {
                                                          PodcastGroup newGroup =
                                                              PodcastGroup(
                                                                  widget
                                                                      .group.name,
                                                                  color: value
                                                                      .toString()
                                                                      .substring(
                                                                          10,
                                                                          16),
                                                                  id: widget
                                                                      .group.id,
                                                                  podcastList:
                                                                      widget
                                                                          .group
                                                                          .podcastList);
                                                          groupList.updateGroup(
                                                              newGroup);
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        pickerColor:
                                                            Colors.blue,
                                                      ),
                                                    ),
                                                  ))));
                                    },
                                    child: Container(
                                      height: 50.0,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.colorize),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5.0),
                                          ),
                                          Text('Change Color'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() => _showSetting = false);
                                      widget.group.name == 'Home'
                                          ? Fluttertoast.showToast(
                                              msg:
                                                  'Home group is not supported',
                                              gravity: ToastGravity.BOTTOM,
                                            )
                                          : showGeneralDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              barrierLabel:
                                                  MaterialLocalizations.of(
                                                          context)
                                                      .modalBarrierDismissLabel,
                                              barrierColor: Colors.black54,
                                              transitionDuration:
                                                  const Duration(
                                                      milliseconds: 200),
                                              pageBuilder: (BuildContext
                                                          context,
                                                      Animation animaiton,
                                                      Animation
                                                          secondaryAnimation) =>
                                                  RenameGroup(
                                                    group: widget.group,
                                                  ));
                                    },
                                    child: Container(
                                      height: 50.0,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.text_fields),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5.0),
                                          ),
                                          Text('Rename'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() => _showSetting = false);
                                      widget.group.name == 'Home'
                                          ? Fluttertoast.showToast(
                                              msg:
                                                  'Home group is not supported',
                                              gravity: ToastGravity.BOTTOM,
                                            )
                                          : showGeneralDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              barrierLabel:
                                                  MaterialLocalizations.of(
                                                          context)
                                                      .modalBarrierDismissLabel,
                                              barrierColor: Colors.black54,
                                              transitionDuration:
                                                  const Duration(
                                                      milliseconds: 200),
                                              pageBuilder: (BuildContext
                                                          context,
                                                      Animation animaiton,
                                                      Animation
                                                          secondaryAnimation) =>
                                                  AnnotatedRegion<
                                                      SystemUiOverlayStyle>(
                                                    value: SystemUiOverlayStyle(
                                                      statusBarIconBrightness:
                                                          Brightness.light,
                                                      systemNavigationBarColor:
                                                          Theme.of(context)
                                                                      .brightness ==
                                                                  Brightness
                                                                      .light
                                                              ? Color.fromRGBO(
                                                                  113,
                                                                  113,
                                                                  113,
                                                                  1)
                                                              : Color.fromRGBO(
                                                                  15,
                                                                  15,
                                                                  15,
                                                                  1),
                                                      statusBarColor: Theme.of(
                                                                      context)
                                                                  .brightness ==
                                                              Brightness.light
                                                          ? Color.fromRGBO(
                                                              113, 113, 113, 1)
                                                          : Color.fromRGBO(
                                                              5, 5, 5, 1),
                                                    ),
                                                    child: SafeArea(
                                                      child: AlertDialog(
                                                        elevation: 1,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        10.0))),
                                                        titlePadding:
                                                            EdgeInsets.only(
                                                                top: 20,
                                                                left: 20,
                                                                right: 200,
                                                                bottom: 20),
                                                        title: Text(
                                                            'Delete confirm'),
                                                        content: Text(
                                                            'Are you sure you want to delete this group? Podcasts will be moved to Home group.'),
                                                        actions: <Widget>[
                                                          FlatButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(),
                                                            child: Text(
                                                              'CANCEL',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600]),
                                                            ),
                                                          ),
                                                          FlatButton(
                                                            onPressed: () {
                                                              groupList.delGroup(
                                                                  widget.group);
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text(
                                                              'CONFIRM',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ));
                                    },
                                    child: Container(
                                      height: 50,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.delete_outline),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5.0),
                                          ),
                                          Text('Delete'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(),
            ],
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
            onTap: () => setState(() => _loadMenu = !_loadMenu),
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
                          ],
                        )),
                    Spacer(),
                    Icon(_loadMenu
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down),
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
                              _buttonOnMenu(Icon(Icons.notifications), () {}),
                              _buttonOnMenu(
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
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
                                      statusBarColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Color.fromRGBO(113, 113, 113, 1)
                                              : Color.fromRGBO(5, 5, 5, 1),
                                    ),
                                    child: SafeArea(
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
                                            'Are you sure you want  to unsubscribe?'),
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
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          )
                                        ],
                                      ),
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
          statusBarColor: Theme.of(context).brightness == Brightness.light
              ? Color.fromRGBO(113, 113, 113, 1)
              : Color.fromRGBO(15, 15, 15, 1),
        ),
        child: SafeArea(
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
            title: Text('Create new group'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    hintText: 'New Group',
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
        ));
  }
}
