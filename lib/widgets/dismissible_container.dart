import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../state/audio_state.dart';
import '../type/episodebrief.dart';
import '../util/extension_helper.dart';
import 'custom_widget.dart';

class DismissibleContainer extends StatefulWidget {
  final EpisodeBrief episode;
  final ValueChanged<bool> onRemove;
  DismissibleContainer({this.episode, this.onRemove, Key key})
      : super(key: key);

  @override
  _DismissibleContainerState createState() => _DismissibleContainerState();
}

class _DismissibleContainerState extends State<DismissibleContainer> {
  bool _delete;

  @override
  void initState() {
    _delete = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInSine,
      alignment: Alignment.center,
      height: _delete ? 0 : 90.0,
      child: _delete
          ? Container(
              color: Colors.transparent,
            )
          : Dismissible(
              key: ValueKey('${widget.episode.enclosureUrl}dis'),
              background: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.red),
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.center,
                      child: Icon(
                        LineIcons.trash_alt_solid,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.red),
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.center,
                      child: Icon(
                        LineIcons.trash_alt_solid,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ],
                ),
                height: 30,
                color: context.accentColor,
              ),
              onDismissed: (direction) async {
                setState(() {
                  _delete = true;
                });
                var index = await context
                    .read<AudioPlayerNotifier>()
                    .delFromPlaylist(widget.episode);
                widget.onRemove(true);
                final episodeRemove = widget.episode;
                Scaffold.of(context).removeCurrentSnackBar();
                Scaffold.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.grey[800],
                  content: Text(s.toastRemovePlaylist,
                      style: TextStyle(color: Colors.white)),
                  action: SnackBarAction(
                      textColor: context.accentColor,
                      label: s.undo,
                      onPressed: () async {
                        await context
                            .read<AudioPlayerNotifier>()
                            .addToPlaylistAt(episodeRemove, index);
                        widget.onRemove(false);
                      }),
                ));
              },
              child: EpisodeCard(
                widget.episode,
                isPlaying: false,
                onTap: () async {
                  await context
                      .read<AudioPlayerNotifier>()
                      .episodeLoad(widget.episode);
                  widget.onRemove(true);
                },
              ),
              //  SizedBox(
              //      height: 90.0,
              //      child: Column(
              //        mainAxisAlignment: MainAxisAlignment.spaceAround,
              //        children: <Widget>[
              //          Expanded(
              //            child: ListTile(
              //              contentPadding: EdgeInsets.symmetric(vertical: 8),
              //              onTap: () async {
              //                await context
              //                    .read<AudioPlayerNotifier>()
              //                    .episodeLoad(widget.episode);
              //                widget.onRemove(true);
              //              },
              //              title: Container(
              //                padding: EdgeInsets.fromLTRB(0, 5.0, 20.0, 5.0),
              //                child: Text(
              //                  widget.episode.title,
              //                  maxLines: 1,
              //                  overflow: TextOverflow.ellipsis,
              //                ),
              //              ),
              //              leading: Row(
              //                mainAxisAlignment: MainAxisAlignment.start,
              //                crossAxisAlignment: CrossAxisAlignment.center,
              //                mainAxisSize: MainAxisSize.min,
              //                children: [
              //                  Icon(Icons.unfold_more, color: c),
              //                  CircleAvatar(
              //                      backgroundColor: c.withOpacity(0.5),
              //                      backgroundImage: widget.episode.avatarImage),
              //                ],
              //              ),
              //              subtitle: Container(
              //                padding: EdgeInsets.only(top: 5, bottom: 5),
              //                height: 35,
              //                child: Row(
              //                  children: <Widget>[
              //                    if (widget.episode.explicit == 1)
              //                      Container(
              //                          decoration: BoxDecoration(
              //                              color: Colors.red[800],
              //                              shape: BoxShape.circle),
              //                          height: 25.0,
              //                          width: 25.0,
              //                          margin: EdgeInsets.only(right: 10.0),
              //                          alignment: Alignment.center,
              //                          child: Text('E',
              //                              style: TextStyle(color: Colors.white))),
              //                    if (widget.episode.duration != 0)
              //                      episodeTag(
              //                          widget.episode.duration == 0
              //                              ? ''
              //                              : s.minsCount(
              //                                  widget.episode.duration ~/ 60),
              //                          Colors.cyan[300]),
              //                    if (widget.episode.enclosureLength != null)
              //                      episodeTag(
              //                          widget.episode.enclosureLength == 0
              //                              ? ''
              //                              : '${(widget.episode.enclosureLength) ~/ 1000000}MB',
              //                          Colors.lightBlue[300]),
              //                  ],
              //                ),
              //              ),
              //              //trailing: Icon(Icons.menu),
              //            ),
              //          ),
              //          Divider(
              //            height: 2,
              //          ),
              //        ],
              //      ),
              //    ),
            ),
    );
  }
}

class EpisodeCard extends StatelessWidget {
  final EpisodeBrief episode;
  final Color tileColor;
  final VoidCallback onTap;
  final bool isPlaying;
  const EpisodeCard(this.episode,
      {this.tileColor, this.onTap, this.isPlaying, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = episode.backgroudColor(context);
    return SizedBox(
      height: 90.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: ListTile(
              tileColor: tileColor,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              onTap: onTap,
              title: Container(
                padding: EdgeInsets.fromLTRB(0, 5.0, 20.0, 5.0),
                child: Text(
                  episode.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              leading: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon(Icons.unfold_more, color: c),
                  SizedBox(width: 24),
                  CircleAvatar(
                      backgroundColor: c.withOpacity(0.5),
                      backgroundImage: episode.avatarImage),
                ],
              ),
              subtitle: Container(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                height: 35,
                child: Row(
                  children: <Widget>[
                    if (episode.explicit == 1)
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.red[800], shape: BoxShape.circle),
                          height: 25.0,
                          width: 25.0,
                          margin: EdgeInsets.only(right: 10.0),
                          alignment: Alignment.center,
                          child:
                              Text('E', style: TextStyle(color: Colors.white))),
                    if (episode.duration != 0)
                      episodeTag(
                          episode.duration == 0
                              ? ''
                              : s.minsCount(episode.duration ~/ 60),
                          Colors.cyan[300]),
                    if (episode.enclosureLength != null)
                      episodeTag(
                          episode.enclosureLength == 0
                              ? ''
                              : '${(episode.enclosureLength) ~/ 1000000}MB',
                          Colors.lightBlue[300]),
                  ],
                ),
              ),
              trailing: isPlaying
                  ? Container(
                      height: 20,
                      width: 20,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: WaveLoader(color: context.accentColor))
                  : SizedBox(width: 1),
            ),
          ),
          Divider(
            height: 1,
          ),
        ],
      ),
    );
  }
}
