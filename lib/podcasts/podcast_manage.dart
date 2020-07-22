import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:feature_discovery/feature_discovery.dart';

import '../state/podcast_group.dart';
import 'podcast_group.dart';
import 'podcastlist.dart';
import '../util/pageroute.dart';
import '../util/extension_helper.dart';
import '../util/general_dialog.dart';
import 'custom_tabview.dart';

const String addGroupFeature = 'addGroupFeature';
const String configureGroup = 'configureFeature';
const String configurePodcast = 'configurePodcast';

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
  double _scroll;
  @override
  void initState() {
    super.initState();
    _showSetting = false;
    _fraction = 0;
    _menuValue = 0;
    _scroll = 0;
    _index = 0;
    _menuController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        if (mounted)
          setState(() {
            _fraction = _animation.value;
          });
      });
    _menuAnimation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _menuController, curve: Curves.easeIn))
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
    FeatureDiscovery.isDisplayed(context, addGroupFeature).then((value) {
      if (!value)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FeatureDiscovery.discoverFeatures(context, const <String>{
            addGroupFeature,
            configureGroup,
            configurePodcast
          });
        });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _menuController.dispose();
    super.dispose();
  }

  Widget _saveButton(BuildContext context) {
    final s = context.s;
    return Consumer<GroupList>(
      builder: (_, groupList, __) {
        if (groupList.orderChanged.contains(groupList.groups[_index])) {
          _controller.forward();
        } else if (_fraction > 0) {
          _controller.reverse();
        }
        return DescribedFeatureOverlay(
          featureId: configureGroup,
          tapTarget: Icon(Icons.menu),
          title: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(s.featureDiscoveryEditGroup),
          ),
          overflowMode: OverflowMode.clipContent,
          backgroundColor: Colors.cyan[600],
          onDismiss: () => Future.value(true),
          description: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(s.featureDiscoveryEditGroupDes),
              FlatButton(
                color: Colors.cyan[500],
                padding: const EdgeInsets.all(0),
                child: Text(s.understood,
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(color: Colors.white)),
                onPressed: () async =>
                    FeatureDiscovery.completeCurrentStep(context),
              ),
              FlatButton(
                color: Colors.cyan[500],
                padding: const EdgeInsets.all(0),
                child: Text(s.dismiss,
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(color: Colors.white)),
                onPressed: () => FeatureDiscovery.dismissAll(context),
              ),
            ],
          ),
          child: Transform(
            alignment: FractionalOffset(0.5, 0.5),
            transform: Matrix4.rotationY(math.pi * _fraction),
            child: Container(
              child: InkWell(
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
                onTap: () async {
                  if (_fraction == 0) {
                    !_showSetting
                        ? _menuController.forward()
                        : await _menuController.reverse();
                    setState(() {
                      _showSetting = !_showSetting;
                    });
                  } else {
                    groupList.saveOrder(groupList.groups[_index]);
                    groupList
                        .drlFromOrderChanged(groupList.groups[_index].name);
                    Fluttertoast.showToast(
                      msg: context.s.toastSettingSaved,
                      gravity: ToastGravity.BOTTOM,
                    );
                    _controller.reverse();
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

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
          centerTitle: true,
          title: Text(context.s.groups(2)),
          actions: <Widget>[
            DescribedFeatureOverlay(
              featureId: addGroupFeature,
              tapTarget: Icon(Icons.add),
              title: Text(s.featureDiscoveryGroup),
              overflowMode: OverflowMode.clipContent,
              backgroundColor: Colors.cyan[600],
              onDismiss: () => Future.value(true),
              description: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(s.featureDiscoveryGroupDes),
                  FlatButton(
                    color: Colors.cyan[500],
                    padding: const EdgeInsets.all(0),
                    child: Text(context.s.understood,
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: Colors.white)),
                    onPressed: () async =>
                        FeatureDiscovery.completeCurrentStep(context),
                  ),
                  FlatButton(
                    color: Colors.cyan[500],
                    padding: const EdgeInsets.all(0),
                    child: Text(context.s.dismiss,
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: Colors.white)),
                    onPressed: () => FeatureDiscovery.dismissAll(context),
                  ),
                ],
              ),
              child: IconButton(
                  onPressed: () => showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: MaterialLocalizations.of(context)
                          .modalBarrierDismissLabel,
                      barrierColor: Colors.black54,
                      transitionDuration: const Duration(milliseconds: 200),
                      pageBuilder: (BuildContext context, Animation animaiton,
                              Animation secondaryAnimation) =>
                          AddGroup()),
                  icon: Icon(Icons.add)),
            ),
            OrderMenu(),
          ],
        ),
        body: WillPopScope(
          onWillPop: () async {
            await Provider.of<GroupList>(context, listen: false)
                .clearOrderChanged();
            return true;
          },
          child: Consumer<GroupList>(builder: (_, groupList, __) {
            bool _isLoading = groupList.isLoading;
            List<PodcastGroup> _groups = groupList.groups;
            return _isLoading
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
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: (_scroll - index).abs() > 1
                                      ? Colors.grey[300]
                                      : Colors.grey[300]
                                          .withOpacity((_scroll - index).abs()),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                child: Text(
                                  _groups[index].name,
                                )),
                          ),
                          pageBuilder: (context, index) =>
                              DescribedFeatureOverlay(
                            featureId: configurePodcast,
                            tapTarget: Text(s.podcast(1)),
                            title: Text(s.featureDiscoveryGroupPodcast),
                            overflowMode: OverflowMode.clipContent,
                            onDismiss: () => Future.value(true),
                            enablePulsingAnimation: false,
                            backgroundColor: Colors.cyan[600],
                            description: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(s.featureDiscoveryGroupPodcastDes),
                                FlatButton(
                                  color: Colors.cyan[500],
                                  padding: const EdgeInsets.all(0),
                                  child: Text(context.s.understood,
                                      style: Theme.of(context)
                                          .textTheme
                                          .button
                                          .copyWith(color: Colors.white)),
                                  onPressed: () async =>
                                      FeatureDiscovery.completeCurrentStep(
                                          context),
                                ),
                                FlatButton(
                                  color: Colors.cyan[500],
                                  padding: const EdgeInsets.all(0),
                                  child: Text(context.s.dismiss,
                                      style: Theme.of(context)
                                          .textTheme
                                          .button
                                          .copyWith(color: Colors.white)),
                                  onPressed: () =>
                                      FeatureDiscovery.dismissAll(context),
                                ),
                              ],
                            ),
                            child: Container(
                                key: ValueKey(_groups[index].name),
                                child: PodcastGroupList(group: _groups[index])),
                          ),
                          onPositionChange: (value) =>
                              setState(() => _index = value),
                          onScroll: (value) => setState(() => _scroll = value),
                        ),
                      ),
                      _showSetting
                          ? Positioned.fill(
                              top: 50,
                              child: GestureDetector(
                                onTap: () async {
                                  await _menuController.reverse();
                                  setState(() => _showSetting = false);
                                },
                                child: Container(
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor
                                      .withOpacity(0.5 * _menuController.value),
                                ),
                              ),
                            )
                          : Center(),
                      Positioned(
                        right: 30,
                        bottom: 30,
                        child: _saveButton(context),
                      ),
                      _showSetting
                          ? Positioned(
                              right: 30 * _menuValue,
                              bottom: 100,
                              child: Container(
                                alignment: Alignment.centerRight,
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
                                                  msg: s
                                                      .toastHomeGroupNotSupport,
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
                                                  pageBuilder: (BuildContext
                                                              context,
                                                          Animation animaiton,
                                                          Animation
                                                              secondaryAnimation) =>
                                                      RenameGroup(
                                                        group: _groups[_index],
                                                      ));
                                        },
                                        child: Container(
                                          height: 30.0,
                                          decoration: BoxDecoration(
                                              color: Colors.grey[700],
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0))),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
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
                                    Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.0)),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          _menuController.reverse();
                                          setState(() => _showSetting = false);
                                          _index == 0
                                              ? Fluttertoast.showToast(
                                                  msg: s
                                                      .toastHomeGroupNotSupport,
                                                  gravity: ToastGravity.BOTTOM,
                                                )
                                              : generalDialog(
                                                  context,
                                                  title: Text(s.removeConfirm),
                                                  content: Text(
                                                      s.groupRemoveConfirm),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      child: Text(
                                                        context.s.cancel,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[600]),
                                                      ),
                                                    ),
                                                    FlatButton(
                                                      onPressed: () {
                                                        if (_index ==
                                                            groupList.groups
                                                                    .length -
                                                                1) {
                                                          setState(() {
                                                            _index = _index - 1;
                                                            _scroll = 0;
                                                          });
                                                          groupList.delGroup(
                                                              _groups[
                                                                  _index + 1]);
                                                        } else {
                                                          groupList.delGroup(
                                                              _groups[_index]);
                                                        }
                                                        Navigator.of(context)
                                                            .pop();
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
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0))),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                                size: 15.0,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5.0),
                                              ),
                                              Text(s.remove,
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Center(),
                    ],
                  );
          }),
        ),
      ),
    );
  }
}

class OrderMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return PopupMenuButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 2,
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        elevation: 1,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        titlePadding:
            const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
        actionsPadding: EdgeInsets.all(0),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              s.cancel,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          FlatButton(
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
