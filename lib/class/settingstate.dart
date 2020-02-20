import 'package:flutter/foundation.dart';

//two types podcast update, backhome nedd to back to default grooup.
enum Update {backhome, justupdate}
class SettingState extends ChangeNotifier{
  Update _subscribeupdate;
  Update get subscribeupdate => _subscribeupdate;
  set subscribeUpdate(Update s){
    _subscribeupdate = s;
    notifyListeners();
  }
}

