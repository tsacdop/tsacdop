## [5.0.0] - 2023-05-15

- Upgrade to Dart 3
- Merge Add Origin Text ([#47](https://github.com/Cretezy/linkify/pull/47))
- Merge Support UserTagLinkifier on Safari ([#48](https://github.com/Cretezy/linkify/pull/48))
- Merge Add quotation marks to loose url regex ([#50](https://github.com/Cretezy/linkify/pull/50))
- Merge Remove `pubspec.lock` from `.gitignore` ([#51](https://github.com/Cretezy/linkify/pull/51))
- Merge Support UserTagLinkifier on Safari ([#52](https://github.com/Cretezy/linkify/pull/52))

## [4.1.0] - 2021-08-02

- Fix loose URL not being parsed if the text have a non loose URL ([#42](https://github.com/Cretezy/linkify/pull/42), thanks [@EsteveAguilera](https://github.com/EsteveAguilera)!)
- User Tagging Linkifier ([#38](https://github.com/Cretezy/linkify/pull/38), thanks [@HSCOGT](https://github.com/HSCOGT)!)

## [4.0.0] - 2021-03-04

- Add null-safety support. Now required Dart >=2.12

## [3.0.0] - 2020-11-05

- Expand parsing to `www.` URLs ([#21](https://github.com/Cretezy/linkify/pull/21), thanks [@SpencerLindemuth](https://github.com/SpencerLindemuth)!)
- Add `\r` parsing, requires Dart >=2.4 ([#26](https://github.com/Cretezy/linkify/pull/26), thanks [@hpoul](https://github.com/hpoul)!)
- Update loose URL regex to make it more reliable (thanks for [the suggestion](https://github.com/Cretezy/linkify/issues/19#issuecomment-640587130) [@olestole](https://github.com/olestole)!)

**Major version has been bumped**:

- Minimum Dart version was upgraded
- Loose URL regex update may change behavior for some use-cases. Please open an issue if you find more issues!
- Non-loose will now parse URLs starting with `www.`, changing behavior

## [2.1.0] - 2020-04-24

- Add loose URL option (`looseUrl`)
  - Parses any URL containing `.`
  - Defaults to `http` URLs. Can use `https` by enabling the `defaultToHttps` option
- Added `www.` removal (`removeWww`)
  - Removes URLs prefixed with `www.`
- Added exclusion of last period (`excludeLastPeriod`, enabled by default)
  - Parses `https://example.com.` as `https://example.com`

## [2.0.3] - 2020-01-08

- Fix more minor lint issues
- Remove extra `print`

## [2.0.2] - 2019-12-30

- Fix minor lint issues

## [2.0.1] - 2019-12-27

- Export `defaultLinkifiers`

## [2.0.0] - 2019-12-27

- Change `LinkTypes` to `Linkifier`
  - Supports custom linkifiers
- Change `LinkElement` to `UrlElement` to better reflect `UrlLinkifier` (link != URL)
- Change `humanize` option to `LinkifyOptions`
- Enabled `humanize` by default

## [1.0.1] - 2019-03-23

- Republish to fix maintenance score

## [1.0.0] - 2019-03-23

- Initial release
