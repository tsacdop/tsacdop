import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:linkify/linkify.dart';
import 'package:provider/provider.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:tsacdop/state/audio_state.dart';
import 'package:tsacdop/state/setting_state.dart';
import 'package:tsacdop/type/episodebrief.dart';
import 'package:tsacdop/util/extension_helper.dart';

class ShowNote extends StatelessWidget {
  final EpisodeBrief? episode;
  const ShowNote({this.episode, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioPlayerNotifier>();
    final s = context.s;
    return FutureBuilder<String?>(
      future: _getSDescription(episode!.enclosureUrl),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var description = snapshot.data;
          if (description == null) return Center();
          if (description.length > 0) {
            return Selector<AudioPlayerNotifier, EpisodeBrief?>(
              selector: (_, audio) => audio.episode,
              builder: (_, playEpisode, __) {
                if (playEpisode == episode && !description!.contains('#t=')) {
                  final linkList = linkify(description,
                      options: LinkifyOptions(humanize: false),
                      linkifiers: [TimeStampLinkifier()]);
                  for (final element in linkList) {
                    if (element is TimeStampElement) {
                      final time = element.timeStamp;
                      description = description!.replaceFirst(time!,
                          '<a rel="nofollow" href = "#t=$time">$time</a>');
                    }
                  }
                }
                return Selector<SettingState, TextStyle>(
                  selector: (_, settings) => settings.showNoteFontStyle,
                  builder: (_, data, __) => Html(
                    style: {
                      'html': Style.fromTextStyle(data.copyWith(fontSize: 14))
                          .copyWith(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      'a': Style(
                        color: context.accentColor,
                        textDecoration: TextDecoration.none,
                      ),
                    },
                    data: description,
                    onLinkTap: (url, _, __, ___) {
                      if (url!.substring(0, 3) == '#t=') {
                        final seconds = _getTimeStamp(url);
                        if (playEpisode == episode) {
                          audio.seekTo(seconds! * 1000);
                        }
                      } else {
                        url.launchUrl;
                      }
                    },
                  ),
                );
              },
            );
          } else {
            return Container(
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
                      style:
                          TextStyle(color: context.textColor.withOpacity(0.5))),
                ],
              ),
            );
          }
        } else {
          return Center();
        }
      },
    );
  }

  int? _getTimeStamp(String url) {
    final time = url.substring(3).trim();
    final data = time.split(':');
    int? seconds;
    if (data.length == 3) {
      seconds = int.tryParse(data[0])! * 3600 +
          int.tryParse(data[1])! * 60 +
          int.tryParse(data[2])!;
    } else if (data.length == 2) {
      seconds = int.tryParse(data[0])! * 60 + int.tryParse(data[1])!;
    }
    return seconds;
  }

  Future<String?> _getSDescription(String url) async {
    final dbHelper = DBHelper();
    String description;
    description = (await dbHelper.getDescription(url))!
        .replaceAll(RegExp(r'\s?<p>(<br>)?</p>\s?'), '')
        .replaceAll('\r', '')
        .trim();
    if (!description.contains('<')) {
      final linkList = linkify(description,
          options: LinkifyOptions(humanize: false),
          linkifiers: [UrlLinkifier(), EmailLinkifier()]);
      for (var element in linkList) {
        if (element is UrlElement) {
          description = description.replaceAll(element.url!,
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
}
