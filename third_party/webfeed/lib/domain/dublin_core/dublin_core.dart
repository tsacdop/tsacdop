import 'package:webfeed/util/helpers.dart';
import 'package:xml/xml.dart';

class DublinCore {
  final String? title;
  final String? description;
  final String? creator;
  final String? subject;
  final String? publisher;
  final String? contributor;
  final String? date;
  final String? type;
  final String? format;
  final String? identifier;
  final String? source;
  final String? language;
  final String? relation;
  final String? coverage;
  final String? rights;

  DublinCore({
    this.title,
    this.description,
    this.creator,
    this.subject,
    this.publisher,
    this.contributor,
    this.date,
    this.type,
    this.format,
    this.identifier,
    this.source,
    this.language,
    this.relation,
    this.coverage,
    this.rights,
  });

  factory DublinCore.parse(XmlElement? element) {
    if (element == null) {
      return DublinCore();
    }
    return DublinCore(
      title: findElementOrNull(element, "dc:title")?.innerText,
      description: findElementOrNull(element, "dc:description")?.innerText,
      creator: findElementOrNull(element, "dc:creator")?.innerText,
      subject: findElementOrNull(element, "dc:subject")?.innerText,
      publisher: findElementOrNull(element, "dc:publisher")?.innerText,
      contributor: findElementOrNull(element, "dc:contributor")?.innerText,
      date: findElementOrNull(element, "dc:date")?.innerText,
      type: findElementOrNull(element, "dc:type")?.innerText,
      format: findElementOrNull(element, "dc:format")?.innerText,
      identifier: findElementOrNull(element, "dc:identifier")?.innerText,
      source: findElementOrNull(element, "dc:source")?.innerText,
      language: findElementOrNull(element, "dc:language")?.innerText,
      relation: findElementOrNull(element, "dc:relation")?.innerText,
      coverage: findElementOrNull(element, "dc:coverage")?.innerText,
      rights: findElementOrNull(element, "dc:rights")?.innerText,
    );
  }
}
