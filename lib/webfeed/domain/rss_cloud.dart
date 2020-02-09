import 'package:xml/xml.dart';

class RssCloud {
  final String domain;
  final String port;
  final String path;
  final String registerProcedure;
  final String protocol;

  RssCloud(
    this.domain,
    this.port,
    this.path,
    this.registerProcedure,
    this.protocol,
  );

  factory RssCloud.parse(XmlElement node) {
    if (node == null) {
      return null;
    }
    var domain = node.getAttribute("domain");
    var port = node.getAttribute("port");
    var path = node.getAttribute("path");
    var registerProcedure = node.getAttribute("registerProcedure");
    var protocol = node.getAttribute("protocol");
    return RssCloud(domain, port, path, registerProcedure, protocol);
  }
}
