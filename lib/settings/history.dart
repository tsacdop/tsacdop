import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:webfeed/webfeed.dart';

import '../local_storage/sqflite_localpodcast.dart';
import '../state/podcast_group.dart';
import '../type/play_histroy.dart';
import '../type/search_api/searchpodcast.dart';
import '../type/sub_history.dart';
import '../util/extension_helper.dart';
import '../widgets/custom_widget.dart';

class PlayedHistory extends StatefulWidget {
  @override
  _PlayedHistoryState createState() => _PlayedHistoryState();
}

class _PlayedHistoryState extends State<PlayedHistory>
    with SingleTickerProviderStateMixin {
  /// Get play history.
  Future<List<PlayHistory>> _getPlayHistory(int top) async {
    var dbHelper = DBHelper();
    List<PlayHistory> playHistory;
    playHistory = await dbHelper.getPlayHistory(top);
    for (var record in playHistory) {
      await record.getEpisode();
    }
    return playHistory;
  }

  bool _loadMore = false;

  Future<void> _loadMoreData() async {
    if (mounted) {
      setState(() {
        _loadMore = true;
      });
    }
    await Future.delayed(Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _top = _top + 10;
        _loadMore = false;
      });
    }
  }

  int _top = 10;

  Future<List<SubHistory>> getSubHistory() async {
    var dbHelper = DBHelper();
    return await dbHelper.getSubHistory();
  }

  TabController? _controller;
  List<int> list = const [0, 1, 2, 3, 4, 5, 6];

  Future<List<FlSpot>> getData() async {
    var dbHelper = DBHelper();
    var stats = <FlSpot>[];

    for (var day in list) {
      var mins = await dbHelper.listenMins(7 - day);
      stats.add(FlSpot(day.toDouble(), mins));
    }
    return stats;
  }

  Future recoverSub(BuildContext context, String url) async {
    Fluttertoast.showToast(
      msg: context.s.toastPodcastRecovering,
      gravity: ToastGravity.BOTTOM,
    );
    var subscribeWorker = context.watch<GroupList>();
    try {
      var options = BaseOptions(
        connectTimeout: 10000,
        receiveTimeout: 10000,
      );
      var response = await Dio(options).get(url);
      var p = RssFeed.parse(response.data);
      var podcast = OnlinePodcast(
          rss: url,
          title: p.title,
          publisher: p.author,
          description: p.description,
          image: p.itunes!.image!.href);
      var item = SubscribeItem(podcast.rss, podcast.title,
          imgUrl: podcast.image, group: 'Home');
      subscribeWorker.setSubscribeItem(item);
    } catch (e) {
      developer.log(e.toString(), name: 'Recover podcast error');
      Fluttertoast.showToast(
        msg: context.s.toastRecoverFailed,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  double top = 0;
  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: context.brightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness: context.iconBrightness,
      ),
      child: Scaffold(
        backgroundColor: context.primaryColor,
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  leading: CustomBackButton(),
                  elevation: 0,
                  expandedHeight: 260,
                  floating: false,
                  pinned: true,
                  flexibleSpace: LayoutBuilder(
                    builder: (context, constraints) {
                      top = constraints.biggest.height;
                      return FlexibleSpaceBar(
                        title: top < 70 + MediaQuery.of(context).padding.top
                            ? Text(
                                s.settingsHistory,
                              )
                            : Center(),
                        background: Padding(
                          padding: EdgeInsets.only(
                              top: 50, left: 20, right: 20, bottom: 20),
                          child: FutureBuilder<List<FlSpot>>(
                              future: getData(),
                              builder: (context, snapshot) {
                                return snapshot.hasData
                                    ? HistoryChart(snapshot.data)
                                    : Center();
                              }),
                        ),
                      );
                    },
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _controller,
                        indicatorColor: context.accentColor,
                        labelColor: context.textColor,
                        labelStyle: context.textTheme.headline6,
                        tabs: <Widget>[
                          Tab(
                            child: Text(s.listen),
                          ),
                          Tab(
                            child: Text(s.subscribe),
                          )
                        ],
                      ),
                      context.primaryColor),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(controller: _controller, children: <Widget>[
              FutureBuilder<List<PlayHistory>>(
                future: _getPlayHistory(_top),
                builder: (context, snapshot) {
                  var width = context.width;
                  return snapshot.hasData
                      ? NotificationListener<ScrollNotification>(
                          onNotification: (scrollInfo) {
                            if (scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent &&
                                snapshot.data!.length == _top) {
                              if (!_loadMore) {
                                _loadMoreData();
                              }
                            }
                            return true;
                          },
                          child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data!.length + 1,
                              itemBuilder: (context, index) {
                                if (index == snapshot.data!.length) {
                                  return SizedBox(
                                      height: 2,
                                      child: _loadMore
                                          ? LinearProgressIndicator()
                                          : Center());
                                } else {
                                  var seekValue =
                                      snapshot.data![index].seekValue!;
                                  var seconds = snapshot.data![index].seconds;
                                  return Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    color: context.background,
                                    child: Column(
                                      children: <Widget>[
                                        ListTile(
                                          title: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                DateFormat.yMd()
                                                    .add_jm()
                                                    .format(snapshot
                                                        .data![index]
                                                        .playdate!),
                                                style: TextStyle(
                                                    color: context.textColor
                                                        .withOpacity(0.8),
                                                    fontSize: 15,
                                                    fontStyle:
                                                        FontStyle.italic),
                                              ),
                                              Text(
                                                snapshot.data![index].title!,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                          subtitle: Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.timelapse,
                                                color: Colors.grey[400],
                                              ),
                                              Container(
                                                height: 2,
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(
                                                            color: Colors
                                                                .grey[400]!,
                                                            width: 2.0))),
                                                width: width * seekValue <
                                                        (width - 120)
                                                    ? width * seekValue
                                                    : width - 120,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 2),
                                              ),
                                              Container(
                                                width: 50,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: context.accentColor,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                padding: EdgeInsets.all(2),
                                                child: Text(
                                                  seconds == 0 && seekValue == 1
                                                      ? s.mark
                                                      : seconds!.toInt().toTime,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }),
                        )
                      : Center(
                          child: SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator()),
                        );
                },
              ),
              FutureBuilder<List<SubHistory>>(
                future: getSubHistory(),
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? ListView.builder(
                          // shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var _status = snapshot.data![index].status;
                            return Container(
                              color: context.background,
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    enabled: _status,
                                    title: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          DateFormat.yMd().add_jm().format(
                                              snapshot.data![index].subDate),
                                          style: TextStyle(
                                              color: context.textColor
                                                  .withOpacity(0.8),
                                              fontSize: 15,
                                              fontStyle: FontStyle.italic),
                                        ),
                                        Text(snapshot.data![index].title!),
                                      ],
                                    ),
                                    subtitle: _status
                                        ? Text(s.daysAgo(DateTime.now()
                                            .difference(
                                                snapshot.data![index].subDate)
                                            .inDays))
                                        : Text(
                                            s.removedAt(DateFormat.yMd()
                                                .add_jm()
                                                .format(snapshot
                                                    .data![index].delDate)),
                                            style: TextStyle(color: Colors.red),
                                          ),
                                    trailing: !_status
                                        ? Material(
                                            color: Colors.transparent,
                                            child: IconButton(
                                              tooltip: s.recoverSubscribe,
                                              icon: Icon(LineIcons
                                                  .alternativeTrashRestore),
                                              onPressed: () => recoverSub(
                                                  context,
                                                  snapshot
                                                      .data![index].rssUrl!),
                                            ),
                                          )
                                        : null,
                                  ),
                                  Divider(
                                    height: 2,
                                  )
                                ],
                              ),
                            );
                          })
                      : Center(
                          child: SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator()),
                        );
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this._color);
  final Color _color;
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _color,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}

class HistoryChart extends StatelessWidget {
  final List<FlSpot>? stats;
  HistoryChart(this.stats);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LineChart(
        LineChartData(
          backgroundColor: Colors.transparent,
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: false,
            getDrawingHorizontalLine: (value) {
              return value % 1000 == 0
                  ? FlLine(
                      color: context.brightness == Brightness.light
                          ? Colors.grey[400]
                          : Colors.grey[700],
                      strokeWidth: 0,
                    )
                  : FlLine(color: Colors.transparent);
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: SideTitles(
              getTextStyles: (_, i) => TextStyle(
                color: const Color(0xff67727d),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              showTitles: true,
              reservedSize: 10,
              getTitles: (value) {
                return DateFormat.E().format(DateTime.now()
                    .subtract(Duration(days: (7 - value.toInt()))));
              },
              margin: 5,
            ),
            leftTitles: SideTitles(
              showTitles: true,
              getTextStyles: (_, s) => TextStyle(
                color: const Color(0xff67727d),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              getTitles: (value) {
                return value % 60 == 0 && value > 0 ? '${value ~/ 60}h' : '';
              },
              reservedSize: 20,
              margin: 5,
            ),
          ),
          borderData: FlBorderData(
              show: false,
              border: Border(
                left: BorderSide(color: Colors.red, width: 2),
              )),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: context.background,
              fitInsideHorizontally: true,
              getTooltipItems: (touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  return LineTooltipItem(context.s.minsCount(barSpot.y.toInt()),
                      context.textTheme.subtitle1!);
                }).toList();
              },
            ),
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((spotIndex) {
                return TouchedSpotIndicatorData(
                    FlLine(color: Colors.transparent),
                    FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                              radius: 3,
                              color: context.accentColor,
                              strokeWidth: 4,
                              strokeColor: context.primaryColor);
                        }));
              }).toList();
            },
          ),
          lineBarsData: [
            LineChartBarData(
              spots: stats,
              isCurved: true,
              colors: [context.accentColor],
              preventCurveOverShooting: true,
              barWidth: 3,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                  show: true,
                  gradientFrom: Offset(0, 0),
                  gradientTo: Offset(0, 1),
                  gradientColorStops: [
                    0.3,
                    0.8,
                    0.99
                  ],
                  colors: [
                    context.accentColor.withOpacity(0.6),
                    context.accentColor.withOpacity(0.1),
                    context.accentColor.withOpacity(0)
                  ]),
              dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                        radius: 2,
                        color: context.primaryColor,
                        strokeWidth: 3,
                        strokeColor: context.accentColor);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
