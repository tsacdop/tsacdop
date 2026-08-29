import 'package:xml/xml.dart';

class PodcastSoundbite {
  final double startTime;
  final double duration;
  final String info;

  PodcastSoundbite(this.startTime, this.duration, this.info);

  static PodcastSoundbite? parse(XmlElement? element) {
    if (element == null) {
      return null;
    }
    var startTime = double.parse(element.getAttribute("startTime")!);
    var duration = double.parse(element.getAttribute("duration")!);
    var info = element.innerText;

    return PodcastSoundbite(startTime, duration, info);
  }
}
