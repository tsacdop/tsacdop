import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// The DefaultCacheManager that can be easily used directly. The code of
/// this implementation can be used as inspiration for more complex cache
/// managers.

class CustomCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'libCachedImageData';

  static final CustomCacheManager _instance = CustomCacheManager._();
  factory CustomCacheManager() {
    return _instance;
  }

  @override
  Future<FileInfo> downloadFile(String url,
      {String? key,
      Map<String, String>? authHeaders,
      bool force = false}) async {
    var file;
    try {
      file = await super
          .downloadFile(url, key: key, authHeaders: authHeaders, force: force);
    } catch (e) {
      rethrow;
    }
    return file;
  }

  @override
  Stream<FileResponse> getImageFile(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
    int? maxHeight,
    int? maxWidth,
  }) async* {
    try {
      super.getImageFile(url,
          key: key,
          headers: headers,
          withProgress: withProgress,
          maxHeight: maxHeight,
          maxWidth: maxWidth);
    } catch (e) {}
  }

  CustomCacheManager._() : super(Config(key));
}
