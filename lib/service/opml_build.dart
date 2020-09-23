import 'dart:developer' as developer;

import 'package:xml/xml.dart' as xml;
import '../state/podcast_group.dart';

class OmplOutline {
  final String text;
  final String xmlUrl;
  OmplOutline({this.text, this.xmlUrl});

  factory OmplOutline.parse(xml.XmlElement element) {
    if (element == null) return null;
    return OmplOutline(
      text: element.getAttribute("text")?.trim(),
      xmlUrl: element.getAttribute("xmlUrl")?.trim(),
    );
  }
}

class PodcastsBackup {
  ///Group list for backup.
  final List<PodcastGroup> groups;
  PodcastsBackup(this.groups) : assert(groups.isNotEmpty);

  xml.XmlNode omplBuilder() {
    var builder = xml.XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('ompl', nest: () {
      builder.attribute('version', '1.0');
      builder.element('head', nest: () {
        builder.element('title', nest: 'Tsacdop Feed Groups');
      });
      builder.element('body', nest: () {
        for (var group in groups) {
          builder.element('outline', nest: () {
            builder.attribute('text', '${group.name}');
            builder.attribute('title', '${group.name}');
            for (var e in group.podcasts) {
              builder.element(
                'outline',
                nest: () {
                  builder.attribute('type', 'rss');
                  builder.attribute('text', '${e.title}');
                  builder.attribute('title', '${e.title}');
                  builder.attribute('xmlUrl', '${e.rssUrl}');
                },
                isSelfClosing: true,
              );
            }
          });
        }
      });
    });
    return builder.build();
  }

  static parseOMPL(String opml) {
    var data = <String, List<OmplOutline>>{};
    // var opml = file.readAsStringSync();
    var content = xml.XmlDocument.parse(opml);
    var title =
        content.findAllElements('head').first.findElements('title').first.text;
    developer.log(title, name: 'Import OMPL');
    var groups = content.findAllElements('body').first.findElements('outline');
    if (title != 'Tsacdop Feed Groups') {
      var total = content
          .findAllElements('outline')
          .map((ele) => OmplOutline.parse(ele))
          .toList();
      data['Home'] = total;
      return data;
    }

    for (var element in groups) {
      var title = element.getAttribute('title');
      var total = element
          .findElements('outline')
          .map((ele) => OmplOutline.parse(ele))
          .toList();
      data[title] = total;
    }
    return data;
  }
}
