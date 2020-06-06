import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:tsacdop/home/audioplayer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/audiostate.dart';
import '../type/episodebrief.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../util/context_extension.dart';
import '../util/custompaint.dart';
import 'episodedownload.dart';

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
  double downloadProgress;
  bool _loaddes;
  bool _showMenu;
  String path;
  String _description;
  Future getSDescription(String url) async {
    var dbHelper = DBHelper();
    _description = (await dbHelper.getDescription(url))
        .replaceAll(RegExp(r'\s?<p>(<br>)?</p>\s?'), '')
        .replaceAll('\r', '');
    if (mounted)
      setState(() {
        _loaddes = true;
      });
  }

  ScrollController _controller;
  _scrollListener() {
    if (_controller.offset > _controller.position.maxScrollExtent * 0.8) {
      setState(() {
        _showMenu = true;
      });
    } else
      setState(() {
        _showMenu = false;
      });
  }

  _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _markListened(EpisodeBrief episode) async {
    DBHelper dbHelper = DBHelper();
    final PlayHistory history =
        PlayHistory(episode.title, episode.enclosureUrl, 0, 1);
    await dbHelper.saveHistory(history);
  }

  @override
  void initState() {
    super.initState();
    _loaddes = false;
    _showMenu = false;
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          //  title: Text(widget.episodeItem.feedTitle),
          centerTitle: true,
          actions: [
            PopupMenuButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              elevation: 1,
              tooltip: 'Menu',
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
                                  stroke: 1.5)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                        ),
                        Text(
                          'Mark listened',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              onSelected: (int value) async {
                switch (value) {
                  case 0:
                    await _markListened(widget.episodeItem);
                    setState(() {});
                    Fluttertoast.showToast(
                      msg: 'Mark as listened',
                      gravity: ToastGravity.BOTTOM,
                    );
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          alignment: Alignment.topLeft,
                          child: Text(
                            widget.episodeItem.title,
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          height: 30.0,
                          child: Text(
                              'Published ' +
                                  DateFormat.yMMMd().format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          widget.episodeItem.pubDate)),
                              style: TextStyle(
                                  color: Theme.of(context).accentColor)),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          height: 50.0,
                          child: Row(
                            children: <Widget>[
                              (widget.episodeItem.explicit == 1)
                                  ? Container(
                                      decoration: BoxDecoration(
                                          color: Colors.red[800],
                                          shape: BoxShape.circle),
                                      height: 25.0,
                                      width: 25.0,
                                      margin: EdgeInsets.only(right: 10.0),
                                      alignment: Alignment.center,
                                      child: Text('E',
                                          style:
                                              TextStyle(color: Colors.white)))
                                  : Center(),
                              widget.episodeItem.duration != 0
                                  ? Container(
                                      decoration: BoxDecoration(
                                          color: Colors.cyan[300],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0))),
                                      height: 25.0,
                                      margin: EdgeInsets.only(right: 10.0),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      alignment: Alignment.center,
                                      child: Text(
                                          (widget.episodeItem.duration ~/ 60)
                                                  .toString() +
                                              'min',
                                          style: textstyle),
                                    )
                                  : Center(),
                              widget.episodeItem.enclosureLength != null &&
                                      widget.episodeItem.enclosureLength != 0
                                  ? Container(
                                      decoration: BoxDecoration(
                                          color: Colors.lightBlue[300],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0))),
                                      height: 25.0,
                                      margin: EdgeInsets.only(right: 10.0),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      alignment: Alignment.center,
                                      child: Text(
                                          ((widget.episodeItem
                                                          .enclosureLength) ~/
                                                      1000000)
                                                  .toString() +
                                              'MB',
                                          style: textstyle),
                                    )
                                  : Center(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 5.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        controller: _controller,
                        child: _loaddes
                            ? (_description.contains('<'))
                                ? Html(
                                    padding: EdgeInsets.only(
                                        left: 20.0, right: 20, bottom: 10),
                                    defaultTextStyle:
                                        GoogleFonts.libreBaskerville(
                                      textStyle: TextStyle(
                                        height: 1.8,
                                      ),
                                    ),
                                    data: _description,
                                    linkStyle: TextStyle(
                                        color: Theme.of(context).accentColor,
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
                                            bottom: 10.0),
                                        alignment: Alignment.topLeft,
                                        child: SelectableLinkify(
                                          onOpen: (link) {
                                            _launchUrl(link.url);
                                          },
                                          text: _description,
                                          style: GoogleFonts.libreBaskerville(
                                            textStyle: TextStyle(
                                              height: 1.8,
                                            ),
                                          ),
                                          linkStyle: TextStyle(
                                            color:
                                                Theme.of(context).accentColor,
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
                                            Padding(
                                                padding: EdgeInsets.all(5.0)),
                                            Text(
                                                'Still no shownote received\n for this episode.',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: context.textTheme
                                                        .bodyText1.color
                                                        .withOpacity(0.5))),
                                          ],
                                        ),
                                      )
                            : Center(),
                      ),
                    ),
                  ),
                  Selector<AudioPlayerNotifier, bool>(
                      selector: (_, audio) => audio.playerRunning,
                      builder: (_, data, __) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: data ? 60.0 : 0),
                        );
                      }),
                ],
              ),
            ),
            Selector<AudioPlayerNotifier, bool>(
                selector: (_, audio) => audio.playerRunning,
                builder: (_, data, __) {
                  return Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.only(bottom: data ? 60.0 : 0),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 400),
                      height: !_showMenu ? 50 : 0,
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
            Container(child: PlayerWidget()),
          ],
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
  bool _liked;

  Future<PlayHistory> getPosition(EpisodeBrief episode) async {
    var dbHelper = DBHelper();
    return await dbHelper.getPosition(episode);
  }

  Future<int> saveLiked(String url) async {
    var dbHelper = DBHelper();
    int result = await dbHelper.setLiked(url);
    if (result == 1 && mounted) setState(() => _liked = true);
    return result;
  }

  Future<int> setUnliked(String url) async {
    var dbHelper = DBHelper();
    int result = await dbHelper.setUniked(url);
    if (result == 1 && mounted)
      setState(() {
        _liked = false;
        // _like = 0;
      });
    return result;
  }

  Future<bool> _isLiked(EpisodeBrief episode) async {
    DBHelper dbHelper = DBHelper();
    return await dbHelper.isLiked(episode.enclosureUrl);
  }

  static String _stringForSeconds(double seconds) {
    if (seconds == null) return null;
    return '${(seconds ~/ 60)}:${(seconds.truncate() % 60).toString().padLeft(2, '0')}';
  }

  _markListened(EpisodeBrief episode) async {
    DBHelper dbHelper = DBHelper();
    final PlayHistory history =
        PlayHistory(episode.title, episode.enclosureUrl, 0, 1);
    await dbHelper.saveHistory(history);
  }

  @override
  void initState() {
    super.initState();
    _liked = false;
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

  @override
  Widget build(BuildContext context) {
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
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

    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[200]
              : Theme.of(context).primaryColor,
        ),
      ),
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
                color: Theme.of(context).scaffoldBackgroundColor,
                child: widget.hide
                    ? Center()
                    : CircleAvatar(
                        backgroundImage:
                            FileImage(File("${widget.episodeItem.imagePath}"))),
              ),
            ),
          ),
          FutureBuilder<bool>(
            future: _isLiked(widget.episodeItem),
            initialData: false,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return (!snapshot.data && !_liked)
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
                  : (snapshot.data && !_liked)
                      ? _buttonOnMenu(
                          Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                          () => setUnliked(widget.episodeItem.enclosureUrl))
                      : _buttonOnMenu(
                          Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                          () {
                            setUnliked(widget.episodeItem.enclosureUrl);
                          },
                        );
            },
          ),
          DownloadButton(episode: widget.episodeItem),
          Selector<AudioPlayerNotifier, List<String>>(
            selector: (_, audio) =>
                audio.queue.playlist.map((e) => e.enclosureUrl).toList(),
            builder: (_, data, __) {
              return data.contains(widget.episodeItem.enclosureUrl)
                  ? _buttonOnMenu(
                      Icon(Icons.playlist_add_check,
                          color: Theme.of(context).accentColor), () {
                      audio.delFromPlaylist(widget.episodeItem);
                      Fluttertoast.showToast(
                        msg: 'Removed from playlist',
                        gravity: ToastGravity.BOTTOM,
                      );
                    })
                  : _buttonOnMenu(
                      Icon(Icons.playlist_add, color: Colors.grey[700]), () {
                      Fluttertoast.showToast(
                        msg: 'Added to playlist',
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
                    ? snapshot.data.seekValue > 0.95
                        ? Container(
                            height: 25,
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: SizedBox(
                              width: 25,
                              height: 25,
                              child: CustomPaint(
                                painter: ListenedAllPainter(context.accentColor,
                                    stroke: 2.0),
                              ),
                            ),
                          )
                        : snapshot.data.seconds < 0.1
                            // ? Material(
                            //     color: Colors.transparent,
                            //     child: InkWell(
                            //       onTap: () async {
                            //         await _markListened(widget.episodeItem);
                            //         setState(() {});
                            //         Fluttertoast.showToast(
                            //           msg: 'Mark as listened',
                            //           gravity: ToastGravity.BOTTOM,
                            //         );
                            //       },
                            //       child: Container(
                            //         height: 50,
                            //         padding: EdgeInsets.only(
                            //             left: 15,
                            //             right: 15,
                            //             top: 12,
                            //             bottom: 12),
                            //         child: SizedBox(
                            //           width: 22,
                            //           height: 22,
                            //           child: CustomPaint(
                            //             painter: MarkListenedPainter(
                            //                 Colors.grey[700],
                            //                 stroke: 2.0),
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //   )
                            ? Center()
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
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
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 2)),
                                        Container(
                                          height: 20,
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            color: context.accentColor,
                                          ),
                                          child: Text(
                                            _stringForSeconds(
                                                snapshot.data.seconds),
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                    : Center();
              }),
          Spacer(),
          Selector<AudioPlayerNotifier, Tuple2<EpisodeBrief, bool>>(
            selector: (_, audio) => Tuple2(audio.episode, audio.playerRunning),
            builder: (_, data, __) {
              return (widget.episodeItem.title == data.item1?.title &&
                      data.item2)
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
                              Text('Play',
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
