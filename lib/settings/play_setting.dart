import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../home/audioplayer.dart';
import '../local_storage/key_value_storage.dart';
import '../state/audio_state.dart';
import '../state/setting_state.dart';
import '../util/extension_helper.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_time_picker.dart';
import '../widgets/custom_widget.dart';

const List kSecondsToSelect = [5, 10, 15, 20, 25, 30, 45, 60];
const List<double> kSpeedToSelect = [
  0.5,
  0.6,
  0.8,
  0.9,
  1.0,
  1.1,
  1.2,
  1.5,
  2.0,
  2.5,
  3.0,
  3.5,
  4.0,
  4.5,
  5.0
];

class PlaySetting extends StatefulWidget {
  @override
  _PlaySettingState createState() => _PlaySettingState();
}

class _PlaySettingState extends State<PlaySetting> {
  String _volumeEffect(BuildContext context, int? i) {
    final s = context.s;
    if (i == 2000) {
      return s!.playerHeightShort;
    } else if (i == 3000) {
      return s!.playerHeightMed;
    }
    return s!.playerHeightTall;
  }

  Future<bool> _getMarkListenedSkip() async {
    final storage = KeyValueStorage(markListenedAfterSkipKey);
    return storage.getBool(defaultValue: false);
  }

  Future<void> _saveMarkListenedSkip(bool boo) async {
    final storage = KeyValueStorage(markListenedAfterSkipKey);
    await storage.saveBool(boo);
    if (mounted) setState(() {});
  }

  Widget _modeWidget(BuildContext context) {
    var settings = Provider.of<SettingState>(context, listen: false);
    return Selector<SettingState, Tuple2<int?, int?>>(
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
                  child: Text(context.s.minsCount(data.item2!),
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
    return Selector<SettingState, Tuple2<int?, int?>>(
      selector: (_, settings) =>
          Tuple2(settings.autoSleepTimerStart, settings.autoSleepTimerEnd),
      builder: (_, data, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () async {
                var startTime = data.item1!;
                final timeOfDay = await showCustomTimePicker(
                    context: context,
                    cancelText: s!.cancel,
                    confirmText: s.confirm,
                    helpText: '',
                    initialTime: TimeOfDay(
                        hour: startTime ~/ 60, minute: startTime % 60));
                if (timeOfDay != null) {
                  startTime = timeOfDay.hour * 60 + timeOfDay.minute;
                  if (startTime != data.item2) {
                    settings.setAutoSleepTimerStart = startTime;
                  } else {
                    Fluttertoast.showToast(
                      msg: s.toastTimeEqualEnd,
                      gravity: ToastGravity.BOTTOM,
                    );
                  }
                }
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
                  child: Text(s!.from(data.item1!.toTime)),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                var endTime = data.item2!;
                final timeOfDay = await showCustomTimePicker(
                    context: context,
                    cancelText: s.cancel,
                    confirmText: s.confirm,
                    helpText: '',
                    initialTime:
                        TimeOfDay(hour: endTime ~/ 60, minute: endTime % 60));
                if (timeOfDay != null) {
                  endTime = timeOfDay.hour * 60 + timeOfDay.minute;
                  if (endTime != data.item1) {
                    settings.setAutoSleepTimerEnd = endTime;
                  } else {
                    Fluttertoast.showToast(
                      msg: s.toastTimeEqualStart,
                      gravity: ToastGravity.BOTTOM,
                    );
                  }
                }
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
                  child: Text(s.to(data.item2!.toTime),
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
    var settings = context.watch<SettingState>();
    var audio = context.watch<AudioPlayerNotifier>();
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
          leading: CustomBackButton(),
          elevation: 0,
          backgroundColor: context.primaryColor,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 60.0,
                padding: EdgeInsets.symmetric(horizontal: 40),
                alignment: Alignment.center,
                child: Text(s.notificationSetting,
                    style: context.textTheme.bodyText1!
                        .copyWith(color: context.accentColor)),
              ),
              _NotificationLayout(),
              Divider(
                height: 1,
              ),
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
                        .bodyText1!
                        .copyWith(color: Theme.of(context).accentColor)),
              ),
              Selector<SettingState, bool?>(
                selector: (_, settings) => settings.autoPlay,
                builder: (_, data, __) => ListTile(
                  onTap: () => settings.setAutoPlay = !data!,
                  contentPadding:
                      EdgeInsets.only(left: 70.0, right: 20, bottom: 10),
                  title: Text(s.settingsMenuAutoPlay),
                  subtitle: Text(s.settingsAutoPlayDes),
                  trailing: Transform.scale(
                    scale: 0.9,
                    child: Switch(
                        value: data!,
                        onChanged: (boo) => settings.setAutoPlay = boo),
                  ),
                ),
              ),
              FutureBuilder<bool>(
                initialData: false,
                future: _getMarkListenedSkip(),
                builder: (context, snapshot) => ListTile(
                  onTap: () => _saveMarkListenedSkip(!snapshot.data!),
                  contentPadding:
                      EdgeInsets.only(left: 70.0, right: 20, bottom: 10),
                  title: Text(s.settingsMarkListenedSkip),
                  subtitle: Text(s.settingsMarkListenedSkipDes),
                  trailing: Transform.scale(
                    scale: 0.9,
                    child: Switch(
                        value: snapshot.data!,
                        onChanged: _saveMarkListenedSkip),
                  ),
                ),
              ),
              Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(10.0),
              ),
              Container(
                height: 30.0,
                padding: EdgeInsets.symmetric(horizontal: 70),
                alignment: Alignment.centerLeft,
                child: Text(s.playback,
                    style: context.textTheme.bodyText1!
                        .copyWith(color: context.accentColor)),
              ),
              ListTile(
                contentPadding:
                    EdgeInsets.only(left: 70.0, right: 20, bottom: 10, top: 10),
                title: Text(s.settingsFastForwardSec),
                subtitle: Text(s.settingsFastForwardSecDes),
                trailing: Selector<SettingState, int?>(
                  selector: (_, settings) => settings.fastForwardSeconds,
                  builder: (_, data, __) => MyDropdownButton(
                      hint: Text(s.secCount(data!)),
                      underline: Center(),
                      elevation: 1,
                      displayItemCount: 5,
                      isDense: true,
                      value: data,
                      onChanged: (dynamic value) =>
                          settings.setFastForwardSeconds = value,
                      items: kSecondsToSelect.map<DropdownMenuItem<int>>((e) {
                        return DropdownMenuItem<int>(
                            value: e, child: Text(s.secCount(e)));
                      }).toList()),
                ),
              ),
              ListTile(
                contentPadding:
                    EdgeInsets.only(left: 70.0, right: 20, bottom: 10, top: 10),
                title: Text(s.settingsRewindSec),
                subtitle: Text(s.settingsRewindSecDes),
                trailing: Selector<SettingState, int?>(
                  selector: (_, settings) => settings.rewindSeconds,
                  builder: (_, data, __) => MyDropdownButton(
                      hint: Text(s.secCount(data!)),
                      underline: Center(),
                      elevation: 1,
                      displayItemCount: 5,
                      isDense: true,
                      value: data,
                      onChanged: (dynamic value) =>
                          settings.setRewindSeconds = value,
                      items: kSecondsToSelect.map<DropdownMenuItem<int>>((e) {
                        return DropdownMenuItem<int>(
                            value: e, child: Text(s.secCount(e)));
                      }).toList()),
                ),
              ),
              ListTile(
                contentPadding:
                    EdgeInsets.only(left: 70.0, right: 20, bottom: 10, top: 10),
                title: Text(s.settingsBoostVolume),
                subtitle: Text(s.settingsBoostVolumeDes),
                trailing: Selector<AudioPlayerNotifier, int?>(
                  selector: (_, audio) => audio.volumeGain,
                  builder: (_, volumeGain, __) => MyDropdownButton(
                      hint: Text(_volumeEffect(context, volumeGain)),
                      underline: Center(),
                      elevation: 1,
                      displayItemCount: 5,
                      isDense: true,
                      value: volumeGain,
                      onChanged: (dynamic value) => audio.setVolumeGain = value,
                      items: [2000, 3000, 4000].map<DropdownMenuItem<int>>((e) {
                        return DropdownMenuItem<int>(
                            value: e, child: Text(_volumeEffect(context, e)));
                      }).toList()),
                ),
              ),
              _SpeedList(),
              Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(10.0),
              ),
              Container(
                height: 30.0,
                padding: EdgeInsets.symmetric(horizontal: 70),
                alignment: Alignment.centerLeft,
                child: Text(s.sleepTimer,
                    style: context.textTheme.bodyText1!
                        .copyWith(color: Theme.of(context).accentColor)),
              ),
              ListView(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 70.0, right: 20),
                    title: Text(s.settingsSTDefaultTime),
                    subtitle: Text(s.settingsSTDefautTimeDes),
                    trailing: Selector<SettingState, int?>(
                      selector: (_, settings) => settings.defaultSleepTimer,
                      builder: (_, data, __) => MyDropdownButton(
                          hint: Text(s.minsCount(data!)),
                          underline: Center(),
                          elevation: 1,
                          displayItemCount: 5,
                          isDense: true,
                          value: data,
                          onChanged: (dynamic value) =>
                              settings.setDefaultSleepTimer = value,
                          items: kMinsToSelect.map<DropdownMenuItem<int>>((e) {
                            return DropdownMenuItem<int>(
                                value: e, child: Text(s.minsCount(e)));
                          }).toList()),
                    ),
                  ),
                  Selector<SettingState, bool?>(
                    selector: (_, settings) => settings.autoSleepTimer,
                    builder: (_, data, __) => ListTile(
                      onTap: () => settings.setAutoSleepTimer = !data!,
                      contentPadding: const EdgeInsets.only(
                          left: 70.0, right: 20.0, bottom: 10.0, top: 10.0),
                      title: Text(s.settingsSTAuto),
                      subtitle: Text(s.settingsSTAutoDes),
                      trailing: Transform.scale(
                        scale: 0.9,
                        child: Switch(
                            value: data!,
                            onChanged: (boo) =>
                                settings.setAutoSleepTimer = boo),
                      ),
                    ),
                  ),
                  ListTile(
                      contentPadding: const EdgeInsets.only(
                          left: 70.0, right: 20.0, bottom: 10.0, top: 10.0),
                      title: Text(s.settingsSTMode),
                      subtitle:
                          context.width > 360 ? null : _modeWidget(context),
                      trailing:
                          context.width > 360 ? _modeWidget(context) : null),
                  ListTile(
                      contentPadding: EdgeInsets.only(left: 70.0, right: 20),
                      title: Text(s.schedule),
                      subtitle:
                          context.width > 360 ? null : _scheduleWidget(context),
                      trailing: context.width > 360
                          ? _scheduleWidget(context)
                          : null),
                  Divider(height: 1)
                ],
              ),
              SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationLayout extends StatefulWidget {
  _NotificationLayout({Key? key}) : super(key: key);

  @override
  __NotificationLayoutState createState() => __NotificationLayoutState();
}

class __NotificationLayoutState extends State<_NotificationLayout> {
  Future<int?> _getNotificationLayout() async {
    final storage = KeyValueStorage(notificationLayoutKey);
    var index = await storage.getInt(defaultValue: 0);
    return index;
  }

  Future<void> _setNotificationLayout(int index) async {
    final storage = KeyValueStorage(notificationLayoutKey);
    await storage.saveInt(index);
    if (mounted) setState(() {});
  }

  Widget _notificationIcon(Widget icon, String des) {
    return LimitedBox(
      maxWidth: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          icon,
          SizedBox(height: 8),
          Text(des,
              style: TextStyle(
                  fontSize: 12, color: context.textColor!.withOpacity(0.5)),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.clip),
        ],
      ),
    );
  }

  Widget _notificationOptions(int index, {int? selected}) {
    final s = context.s;
    return InkWell(
      borderRadius: BorderRadius.circular(10.0),
      onTap: () => _setNotificationLayout(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: index == selected
                ? context.accentColor.withAlpha(70)
                : context.primaryColorDark,
          ),
          borderRadius: BorderRadius.circular(10),
          color: index == selected
              ? context.accentColor.withAlpha(70)
              : Colors.transparent,
        ),
        child: index == 0
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _notificationIcon(Icon(Icons.pause_circle_filled),
                      '${s!.play}| ${s.pause}'),
                  _notificationIcon(Icon(Icons.fast_forward), s.fastForward),
                  _notificationIcon(Icon(Icons.skip_next), s.skipToNext),
                  _notificationIcon(Icon(Icons.close), s.stop),
                ],
              )
            : index == 1
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        _notificationIcon(Icon(Icons.pause_circle_filled),
                            '${s!.play}| ${s.pause}'),
                        _notificationIcon(
                            Icon(Icons.fast_rewind), s.fastRewind),
                        _notificationIcon(Icon(Icons.skip_next), s.skipToNext),
                        _notificationIcon(Icon(Icons.close), s.stop),
                      ])
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _notificationIcon(Icon(Icons.fast_rewind), s!.fastRewind),
                      _notificationIcon(Icon(Icons.pause_circle_filled),
                          '${s.play}| ${s.pause}'),
                      _notificationIcon(
                          Icon(Icons.fast_forward), s.fastForward),
                      _notificationIcon(Icon(Icons.close), s.stop),
                    ],
                  ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(40, 0, 40, 30),
      child: FutureBuilder<int?>(
        future: _getNotificationLayout(),
        initialData: 0,
        builder: (context, snapshot) => Column(
          children: [
            _notificationOptions(0, selected: snapshot.data),
            SizedBox(height: 20),
            _notificationOptions(1, selected: snapshot.data),
            SizedBox(height: 20),
            _notificationOptions(2, selected: snapshot.data),
          ],
        ),
      ),
    );
  }
}

class _SpeedList extends StatefulWidget {
  _SpeedList({Key? key}) : super(key: key);

  @override
  __SpeedListState createState() => __SpeedListState();
}

class __SpeedListState extends State<_SpeedList> {
  Future<List<double>> _getSpeedList() async {
    var storage = KeyValueStorage('speedListKey');
    return await storage.getSpeedList();
  }

  Future<void> _saveSpeedList(List<double> list) async {
    var storage = KeyValueStorage('speedListKey');
    await storage.saveSpeedList(list);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return ListTile(
      contentPadding:
          EdgeInsets.only(left: 70.0, right: 20, bottom: 10, top: 10),
      title: Text(s.settingsSpeeds),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.settingsSpeedsDes),
          FutureBuilder<List<double>>(
              future: _getSpeedList(),
              initialData: [],
              builder: (context, snapshot) {
                var speedSelected = snapshot.data;
                return Wrap(
                    children: kSpeedToSelect
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                key: ValueKey<String>(e.toString()),
                                label: Text('X ${e.toStringAsFixed(1)}'),
                                selectedColor: context.accentColor,
                                labelStyle: TextStyle(
                                    color: snapshot.data!.contains(e)
                                        ? Colors.white
                                        : context.textColor),
                                elevation: 0,
                                showCheckmark: false,
                                selected: snapshot.data!.contains(e),
                                onSelected: (value) async {
                                  if (!value) {
                                    speedSelected!.remove(e);
                                  } else {
                                    speedSelected!.add(e);
                                  }
                                  await _saveSpeedList(speedSelected);
                                  setState(() {});
                                },
                              ),
                            ))
                        .toList());
              }),
        ],
      ),
    );
  }
}
