import 'dart:math' as math;

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/audio_state.dart';
import '../type/episodebrief.dart';
import '../type/playlist.dart';
import '../util/extension_helper.dart';
import '../widgets/general_dialog.dart';

class PlaylistDetail extends StatefulWidget {
  final Playlist playlist;
  PlaylistDetail(this.playlist, {Key? key}) : super(key: key);

  @override
  _PlaylistDetailState createState() => _PlaylistDetailState();
}

class _PlaylistDetailState extends State<PlaylistDetail> {
  final List<EpisodeBrief> _selectedEpisodes = [];
  bool? _resetSelected;

  @override
  void initState() {
    _resetSelected = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          splashRadius: 20,
          icon: Icon(Icons.close),
          tooltip: context.s.back,
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        title: Text(_selectedEpisodes.isEmpty
            ? widget.playlist.isQueue
                ? s.queue
                : widget.playlist.name!
            : s.selected(_selectedEpisodes.length)),
        actions: [
          if (_selectedEpisodes.isNotEmpty)
            IconButton(
                splashRadius: 20,
                icon: Icon(Icons.delete_outline_rounded),
                onPressed: () {
                  context.read<AudioPlayerNotifier>().removeEpisodeFromPlaylist(
                      widget.playlist,
                      episodes: _selectedEpisodes);
                  setState(_selectedEpisodes.clear);
                }),
          if (_selectedEpisodes.isNotEmpty)
            IconButton(
                splashRadius: 20,
                icon: Icon(Icons.select_all_outlined),
                onPressed: () {
                  setState(() {
                    _selectedEpisodes.clear();
                    _resetSelected = !_resetSelected!;
                  });
                }),
          IconButton(
            splashRadius: 20,
            icon: Icon(Icons.more_vert),
            onPressed: () => generalSheet(context,
                    title: widget.playlist.name,
                    child: _PlaylistSetting(widget.playlist))
                .then((value) {
              if (!context
                  .read<AudioPlayerNotifier>()
                  .playlists
                  .contains(widget.playlist)) {
                Navigator.pop(context);
              }
              setState(() {});
            }),
          ),
        ],
      ),
      body: Selector<AudioPlayerNotifier, List<Playlist>>(
        selector: (_, audio) => audio.playlists,
        builder: (_, data, __) {
          final playlist = data.firstWhereOrNull(
            (e) => e == widget.playlist,
          );
          final episodes = playlist?.episodes ?? [];
          return ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                if (widget.playlist.isQueue) {
                  context
                      .read<AudioPlayerNotifier>()
                      .reorderPlaylist(oldIndex, newIndex);
                  setState(() {});
                } else {
                  context.read<AudioPlayerNotifier>().reorderEpisodesInPlaylist(
                      widget.playlist,
                      oldIndex: oldIndex,
                      newIndex: newIndex);
                  setState(() {});
                }
              },
              scrollDirection: Axis.vertical,
              children: episodes.map<Widget>((episode) {
                return _PlaylistItem(episode,
                    key: ValueKey(episode!.enclosureUrl), onSelect: (episode) {
                  _selectedEpisodes.add(episode);
                  setState(() {});
                }, onRemove: (episode) {
                  _selectedEpisodes.remove(episode);
                  setState(() {});
                }, reset: _resetSelected);
              }).toList());
        },
      ),
    );
  }
}

class _PlaylistItem extends StatefulWidget {
  final EpisodeBrief? episode;
  final bool? reset;
  final ValueChanged<EpisodeBrief> onSelect;
  final ValueChanged<EpisodeBrief> onRemove;
  _PlaylistItem(this.episode,
      {required this.onSelect, required this.onRemove, this.reset, Key? key})
      : super(key: key);

  @override
  __PlaylistItemState createState() => __PlaylistItemState();
}

class __PlaylistItemState extends State<_PlaylistItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;
  double? _fraction;

  @override
  void initState() {
    super.initState();
    _fraction = 0;
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        if (mounted) {
          setState(() => _fraction = _animation.value);
        }
      });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.stop();
      } else if (status == AnimationStatus.dismissed) {
        _controller.stop();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _PlaylistItem oldWidget) {
    if (oldWidget.reset != widget.reset && _animation.value == 1.0) {
      _controller.reverse();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _episodeTag(String text, Color? color) {
    if (text == '') {
      return Center();
    }
    return Container(
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(15.0)),
      height: 25.0,
      margin: EdgeInsets.only(right: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      alignment: Alignment.center,
      child: Text(text, style: TextStyle(fontSize: 14.0, color: Colors.black)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final episode = widget.episode!;
    final c = episode.backgroudColor(context);
    return SizedBox(
      height: 90.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              onTap: () {
                if (_fraction == 0) {
                  _controller.forward();
                  widget.onSelect(episode);
                } else {
                  _controller.reverse();
                  widget.onRemove(episode);
                }
              },
              title: Container(
                padding: EdgeInsets.fromLTRB(0, 5.0, 20.0, 5.0),
                child: Text(
                  episode.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              leading: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.unfold_more, color: c),
                  Transform(
                    alignment: FractionalOffset.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(math.pi * _fraction!),
                    child: _fraction! < 0.5
                        ? CircleAvatar(
                            backgroundColor: c.withOpacity(0.5),
                            backgroundImage: episode.avatarImage)
                        : CircleAvatar(
                            backgroundColor: context.accentColor.withAlpha(70),
                            child: Transform(
                                alignment: FractionalOffset.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(math.pi),
                                child: Icon(Icons.done)),
                          ),
                  ),
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
                      _episodeTag(
                          episode.duration == 0
                              ? ''
                              : s.minsCount(episode.duration! ~/ 60),
                          Colors.cyan[300]),
                    if (episode.enclosureLength != null)
                      _episodeTag(
                          episode.enclosureLength == 0
                              ? ''
                              : '${episode.enclosureLength! ~/ 1000000}MB',
                          Colors.lightBlue[300]),
                  ],
                ),
              ),
            ),
          ),
          Divider(
            height: 2,
          ),
        ],
      ),
    );
  }
}

class _PlaylistSetting extends StatefulWidget {
  final Playlist playlist;
  _PlaylistSetting(this.playlist, {Key? key}) : super(key: key);

  @override
  __PlaylistSettingState createState() => __PlaylistSettingState();
}

class __PlaylistSettingState extends State<_PlaylistSetting> {
  late bool _clearConfirm;
  late bool _removeConfirm;

  @override
  void initState() {
    _clearConfirm = false;
    _removeConfirm = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final textStyle = context.textTheme.bodyText2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.playlist.isLocal!)
          ListTile(
            onTap: () {
              setState(() => _clearConfirm = true);
            },
            dense: true,
            title: Row(
              children: [
                Icon(Icons.clear_all_outlined, size: 18),
                SizedBox(width: 20),
                Text(s.clearAll, style: textStyle),
              ],
            ),
          ),
        if (_clearConfirm)
          Container(
            width: double.infinity,
            color: context.primaryColorDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => setState(() {
                    _clearConfirm = false;
                  }),
                  child:
                      Text(s.cancel, style: TextStyle(color: Colors.grey[600])),
                ),
                FlatButton(
                    splashColor: Colors.red.withAlpha(70),
                    onPressed: () async {
                      context
                          .read<AudioPlayerNotifier>()
                          .clearPlaylist(widget.playlist);
                      Navigator.of(context).pop();
                    },
                    child:
                        Text(s.confirm, style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        if (widget.playlist.name != 'Queue')
          ListTile(
            onTap: () {
              setState(() => _removeConfirm = true);
            },
            dense: true,
            title: Row(
              children: [
                Icon(Icons.delete, color: Colors.red, size: 18),
                SizedBox(width: 20),
                Text(s.remove,
                    style: textStyle!.copyWith(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        if (_removeConfirm)
          Container(
            width: double.infinity,
            color: context.primaryColorDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => setState(() {
                    _removeConfirm = false;
                  }),
                  child:
                      Text(s.cancel, style: TextStyle(color: Colors.grey[600])),
                ),
                FlatButton(
                    splashColor: Colors.red.withAlpha(70),
                    onPressed: () async {
                      context
                          .read<AudioPlayerNotifier>()
                          .deletePlaylist(widget.playlist);
                      Navigator.of(context).pop();
                    },
                    child:
                        Text(s.confirm, style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        if (widget.playlist.isQueue)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: context.textColor.withAlpha(90)),
                Text(s.defaultQueueReminder,
                    style: TextStyle(color: context.textColor.withAlpha(90))),
              ],
            ),
          )
      ],
    );
  }
}
