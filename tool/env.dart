import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final config = {
    'apiKey': Platform.environment['API_KEY'],
    'podcastIndexApiKey': Platform.environment['PI_API_KEY'],
    'podcastIndexApiSecret': Platform.environment['PI_API_SECRET']
  };

  final filename = 'lib/.env.dart';
  File(filename).writeAsString('final environment = ${json.encode(config)};');
  print('Write successfully');
}
