// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Refresh all`
  String get homeToprightMenuRefreshAll {
    return Intl.message(
      'Refresh all',
      name: 'homeToprightMenuRefreshAll',
      desc: '',
      args: [],
    );
  }

  /// `Import OMPL`
  String get homeToprightMenuImportOMPL {
    return Intl.message(
      'Import OMPL',
      name: 'homeToprightMenuImportOMPL',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get homeToprightMenuSettings {
    return Intl.message(
      'Settings',
      name: 'homeToprightMenuSettings',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get homeToprightMenuAbout {
    return Intl.message(
      'About',
      name: 'homeToprightMenuAbout',
      desc: '',
      args: [],
    );
  }

  /// `See All`
  String get homeGroupsSeeAll {
    return Intl.message(
      'See All',
      name: 'homeGroupsSeeAll',
      desc: '',
      args: [],
    );
  }

  /// `Recent`
  String get homeTabMenuRecent {
    return Intl.message(
      'Recent',
      name: 'homeTabMenuRecent',
      desc: '',
      args: [],
    );
  }

  /// `Favorite`
  String get homeTabMenuFavotite {
    return Intl.message(
      'Favorite',
      name: 'homeTabMenuFavotite',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get homeTabMenuDownload {
    return Intl.message(
      'Download',
      name: 'homeTabMenuDownload',
      desc: '',
      args: [],
    );
  }

  /// `Playlist`
  String get homeMenuPlaylist {
    return Intl.message(
      'Playlist',
      name: 'homeMenuPlaylist',
      desc: '',
      args: [],
    );
  }

  /// `Sort by`
  String get homeSubMenuSortBy {
    return Intl.message(
      'Sort by',
      name: 'homeSubMenuSortBy',
      desc: '',
      args: [],
    );
  }

  /// `UpdateDate`
  String get homeSubMenuUpdateDate {
    return Intl.message(
      'UpdateDate',
      name: 'homeSubMenuUpdateDate',
      desc: '',
      args: [],
    );
  }

  /// `Like Date`
  String get homeSubMenuLikeData {
    return Intl.message(
      'Like Date',
      name: 'homeSubMenuLikeData',
      desc: '',
      args: [],
    );
  }

  /// `Downloaded`
  String get homeSubMenuDownloaded {
    return Intl.message(
      'Downloaded',
      name: 'homeSubMenuDownloaded',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}