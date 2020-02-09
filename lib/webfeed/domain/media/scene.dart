import 'package:webfeed/util/helpers.dart';
import 'package:xml/xml.dart';

class Scene {
  final String title;
  final String description;
  final String startTime;
  final String endTime;

  Scene({
    this.title,
    this.description,
    this.startTime,
    this.endTime,
  });

  factory Scene.parse(XmlElement element) {
    if (element == null) {
      return null;
    }
    return new Scene(
      title: findElementOrNull(element, "sceneTitle")?.text,
      description: findElementOrNull(element, "sceneDescription")?.text,
      startTime: findElementOrNull(element, "sceneStartTime")?.text,
      endTime: findElementOrNull(element, "sceneEndTime")?.text,
    );
  }
}
