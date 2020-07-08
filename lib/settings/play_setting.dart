import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

import '../state/setting_state.dart';
import '../home/audioplayer.dart';
import '../util/general_dialog.dart';
import '../util/context_extension.dart';
import '../util/custom_dropdown.dart';

String stringForMins(int mins) {
  if (mins == null) return null;
  return '${(mins ~/ 60)}:${(mins.truncate() % 60).toString().padLeft(2, '0')}';
}

class PlaySetting extends StatelessWidget {
  Widget _modeWidget(BuildContext context) {
    var settings = Provider.of<SettingState>(context, listen: false);
    return Selector<SettingState, Tuple2<int, int>>(
      selector: (_, settings) =>
          Tuple2(settings.autoSleepTimerMode, settings.defaultSleepTimer),
      builder: (_, data, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => settings.setAutoSleepTimerMode = 0,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5), topLeft: Radius.circular(5)),
              child: Material(
                color: Colors.transparent,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 400),
                  decoration: BoxDecoration(
                    color: data.item1 == 0
                        ? context.accentColor
                        : context.primaryColorDark,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        topLeft: Radius.circular(5)),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Text(context.s.endOfEpisode,
                      style: TextStyle(
                          color: data.item1 == 0 ? Colors.white : null)),
                ),
              ),
            ),
            InkWell(
              onTap: () => settings.setAutoSleepTimerMode = 1,
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(5),
                  topRight: Radius.circular(5)),
              child: Material(
                color: Colors.transparent,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 400),
                  decoration: BoxDecoration(
                    color: data.item1 == 1
                        ? context.accentColor
                        : context.primaryColorDark,
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(5),
                        topRight: Radius.circular(5)),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Text(context.s.minsCount(data.item2),
                      style: TextStyle(
                          color: data.item1 == 1 ? Colors.white : null)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scheduleWidget(BuildContext context) {
    var settings = Provider.of<SettingState>(context, listen: false);
    final s = context.s;
    return Selector<SettingState, Tuple2<int, int>>(
      selector: (_, settings) =>
          Tuple2(settings.autoSleepTimerStart, settings.autoSleepTimerEnd),
      builder: (_, data, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                int startTime = data.item1;
                generalDialog(
                  context,
                  content: TimePickerSpinner(
                    minutesInterval: 15,
                    time: DateTime.fromMillisecondsSinceEpoch(
                        data.item1 * 60 * 1000,
                        isUtc: true),
                    isForce2Digits: true,
                    is24HourMode: false,
                    highlightedTextStyle: GoogleFonts.teko(
                        textStyle: TextStyle(
                            fontSize: 40, color: context.accentColor)),
                    normalTextStyle: GoogleFonts.teko(
                        textStyle:
                            TextStyle(fontSize: 40, color: Colors.black38)),
                    onTimeChange: (DateTime time) {
                      startTime = time.hour * 60 + time.minute;
                    },
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        s.cancel,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        if (startTime != data.item2) {
                          settings.setAutoSleepTimerStart = startTime;
                          Navigator.of(context).pop();
                        } else {
                          Fluttertoast.showToast(
                            msg: s.toastTimeEqualEnd,
                            gravity: ToastGravity.BOTTOM,
                          );
                        }
                      },
                      child: Text(
                        s.confirm,
                        style: TextStyle(color: context.accentColor),
                      ),
                    )
                  ],
                );
              },
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5), topLeft: Radius.circular(5)),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.primaryColorDark,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        topLeft: Radius.circular(5)),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Text(s.from(stringForMins(data.item1))),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                int endTime;
                generalDialog(
                  context,
                  content: TimePickerSpinner(
                    minutesInterval: 15,
                    time: DateTime.fromMillisecondsSinceEpoch(
                        data.item2 * 60 * 1000,
                        isUtc: true),
                    isForce2Digits: true,
                    highlightedTextStyle: GoogleFonts.teko(
                        textStyle: TextStyle(
                            fontSize: 40, color: context.accentColor)),
                    normalTextStyle: GoogleFonts.teko(
                        textStyle:
                            TextStyle(fontSize: 40, color: Colors.black38)),
                    is24HourMode: false,
                    onTimeChange: (DateTime time) {
                      endTime = time.hour * 60 + time.minute;
                    },
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        s.cancel,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        if (endTime != data.item1) {
                          settings.setAutoSleepTimerEnd = endTime;
                          Navigator.of(context).pop();
                        } else {
                          Fluttertoast.showToast(
                            msg: s.toastTimeEqualStart,
                            gravity: ToastGravity.BOTTOM,
                          );
                        }
                      },
                      child: Text(
                        s.confirm,
                        style: TextStyle(color: context.accentColor),
                      ),
                    )
                  ],
                );
              },
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(5),
                  topRight: Radius.circular(5)),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(5),
                          topRight: Radius.circular(5))),
                  child: Text(s.to(stringForMins(data.item2)),
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<SettingState>(context, listen: false);
    final s = context.s;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.play),
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                  ),
                  Container(
                    height: 30.0,
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    alignment: Alignment.centerLeft,
                    child: Text(s.homeMenuPlaylist,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(color: Theme.of(context).accentColor)),
                  ),
                  ListView(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      Selector<SettingState, bool>(
                        selector: (_, settings) => settings.autoPlay,
                        builder: (_, data, __) => ListTile(
                          onTap: () => settings.setAutoPlay = !data,
                          contentPadding:
                              EdgeInsets.only(left: 80.0, right: 20),
                          title: Text(s.settingsMenuAutoPlay),
                          subtitle: Text(s.settingsAutoPlayDes),
                          trailing: Transform.scale(
                            scale: 0.9,
                            child: Switch(
                                value: data,
                                onChanged: (boo) => settings.setAutoPlay = boo),
                          ),
                        ),
                      ),
                      Divider(height: 2),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                  ),
                  Container(
                    height: 30.0,
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    alignment: Alignment.centerLeft,
                    child: Text(s.sleepTimer,
                        style: context.textTheme.bodyText1
                            .copyWith(color: Theme.of(context).accentColor)),
                  ),
                  ListView(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      ListTile(
                        contentPadding: EdgeInsets.only(left: 80.0, right: 20),
                        title: Text(s.settingsSTDefaultTime),
                        subtitle: Text(s.settingsSTDefautTimeDes),
                        trailing: Selector<SettingState, int>(
                          selector: (_, settings) => settings.defaultSleepTimer,
                          builder: (_, data, __) => MyDropdownButton(
                              hint: Text(s.minsCount(data)),
                              underline: Center(),
                              elevation: 1,
                              displayItemCount: 5,
                              isDense: true,
                              value: data,
                              onChanged: (int value) =>
                                  settings.setDefaultSleepTimer = value,
                              items:
                                  minsToSelect.map<DropdownMenuItem<int>>((e) {
                                return DropdownMenuItem<int>(
                                    value: e, child: Text(s.minsCount(e)));
                              }).toList()),
                        ),
                      ),
                      Selector<SettingState, bool>(
                        selector: (_, settings) => settings.autoSleepTimer,
                        builder: (_, data, __) => ListTile(
                          onTap: () => settings.setAutoSleepTimer = !data,
                          contentPadding: const EdgeInsets.only(
                              left: 80.0, right: 20.0, bottom: 10.0, top: 10.0),
                          title: Text(s.settingsSTAuto),
                          subtitle: Text(s.settingsSTAutoDes),
                          trailing: Transform.scale(
                            scale: 0.9,
                            child: Switch(
                                value: data,
                                onChanged: (boo) =>
                                    settings.setAutoSleepTimer = boo),
                          ),
                        ),
                      ),
                      ListTile(
                          contentPadding: const EdgeInsets.only(
                              left: 80.0, right: 20.0, bottom: 10.0, top: 10.0),
                          title: Text(s.settingsSTMode),
                          subtitle:
                              context.width > 360 ? null : _modeWidget(context),
                          trailing: context.width > 360
                              ? _modeWidget(context)
                              : null),
                      ListTile(
                          contentPadding:
                              EdgeInsets.only(left: 80.0, right: 20),
                          title: Text(s.schedule),
                          subtitle: context.width > 360
                              ? null
                              : _scheduleWidget(context),
                          trailing: context.width > 360
                              ? _scheduleWidget(context)
                              : null),
                      Divider(height: 2)
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
