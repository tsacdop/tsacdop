import 'package:flutter/foundation.dart';

enum ImportState{start, import, complete, stop, error}

class ImportOmpl extends ChangeNotifier{
  ImportState _importState = ImportState.stop;
  String _rssTitle;
  String get rsstitle => _rssTitle;
  set rssTitle(String title){
    _rssTitle = title;
    notifyListeners();
  }
  ImportState get importState => _importState;
  set importState(ImportState state){
    _importState = state;
    notifyListeners();
  }
}