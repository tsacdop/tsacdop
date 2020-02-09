import 'package:xml/xml.dart';

class Content {
  final String url;
  final String type;
  final int fileSize;
  final String medium;
  final bool isDefault;
  final String expression;
  final int bitrate;
  final double framerate;
  final double samplingrate;
  final int channels;
  final int duration;
  final int height;
  final int width;
  final String lang;

  Content({
    this.url,
    this.type,
    this.fileSize,
    this.medium,
    this.isDefault,
    this.expression,
    this.bitrate,
    this.framerate,
    this.samplingrate,
    this.channels,
    this.duration,
    this.height,
    this.width,
    this.lang,
  });

  factory Content.parse(XmlElement element) {
    return new Content(
      url: element.getAttribute("url"),
      type: element.getAttribute("type"),
      fileSize: int.tryParse(element.getAttribute("fileSize") ?? "0"),
      medium: element.getAttribute("medium"),
      isDefault: element.getAttribute("isDefault") == "true",
      expression: element.getAttribute("expression"),
      bitrate: int.tryParse(element.getAttribute("bitrate") ?? "0"),
      framerate: double.tryParse(element.getAttribute("framerate") ?? "0"),
      samplingrate: double.tryParse(
        element.getAttribute("samplingrate") ?? "0",
      ),
      channels: int.tryParse(element.getAttribute("channels") ?? "0"),
      duration: int.tryParse(element.getAttribute("duration") ?? "0"),
      height: int.tryParse(element.getAttribute("height") ?? "0"),
      width: int.tryParse(element.getAttribute("width") ?? "0"),
      lang: element.getAttribute("lang"),
    );
  }
}
