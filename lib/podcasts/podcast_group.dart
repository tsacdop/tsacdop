import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../local_storage/sqflite_localpodcast.dart';
import '../state/podcast_group.dart';
import '../type/podcastlocal.dart';
import '../util/extension_helper.dart';
import '../widgets/duraiton_picker.dart';
import '../widgets/general_dialog.dart';
import 'podcast_settings.dart';

class PodcastGroupList extends StatefulWidget {
  final PodcastGroup group;
  PodcastGroupList({this.group, Key key}) : super(key: key);
  @override
  _PodcastGroupListState createState() => _PodcastGroupListState();
}

class _PodcastGroupListState extends State<PodcastGroupList> {
  PodcastGroup _group;
  @override
  void initState() {
    super.initState();
    _group = widget.group;
  }

  @override
  void didUpdateWidget(PodcastGroupList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group != widget.group) setState(() => _group = widget.group);
  }

  @override
  Widget build(BuildContext context) {
    return _group.podcastList.isEmpty
        ? Container(
            color: context.primaryColor,
          )
        : Container(
            color: context.primaryColor,
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  _group.reorderGroup(oldIndex, newIndex);
                });
                context.read<GroupList>().addToOrderChanged(_group);
              },
              children: _group.podcasts.map<Widget>(
                (podcastLocal) {
                  return Container(
                    decoration:
                        BoxDecoration(color: Theme.of(context).primaryColor),
                    key: ObjectKey(podcastLocal.title),
                    child: _PodcastCard(
                      podcastLocal: podcastLocal,
                      group: _group,
                    ),
                  );
                },
              ).toList(),
            ),
          );
  }
}

class _PodcastCard extends StatefulWidget {
  final PodcastLocal podcastLocal;
  final PodcastGroup group;
  _PodcastCard({this.podcastLocal, this.group, Key key}) : super(key: key);
  @override
  __PodcastCardState createState() => __PodcastCardState();
}

class __PodcastCardState extends State<_PodcastCard>
    with SingleTickerProviderStateMixin {
  bool _addGroup;
  List<PodcastGroup> _selectedGroups;
  List<PodcastGroup> _belongGroups;
  AnimationController _controller;
  Animation _animation;
  double _value;
  int _seconds;
  int _skipSeconds;

  Future<int> _getSkipSecond(String id) async {
    var dbHelper = DBHelper();
    var seconds = await dbHelper.getSkipSecondsStart(id);
    _skipSeconds = seconds;
    return seconds;
  }

  _saveSkipSeconds(String id, int seconds) async {
    var dbHelper = DBHelper();
    await dbHelper.saveSkipSecondsStart(id, seconds);
  }

  _setAutoDownload(String id, bool boo) async {
    var permission = await _checkPermmison();
    if (permission) {
      var dbHelper = DBHelper();
      await dbHelper.saveAutoDownload(id, boo: boo);
    }
  }

  Future<bool> _getAutoDownload(String id) async {
    var dbHelper = DBHelper();
    return await dbHelper.getAutoDownload(id);
  }

  Future<bool> _checkPermmison() async {
    var permission = await Permission.storage.status;
    if (permission != PermissionStatus.granted) {
      var permissions = await [Permission.storage].request();
      if (permissions[Permission.storage] == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
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

  Widget _buttonOnMenu({Widget icon, VoidCallback onTap, String tooltip}) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
              height: 50.0,
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: icon,
                  ),
                  Text(tooltip, style: context.textTheme.subtitle2),
                ],
              )),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final c = widget.podcastLocal.backgroudColor(context);
    final s = context.s;
    var groupList = context.watch<GroupList>();
    _belongGroups = groupList.getPodcastGroup(widget.podcastLocal.id);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _addGroup = !_addGroup),
            child: SizedBox(
              height: 100,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.unfold_more,
                      color: c,
                    ),
                    SizedBox(width: 5),
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: widget.podcastLocal.avatarImage,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            widget.podcastLocal.title,
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Row(
                            children: _belongGroups.map((group) {
                              return Container(
                                  padding: EdgeInsets.only(right: 5.0),
                                  child: Text(group.name));
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.add),
                        splashRadius: 20,
                        tooltip: s.menu,
                        onPressed: () =>
                            setState(() => _addGroup = !_addGroup)),
                    IconButton(
                        icon: Icon(Icons.more_vert),
                        splashRadius: 20,
                        tooltip: s.menu,
                        onPressed: () => generalSheet(
                              context,
                              title: widget.podcastLocal.title,
                              child: PodcastSetting(
                                  podcastLocal: widget.podcastLocal),
                            ).then((value) {
                              if (mounted) setState(() {});
                            })),
                  ]),
            ),
          ),
        ),
        !_addGroup
            ? Center()
            : Container(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.scaffoldBackgroundColor,
                  ),
                  // border: Border(
                  //     bottom: BorderSide(
                  //         color: Theme.of(context).primaryColorDark),
                  //     top: BorderSide(
                  //         color: Theme.of(context).primaryColorDark))),
                  height: 50,
                  child: _addGroup
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                    children:
                                        groupList.groups.map<Widget>((group) {
                                  return Container(
                                    padding: EdgeInsets.only(left: 5.0),
                                    child: FilterChip(
                                      key: ValueKey<String>(group.id),
                                      label: Text(group.name),
                                      selected: _selectedGroups.contains(group),
                                      onSelected: (value) {
                                        setState(() {
                                          if (!value) {
                                            _selectedGroups.remove(group);
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
                            Material(
                              color: Colors.transparent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.clear),
                                    splashRadius: 20,
                                    onPressed: () => setState(() {
                                      _addGroup = false;
                                    }),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.done),
                                    splashRadius: 20,
                                    onPressed: () async {
                                      if (_selectedGroups.length > 0) {
                                        setState(() {
                                          _addGroup = false;
                                        });
                                        await groupList.changeGroup(
                                          widget.podcastLocal,
                                          _selectedGroups,
                                        );
                                        Fluttertoast.showToast(
                                          msg: s.toastSettingSaved,
                                          gravity: ToastGravity.BOTTOM,
                                        );
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: s.toastOneGroup,
                                          gravity: ToastGravity.BOTTOM,
                                        );
                                      }
                                    },
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
                                icon: Icon(Icons.add,
                                    size: _value == 0 ? 1 : 20 * _value),
                                onTap: () {
                                  setState(() {
                                    _addGroup = true;
                                  });
                                },
                                tooltip: s.groups(0)),
                            FutureBuilder<bool>(
                              future: _getAutoDownload(widget.podcastLocal.id),
                              initialData: false,
                              builder: (context, snapshot) {
                                return _buttonOnMenu(
                                  icon: Container(
                                    child: Icon(Icons.file_download,
                                        size: _value * 15,
                                        color: snapshot.data
                                            ? Colors.white
                                            : null),
                                    height: _value == 0 ? 1 : 20 * _value,
                                    width: _value == 0 ? 1 : 20 * _value,
                                    decoration: BoxDecoration(
                                        border: snapshot.data
                                            ? Border.all(
                                                width: 1,
                                                color: snapshot.data
                                                    ? context.accentColor
                                                    : context.textTheme
                                                        .subtitle1.color)
                                            : null,
                                        shape: BoxShape.circle,
                                        color: snapshot.data
                                            ? context.accentColor
                                            : null),
                                  ),
                                  tooltip: s.autoDownload,
                                  onTap: () async {
                                    await _setAutoDownload(
                                        widget.podcastLocal.id, !snapshot.data);
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                            FutureBuilder<int>(
                                future: _getSkipSecond(widget.podcastLocal.id),
                                initialData: 0,
                                builder: (context, snapshot) {
                                  return _buttonOnMenu(
                                      icon: Icon(
                                        Icons.fast_forward,
                                        size: _value == 0 ? 1 : 20 * (_value),
                                      ),
                                      tooltip:
                                          'Skip${snapshot.data == 0 ? '' : snapshot.data.toTime}',
                                      onTap: () {
                                        generalDialog(
                                          context,
                                          title: Text(s.skipSecondsAtStart,
                                              maxLines: 2),
                                          content: DurationPicker(
                                            duration: Duration(
                                                seconds: _skipSeconds ?? 0),
                                            onChange: (value) =>
                                                _seconds = value.inSeconds,
                                          ),
                                          actions: <Widget>[
                                            FlatButton(
                                              splashColor: context.accentColor
                                                  .withAlpha(70),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                _seconds = 0;
                                              },
                                              child: Text(
                                                s.cancel,
                                                style: TextStyle(
                                                    color: Colors.grey[600]),
                                              ),
                                            ),
                                            FlatButton(
                                              splashColor: context.accentColor
                                                  .withAlpha(70),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                _saveSkipSeconds(
                                                    widget.podcastLocal.id,
                                                    _seconds);
                                              },
                                              child: Text(
                                                s.confirm,
                                                style: TextStyle(
                                                    color: context.accentColor),
                                              ),
                                            )
                                          ],
                                        );
                                      });
                                }),
                            _buttonOnMenu(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: _value == 0 ? 1 : 20 * _value,
                                ),
                                tooltip: s.remove,
                                onTap: () {
                                  generalDialog(
                                    context,
                                    title: Text(s.removeConfirm),
                                    content: Text(s.removePodcastDes),
                                    actions: <Widget>[
                                      FlatButton(
                                        splashColor:
                                            context.accentColor.withAlpha(70),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text(
                                          s.cancel,
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                      ),
                                      FlatButton(
                                        splashColor: Colors.red.withAlpha(70),
                                        onPressed: () {
                                          groupList.removePodcast(
                                              widget.podcastLocal);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          s.confirm,
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      )
                                    ],
                                  );
                                }),
                          ],
                        ),
                ),
              ),
        Divider(height: 1)
      ],
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
    _controller = TextEditingController(text: widget.group.name);
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
    final s = context.s;
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
        titlePadding: EdgeInsets.all(20),
        actionsPadding: EdgeInsets.zero,
        actions: <Widget>[
          FlatButton(
            splashColor: context.accentColor.withAlpha(70),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              s.cancel,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          FlatButton(
            splashColor: context.accentColor.withAlpha(70),
            onPressed: () async {
              if (list.contains(_newName)) {
                setState(() => _error = 1);
              } else {
                var newGroup = PodcastGroup(_newName,
                    color: widget.group.color,
                    id: widget.group.id,
                    podcastList: widget.group.podcastList);
                groupList.updateGroup(newGroup);
                Navigator.of(context).pop();
              }
            },
            child: Text(s.confirm,
                style: TextStyle(color: Theme.of(context).accentColor)),
          )
        ],
        title:
            SizedBox(width: context.width - 160, child: Text(s.editGroupName)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                hintStyle: TextStyle(fontSize: 18),
                filled: true,
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: context.accentColor, width: 2.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: context.accentColor, width: 2.0),
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
                      s.groupExisted,
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
