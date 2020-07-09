[![Tsacdop Banner][]][google play]

[![Build Status - Cirrus][]][build status]
[![GitHub Release][]][github release - recent]
[![Github Downloads][]][github release - recent]
[![Localizely][]][localizely - website]

## About

Enjoy podcast with Tsacdop.

Tsacdop is a podcast player developed with flutter, a clean, simply beautiful and friendly app, and is free and open source.

Credit to flutter team and all involved plugins, especially [webfeed](https://github.com/witochandra/webfeed) and [Just_Audio](https://pub.dev/packages/just_audio).

The podcasts search engine is powered by [ListenNotes](https://listennotes.com).

## Features

* Podcasts group management
* Playlist support
* Sleep timer / Speed setting
* OMPL file export and import
* Auto syncing in background
* Listen and subscribe history record
* Dark mode / Accent color
* Download for offline playing
* Auto download new episodes / Auto delete outdated downloads

More to come...

## Preview

| HomePage                                                                                                         | Group                                                                                                          | Podcast                                                                                                         | Episode                                                                                                         | DarkMode                                                                                                         |
| ---------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
|![][Homepage ScreenShot]|![][Group Screenshot] | ![][Podcast Screenshot] | ![][Episode Screenshot]| ![][Darkmode Screenshot] |

## Localization

Support languages

* English
* Chinese Simplified (beta)

Please [Email](mailto:<tsacdop.app@gmail.com>) me you'd like to contribute to support more languages!

Credit to [Localizely](https://localizely.com/) for kind support to open source project.

## License

Tsacdop is licensed under the [GPL V3.0](https://github.com/stonega/tsacdop/blob/master/LICENSE) license.

## Build

Tsacdop is using ListenNotes api 1.0 pro to search podcast, which is not free. So I can not expose the api key in the repo.
If you want to build the app, you need to create a new file named .env.dart in lib folder. Add below code in .env.dart.

``` dart
final environment = {"apiKey":"APIKEY"};
```

You can get own api key on [ListenNotes](https://www.listennotes.com/api/), basic plan is free to all, and replace "APIKEY" with it.
If no api key added, the search function in the app won't work. But you can still add podcasts by serach rss link or import ompl file.

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
   ├──addpodcast.dart [Search Page]
   ├──playlist.dart [Playlist Page]
├──podcasts
   ├──podcast_manage.dart [Group Page]
   ├──podcast_detail.dart [Podcast Page]
├──episodes
   ├──episode_detail.dart [Episode Page]
├──settings
   ├──setting.dart [Setting Page]

STATES
src
├──state
   ├──audio_state.dart [Audio State]
   ├──download_state.dart [Episode Download]
   ├──podcast_group.dart [Podcast Groups]
   ├──refresh_podcast.dart [Episode Refresh]
   ├──setting_state.dart [Setting]
   ├──subscribe_podcast.dart [Podcast Subscribe]
```

## Known Issue

* Playlist unstable

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

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
[localizely - website]: https://localizely.com/
[google play - icon]: https://img.shields.io/badge/google-playStore-%2323CCC6
[google play]: https://play.google.com/store/apps/details?id=com.stonegate.tsacdop
[Homepage ScreenShot]: https://raw.githubusercontent.com/stonega/tsacdop/master/preview/1585893838840.png
[Group Screenshot]: https://raw.githubusercontent.com/stonega/tsacdop/master/preview/1585894051734.png
[Podcast Screenshot]: https://raw.githubusercontent.com/stonega/tsacdop/master/preview/1585893877702.png
[Episode Screenshot]: https://raw.githubusercontent.com/stonega/tsacdop/master/preview/1585896237809.png
[Darkmode Screenshot]: https://raw.githubusercontent.com/stonega/tsacdop/master/preview/1585893920721.png
