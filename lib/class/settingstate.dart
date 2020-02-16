import 'package:flutter/foundation.dart';

enum Setting {start, stop}
class SettingState extends ChangeNotifier{
  Setting _subscribeupdate;
  Setting get subscribeupdate => _subscribeupdate;
  set subscribeUpdate(Setting s){
    _subscribeupdate = s;
    notifyListeners();
  }
  Setting _themeupdate;
  Setting get themeUpdate => _themeupdate;
  set themeUpdate(Setting s){
    _themeupdate = s;
    notifyListeners();
  }

}

