import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../state/audio_state.dart';
import '../type/episodebrief.dart';
import '../util/extension_helper.dart';
import 'custom_widget.dart';

class DismissibleContainer extends StatefulWidget {
  final EpisodeBrief? episode;
  final ValueChanged<bool>? onRemove;
  DismissibleContainer({this.episode, this.onRemove, Key? key})
      : super(key: key);

  @override
  _DismissibleContainerState createState() => _DismissibleContainerState();
}

class _DismissibleContainerState extends State<DismissibleContainer> {
  late bool _delete;

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
      height: _delete ? 0 : 91.0,
      child: _delete
          ? Container(
              color: Colors.transparent,
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Dismissible(
                    key: ValueKey('${widget.episode!.enclosureUrl}dis'),
                    background: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.red),
                            padding: EdgeInsets.all(5),
                            alignment: Alignment.center,
                            child: Icon(
                              LineIcons.alternateTrash,
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
                              LineIcons.alternateTrash,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onDismissed: (direction) async {
                      setState(() {
                        _delete = true;
                      });
                      var index = await context
                          .read<AudioPlayerNotifier>()
                          .delFromPlaylist(widget.episode!);
                      widget.onRemove!(true);
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
                                  .addToPlaylistAt(episodeRemove!, index);
                              widget.onRemove!(false);
                            }),
                      ));
                    },
                    child: EpisodeCard(
                      widget.episode!,
                      isPlaying: false,
                      canReorder: true,
                      showDivider: false,
                      onTap: () async {
                        await context
                            .read<AudioPlayerNotifier>()
                            .episodeLoad(widget.episode);
                        widget.onRemove!(true);
                      },
                    ),
                  ),
                ),
                Divider(height: 1)
              ],
            ),
    );
  }
}

class EpisodeCard extends StatelessWidget {
  final EpisodeBrief episode;
  final Color? tileColor;
  final VoidCallback? onTap;
  final bool? isPlaying;
  final bool canReorder;
  final bool showDivider;
  final bool havePadding;
  const EpisodeCard(this.episode,
      {this.tileColor,
      this.onTap,
      this.isPlaying,
      this.canReorder = false,
      this.showDivider = true,
      this.havePadding = false,
      Key? key})
      : assert(episode != null),
        super(key: key);

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
                child: Text(
                  episode.title!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              leading: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canReorder && !havePadding)
                    Icon(Icons.unfold_more, color: c),
                  SizedBox(width: canReorder && !havePadding ? 0 : 24),
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
                              : s.minsCount(episode.duration! ~/ 60),
                          Colors.cyan[300]),
                    if (episode.enclosureLength != null)
                      episodeTag(
                          episode.enclosureLength == 0
                              ? ''
                              : '${episode.enclosureLength! ~/ 1000000}MB',
                          Colors.lightBlue[300]),
                  ],
                ),
              ),
              trailing: isPlaying!
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
          if (showDivider) Divider(height: 1),
        ],
      ),
    );
  }
}
