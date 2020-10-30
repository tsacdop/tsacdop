[![Tsacdop Banner][]][google play]

[![github action][]][github action link]
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
* OPML file export and import
* Auto syncing in background
* Listening and subscription history record
* Dark mode / accent color
* Download for offline play
* Auto download new episodes / auto delete outdated downloads
* Settings backup
* Skip silence
* Boost volume

More to come...

## Preview

| Home Page | Group | Podcast | Episode| Dark Mode |
| ----- | ----- | ----- | ------ | ----- |
|![][Homepage ScreenShot]|![][Group Screenshot] | ![][Podcast Screenshot] | ![][Episode Screenshot]| ![][Darkmode Screenshot] |

## Localization

Please [Email](mailto:<tsacdop.app@gmail.com>) me you'd like to contribute to support more languages!

Credit to [Localizely](https://localizely.com/) for kind support to open source projects.

### ![English]

### ![Chinese Simplified]

### ![French] 

### ![Spanish]

### ![Portuguese]

## License

Tsacdop is licensed under the [GPL v3.0](https://github.com/stonega/tsacdop/blob/master/LICENSE) license.

## Build

1. If you don't have Flutter SDK installed, please visit offcial [Flutter][Flutter Install] site.
2. Fetch latest sorce code from master branch.

``` 
git clone https://github.com/stonega/tsacdop.git
```

3. Add api search api configure file.  

Tsacdop uses ListenNotes API 1.0 pro to search for podcasts, which is not free, so I can not expose the API key in the repo.
If you want to build the app, you need to create a new file named `.env.dart` in lib folder. Add the following code to `.env.dart` .
You can get your own API key on [ListenNotes](https://www.listennotes.com/api/), remember that you need to get pro plan API, because basic plan dosen't provide rss link for serach result. If no api key is added, the search function in the app won't work. But you can still add podcasts by using an RSS link or importing an OMPL file.

``` dart
final environment = {"apiKey":"APIKEY"};
```

4. Run the app with Android Studio or Visual Studio. Or the command line.

``` 
flutter pub get
flutter run
```

## Contribute 

If you have an issue or found a bug, please raise a GitHub issue. Pull requests are also welcome.

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
* Background task
  + workmanager

### Directory Structure

``` 
UI
src
├──home
   ├──home.dart [Homepage]
   ├──searc_podcast.dart [Search Page]
   └──playlist.dart [Playlist Page]
├──podcasts
   ├──podcast_manage.dart [Group Page]
   └──podcast_detail.dart [Podcast Page]
├──episodes
   └──episode_detail.dart [Episode Page]
├──settings
   └──setting.dart [Setting Page]

STATE
src
├──state
   ├──audio_state.dart [Audio State]
   ├──download_state.dart [Episode Download]
   ├──podcast_group.dart [Podcast Groups]
   ├──refresh_podcast.dart [Episode Refresh]
   └──setting_state.dart [Setting]

Service
src
├──service
   ├──api_service.dart [Podcast Search]
   └──ompl_builde.dart [OMPL export]
```

## Known Issue

* Playlist is unstable

## Contact

You can reach out to me directly at [tsacdop.app@gmail.com](mailto:<tsacdop.app@gmail.com>).

Or you can join our [Telegram Group](https://t.me/joinchat/Bk3LkRpTHy40QYC78PK7Qg).

## Getting Started with Flutter

This project is a starting point for a Flutter application.

Here are a few resources to get you started if this is your first Flutter project:

* [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
* [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials, samples, guidance on mobile development, and a full API reference.

[Flutter Install]: https://flutter.dev/docs/get-started/install
[tsacdop banner]: https://raw.githubusercontent.com/stonega/tsacdop/master/preview/banner.png
[build status - cirrus]: https://circleci.com/gh/stonega/tsacdop/tree/master.svg?style=shield
[github action]: https://github.com/stonega/tsacdop/workflows/Flutter%20Build/badge.svg
[github action link]: https://github.com/stonega/tsacdop/actions
[build status ]: https://circleci.com/gh/stonega/tsacdop/tree/master
[github release]: https://img.shields.io/github/v/release/stonega/tsacdop
[github release - recent]: https://github.com/stonega/tsacdop/releases
[github downloads]: https://img.shields.io/github/downloads/stonega/tsacdop/total?color=%230000d&label=downloads
[localizely]: https://img.shields.io/badge/dynamic/json?color=%2326c6da&label=localizely&query=%24.languages.length&url=https%3A%2F%2Fapi.localizely.com%2Fv1%2Fprojects%2Fbde4e9bd-4cb2-449b-9de2-18f231ddb47d%2Fstatus
[English]: https://img.shields.io/badge/dynamic/json?style=for-the-badge&color=%2323CCC6&label=English&query=%24.languages%5B3%5D.reviewedProgress&url=https%3A%2F%2Fapi.localizely.com%2Fv1%2Fprojects%2Fbde4e9bd-4cb2-449b-9de2-18f231ddb47d%2Fstatus&suffix=%
[Chinese Simplified]: https://img.shields.io/badge/dynamic/json?style=for-the-badge&color=%2323CCC6&label=Chinese%20Simplified&query=%24.languages%5B2%5D.reviewedProgress&url=https%3A%2F%2Fapi.localizely.com%2Fv1%2Fprojects%2Fbde4e9bd-4cb2-449b-9de2-18f231ddb47d%2Fstatus&suffix=%
[French]: https://img.shields.io/badge/dynamic/json?style=for-the-badge&color=%2323CCC6&label=French(ppp)&query=%24.languages%5B5%5D.reviewedProgress&url=https%3A%2F%2Fapi.localizely.com%2Fv1%2Fprojects%2Fbde4e9bd-4cb2-449b-9de2-18f231ddb47d%2Fstatus&suffix=%
[Spanish]: https://img.shields.io/badge/dynamic/json?style=for-the-badge&color=%2323CCC6&label=Spanish(Joel)&query=%24.languages%5B7%5D.reviewedProgress&url=https%3A%2F%2Fapi.localizely.com%2Fv1%2Fprojects%2Fbde4e9bd-4cb2-449b-9de2-18f231ddb47d%2Fstatus&suffix=%
[Portuguese]: https://img.shields.io/badge/dynamic/json?style=for-the-badge&color=%2323CCC6&label=portuguese(Bruno)&query=%24.languages%5B9%5D.reviewedProgress&url=https%3A%2F%2Fapi.localizely.com%2Fv1%2Fprojects%2Fbde4e9bd-4cb2-449b-9de2-18f231ddb47d%2Fstatus&suffix=%
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
