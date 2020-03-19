import 'package:tsacdop/class/podcastlocal.dart';
import 'package:xml/xml.dart' as xml;

omplBuilder(List<PodcastLocal> podcasts) {
  var builder = xml.XmlBuilder();
  builder.processing('xml', 'version="1.0"');
  builder.element('ompl', nest: () {
    builder.attribute('version', '1.0');
    builder.element('head', nest: () {
      builder.element('title', nest: 'Tsacdop Feeds');
    });
    builder.element('body', nest: () {
      builder.element('outline', nest: () {
        builder.attribute('text', 'feed');
        podcasts.forEach((e) => builder.element(
              'outline',
              nest: () {
                builder.attribute('type', 'rss');
                builder.attribute('text', '${e.title}');
                builder.attribute('xmlUrl', '${e.rssUrl}');
              },
              isSelfClosing: true,
            ));
      });
    });
  });
  return builder.build();
}
