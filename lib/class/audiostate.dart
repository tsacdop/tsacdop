import 'package:flutter/foundation.dart';
import 'package:tsacdop/class/episodebrief.dart';

enum AudioState {load, play, pause, complete, error}

class AudioPlay with ChangeNotifier {
  
  EpisodeBrief _episode;
  EpisodeBrief get episode => _episode;
  set episodeLoad(EpisodeBrief episdoe){
    _episode = episdoe;
    notifyListeners();
  }
  
  AudioState _audioState;
  AudioState get audioState => _audioState;
  set audioState(AudioState state){
    _audioState = state;
    notifyListeners();
  }
}