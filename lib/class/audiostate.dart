import 'package:flutter/foundation.dart';

enum AudioState {load, play, pause, complete, error}

class Urlchange with ChangeNotifier {
  String _audiourl;
  String get audiourl => _audiourl;
  set audioUrl(String playing) {
    _audiourl = playing;
    notifyListeners();
  }

  String _title;
  String get title => _title;
  set rssTitle(String title){
    _title = title;
  }
  
  String _feedTitle;
  String get feedtitle => _feedTitle;
  set feedTitle(String feed){
    _feedTitle = feed;
  }
  
  String _primaryColor;
  String get primarycolor => _primaryColor;
  set primaryColor(String c){
    _primaryColor = c;
  }
  
  AudioState _audioState;
  AudioState get audioState => _audioState;
  set audioState(AudioState state){
    _audioState = state;
    notifyListeners();
  }
}