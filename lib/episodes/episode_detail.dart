import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tsacdop/episodes/menu_bar.dart';
import 'package:tsacdop/episodes/shownote.dart';
import 'package:tsacdop/util/helpers.dart';
import 'package:tuple/tuple.dart';

import '../home/audioplayer.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../state/audio_state.dart';
import '../type/episodebrief.dart';
import '../type/play_histroy.dart';
import '../util/extension_helper.dart';
import '../widgets/audiopanel.dart';
import '../widgets/custom_widget.dart';

class EpisodeDetail extends StatefulWidget {
  final EpisodeBrief? episodeItem;
  final String heroTag;
  final bool hide;
  EpisodeDetail(
      {this.episodeItem, this.heroTag = '', this.hide = false, Key? key})
      : super(key: key);

  @override
  _EpisodeDetailState createState() => _EpisodeDetailState();
}

class _EpisodeDetailState extends State<EpisodeDetail> {
  final textstyle = TextStyle(fontSize: 15.0, color: Colors.black);
  final GlobalKey<AudioPanelState> _playerKey = GlobalKey<AudioPanelState>();
  double? downloadProgress;

  /// Show page title.
  late bool _showTitle;
  late bool _showMenu;
  String? path;

  Future<PlayHistory> _getPosition(EpisodeBrief episode) async {
    final dbHelper = DBHelper();
    return await dbHelper.getPosition(episode);
  }

  late ScrollController _controller;
  _scrollListener() {
    if (_controller.position.userScrollDirection == ScrollDirection.reverse) {
      if (_showMenu && mounted) {
        setState(() {
          _showMenu = false;
        });
      }
    }
    if (_controller.position.userScrollDirection == ScrollDirection.forward) {
      if (!_showMenu && mounted) {
        setState(() {
          _showMenu = true;
        });
      }
    }
    if (_controller.offset > context.textTheme.headline5!.fontSize!) {
      if (!_showTitle) setState(() => _showTitle = true);
    } else if (_showTitle) setState(() => _showTitle = false);
  }

  @override
  void initState() {
    super.initState();
    _showMenu = true;
    _showTitle = false;
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final audio = context.watch<AudioPlayerNotifier>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: context.priamryContainer,
          systemNavigationBarColor: context.priamryContainer,
          systemNavigationBarContrastEnforced: false,
          systemNavigationBarIconBrightness: context.iconBrightness,
          statusBarBrightness: context.brightness,
          statusBarIconBrightness: context.iconBrightness),
      child: WillPopScope(
        onWillPop: () async {
          if (_playerKey.currentState != null &&
              _playerKey.currentState!.initSize! > 100) {
            _playerKey.currentState!.backToMini();
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: SafeArea(
            child: Stack(
              children: <Widget>[
                StretchingOverscrollIndicator(
                  axisDirection: AxisDirection.down,
                  child: NestedScrollView(
                    scrollDirection: Axis.vertical,
                    controller: _controller,
                    headerSliverBuilder: (context, innerBoxScrolled) {
                      return <Widget>[
                        SliverAppBar(
                          backgroundColor: context.priamryContainer,
                          floating: true,
                          pinned: true,
                          title: _showTitle
                              ? Text(
                                  widget.episodeItem?.title ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : Text(
                                  widget.episodeItem!.feedTitle!,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color:
                                          context.textColor.withOpacity(0.7)),
                                ),
                          leading: CustomBackButton(),
                          elevation: 0,
                        ),
                      ];
                    },
                    body: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.episodeItem!.title!,
                                textAlign: TextAlign.left,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: Row(
                              children: [
                                Text(
                                    s.published(formateDate(
                                        widget.episodeItem!.pubDate!)),
                                    style:
                                        TextStyle(color: context.accentColor)),
                                SizedBox(width: 10),
                                if (widget.episodeItem!.explicit == 1)
                                  Text('E',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: context.error)),
                                Spacer(),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: Row(
                              children: <Widget>[
                                if (widget.episodeItem!.duration != 0)
                                  Container(
                                      decoration: BoxDecoration(
                                          color: context.secondary,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16.0))),
                                      height: 30.0,
                                      margin: EdgeInsets.only(right: 12.0),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      alignment: Alignment.center,
                                      child: Text(
                                        s.minsCount(
                                          widget.episodeItem!.duration! ~/ 60,
                                        ),
                                        style:
                                            TextStyle(color: context.onPrimary),
                                      )),
                                if (widget.episodeItem!.enclosureLength !=
                                        null &&
                                    widget.episodeItem!.enclosureLength != 0)
                                  Container(
                                    decoration: BoxDecoration(
                                        color: context.tertiary,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16.0))),
                                    height: 30.0,
                                    margin: EdgeInsets.only(right: 12.0),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${widget.episodeItem!.enclosureLength! ~/ 1000000}MB',
                                      style:
                                          TextStyle(color: context.onPrimary),
                                    ),
                                  ),
                                FutureBuilder<PlayHistory>(
                                    future: _getPosition(widget.episodeItem!),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        developer.log(snapshot.error as String);
                                      }
                                      if (snapshot.hasData &&
                                          snapshot.data!.seekValue! < 0.9 &&
                                          snapshot.data!.seconds! > 10) {
                                        return ButtonTheme(
                                          height: 28,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 0),
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  side: BorderSide(
                                                      color:
                                                          context.accentColor)),
                                            ),
                                            onPressed: () => audio.episodeLoad(
                                                widget.episodeItem,
                                                startPosition:
                                                    (snapshot.data!.seconds! *
                                                            1000)
                                                        .toInt()),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CustomPaint(
                                                    painter: ListenedPainter(
                                                        context.textColor,
                                                        stroke: 2.0),
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  snapshot
                                                      .data!.seconds!.toTime,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Center();
                                      }
                                    }),
                              ],
                            ),
                          ),
                          ShowNote(episode: widget.episodeItem),
                          Selector<AudioPlayerNotifier,
                                  Tuple2<bool, PlayerHeight?>>(
                              selector: (_, audio) => Tuple2(
                                  audio.playerRunning, audio.playerHeight),
                              builder: (_, data, __) {
                                final height =
                                    kMinPlayerHeight[data.item2!.index];
                                return SizedBox(
                                  height: data.item1 ? height : 0,
                                );
                              }),
                        ],
                      ),
                    ),
                  ),
                ),
                Selector<AudioPlayerNotifier, Tuple2<bool, PlayerHeight?>>(
                    selector: (_, audio) =>
                        Tuple2(audio.playerRunning, audio.playerHeight),
                    builder: (_, data, __) {
                      final height = kMinPlayerHeight[data.item2!.index];
                      return Container(
                        alignment: Alignment.bottomCenter,
                        padding:
                            EdgeInsets.only(bottom: data.item1 ? height : 0),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 400),
                          height: _showMenu ? 50 : 0,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: MenuBar(
                                episodeItem: widget.episodeItem,
                                heroTag: widget.heroTag,
                                hide: widget.hide),
                          ),
                        ),
                      );
                    }),
                Selector<AudioPlayerNotifier, EpisodeBrief?>(
                    selector: (_, audio) => audio.episode,
                    builder: (_, data, __) => Container(
                        child: PlayerWidget(
                            playerKey: _playerKey,
                            isPlayingPage: data == widget.episodeItem))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
