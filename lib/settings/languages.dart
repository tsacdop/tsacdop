import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';

import '../generated/l10n.dart';
import '../local_storage/key_value_storage.dart';
import '../util/extension_helper.dart';

class LanguagesSetting extends StatefulWidget {
  const LanguagesSetting({Key? key}) : super(key: key);

  @override
  _LanguagesSettingState createState() => _LanguagesSettingState();
}

class _LanguagesSettingState extends State<LanguagesSetting> {
  @override
  void initState() {
    super.initState();
    findSystemLocale();
  }

  _setLocale(Locale? locale, {bool systemDefault = false}) async {
    var localeStorage = KeyValueStorage(localeKey);
    if (systemDefault) {
      await localeStorage.saveStringList([]);
      await findSystemLocale();
      var systemLanCode;
      final list = Intl.systemLocale.split('_');
      if (list.length == 2) {
        systemLanCode = list.first;
      } else if (list.length == 3) {
        systemLanCode = '${list[0]}_${list[1]}';
      } else {
        systemLanCode = 'en';
      }
      await S.load(Locale(systemLanCode));
      if (mounted) {
        setState(() {});
      }
    } else {
      await localeStorage
          .saveStringList([locale!.languageCode, locale.countryCode??'']);
      await S.load(locale);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _langListTile(String lang, {Locale? locale}) => ListTile(
        title: Text(lang, style: context.textTheme.bodyText2),
        onTap: () => _setLocale(locale),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        trailing: Transform.scale(
          scale: 0.8,
          child: Radio<Locale?>(
              value: locale,
              groupValue: Locale(Intl.getCurrentLocale()),
              onChanged: _setLocale),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final textStyle = context.textTheme.bodyText2!;
    final s = context.s!;
    return Column(
      children: [
        ListTile(
          title: Text(
            s.systemDefault,
            style: textStyle.copyWith(
                color: Intl.systemLocale.contains(Intl.getCurrentLocale())
                    ? context.accentColor
                    : null),
          ),
          dense: true,
          onTap: () =>
              _setLocale(Locale(Intl.systemLocale), systemDefault: true),
          contentPadding: const EdgeInsets.only(left: 20, right: 20),
        ),
        _langListTile('English', locale: Locale('en')),
        _langListTile('简体中文', locale: Locale('zh_Hans')),
        _langListTile('Français', locale: Locale('fr')),
        _langListTile('Español', locale: Locale('es')),
        _langListTile('Português', locale: Locale('pt')),
        _langListTile('Italiano', locale: Locale('it')),
        _langListTile('Türkçe', locale: Locale('tr')),
        _langListTile('Ελληνικά', locale: Locale('el')),
        Divider(height: 1),
        ListTile(
          onTap: () =>
              'mailto:<tsacdop.app@gmail.com>?subject=Tsacdop localization project'
                  .launchUrl,
          contentPadding: const EdgeInsets.only(left: 20, right: 20),
          dense: true,
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
    );
  }
}
