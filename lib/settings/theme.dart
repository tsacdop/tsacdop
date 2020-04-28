import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tsacdop/class/settingstate.dart';
import 'package:tsacdop/util/context_extension.dart';

class ThemeSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<SettingState>(context, listen: false);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Appearance'),
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                ),
                Container(
                  height: 30.0,
                  padding: EdgeInsets.symmetric(horizontal: 80),
                  alignment: Alignment.centerLeft,
                  child: Text('Interface',
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
                    ListTile(
                      onTap: () => showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: MaterialLocalizations.of(context)
                              .modalBarrierDismissLabel,
                          barrierColor: Colors.black54,
                          transitionDuration: const Duration(milliseconds: 200),
                          pageBuilder: (BuildContext context,
                                  Animation animaiton,
                                  Animation secondaryAnimation) =>
                              AnnotatedRegion<SystemUiOverlayStyle>(
                                value: SystemUiOverlayStyle(
                                  statusBarIconBrightness: Brightness.light,
                                  systemNavigationBarColor:
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Color.fromRGBO(113, 113, 113, 1)
                                          : Color.fromRGBO(15, 15, 15, 1),
                                ),
                                child: AlertDialog(
                                  titlePadding: EdgeInsets.only(
                                    top: 20,
                                    left: 40,
                                    right: 200,
                                  ),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0))),
                                  title: Text('Theme'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      RadioListTile(
                                          title: Container(
                                              padding:
                                                  EdgeInsets.only(right: 80),
                                              child: Text('System default')),
                                          value: ThemeMode.system,
                                          groupValue: settings.theme,
                                          onChanged: (value) {
                                            settings.setTheme = value;
                                            Navigator.of(context).pop();
                                          }),
                                      RadioListTile(
                                          title: Text('Dark mode'),
                                          value: ThemeMode.dark,
                                          groupValue: settings.theme,
                                          onChanged: (value) {
                                            settings.setTheme = value;
                                            Navigator.of(context).pop();
                                          }),
                                      RadioListTile(
                                          title: Text('Light mode'),
                                          value: ThemeMode.light,
                                          groupValue: settings.theme,
                                          onChanged: (value) {
                                            settings.setTheme = value;
                                            Navigator.of(context).pop();
                                          }),
                                    ],
                                  ),
                                ),
                              )),
                      contentPadding: EdgeInsets.symmetric(horizontal: 80.0),
                      //  leading: Icon(Icons.colorize),
                      title: Text('Theme'),
                      subtitle: Text('System default'),
                    ),
                    ListTile(
                      contentPadding:
                          EdgeInsets.only(left: 80.0, right: 20, bottom: 10),
                      //  leading: Icon(Icons.colorize),
                      title: Text(
                        'Real Dark',
                      ),
                      subtitle: Text(
                          'Turn on if you think the night is not dark enough'),
                      trailing: Selector<SettingState, bool>(
                        selector: (_, setting) => setting.realDark,
                        builder: (_, data, __) => Switch(
                            value: data,
                            onChanged: (boo) async {
                              settings.setRealDark = boo;
                            }),
                      ),
                    ),
                    Divider(height: 2),
                    ListTile(
                      onTap: () => showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: MaterialLocalizations.of(context)
                              .modalBarrierDismissLabel,
                          barrierColor: Colors.black54,
                          transitionDuration: const Duration(milliseconds: 200),
                          pageBuilder: (BuildContext context,
                                  Animation animaiton,
                                  Animation secondaryAnimation) =>
                              AnnotatedRegion<SystemUiOverlayStyle>(
                                  value: SystemUiOverlayStyle(
                                    statusBarIconBrightness: Brightness.light,
                                    systemNavigationBarColor:
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Color.fromRGBO(113, 113, 113, 1)
                                            : Color.fromRGBO(15, 15, 15, 1),
                                  ),
                                  child: AlertDialog(
                                    elevation: 1,
                                    titlePadding: EdgeInsets.only(
                                        top: 20,
                                        left: 40,
                                        right: 200,
                                        bottom: 0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0))),
                                    title: Text('Choose a color'),
                                    content: MaterialPicker(
                                      onColorChanged: (value) {
                                        settings.setAccentColor = value;
                                      },
                                      pickerColor: context.accentColor,
                                    ),
                                  ))),
                      contentPadding: EdgeInsets.only(left: 80.0, right: 25),
                      title: Text('Accent color'),
                      subtitle: Text('Include the overlay color'),
                      trailing: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: context.accentColor),
                      ),
                    ),
                    Divider(height: 2),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}