import 'package:package_info_plus/package_info_plus.dart';

abstract final class AppInfo {
  static final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  static Future<String> get version async => (await _packageInfo).version;
}
