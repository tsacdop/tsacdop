import 'dart:convert';
import 'package:flutter/material.dart';

extension Colorize on String {
  Color colorizedark() {
    Color _c;
    var color = json.decode(this);
    if (color[0] > 200 && color[1] > 200 && color[2] > 200) {
      _c =
          Color.fromRGBO((255 - color[0]), 255 - color[1], 255 - color[2], 1.0);
    } else {
      _c = Color.fromRGBO(color[0], color[1] > 200 ? 190 : color[1],
          color[2] > 200 ? 190 : color[2], 1);
    }
    return _c;
  }

  Color colorizeLight() {
    Color _c;
    var color = json.decode(this);
    if (color[0] < 50 && color[1] < 50 && color[2] < 50) {
      _c =
          Color.fromRGBO((255 - color[0]), 255 - color[1], 255 - color[2], 1.0);
    } else {
      _c = Color.fromRGBO(color[0], color[1], color[2], 1.0);
    }
    return _c;
  }
}
