import 'package:flutter/foundation.dart';

enum DownloadState { stop, load, donwload, complete, error }

class EpisodeDownload with ChangeNotifier {
  String _title;
  String get title => _title;
  set title(String t) {
    _title = t;
    notifyListeners();
  }
  DownloadState _downloadState = DownloadState.stop;
  DownloadState get downloadState => _downloadState;
  set downloadState(DownloadState state){
    _downloadState = state;
    notifyListeners();
  }
}
