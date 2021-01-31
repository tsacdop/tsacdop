import 'package:flutter/material.dart';
import 'package:tsacdop/type/search_api/search_genre.dart';
import '../type/search_api/searchpodcast.dart';

class SearchState extends ChangeNotifier {
  final List<OnlinePodcast> _subscribedList = [];
  bool _update = false;
  List<OnlinePodcast> get subscribedList => _subscribedList;
  bool get update => _update;
  OnlinePodcast _selectedPodcast;
  OnlinePodcast get selectedPodcast => _selectedPodcast;
  Genre _genre;
  Genre get genre => _genre;

  set selectedPodcast(OnlinePodcast podcast) {
    _selectedPodcast = podcast;
    notifyListeners();
  }

  set setGenre(Genre genre) {
    _genre = genre;
    notifyListeners();
  }

  bool isSubscribed(OnlinePodcast podcast) => _subscribedList.contains(podcast);

  void clearSelect() {
    _selectedPodcast = null;
    notifyListeners();
  }

  void clearList() {
    _subscribedList.clear();
  }

  void clearGenre(){
    _genre = null;
    notifyListeners();
  }

  void addPodcast(OnlinePodcast podcast) {
    _subscribedList.add(podcast);
    _update = !_update;
    notifyListeners();
  }
}
