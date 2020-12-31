import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/audio_state.dart';
import '../type/episodebrief.dart';
import '../type/playlist.dart';
import '../util/extension_helper.dart';

class PlaylistDetail extends StatefulWidget {
  final Playlist playlist;
  PlaylistDetail(this.playlist, {Key key}) : super(key: key);

  @override
  _PlaylistDetailState createState() => _PlaylistDetailState();
}

class _PlaylistDetailState extends State<PlaylistDetail> {
  final List<EpisodeBrief> _selectedEpisodes = [];
  bool _resetSelected;
  @override
  void setState(fn) {
    _resetSelected = false;
    super.setState(fn);
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
            ? widget.playlist.name
            : '${_selectedEpisodes.length} selected'),
        actions: [
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
                    _resetSelected = !_resetSelected;
                  });
                }),
          SizedBox(
            height: 40,
            width: 40,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                height: 40,
                width: 40,
                child: PopupMenuButton<int>(
                    icon: Icon(Icons.more_vert),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 1,
                    tooltip: s.menu,
                    itemBuilder: (context) => [
                          PopupMenuItem(value: 1, child: Text('Clear all')),
                        ],
                    onSelected: (value) {
                      if (value == 1) {
                        context
                            .read<AudioPlayerNotifier>()
                            .clearPlaylist(widget.playlist);
                      }
                    }),
              ),
            ),
          )
        ],
      ),
      body: Selector<AudioPlayerNotifier, List<Playlist>>(
          selector: (_, audio) => audio.playlists,
          builder: (_, data, __) {
            final playlist = data.firstWhere((e) => e == widget.playlist);
            final episodes = playlist.episodes;
            return ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  context.read<AudioPlayerNotifier>().reorderEpisodesInPlaylist(
                      widget.playlist,
                      oldIndex: oldIndex,
                      newIndex: newIndex);
                  setState(() {});
                },
                scrollDirection: Axis.vertical,
                children: episodes.map<Widget>((episode) {
                  return _PlaylistItem(episode,
                      key: ValueKey(episode.enclosureUrl), onSelect: (episode) {
                    _selectedEpisodes.add(episode);
                    setState(() {});
                  }, onRemove: (episode) {
                    _selectedEpisodes.remove(episode);
                    setState(() {});
                  }, reset: _resetSelected);
                }).toList());
          }),
    );
  }
}

class _PlaylistItem extends StatefulWidget {
  final EpisodeBrief episode;
  final bool reset;
  final ValueChanged<EpisodeBrief> onSelect;
  final ValueChanged<EpisodeBrief> onRemove;
  _PlaylistItem(this.episode,
      {@required this.onSelect, @required this.onRemove, this.reset, Key key})
      : super(key: key);

  @override
  __PlaylistItemState createState() => __PlaylistItemState();
}

class __PlaylistItemState extends State<_PlaylistItem>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;
  double _fraction;

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

  Widget _episodeTag(String text, Color color) {
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
    final episode = widget.episode;
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
                    Icon(Icons.unfold_more, color: c),
                    Transform(
                      alignment: FractionalOffset.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(math.pi * _fraction),
                      child: _fraction < 0.5
                          ? CircleAvatar(
                              backgroundColor: c.withOpacity(0.5),
                              backgroundImage: episode.avatarImage)
                          : CircleAvatar(
                              backgroundColor:
                                  context.accentColor.withAlpha(70),
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
                            child: Text('E',
                                style: TextStyle(color: Colors.white))),
                      if (episode.duration != 0)
                        _episodeTag(
                            episode.duration == 0
                                ? ''
                                : s.minsCount(episode.duration ~/ 60),
                            Colors.cyan[300]),
                      if (episode.enclosureLength != null)
                        _episodeTag(
                            episode.enclosureLength == 0
                                ? ''
                                : '${(episode.enclosureLength) ~/ 1000000}MB',
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
        ));
  }
}
