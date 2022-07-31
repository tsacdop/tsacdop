import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:tsacdop/class/settingstate.dart';

import '../local_storage/sqflite_localpodcast.dart';
import '../state/podcast_group.dart';
import '../type/podcastlocal.dart';
import '../util/extension_helper.dart';
import '../util/pageroute.dart';
import '../widgets/custom_widget.dart';
import '../widgets/general_dialog.dart';
import 'podcast_detail.dart';
import 'podcast_manage.dart';
import 'podcast_settings.dart';

class PodcastList extends StatefulWidget {
  @override
  _PodcastListState createState() => _PodcastListState();
}

class _PodcastListState extends State<PodcastList> {
  Future<List<PodcastLocal>> _getPodcastLocal() async {
    var dbHelper = DBHelper();
    var podcastList = await dbHelper.getPodcastLocalAll();
    return podcastList;
  }

  @override
  Widget build(BuildContext context) {
    final width = context.width;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlay,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: context.background,
          appBar: AppBar(
            backgroundColor: context.background,
            title: Text(context.s.podcast(2)),
            leading: CustomBackButton(),
            actions: [
              Selector<SettingState, bool?>(
                selector: (_, setting) => setting.openAllPodcastDefalt,
                builder: (_, data, __) {
                  if (!data!) return Center();
                  return IconButton(
                    splashRadius: 20,
                    icon: Icon(Icons.all_out),
                    onPressed: () => Navigator.push(
                      context,
                      ScaleRoute(
                        page: PodcastManage(),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
          body: Container(
            color: context.primaryColor,
            child: FutureBuilder<List<PodcastLocal>>(
              future: _getPodcastLocal(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CustomScrollView(
                    slivers: <Widget>[
                      SliverPadding(
                        padding: const EdgeInsets.all(10.0),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 0.8,
                            crossAxisCount: 3,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SlideLeftRoute(
                                        page: PodcastDetail(
                                      podcastLocal: snapshot.data![index],
                                    )),
                                  );
                                },
                                onLongPress: () async {
                                  generalSheet(
                                    context,
                                    title: snapshot.data![index].title,
                                    child: PodcastSetting(
                                        podcastLocal: snapshot.data![index]),
                                  ).then((value) {
                                    if (mounted) setState(() {});
                                  });
                                },
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(width / 8),
                                        child: Container(
                                          height: width / 4,
                                          width: width / 4,
                                          child: Image.file(File(
                                              "${snapshot.data![index].imagePath}")),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          snapshot.data![index].title!,
                                          textAlign: TextAlign.center,
                                          style: context.textTheme.bodyText1,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: snapshot.data!.length,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
