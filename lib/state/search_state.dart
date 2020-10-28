import 'package:flutter/material.dart';
import '../type/search_api/searchpodcast.dart';

class SearchState extends ChangeNotifier {
  final List<OnlinePodcast> _subscribedList = [];
  bool _update = false;
  List<OnlinePodcast> get subscribedList => _subscribedList;
  bool get update => _update;
  OnlinePodcast _selectedPodcast;
  OnlinePodcast get selectedPodcast => _selectedPodcast;

  set selectedPodcast(OnlinePodcast podcast) {
    _selectedPodcast = podcast;
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

  void addPodcast(OnlinePodcast podcast) {
    _subscribedList.add(podcast);
    _update = !_update;
    notifyListeners();
  }
}
