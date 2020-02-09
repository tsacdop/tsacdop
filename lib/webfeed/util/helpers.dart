import 'dart:core';

import 'package:xml/xml.dart';

XmlElement findElementOrNull(XmlElement element, String name,
    {String namespace}) {
  try {
    return element.findAllElements(name, namespace: namespace).first;
  } on StateError {
    return null;
  }
}

List<XmlElement> findAllDirectElementsOrNull(XmlElement element, String name,
    {String namespace}) {
  try {
    return element.findElements(name, namespace: namespace).toList();
  } on StateError {
    return null;
  }
}

bool parseBoolLiteral(XmlElement element, String tagName) {
  var v = findElementOrNull(element, tagName)?.text?.toLowerCase()?.trim();
  if (v == null) return null;
  return ["yes", "true"].contains(v);
}

