import 'package:xml/xml.dart' as xml;
import '../state/podcast_group.dart';

class PodcastsBackup {
  ///Group list for backup.
  final List<PodcastGroup> groups;
  PodcastsBackup(this.groups) : assert(groups.length > 0);

  omplBuilder() async {
    var builder = xml.XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('ompl', nest: () {
      builder.attribute('version', '1.0');
      builder.element('head', nest: () {
        builder.element('title', nest: 'Tsacdop Feeds');
      });
      builder.element('body', nest: () {
        builder.element('outline', nest: () {
          groups.forEach((group) {
            builder.attribute('text', '${group.name}');
            builder.attribute('title', '${group.name}');
            group.podcasts.forEach((e) => builder.element(
                  'outline',
                  nest: () {
                    builder.attribute('type', 'rss');
                    builder.attribute('text', '${e.title}');
                    builder.attribute('title', '${e.title}');
                    builder.attribute('xmlUrl', '${e.rssUrl}');
                  },
                  isSelfClosing: true,
                ));
          });
        });
      });
    });
    return builder.build();
  }
}
