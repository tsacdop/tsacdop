import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:linkify/linkify.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../home/audioplayer.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../state/audio_state.dart';
import '../state/setting_state.dart';
import '../type/episodebrief.dart';
import '../type/play_histroy.dart';
import '../util/extension_helper.dart';
import '../widgets/audiopanel.dart';
import '../widgets/custom_widget.dart';
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
  bool _showMenu;
  String path;

  Future<PlayHistory> _getPosition(EpisodeBrief episode) async {
    var dbHelper = DBHelper();
    return await dbHelper.getPosition(episode);
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
                : Text(
                    widget.episodeItem.feedTitle,
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 15,
                        color: context.textColor.withOpacity(0.7)),
                  ),
            leading: CustomBackButton(),
            elevation: _showTitle ? 1 : 0,
            //actions: [
            //  PopupMenuButton(
            //    shape: RoundedRectangleBorder(
            //        borderRadius: BorderRadius.all(Radius.circular(10))),
            //    elevation: 1,
            //    tooltip: s.menu,
            //    itemBuilder: (context) => [
            //      PopupMenuItem(
            //        value: 0,
            //        child: Container(
            //          padding: EdgeInsets.only(left: 10),
            //          child: Row(
            //            crossAxisAlignment: CrossAxisAlignment.center,
            //            children: <Widget>[
            //              SizedBox(
            //                width: 25,
            //                height: 25,
            //                child: CustomPaint(
            //                    painter: ListenedAllPainter(
            //                        context.textTheme.bodyText1.color,
            //                        stroke: 2)),
            //              ),
            //              Padding(
            //                padding: EdgeInsets.symmetric(horizontal: 5.0),
            //              ),
            //              Text(
            //                s.markListened,
            //              ),
            //            ],
            //          ),
            //        ),
            //      ),
            //    ],
            //    onSelected: (value) async {
            //      switch (value) {
            //        case 0:
            //          await _markListened(widget.episodeItem);
            //          if (mounted) setState(() {});
            //          Fluttertoast.showToast(
            //            msg: s.markListened,
            //            gravity: ToastGravity.BOTTOM,
            //          );
            //          break;
            //        default:
            //          break;
            //      }
            //    },
            //  ),
            //],
          ),
          body: Stack(
            children: <Widget>[
              Container(
                color: context.primaryColor,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  controller: _controller,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Row(
                          children: [
                            Text(
                                s.published(DateFormat.yMMMd().format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        widget.episodeItem.pubDate))),
                                style: TextStyle(color: context.accentColor)),
                            SizedBox(width: 10),
                            if (widget.episodeItem.explicit == 1)
                              Text('E',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red)),
                            Spacer(),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Row(
                          children: <Widget>[
                            if (widget.episodeItem.duration != 0)
                              Container(
                                  decoration: BoxDecoration(
                                      color: Colors.cyan[300],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(16.0))),
                                  height: 28.0,
                                  margin: EdgeInsets.only(right: 10.0),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                      s.minsCount(
                                          widget.episodeItem.duration ~/ 60),
                                      style: context.textTheme.button)),
                            if (widget.episodeItem.enclosureLength != null &&
                                widget.episodeItem.enclosureLength != 0)
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.lightBlue[300],
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(16.0))),
                                height: 28.0,
                                margin: EdgeInsets.only(right: 10.0),
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                alignment: Alignment.center,
                                child: Text(
                                    '${(widget.episodeItem.enclosureLength) ~/ 1000000}MB',
                                    style: context.textTheme.button),
                              ),
                            FutureBuilder<PlayHistory>(
                                future: _getPosition(widget.episodeItem),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    developer.log(snapshot.error);
                                  }
                                  if (snapshot.hasData &&
                                      snapshot.data.seekValue < 0.9 &&
                                      snapshot.data.seconds > 10) {
                                    return ButtonTheme(
                                      height: 28,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 0),
                                      child: OutlineButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            side: BorderSide(
                                                color: context.accentColor)),
                                        highlightedBorderColor:
                                            Colors.green[700],
                                        onPressed: () => audio.episodeLoad(
                                            widget.episodeItem,
                                            startPosition:
                                                (snapshot.data.seconds * 1000)
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
                                            Text(snapshot.data.seconds.toTime),
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
                      _ShowNote(episode: widget.episodeItem),
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
                          child: _MenuBar(
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

class _MenuBar extends StatefulWidget {
  final EpisodeBrief episodeItem;
  final String heroTag;
  final bool hide;
  _MenuBar({this.episodeItem, this.heroTag, this.hide, Key key})
      : super(key: key);
  @override
  __MenuBarState createState() => __MenuBarState();
}

class __MenuBarState extends State<_MenuBar> {
  Future<int> _isListened(EpisodeBrief episode) async {
    var dbHelper = DBHelper();
    return await dbHelper.isListened(episode.enclosureUrl);
  }

  Future<void> _saveLiked(String url) async {
    var dbHelper = DBHelper();
    await dbHelper.setLiked(url);
    if (mounted) setState(() {});
  }

  Future<void> _setUnliked(String url) async {
    var dbHelper = DBHelper();
    await dbHelper.setUniked(url);
    if (mounted) setState(() {});
  }

  Future<void> _markListened(EpisodeBrief episode) async {
    var dbHelper = DBHelper();
    final history = PlayHistory(episode.title, episode.enclosureUrl, 0, 1);
    await dbHelper.saveHistory(history);
    if (mounted) setState(() {});
  }

  Future<void> _markNotListened(String url) async {
    var dbHelper = DBHelper();
    await dbHelper.markNotListened(url);
    if (mounted) setState(() {});
  }

  Future<bool> _isLiked(EpisodeBrief episode) async {
    var dbHelper = DBHelper();
    return await dbHelper.isLiked(episode.enclosureUrl);
  }

  Widget _buttonOnMenu({Widget child, VoidCallback onTap}) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 50,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0), child: child),
          ),
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
                                backgroundImage:
                                    widget.episodeItem.avatarImage),
                      ),
                    ),
                  ),
                  FutureBuilder<bool>(
                    future: _isLiked(widget.episodeItem),
                    initialData: false,
                    builder: (context, snapshot) {
                      return (!snapshot.data)
                          ? _buttonOnMenu(
                              child: Icon(
                                Icons.favorite_border,
                                color: Colors.grey[700],
                              ),
                              onTap: () async {
                                await _saveLiked(
                                    widget.episodeItem.enclosureUrl);
                                OverlayEntry _overlayEntry;
                                _overlayEntry = _createOverlayEntry();
                                Overlay.of(context).insert(_overlayEntry);
                                await Future.delayed(Duration(seconds: 2));
                                _overlayEntry?.remove();
                              })
                          : _buttonOnMenu(
                              child: Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                              onTap: () =>
                                  _setUnliked(widget.episodeItem.enclosureUrl));
                    },
                  ),
                  DownloadButton(episode: widget.episodeItem),
                  Selector<AudioPlayerNotifier, List<EpisodeBrief>>(
                    selector: (_, audio) => audio.queue.episodes,
                    builder: (_, data, __) {
                      final inPlaylist = data.contains(widget.episodeItem);
                      return inPlaylist
                          ? _buttonOnMenu(
                              child: Icon(Icons.playlist_add_check,
                                  color: context.accentColor),
                              onTap: () {
                                audio.delFromPlaylist(widget.episodeItem);
                                Fluttertoast.showToast(
                                  msg: s.toastRemovePlaylist,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              })
                          : _buttonOnMenu(
                              child: Icon(Icons.playlist_add,
                                  color: Colors.grey[700]),
                              onTap: () {
                                audio.addToPlaylist(widget.episodeItem);
                                Fluttertoast.showToast(
                                  msg: s.toastAddPlaylist,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              });
                    },
                  ),
                  FutureBuilder<int>(
                    future: _isListened(widget.episodeItem),
                    initialData: 0,
                    builder: (context, snapshot) {
                      return snapshot.data == 0
                          ? _buttonOnMenu(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: CustomPaint(
                                  size: Size(25, 20),
                                  painter: ListenedAllPainter(Colors.grey[700],
                                      stroke: 2.0),
                                ),
                              ),
                              onTap: () {
                                _markListened(widget.episodeItem);
                                Fluttertoast.showToast(
                                  msg: s.markListened,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              })
                          : _buttonOnMenu(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: CustomPaint(
                                  size: Size(25, 20),
                                  painter: ListenedAllPainter(
                                      context.accentColor,
                                      stroke: 2.0),
                                ),
                              ),
                              onTap: () {
                                _markNotListened(
                                    widget.episodeItem.enclosureUrl);
                                Fluttertoast.showToast(
                                  msg: s.markNotListened,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              });
                    },
                  ),
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

class _ShowNote extends StatelessWidget {
  final EpisodeBrief episode;
  const _ShowNote({this.episode, Key key}) : super(key: key);

  int _getTimeStamp(String url) {
    final time = url.substring(3).trim();
    final data = time.split(':');
    var seconds;
    if (data.length == 3) {
      seconds = int.tryParse(data[0]) * 3600 +
          int.tryParse(data[1]) * 60 +
          int.tryParse(data[2]);
    } else if (data.length == 2) {
      seconds = int.tryParse(data[0]) * 60 + int.tryParse(data[1]);
    }
    return seconds;
  }

  Future<String> _getSDescription(String url) async {
    var description;
    var dbHelper = DBHelper();
    description = (await dbHelper.getDescription(url))
        .replaceAll(RegExp(r'\s?<p>(<br>)?</p>\s?'), '')
        .replaceAll('\r', '')
        .trim();
    if (!description.contains('<')) {
      final linkList = linkify(description,
          options: LinkifyOptions(humanize: false),
          linkifiers: [UrlLinkifier(), EmailLinkifier()]);
      for (var element in linkList) {
        if (element is UrlElement) {
          description = description.replaceAll(element.url,
              '<a rel="nofollow" href = ${element.url}>${element.text}</a>');
        }
        if (element is EmailElement) {
          final address = element.emailAddress;
          description = description.replaceAll(address,
              '<a rel="nofollow" href = "mailto:$address">$address</a>');
        }
      }
      await dbHelper.saveEpisodeDes(url, description: description);
    }
    return description;
  }

  @override
  Widget build(BuildContext context) {
    var audio = context.watch<AudioPlayerNotifier>();
    final s = context.s;
    return FutureBuilder(
      future: _getSDescription(episode.enclosureUrl),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var description = snapshot.data;
          return description.length > 0
              ? Selector<AudioPlayerNotifier, EpisodeBrief>(
                  selector: (_, audio) => audio.episode,
                  builder: (_, playEpisode, __) {
                    if (playEpisode == episode &&
                        !description.contains('#t=')) {
                      final linkList = linkify(description,
                          options: LinkifyOptions(humanize: false),
                          linkifiers: [TimeStampLinkifier()]);
                      for (var element in linkList) {
                        if (element is TimeStampElement) {
                          final time = element.timeStamp;
                          description = description.replaceFirst(time,
                              '<a rel="nofollow" href = "#t=$time">$time</a>');
                        }
                      }
                    }
                    return Selector<SettingState, TextStyle>(
                      selector: (_, settings) => settings.showNoteFontStyle,
                      builder: (_, data, __) => Html(
                        padding:
                            EdgeInsets.only(left: 20.0, right: 20, bottom: 50),
                        defaultTextStyle: data,
                        data: description,
                        linkStyle: TextStyle(
                            color: context.accentColor,
                            textBaseline: TextBaseline.ideographic),
                        onLinkTap: (url) {
                          if (url.substring(0, 3) == '#t=') {
                            final seconds = _getTimeStamp(url);
                            if (playEpisode == episode) {
                              audio.seekTo(seconds * 1000);
                            }
                          } else {
                            url.launchUrl;
                          }
                        },
                        useRichText: true,
                      ),
                    );
                  })
              : Container(
                  height: context.width,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image(
                        image: AssetImage('assets/shownote.png'),
                        height: 100.0,
                      ),
                      Padding(padding: EdgeInsets.all(5.0)),
                      Text(s.noShownote,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: context.textColor.withOpacity(0.5))),
                    ],
                  ),
                );
        } else {
          return Center();
        }
      },
    );
  }
}
