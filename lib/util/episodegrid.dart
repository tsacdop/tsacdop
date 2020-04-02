import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:line_icons/line_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'open_container.dart';

import 'package:tsacdop/class/audiostate.dart';
import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/episodes/episodedetail.dart';
import 'package:tsacdop/util/colorize.dart';

class EpisodeGrid extends StatelessWidget {
  final List<EpisodeBrief> episodes;
  final bool showFavorite;
  final bool showDownload;
  final bool showNumber;
  final int episodeCount;
  EpisodeGrid(
      {Key key,
      @required this.episodes,
      this.showDownload = false,
      this.showFavorite = false,
      this.showNumber = false,
      this.episodeCount = 0
     })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    Offset _offset;
    _showPopupMenu(Offset offset, EpisodeBrief episode, BuildContext context,
        bool isPlaying, bool isInPlaylist) async {
      var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
      double left = offset.dx;
      double top = offset.dy;
      await showMenu<int>(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        context: context,
        position: RelativeRect.fromLTRB(left, top, _width - left, 0),
        items: <PopupMenuEntry<int>>[
          PopupMenuItem(
            value: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Icon(
                  LineIcons.play_circle_solid,
                  color: Theme.of(context).accentColor,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                ),
                !isPlaying ? Text('Play') : Text('Playing'),
              ],
            ),
          ),
          PopupMenuItem(
              value: 1,
              child: Row(
                children: <Widget>[
                  Icon(
                    LineIcons.clock_solid,
                    color: Colors.red,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                  ),
                  !isInPlaylist ? Text('Later') : Text('Remove')
                ],
              )),
        ],
        elevation: 5.0,
      ).then((value) {
        if (value == 0) {
          if (!isPlaying) audio.episodeLoad(episode);
        } else if (value == 1) {
          if (!isInPlaylist) {
            audio.addToPlaylist(episode);
            Fluttertoast.showToast(
              msg: 'Added to playlist',
              gravity: ToastGravity.BOTTOM,
            );
          } else {
            audio.delFromPlaylist(episode);
            Fluttertoast.showToast(
              msg: 'Removed from playlist',
              gravity: ToastGravity.BOTTOM,
            );
          }
        }
      });
    }

    return SliverPadding(
      padding:
          const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 15.0, right: 15.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1,
          crossAxisCount: 3,
          mainAxisSpacing: 6.0,
          crossAxisSpacing: 6.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            Color _c = (Theme.of(context).brightness == Brightness.light)
                ? episodes[index].primaryColor.colorizedark()
                : episodes[index].primaryColor.colorizeLight();
            return Selector<AudioPlayerNotifier,
                Tuple2<EpisodeBrief, List<String>>>(
              selector: (_, audio) => Tuple2(audio?.episode,
                  audio.queue.playlist.map((e) => e.enclosureUrl).toList()),
              builder: (_, data, __) => OpenContainerWrapper(
                episode: episodes[index],
                closedBuilder: (context, action, boo) => Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor,
                          blurRadius: 0.5,
                          spreadRadius: 0.5,
                        ),
                      ]),
                  alignment: Alignment.center,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      onTapDown: (details) => _offset = Offset(
                          details.globalPosition.dx, details.globalPosition.dy),
                      onLongPress: () => _showPopupMenu(
                          _offset,
                          episodes[index],
                          context,
                          data.item1 == episodes[index],
                          data.item2.contains(episodes[index].enclosureUrl)),
                      onTap: action,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).scaffoldBackgroundColor,
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    height: _width / 16,
                                    width: _width / 16,
                                    child: boo
                                        ? Center()
                                        : CircleAvatar(
                                            backgroundColor:
                                                _c.withOpacity(0.5),
                                            backgroundImage: FileImage(File(
                                                "${episodes[index].imagePath}")),
                                          ),
                                  ),
                                  Spacer(),
                                  episodes[index].isNew == 1
                                      ? Text('New',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontStyle: FontStyle.italic))
                                      : Center(),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 2),
                                  ),
                                  showNumber
                                      ? Container(
                                          alignment: Alignment.topRight,
                                          child: Text(
                                            (episodeCount - index).toString(),
                                            style: GoogleFonts.teko(
                                              textStyle: TextStyle(
                                                fontSize: _width / 24,
                                                color: _c,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Center(),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                alignment: Alignment.topLeft,
                                padding: EdgeInsets.only(top: 2.0),
                                child: Text(
                                  episodes[index].title,
                                  style: TextStyle(
                                   // fontSize: _width / 32,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      episodes[index].dateToString(),
                                      style: TextStyle(
                                          fontSize: _width / 35,
                                          color: _c,
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: EdgeInsets.all(1),
                                  ),
                                  showFavorite
                                      ? Container(
                                          alignment: Alignment.bottomRight,
                                          child: (episodes[index].liked == 0)
                                              ? Center()
                                              : IconTheme(
                                                  data: IconThemeData(size: 15),
                                                  child: Icon(
                                                    Icons.favorite,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                        )
                                      : Center(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: episodes.length,
        ),
      ),
    );
  }
}


class OpenContainerWrapper extends StatelessWidget {
  const OpenContainerWrapper({
    this.closedBuilder,
    this.episode,
    this.playerRunning,
  });

  final OpenContainerBuilder closedBuilder;
  final EpisodeBrief episode;
  final bool playerRunning;

  @override
  Widget build(BuildContext context) {
    return Selector<AudioPlayerNotifier, bool>(
      selector: (_, audio) => audio.playerRunning,
      builder: (_, data, __) => OpenContainer(
        playerRunning: data,
        flightWidget: CircleAvatar(
          backgroundImage: FileImage(File("${episode.imagePath}")),
        ),
        transitionDuration: Duration(milliseconds: 400),
        beginColor: Theme.of(context).primaryColor,
        endColor: Theme.of(context).primaryColor,
        closedColor: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).primaryColor
            : Theme.of(context).scaffoldBackgroundColor,
        openColor: Theme.of(context).scaffoldBackgroundColor,
        openElevation: 0,
        closedElevation: 0,
        openShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        transitionType: ContainerTransitionType.fadeThrough,
        openBuilder: (BuildContext context, VoidCallback _, bool boo) {
          return EpisodeDetail(
            episodeItem: episode,
            hide: boo,
          );
        },
        tappable: true,
        closedBuilder: closedBuilder,
      ),
    );
  }
}


