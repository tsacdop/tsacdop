import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<ui.Image> getImageFromProvider(ImageProvider imageProvider) async {
  final ImageStream stream = imageProvider.resolve(
    ImageConfiguration(devicePixelRatio: 1.0),
  );
  final Completer<ui.Image> imageCompleter = Completer<ui.Image>();
  late ImageStreamListener listener;
  listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
    stream.removeListener(listener);
    imageCompleter.complete(info.image);
  });
  stream.addListener(listener);
  final image = await imageCompleter.future;
  return image;
}

String formateDate(int timeStamp) {
  return DateFormat.yMMMd().format(
    DateTime.fromMillisecondsSinceEpoch(timeStamp),
  );
}
