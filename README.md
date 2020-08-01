[![Tsacdop Banner][]][google play]

[![Build Status - Cirrus][]][build status]
[![GitHub Release][]][github release - recent]
[![Github Downloads][]][github release - recent]
[![Localizely][]][localizely - website]
[![style: effective dart][]][effective dart pub]
[![License badge][]][license]

## About

Enjoy podcasts with Tsacdop.

Tsacdop is a podcast player developed with Flutter, a clean, simply beautiful and friendly app, which is also free and open source.

Credit to Flutter team and all involved plugins, especially [webfeed](https://github.com/witochandra/webfeed) and [Just_Audio](https://pub.dev/packages/just_audio).

The podcast search engine is powered by [ListenNotes](https://listennotes.com).

## Features

* Podcast group management
* Playlist support
* Sleep timer / speed setting
* OMPL file export and import
* Auto syncing in background
* Listening and subscription history record
* Dark mode / accent color
* Download for offline play
* Auto download new episodes / auto delete outdated downloads
* Settings backup

More to come...

## Preview

| Home Page | Group | Podcast | Episode| Dark Mode |
| ----- | ----- | ----- | ------ | ----- |
|![][Homepage ScreenShot]|![][Group Screenshot] | ![][Podcast Screenshot] | ![][Episode Screenshot]| ![][Darkmode Screenshot] |

## Localization

Support languages

* ![English]
* ![Chinese Simplified]
* ![French]  

   Translator: ppp

Please [Email](mailto:<tsacdop.app@gmail.com>) me you'd like to contribute to support more languages!

Credit to [Localizely](https://localizely.com/) for kind support to open source projects.

## License

Tsacdop is licensed under the [GPL v3.0](https://github.com/stonega/tsacdop/blob/master/LICENSE) license.

## Build

Tsacdop uses ListenNotes API 1.0 pro to search for podcasts, which is not free, so I can not expose the API key in the repo.
If you want to build the app, you need to create a new file named `.env.dart` in lib folder. Add the following code to `.env.dart` .

``` dart
final environment = {"apiKey":"APIKEY"};
```

You can get your own API key on [ListenNotes](https://www.listennotes.com/api/), basic plan is free for everyone. Replace `"APIKEY"` with it.
If no api key is added, the search function in the app won't work. But you can still add podcasts by using an RSS link or importing an OMPL file.

## Archetecture

### Plugins

* Local storage
  + sqflite
  + shared_preferences
* Audio
  + just_audio
  + audio_service
* State management
  + provider
* Download
  + flutter_downloader

### Directory Structure

``` 
UI
src
├──home
   ├──home.dart [Homepage]
   ├──searc_podcast.dart [Search Page]
   ├──playlist.dart [Playlist Page]
├──podcasts
   ├──podcast_manage.dart [Group Page]
   ├──podcast_detail.dart [Podcast Page]
├──episodes
   ├──episode_detail.dart [Episode Page]
├──settings
   ├──setting.dart [Setting Page]

STATE
src
├──state
   ├──audio_state.dart [Audio State]
   ├──download_state.dart [Episode Download]
   ├──podcast_group.dart [Podcast Groups]
   ├──refresh_podcast.dart [Episode Refresh]
   ├──setting_state.dart [Setting]
```

## Known Issue

* Playlist is unstable

## Getting Started

This project is a starting point for a Flutter application.

Here are a few resources to get you started if this is your first Flutter project:

* [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
* [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials, samples, guidance on mobile development, and a full API reference.

[tsacdop banner]: https://raw.githubusercontent.com/stonega/tsacdop/master/preview/banner.png
[build status - cirrus]: https://circleci.com/gh/stonega/tsacdop/tree/master.svg?style=shield
[build status]: https://circleci.com/gh/stonega/tsacdop/tree/master
[github release]: https://img.shields.io/github/v/release/stonega/tsacdop
[github release - recent]: https://github.com/stonega/tsacdop/releases
[github downloads]: https://img.shields.io/github/downloads/stonega/tsacdop/total?color=%230000d&label=downloads
[localizely]: https://img.shields.io/badge/dynamic/json?color=%2326c6da&label=localizely&query=%24.languages.length&url=https%3A%2F%2Fapi.localizely.com%2Fv1%2Fprojects%2Fbde4e9bd-4cb2-449b-9de2-18f231ddb47d%2Fstatus
[English]: https://img.shields.io/badge/dynamic/json?color=%2323CCC6&label=English&query=%24.languages%5B0%5D.reviewedProgress&url=https%3A%2F%2Fapi.localizely.com%2Fv1%2Fprojects%2Fbde4e9bd-4cb2-449b-9de2-18f231ddb47d%2Fstatus&suffix=%
[Chinese Simplified]: https://img.shields.io/badge/dynamic/json?color=%2323CCC6&label=Chinese%20Simplified&query=%24.languages%5B1%5D.reviewedProgress&url=https%3A%2F%2Fapi.localizely.com%2Fv1%2Fprojects%2Fbde4e9bd-4cb2-449b-9de2-18f231ddb47d%2Fstatus&suffix=%
[French]: https://img.shields.io/badge/dynamic/json?color=%2323CCC6&label=French&query=%24.languages%5B3%5D.reviewedProgress&url=https%3A%2F%2Fapi.localizely.com%2Fv1%2Fprojects%2Fbde4e9bd-4cb2-449b-9de2-18f231ddb47d%2Fstatus&suffix=%
[localizely - website]: https://localizely.com/
[google play - icon]: https://img.shields.io/badge/google-playStore-%2323CCC6
[google play]: https://play.google.com/store/apps/details?id=com.stonegate.tsacdop
[Homepage ScreenShot]: https://raw.githubusercontent.com/stonega/tsacdop/master/preview/1585893838840.png
[Group Screenshot]: https://raw.githubusercontent.com/stonega/tsacdop/master/preview/1585894051734.png
[Podcast Screenshot]: https://raw.githubusercontent.com/stonega/tsacdop/master/preview/1585893877702.png
[Episode Screenshot]: https://raw.githubusercontent.com/stonega/tsacdop/master/preview/1585896237809.png
[Darkmode Screenshot]: https://raw.githubusercontent.com/stonega/tsacdop/master/preview/1585893920721.png
[style: effective dart]: https://img.shields.io/badge/style-effective_dart-40c4ff.svg
[effective dart pub]: https://pub.dev/packages/effective_dart
[license]: https://github.com/stonega/tsacdop/blob/master/LICENSE
[License badge]: https://img.shields.io/badge/license-GPLv3-yellow.svg
