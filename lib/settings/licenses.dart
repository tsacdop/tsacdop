const String apacheLicense = "Apache License 2.0";
const String mit = "MIT License";
const String bsd = "BSD 3-Clause";
const String gpl = "GPL 3.0";
const String font = "Open Font License";

class Libries {
  String name;
  String license;
  String link;
  Libries(this.name, this.license, this.link);
}

List<Libries> google = [
  Libries('Android X', apacheLicense,
      'https://source.android.com/setup/start/licenses'),
  Libries(
      'Flutter', bsd, 'https://github.com/flutter/flutter/blob/master/LICENSE')
];

List<Libries> fonts = [
  Libries('Libre Baskerville', font,
      "https://fonts.google.com/specimen/Libre+Baskerville"),
  Libries('Teko', font, "https://fonts.google.com/specimen/Teko"),
  Libries('Martel', font, "https://fonts.google.com/specimen/Martel"),
  Libries('Bitter', font, "https://fonts.google.com/specimen/Bitter")
];

List<Libries> plugins = [
  Libries('webfeed', mit, 'https://pub.dev/packages/webfeed'),
  Libries('json_annotation', bsd, 'https://pub.dev/packages/json_annotation'),
  Libries('sqflite', mit, 'https://pub.dev/packages/sqflite'),
  Libries('flutter_html', mit, 'https://pub.dev/packages/flutter_html'),
  Libries('path_provider', bsd, 'https://pub.dev/packages/path_provider'),
  Libries('color_thief_flutter', mit,
      'https://pub.dev/packages/color_thief_flutter'),
  Libries('provider', mit, 'https://pub.dev/packages/provider'),
  Libries(
      'google_fonts', apacheLicense, 'https://pub.dev/packages/google_fonts'),
  Libries('dio', mit, 'https://pub.dev/packages/dio'),
  Libries('file_picker', mit, 'https://pub.dev/packages/file_picker'),
  Libries('xml', mit, 'https://pub.dev/packages/xml'),
  Libries('marquee', mit, 'https://pub.dev/packages/marquee'),
  Libries(
      'flutter_downloader', bsd, 'https://pub.dev/packages/flutter_downloader'),
  Libries(
      'permission_handler', mit, 'https://pub.dev/packages/permission_handler'),
  Libries('fluttertoast', mit, 'https://pub.dev/packages/fluttertoast'),
  Libries('intl', bsd, 'https://pub.dev/packages/intl'),
  Libries('url_launcher', bsd, 'https://pub.dev/packages/url_launcher'),
  Libries('image', apacheLicense, 'https://pub.dev/packages/image'),
  Libries(
      'shared_preferences', bsd, 'https://pub.dev/packages/shared_preferences'),
  Libries('uuid', mit, 'https://pub.dev/packages/uuid'),
  Libries('tuple', bsd, 'https://pub.dev/packages/tuple'),
  Libries('cached_network_image', mit,
      'https://pub.dev/packages/cached_network_image'),
  Libries('workmanager', mit, 'https://pub.dev/packages/workmanager'),
  Libries('app_settings', mit, 'https://pub.dev/packages/app_settings'),
  Libries('fl_chart', bsd, 'https://pub.dev/packages/fl_chart'),
  Libries('audio_service', mit, 'https://pub.dev/packages/audio_service'),
  Libries('just_audio', apacheLicense, 'https://pub.dev/packages/just_audio'),
  Libries('line_icons', gpl, 'https://pub.dev/packages/line_icons'),
  Libries('flutter_file_dialog', bsd,
      'https://pub.dev/packages/flutter_file_dialog'),
  Libries('flutter_linkify', mit, 'https://pub.dev/packages/flutter_linkify'),
  Libries('extended_nested_scroll_view', mit,
      'https://pub.dev/packages/extended_nested_scroll_view'),
  Libries('connectivity', bsd, 'https://pub.dev/packages/connectivity'),
  Libries('Rxdart', apacheLicense, 'https://pub.dev/packages/rxdart'),
  Libries('flutter_isolate', mit, 'https://pub.dev/packages/flutter_isolate'),
  Libries('auto_animated', mit, 'https://pub.dev/packages/auto_animated'),
  Libries('wc_flutter_share', apacheLicense,
      'https://pub.dev/packages/wc_flutter_share'),
  Libries('flutter_time_picker_spinner', 'unknow',
      'https://pub.dev/packages/flutter_time_picker_spinner'),
  Libries('focused_menu', mit, 'https://pub.dev/packages/focused_menu')
];
