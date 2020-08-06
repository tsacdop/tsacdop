import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final config = {
    'apiKey': Platform.environment['API_KEY'],
  };

  final filename = 'lib/.env.dart';
  File(filename).writeAsString('final environment = ${json.encode(config)};');
  print('Write successfully');
}
