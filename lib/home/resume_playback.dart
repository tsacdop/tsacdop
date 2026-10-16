import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../type/episodebrief.dart';
import '../util/extension_helper.dart';

double resumePlaybackHeight(BuildContext context) {
  final scaler = MediaQuery.textScalerOf(context);
  return math.max(
    70,
    scaler.scale(11) * 1.1 +
        scaler.scale(14) * 1.2 +
        scaler.scale(12) * 1.2 +
        26,
  );
}

class ResumePlaybackBar extends StatefulWidget {
  const ResumePlaybackBar({
    required this.episode,
    required this.position,
    required this.onResume,
    this.bottomPadding = 0,
    super.key,
  });
  final EpisodeBrief episode;
  final int position;
  final Future<void> Function() onResume;
  final double bottomPadding;

  @override
  State<ResumePlaybackBar> createState() => _ResumePlaybackBarState();
}

class _ResumePlaybackBarState extends State<ResumePlaybackBar> {
  bool _busy = false;

  Future<void> _resume() async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final failure = '${context.s.play}: ${context.s.statusFail}';
    final failureBottom =
        resumePlaybackHeight(context) + widget.bottomPadding + 8;
    setState(() => _busy = true);
    try {
      await widget.onResume();
    } catch (_) {
      if (messenger.mounted) {
        messenger.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.fromLTRB(12, 0, 12, failureBottom),
            content: Text(failure),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Material(
    color: widget.episode.cardColor(context),
    child: InkWell(
      onTap: _busy ? null : _resume,
      child: SizedBox(
        height: resumePlaybackHeight(context) + widget.bottomPadding,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 8, 4, 8 + widget.bottomPadding),
          child: Row(
            children: [
              CircleAvatar(backgroundImage: widget.episode.avatarImage),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.s.continueListening,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, height: 1.1),
                    ),
                    SizedBox(height: 2),
                    Text(
                      widget.episode.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${widget.episode.feedTitle ?? ''} · ${(widget.position ~/ 1000).toTime}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, height: 1.2),
                    ),
                  ],
                ),
              ),
              if (_busy)
                Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                IconButton(
                  tooltip: context.s.continueListening,
                  onPressed: _resume,
                  icon: Icon(Icons.play_arrow),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
