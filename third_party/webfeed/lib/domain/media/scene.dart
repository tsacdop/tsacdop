import 'package:webfeed/util/helpers.dart';
import 'package:xml/xml.dart';

class Scene {
  final String? title;
  final String? description;
  final String? startTime;
  final String? endTime;

  Scene({this.title, this.description, this.startTime, this.endTime});

  static Scene? parse(XmlElement? element) {
    if (element == null) {
      return null;
    }
    return Scene(
      title: findElementOrNull(element, "sceneTitle")?.innerText,
      description: findElementOrNull(element, "sceneDescription")?.innerText,
      startTime: findElementOrNull(element, "sceneStartTime")?.innerText,
      endTime: findElementOrNull(element, "sceneEndTime")?.innerText,
    );
  }
}
