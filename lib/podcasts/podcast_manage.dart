import 'dart:math' as math;

import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../state/podcast_group.dart';
import '../util/extension_helper.dart';
import '../util/pageroute.dart';
import '../widgets/custom_widget.dart';
import '../widgets/feature_discovery.dart';
import '../widgets/general_dialog.dart';
import 'custom_tabview.dart';
import 'podcast_group.dart';
import 'podcastlist.dart';

class PodcastManage extends StatefulWidget {
  @override
  _PodcastManageState createState() => _PodcastManageState();
}

class _PodcastManageState extends State<PodcastManage>
    with TickerProviderStateMixin {
  bool _showSetting;
  double _menuValue;
  AnimationController _controller;
  AnimationController _menuController;
  Animation _animation;
  Animation _menuAnimation;
  double _fraction;
  int _index;

  @override
  void initState() {
    super.initState();
    _showSetting = false;
    _fraction = 0;
    _menuValue = 0;
    _index = 0;
    _menuController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        if (mounted) {
          setState(() => _fraction = _animation.value);
        }
      });
    _menuAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _menuController, curve: Curves.elasticInOut))
      ..addListener(() {
        if (mounted) setState(() => _menuValue = _menuAnimation.value);
      });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.stop();
      } else if (status == AnimationStatus.dismissed) {
        _controller.stop();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FeatureDiscovery.discoverFeatures(context,
          const <String>{addGroupFeature, configureGroup, configurePodcast});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _menuController.dispose();
    super.dispose();
  }

  Widget _saveButton() {
    final s = context.s;
    return Consumer<GroupList>(
      builder: (_, groupList, __) {
        if (groupList.orderChanged.contains(groupList.groups[_index])) {
          _controller.forward();
        } else if (_fraction > 0) {
          _controller.reverse();
        }
        return featureDiscoveryOverlay(
          context,
          featureId: configureGroup,
          tapTarget: Icon(Icons.menu),
          title: s.featureDiscoveryEditGroup,
          backgroundColor: Colors.cyan[600],
          description: s.featureDiscoveryEditGroupDes,
          buttonColor: Colors.cyan[500],
          child: Transform(
            alignment: FractionalOffset.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(math.pi * _fraction),
            child: InkWell(
              onTap: () async {
                if (_fraction == 0) {
                  !_showSetting
                      ? _menuController.forward()
                      : await _menuController.reverse();
                  if (mounted) {
                    setState(() {
                      _showSetting = !_showSetting;
                    });
                  }
                } else {
                  groupList.saveOrder(groupList.groups[_index]);
                  groupList.drlFromOrderChanged(groupList.groups[_index].name);
                  Fluttertoast.showToast(
                    msg: context.s.toastSettingSaved,
                    gravity: ToastGravity.BOTTOM,
                  );
                  _controller.reverse();
                }
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: _fraction > 0.5
                        ? Colors.red
                        : Theme.of(context).accentColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[700].withOpacity(0.5),
                        blurRadius: 1,
                        offset: Offset(1, 1),
                      ),
                    ]),
                alignment: Alignment.center,
                child: _fraction > 0.5
                    ? Icon(LineIcons.save_solid, color: Colors.white)
                    : AnimatedIcon(
                        color: Colors.white,
                        icon: AnimatedIcons.menu_close,
                        progress: _menuController,
                      ),
                // color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
        // statusBarColor: Theme.of(context).primaryColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.s.groups(2)),
          leading: CustomBackButton(),
          actions: <Widget>[
            featureDiscoveryOverlay(
              context,
              featureId: addGroupFeature,
              tapTarget: Icon(Icons.add),
              title: s.featureDiscoveryGroup,
              backgroundColor: Colors.cyan[600],
              description: s.featureDiscoveryGroupDes,
              buttonColor: Colors.cyan[500],
              child: IconButton(
                  splashRadius: 20,
                  onPressed: () => showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: MaterialLocalizations.of(context)
                          .modalBarrierDismissLabel,
                      barrierColor: Colors.black54,
                      transitionDuration: const Duration(milliseconds: 200),
                      pageBuilder: (context, animaiton, secondaryAnimation) =>
                          AddGroup()),
                  icon: Icon(Icons.add_circle_outline)),
            ),
            IconButton(
                splashRadius: 20,
                onPressed: () =>
                    Navigator.push(context, ScaleRoute(page: PodcastList())),
                icon: Icon(Icons.all_out)),
           // _OrderMenu(),
          ],
        ),
        body: WillPopScope(
          onWillPop: () async {
            context.read<GroupList>().clearOrderChanged();
            return true;
          },
          child: Consumer<GroupList>(
            builder: (_, groupList, __) {
              // var _isLoading = groupList.isLoading;
              var _groups = groupList.groups;
              return _groups.isEmpty
                  ? Center()
                  : Stack(
                      children: <Widget>[
                        Container(
                          color: context.scaffoldBackgroundColor,
                          child: CustomTabView(
                            itemCount: _groups.length,
                            tabBuilder: (context, index) => Tab(
                              child: Container(
                                  height: 30.0,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[600].withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    _groups[index].name,
                                  )),
                            ),
                            pageBuilder: (context, index) =>
                                featureDiscoveryOverlay(
                              context,
                              featureId: configurePodcast,
                              tapTarget: Text(s.podcast(1)),
                              title: s.featureDiscoveryGroupPodcast,
                              backgroundColor: Colors.cyan[600],
                              buttonColor: Colors.cyan[500],
                              description: s.featureDiscoveryGroupPodcastDes,
                              child: PodcastGroupList(
                                group: _groups[index],
                                key: ValueKey<String>(_groups[index].name),
                              ),
                            ),
                            onPositionChange: (value) =>
                                // setState(() =>
                                _index = value,
                          ),
                        ),
                        if (_showSetting)
                          Positioned.fill(
                            top: 50,
                            child: GestureDetector(
                              onTap: () async {
                                await _menuController.reverse();
                                if (mounted) {
                                  setState(() => _showSetting = false);
                                }
                              },
                              child: Container(
                                color: context.scaffoldBackgroundColor
                                    .withOpacity(0.8 *
                                        math.min(
                                            _menuController.value * 2, 1.0)),
                              ),
                            ),
                          ),
                        Positioned(
                          right: 30,
                          bottom: 30,
                          child: _saveButton(),
                        ),
                        if (_showSetting)
                          Positioned(
                            right: 100 * _menuValue - 70,
                            bottom: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      _menuController.reverse();
                                      setState(() => _showSetting = false);
                                      _index == 0
                                          ? Fluttertoast.showToast(
                                              msg: s.toastHomeGroupNotSupport,
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
                                                      milliseconds: 300),
                                              pageBuilder: (context, animaiton,
                                                      secondaryAnimation) =>
                                                  RenameGroup(
                                                    group: _groups[_index],
                                                  ));
                                    },
                                    child: Container(
                                      height: 30.0,
                                      decoration: BoxDecoration(
                                          color: Colors.grey[700],
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.text_fields,
                                            color: Colors.white,
                                            size: 15.0,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5.0),
                                          ),
                                          Text(context.s.editGroupName,
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      _menuController.reverse();
                                      setState(() => _showSetting = false);
                                      _index == 0
                                          ? Fluttertoast.showToast(
                                              msg: s.toastHomeGroupNotSupport,
                                              gravity: ToastGravity.BOTTOM,
                                            )
                                          : generalDialog(
                                              context,
                                              title: Text(s.removeConfirm),
                                              content:
                                                  Text(s.groupRemoveConfirm),
                                              actions: <Widget>[
                                                FlatButton(
                                                  splashColor: context
                                                      .accentColor
                                                      .withAlpha(70),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: Text(
                                                    context.s.cancel,
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                ),
                                                FlatButton(
                                                  splashColor: context
                                                      .accentColor
                                                      .withAlpha(70),
                                                  onPressed: () {
                                                    if (_index ==
                                                        groupList
                                                                .groups.length -
                                                            1) {
                                                      setState(() {
                                                        _index = _index - 1;
                                                      });
                                                      groupList.delGroup(
                                                          _groups[_index + 1]);
                                                    } else {
                                                      groupList.delGroup(
                                                          _groups[_index]);
                                                    }
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    context.s.confirm,
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                )
                                              ],
                                            );
                                    },
                                    child: Container(
                                      height: 30,
                                      decoration: BoxDecoration(
                                          color: Colors.grey[700],
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 15.0,
                                          ),
                                          SizedBox(width: 10),
                                          Text(s.remove,
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}

class _OrderMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return PopupMenuButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      tooltip: s.menu,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Row(
            children: <Widget>[
              Icon(Icons.all_out),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
              ),
              Text(s.menuAllPodcasts),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 1) {
          Navigator.push(context, ScaleRoute(page: PodcastList()));
        }
      },
    );
  }
}

class AddGroup extends StatefulWidget {
  @override
  _AddGroupState createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  TextEditingController _controller;
  String _newGroup;
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
    final s = context.s;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              if (list.contains(_newGroup)) {
                setState(() => _error = 1);
              } else {
                groupList.addGroup(PodcastGroup(_newGroup));
                Navigator.of(context).pop();
              }
            },
            child: Text(s.confirm,
                style: TextStyle(color: Theme.of(context).accentColor)),
          )
        ],
        title: SizedBox(width: context.width - 160, child: Text(s.newGroup)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                hintText: s.newGroup,
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
                _newGroup = value;
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
