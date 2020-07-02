import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';

import '../local_storage/sqflite_localpodcast.dart';
import '../webfeed/webfeed.dart';
import '../type/searchpodcast.dart';
import '../util/context_extension.dart';
import '../state/audiostate.dart';
import '../state/subscribe_podcast.dart';
import '../type/sub_history.dart';

class PlayedHistory extends StatefulWidget {
  @override
  _PlayedHistoryState createState() => _PlayedHistoryState();
}

class _PlayedHistoryState extends State<PlayedHistory>
    with SingleTickerProviderStateMixin {
  Future<List<PlayHistory>> getPlayHistory(int top) async {
    DBHelper dbHelper = DBHelper();
    List<PlayHistory> playHistory;
    playHistory = await dbHelper.getPlayHistory(top);
    await Future.forEach(playHistory, (playHistory) async {
      await playHistory.getEpisode();
    });
    return playHistory;
  }

  _loadMoreData() async {
    // await Future.delayed(Duration(seconds: 3));
    if (mounted)
      setState(() {
        _top = _top + 100;
      });
  }

  int _top = 100;

  Future<List<SubHistory>> getSubHistory() async {
    DBHelper dbHelper = DBHelper();
    return await dbHelper.getSubHistory();
  }

  static String _stringForSeconds(double seconds) {
    if (seconds == null) return null;
    return '${(seconds ~/ 60)}:${(seconds.truncate() % 60).toString().padLeft(2, '0')}';
  }

  TabController _controller;
  List<int> list = const [0, 1, 2, 3, 4, 5, 6];

  Future<List<FlSpot>> getData() async {
    var dbHelper = DBHelper();
    List<FlSpot> stats = [];
    await Future.forEach(list, (day) async {
      double mins = await dbHelper.listenMins(7 - day);
      stats.add(FlSpot(day.toDouble(), mins));
    });
    return stats;
  }

  Future recoverSub(BuildContext context, String url) async {
    Fluttertoast.showToast(
      msg: 'Recovering, wait for seconds',
      gravity: ToastGravity.BOTTOM,
    );
    var subscribeWorker = context.read<SubscribeWorker>();
    try {
      BaseOptions options = new BaseOptions(
        connectTimeout: 10000,
        receiveTimeout: 10000,
      );
      Response response = await Dio(options).get(url);
      var p = RssFeed.parse(response.data);
      var podcast = OnlinePodcast(
          rss: url,
          title: p.title,
          publisher: p.author,
          description: p.description,
          image: p.itunes.image.href);
      SubscribeItem item =
          SubscribeItem(podcast.rss, podcast.title, imgUrl: podcast.image);
      subscribeWorker.setSubscribeItem(item);
    } on DioError catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: 'Podcast recover failed',
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
    _controller.dispose();
    super.dispose();
  }

  double top = 0;
  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  elevation: 0,
                  expandedHeight: 260,
                  floating: false,
                  pinned: true,
                  flexibleSpace: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      top = constraints.biggest.height;
                      return FlexibleSpaceBar(
                        title: top < 70 + MediaQuery.of(context).padding.top
                            ? Text(
                                s.settingsHistory,
                              )
                            : Center(),
                        background: Padding(
                          padding: EdgeInsets.only(
                              top: 50, left: 50, right: 50, bottom: 30),
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
                        tabs: <Widget>[
                          Tab(
                            child: Text(s.listen,
                                style: context.textTheme.headline6),
                          ),
                          Tab(
                            child: Text(s.subscribe,
                                style: context.textTheme.headline6),
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
                future: getPlayHistory(_top),
                builder: (context, snapshot) {
                  double _width = MediaQuery.of(context).size.width;
                  return snapshot.hasData
                      ? NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent &&
                                snapshot.data.length == _top) _loadMoreData();
                            return true;
                          },
                          child: ListView.builder(
                              //shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
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
                                              DateFormat.yMd().add_jm().format(
                                                  snapshot
                                                      .data[index].playdate),
                                              style: TextStyle(
                                                  color:
                                                      const Color(0xff67727d),
                                                  fontSize: 15,
                                                  fontStyle: FontStyle.italic),
                                            ),
                                            Text(
                                              snapshot.data[index].title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        subtitle: Container(
                                          width: double.infinity,
                                          child: Row(
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
                                                                .grey[400],
                                                            width: 2.0))),
                                                width: _width *
                                                            snapshot.data[index]
                                                                .seekValue <
                                                        (_width - 120)
                                                    ? _width *
                                                        snapshot.data[index]
                                                            .seekValue
                                                    : _width - 120,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 2),
                                              ),
                                              Container(
                                                width: 50,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .accentColor,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                padding: EdgeInsets.all(2),
                                                child: Text(
                                                  snapshot.data[index]
                                                                  .seconds ==
                                                              0 &&
                                                          snapshot.data[index]
                                                                  .seekValue ==
                                                              1
                                                      ? 'Mark'
                                                      : _stringForSeconds(
                                                          snapshot.data[index]
                                                              .seconds),
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      //  Divider(height: 2),
                                    ],
                                  ),
                                );
                              }),
                        )
                      : Center(
                          child: CircularProgressIndicator(),
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
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            bool _status = snapshot.data[index].status;
                            return Container(
                              color: context.scaffoldBackgroundColor,
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
                                              snapshot.data[index].subDate),
                                          style: TextStyle(
                                              color: const Color(0xff67727d),
                                              fontSize: 15,
                                              fontStyle: FontStyle.italic),
                                        ),
                                        Text(snapshot.data[index].title),
                                      ],
                                    ),
                                    subtitle: _status
                                        ? Text(DateTime.now()
                                                .difference(snapshot
                                                    .data[index].subDate)
                                                .inDays
                                                .toString() +
                                            ' day ago')
                                        : Text(
                                            'Removed at ' +
                                                DateFormat.yMd()
                                                    .add_jm()
                                                    .format(snapshot
                                                        .data[index].delDate),
                                            style: TextStyle(color: Colors.red),
                                          ),
                                    // Text(snapshot.data[index].delDate
                                    //         .difference(snapshot
                                    //             .data[index].subDate)
                                    //         .inDays
                                    //         .toString() +
                                    //     ' day on your device'),

                                    trailing: !_status
                                        ? Material(
                                            color: Colors.transparent,
                                            child: IconButton(
                                              tooltip: 'Recover subscribe',
                                              icon: Icon(LineIcons
                                                  .trash_restore_alt_solid),
                                              onPressed: () => recoverSub(
                                                  context,
                                                  snapshot.data[index].rssUrl),
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
                          child: CircularProgressIndicator(),
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
    return new Container(
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
  final List<FlSpot> stats;
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
              textStyle: TextStyle(
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
              textStyle: TextStyle(
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
          lineBarsData: [
            LineChartBarData(
              spots: this.stats,
              isCurved: false,
              colors: [
                context.accentColor,
              ],
              barWidth: 3,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                  show: true,
                  gradientFrom: Offset(0, 0),
                  gradientTo: Offset(0, 1),
                  gradientColorStops: [
                    0.3,
                    0.8
                  ],
                  colors: [
                    context.accentColor.withOpacity(0.6),
                    context.accentColor.withOpacity(0.1)
                  ]),
              dotData: FlDotData(
                show: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
