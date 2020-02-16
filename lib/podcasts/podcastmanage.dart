import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tsacdop/class/podcastlocal.dart';
import 'package:tsacdop/class/sqflite_localpodcast.dart';
import 'package:tsacdop/class/settingstate.dart';

class PodcastManage extends StatefulWidget {
  @override
  _PodcastManageState createState() => _PodcastManageState();
}

class _PodcastManageState extends State<PodcastManage> {
  var dir;
  bool _loading;
  bool _loadSave;
  Color _c;
  double _width;
  List<PodcastLocal> podcastList;
  getPodcastLocal() async {
    dir = await getApplicationDocumentsDirectory();
    var dbHelper = DBHelper();
    podcastList = await dbHelper.getPodcastLocal();
    setState(() {
      _loading = true;
    });
  }

  _unSubscribe(String title) async {
    var dbHelper = DBHelper();
    await dbHelper.delPodcastLocal(title);
    print('Unsubscribe');
  }

  @override
  void initState() {
    super.initState();
    _loading = false;
    _loadSave = false;
    getPodcastLocal();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final PodcastLocal podcast = podcastList.removeAt(oldIndex);
      podcastList.insert(newIndex, podcast);
      _loadSave = true;
    });
  }

  _saveOrder(List<PodcastLocal> podcastList) async {
    var dbHelper = DBHelper();
    await dbHelper.saveOrder(podcastList);
  }

  Widget _podcastCard(BuildContext context, PodcastLocal podcastLocal) {
    var _settingState = Provider.of<SettingState>(context);
    return Container(
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
              child: Image.file(File("${dir.path}/${podcastLocal.title}.png")),
            ),
          ),
        ),
        Container(
            width: _width / 2,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              podcastLocal.title,
              maxLines: 2,
              overflow: TextOverflow.fade,
            )),
        Spacer(),
        OutlineButton(
          child: Text('Unsubscribe'),
          onPressed: () {
            _unSubscribe(podcastLocal.title);
            _settingState.subscribeUpdate = Setting.start;
            setState(() {
              getPodcastLocal();
            });
          },
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    var _settingState = Provider.of<SettingState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Podcasts'),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          !_loadSave
              ? Center()
              : InkWell(
                  child: Container(
                      padding: EdgeInsets.all(20.0),
                      alignment: Alignment.center,
                      child: Text('Save')),
                  onTap: () async{
                    await _saveOrder(podcastList);
                    Fluttertoast.showToast(
                      msg: 'Saved',
                      gravity: ToastGravity.BOTTOM,
                    );
                    _settingState.subscribeUpdate = Setting.start;
                    setState(() {
                      _loadSave = false;
                    });
                  },
                ),
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: !_loading
            ? CircularProgressIndicator()
            : ReorderableListView(
                onReorder: _onReorder,
                children: podcastList.map<Widget>((PodcastLocal podcastLocal) {
                  var color = json.decode(podcastLocal.primaryColor);
                  (color[0] > 200 && color[1] > 200 && color[2] > 200)
                      ? _c = Color.fromRGBO(
                          (255 - color[0]), 255 - color[1], 255 - color[2], 1.0)
                      : _c = Color.fromRGBO(color[0], color[1], color[2], 1.0);
                  return Container(
                    decoration: BoxDecoration(color: Colors.grey[100]),
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    key: ObjectKey(podcastLocal.title),
                    child: _podcastCard(context, podcastLocal),
                  );
                }).toList(),
              ),
      ),
    );
  }
}
