import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../home/audioplayer.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../state/audio_state.dart';
import '../type/episodebrief.dart';
import '../type/play_histroy.dart';
import '../util/audiopanel.dart';
import '../util/custom_widget.dart';
import '../util/extension_helper.dart';
import 'episode_download.dart';

class EpisodeDetail extends StatefulWidget {
  final EpisodeBrief episodeItem;
  final String heroTag;
  final bool hide;
  EpisodeDetail(
      {this.episodeItem, this.heroTag = '', this.hide = false, Key key})
      : super(key: key);

  @override
  _EpisodeDetailState createState() => _EpisodeDetailState();
}

class _EpisodeDetailState extends State<EpisodeDetail> {
  final textstyle = TextStyle(fontSize: 15.0, color: Colors.black);
  final GlobalKey<AudioPanelState> _playerKey = GlobalKey<AudioPanelState>();
  double downloadProgress;

  /// Show page title.
  bool _showTitle;

  /// Load shownote.
  bool _loaddes;
  bool _showMenu;
  String path;
  String _description;

  Future getSDescription(String url) async {
    var dbHelper = DBHelper();
    _description = (await dbHelper.getDescription(url))
        .replaceAll(RegExp(r'\s?<p>(<br>)?</p>\s?'), '')
        .replaceAll('\r', '');
    if (mounted) {
      setState(() {
        _loaddes = true;
      });
    }
  }

  ScrollController _controller;
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
    if (_controller.offset > context.textTheme.headline5.fontSize) {
      if (!_showTitle) setState(() => _showTitle = true);
    } else if (_showTitle) setState(() => _showTitle = false);
  }

  _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _markListened(EpisodeBrief episode) async {
    var dbHelper = DBHelper();
    var marked = await dbHelper.checkMarked(episode);
    if (!marked) {
      final history = PlayHistory(episode.title, episode.enclosureUrl, 0, 1);
      await dbHelper.saveHistory(history);
    }
  }

  @override
  void initState() {
    super.initState();
    _loaddes = false;
    _showMenu = true;
    _showTitle = false;
    getSDescription(widget.episodeItem.enclosureUrl);
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
      ),
      child: WillPopScope(
        onWillPop: () async {
          if (_playerKey.currentState != null &&
              _playerKey.currentState.initSize > 100) {
            _playerKey.currentState.backToMini();
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          appBar: AppBar(
            title: _showTitle
                ? Text(
                    widget.episodeItem.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : Center(),
            elevation: _showTitle ? 1 : 0,
            actions: [
              PopupMenuButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                elevation: 1,
                tooltip: s.menu,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 0,
                    child: Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 25,
                            height: 25,
                            child: CustomPaint(
                                painter: ListenedAllPainter(
                                    context.textTheme.bodyText1.color,
                                    stroke: 2)),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                          ),
                          Text(
                            s.markListened,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                onSelected: (value) async {
                  switch (value) {
                    case 0:
                      await _markListened(widget.episodeItem);
                      if (mounted) setState(() {});
                      Fluttertoast.showToast(
                        msg: s.markListened,
                        gravity: ToastGravity.BOTTOM,
                      );
                      break;
                    default:
                      break;
                  }
                },
              ),
            ],
          ),
          body: Stack(
            children: <Widget>[
              Container(
                color: Theme.of(context).primaryColor,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  controller: _controller,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.episodeItem.title,
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(
                            left: 20.0, right: 20, top: 10, bottom: 10),
                        child: Text(
                            s.published(DateFormat.yMMMd().format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    widget.episodeItem.pubDate))),
                            style: TextStyle(
                                color: Theme.of(context).accentColor)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 20.0, right: 20, top: 10, bottom: 10),
                        child: Row(
                          children: <Widget>[
                            if (widget.episodeItem.explicit == 1)
                              Container(
                                  decoration: BoxDecoration(
                                      color: Colors.red[800],
                                      shape: BoxShape.circle),
                                  height: 25.0,
                                  width: 25.0,
                                  margin: EdgeInsets.only(right: 10.0),
                                  alignment: Alignment.center,
                                  child: Text('E',
                                      style: TextStyle(color: Colors.white))),
                            if (widget.episodeItem.duration != 0)
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.cyan[300],
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(15.0))),
                                height: 25.0,
                                margin: EdgeInsets.only(right: 10.0),
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                alignment: Alignment.center,
                                child: Text(
                                    s.minsCount(
                                        widget.episodeItem.duration ~/ 60),
                                    style: textstyle),
                              ),
                            if (widget.episodeItem.enclosureLength != null &&
                                widget.episodeItem.enclosureLength != 0)
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.lightBlue[300],
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(15.0))),
                                height: 25.0,
                                margin: EdgeInsets.only(right: 10.0),
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                alignment: Alignment.center,
                                child: Text(
                                    '${(widget.episodeItem.enclosureLength) ~/ 1000000}MB',
                                    style: textstyle),
                              ),
                          ],
                        ),
                      ),
                      _loaddes
                          ? (_description.contains('<'))
                              ? Html(
                                  padding: EdgeInsets.only(
                                      left: 20.0, right: 20, bottom: 50),
                                  defaultTextStyle:
                                      // GoogleFonts.libreBaskerville(
                                      GoogleFonts.martel(
                                    textStyle: TextStyle(
                                      height: 1.8,
                                    ),
                                  ),
                                  data: _description,
                                  linkStyle: TextStyle(
                                      color: context.accentColor,
                                      // decoration: TextDecoration.underline,
                                      textBaseline: TextBaseline.ideographic),
                                  onLinkTap: (url) {
                                    _launchUrl(url);
                                  },
                                  useRichText: true,
                                )
                              : _description.length > 0
                                  ? Container(
                                      padding: EdgeInsets.only(
                                          left: 20.0,
                                          right: 20.0,
                                          bottom: 50.0),
                                      alignment: Alignment.topLeft,
                                      child: SelectableLinkify(
                                        onOpen: (link) {
                                          _launchUrl(link.url);
                                        },
                                        text: _description,
                                        style: GoogleFonts.martel(
                                          textStyle: TextStyle(
                                            height: 1.8,
                                          ),
                                        ),
                                        linkStyle: TextStyle(
                                          color: Theme.of(context).accentColor,
                                          //  decoration:
                                          //      TextDecoration.underline,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: context.width,
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Image(
                                            image: AssetImage(
                                                'assets/shownote.png'),
                                            height: 100.0,
                                          ),
                                          Padding(padding: EdgeInsets.all(5.0)),
                                          Text(s.noShownote,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: context.textColor
                                                      .withOpacity(0.5))),
                                        ],
                                      ),
                                    )
                          : Center(),
                      Selector<AudioPlayerNotifier, Tuple2<bool, PlayerHeight>>(
                          selector: (_, audio) =>
                              Tuple2(audio.playerRunning, audio.playerHeight),
                          builder: (_, data, __) {
                            var height = kMinPlayerHeight[data.item2.index];
                            return SizedBox(
                              height: data.item1 ? height : 0,
                            );
                          }),
                    ],
                  ),
                ),
              ),
              Selector<AudioPlayerNotifier, Tuple2<bool, PlayerHeight>>(
                  selector: (_, audio) =>
                      Tuple2(audio.playerRunning, audio.playerHeight),
                  builder: (_, data, __) {
                    var height = kMinPlayerHeight[data.item2.index];
                    return Container(
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.only(bottom: data.item1 ? height : 0),
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
              Selector<AudioPlayerNotifier, EpisodeBrief>(
                  selector: (_, audio) => audio.episode,
                  builder: (_, data, __) => Container(
                      child: PlayerWidget(
                          playerKey: _playerKey,
                          isPlayingPage: data == widget.episodeItem))),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuBar extends StatefulWidget {
  final EpisodeBrief episodeItem;
  final String heroTag;
  final bool hide;
  MenuBar({this.episodeItem, this.heroTag, this.hide, Key key})
      : super(key: key);
  @override
  _MenuBarState createState() => _MenuBarState();
}

class _MenuBarState extends State<MenuBar> {
  Future<PlayHistory> getPosition(EpisodeBrief episode) async {
    var dbHelper = DBHelper();
    return await dbHelper.getPosition(episode);
  }

  saveLiked(String url) async {
    var dbHelper = DBHelper();
    await dbHelper.setLiked(url);
    if (mounted) setState(() {});
  }

  setUnliked(String url) async {
    var dbHelper = DBHelper();
    await dbHelper.setUniked(url);
    if (mounted) setState(() {});
  }

  Future<bool> _isLiked(EpisodeBrief episode) async {
    var dbHelper = DBHelper();
    return await dbHelper.isLiked(episode.enclosureUrl);
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

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    var offset = renderBox.localToGlobal(Offset.zero);
    return OverlayEntry(
      builder: (constext) => Positioned(
        left: offset.dx + 50,
        top: offset.dy - 60,
        child: Container(
            width: 70,
            height: 100,
            //color: Colors.grey[200],
            child: HeartOpen(width: 50, height: 80)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    final s = context.s;
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        //border: Border.all(
        //  color: Theme.of(context).brightness == Brightness.light
        //      ? Colors.grey[200]
        //      : context.primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Hero(
                    tag: widget.episodeItem.enclosureUrl + widget.heroTag,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        height: 30.0,
                        width: 30.0,
                        color: context.scaffoldBackgroundColor,
                        child: widget.hide
                            ? Center()
                            : CircleAvatar(
                                radius: 15,
                                backgroundImage: FileImage(
                                    File("${widget.episodeItem.imagePath}"))),
                      ),
                    ),
                  ),
                  FutureBuilder<bool>(
                    future: _isLiked(widget.episodeItem),
                    initialData: false,
                    builder: (context, snapshot) {
                      return (!snapshot.data)
                          ? _buttonOnMenu(
                              Icon(
                                Icons.favorite_border,
                                color: Colors.grey[700],
                              ), () async {
                              await saveLiked(widget.episodeItem.enclosureUrl);
                              OverlayEntry _overlayEntry;
                              _overlayEntry = _createOverlayEntry();
                              Overlay.of(context).insert(_overlayEntry);
                              await Future.delayed(Duration(seconds: 2));
                              _overlayEntry?.remove();
                            })
                          : _buttonOnMenu(
                              Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                              () =>
                                  setUnliked(widget.episodeItem.enclosureUrl));
                    },
                  ),
                  DownloadButton(episode: widget.episodeItem),
                  Selector<AudioPlayerNotifier, List<EpisodeBrief>>(
                    selector: (_, audio) => audio.queue.playlist,
                    builder: (_, data, __) {
                      return data.contains(widget.episodeItem)
                          ? _buttonOnMenu(
                              Icon(Icons.playlist_add_check,
                                  color: context.accentColor), () {
                              audio.delFromPlaylist(widget.episodeItem);
                              Fluttertoast.showToast(
                                msg: s.toastRemovePlaylist,
                                gravity: ToastGravity.BOTTOM,
                              );
                            })
                          : _buttonOnMenu(
                              Icon(Icons.playlist_add, color: Colors.grey[700]),
                              () {
                              Fluttertoast.showToast(
                                msg: s.toastAddPlaylist,
                                gravity: ToastGravity.BOTTOM,
                              );
                              audio.addToPlaylist(widget.episodeItem);
                            });
                    },
                  ),
                  FutureBuilder<PlayHistory>(
                      future: getPosition(widget.episodeItem),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) print(snapshot.error);
                        return snapshot.hasData
                            ? snapshot.data.seekValue > 0.90
                                ? Container(
                                    height: 25,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    child: SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: CustomPaint(
                                        painter: ListenedAllPainter(
                                            context.accentColor,
                                            stroke: 2.0),
                                      ),
                                    ),
                                  )
                                : snapshot.data.seconds < 0.1
                                    ? SizedBox(
                                        width: 1,
                                      )
                                    : Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => audio.episodeLoad(
                                              widget.episodeItem,
                                              startPosition:
                                                  (snapshot.data.seconds * 1000)
                                                      .toInt()),
                                          child: Container(
                                            height: 50,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Row(
                                              children: <Widget>[
                                                SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CustomPaint(
                                                    painter: ListenedPainter(
                                                        context.accentColor,
                                                        stroke: 2.0),
                                                  ),
                                                ),
                                                Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 2)),
                                                Container(
                                                  height: 20,
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 5),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10.0)),
                                                    color: context.accentColor,
                                                  ),
                                                  child: Text(
                                                    snapshot
                                                        .data.seconds.toTime,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                            : Center();
                      }),
                ],
              ),
            ),
          ),
          Selector<AudioPlayerNotifier, Tuple2<EpisodeBrief, bool>>(
            selector: (_, audio) => Tuple2(audio.episode, audio.playerRunning),
            builder: (_, data, __) {
              return (widget.episodeItem == data.item1 && data.item2)
                  ? Container(
                      padding: EdgeInsets.only(right: 30),
                      child: SizedBox(
                          width: 20,
                          height: 15,
                          child: WaveLoader(color: context.accentColor)))
                  : Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          audio.episodeLoad(widget.episodeItem);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50.0,
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              Text(s.play,
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  )),
                              Icon(
                                Icons.play_arrow,
                                color: Theme.of(context).accentColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }
}
