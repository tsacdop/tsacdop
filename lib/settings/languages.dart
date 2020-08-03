import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';
import '../local_storage/key_value_storage.dart';
import '../util/extension_helper.dart';

class LanguagesSetting extends StatefulWidget {
  const LanguagesSetting({Key key}) : super(key: key);

  @override
  _LanguagesSettingState createState() => _LanguagesSettingState();
}

class _LanguagesSettingState extends State<LanguagesSetting> {
  _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _setLocale(Locale locale, {bool systemDefault = false}) async {
    var localeStorage = KeyValueStorage(localeKey);
    if (systemDefault) {
      await localeStorage.saveStringList([]);
    } else {
      await localeStorage
          .saveStringList([locale.languageCode, locale.countryCode]);
    }
    await S.load(locale);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text(s.settingsLanguages),
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              ListTile(
                title: Text(s.systemDefault),
                onTap: () =>
                    _setLocale(Locale(Intl.systemLocale), systemDefault: true),
                contentPadding: const EdgeInsets.only(left: 75, right: 20),
                trailing: Radio<Locale>(
                    value: Locale(Intl.systemLocale),
                    groupValue: Locale(Intl.getCurrentLocale()),
                    onChanged: (locale) =>
                        _setLocale(locale, systemDefault: true)),
              ),
              Divider(height: 2),
              ListTile(
                  title: Text('English'),
                  onTap: () => _setLocale(Locale('en')),
                  contentPadding: const EdgeInsets.only(left: 75, right: 20),
                  trailing: Radio<Locale>(
                      value: Locale('en'),
                      groupValue: Locale(Intl.getCurrentLocale()),
                      onChanged: _setLocale)),
              Divider(height: 2),
              ListTile(
                  title: Text('简体中文'),
                  onTap: () => _setLocale(Locale('zh_Hans')),
                  contentPadding: const EdgeInsets.only(left: 75, right: 20),
                  trailing: Radio<Locale>(
                    value: Locale('zh_Hans'),
                    groupValue: Locale(Intl.getCurrentLocale()),
                    onChanged: _setLocale,
                  )),
              Divider(height: 2),
              ListTile(
                title: Text('Français'),
                onTap: () => _setLocale(Locale('fr')),
                contentPadding: const EdgeInsets.only(left: 75, right: 20),
                trailing: Radio<Locale>(
                    value: Locale('fr'),
                    groupValue: Locale(Intl.getCurrentLocale()),
                    onChanged: _setLocale),
              ),
              Divider(height: 2),
              ListTile(
                title: Text('Español'),
                onTap: () => _setLocale(Locale('es')),
                contentPadding: const EdgeInsets.only(left: 75, right: 20),
                trailing: Radio<Locale>(
                    value: Locale('es'),
                    groupValue: Locale(Intl.getCurrentLocale()),
                    onChanged: _setLocale),
              ),
              Divider(height: 2),
              ListTile(
                onTap: () => _launchUrl(
                    'mailto:<tsacdop.app@gmail.com>?subject=Tsacdop localization project'),
                contentPadding: const EdgeInsets.only(left: 75, right: 20),
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Image(
                      image: Theme.of(context).brightness == Brightness.light
                          ? AssetImage('assets/localizely_logo.png')
                          : AssetImage('assets/localizely_logo_light.png'),
                      height: 20),
                ),
                subtitle: Text(
                    "If you'd like to contribute to localization project, please contact me."),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
