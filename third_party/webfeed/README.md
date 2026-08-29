# WebFeed

[![Build Status](https://travis-ci.org/witochandra/webfeed.svg?branch=master)](https://travis-ci.org/witochandra/webfeed)
[![Pub](https://img.shields.io/pub/v/webfeed.svg)](https://pub.dartlang.org/packages/webfeed)

A dart package for parsing RSS and Atom feed.

### Features

- [x] RSS
- [x] Atom
- [x] Namespaces
    - [x] Media RSS
    - [x] Dublin Core

### Installing

Add this line into your `pubspec.yaml`
```
webfeed: ^0.4.2
```

Import the package into your dart code using:
```
import 'package:webfeed/webfeed.dart';
```

### Example

To parse string into `RssFeed` object use:
```
var rssFeed = new RssFeed.parse(xmlString); // for parsing RSS feed
var atomFeed = new AtomFeed.parse(xmlString); // for parsing Atom feed
```

### Preview

**RSS**
```
feed.title
feed.description
feed.link
feed.author
feed.items
feed.image
feed.cloud
feed.categories
feed.skipDays
feed.skipHours
feed.lastBuildDate
feed.language
feed.generator
feed.copyright
feed.docs
feed.managingEditor
feed.rating
feed.webMaster
feed.ttl
feed.dc

RssItem item = feed.items.first;
item.title
item.description
item.link
item.categories
item.guid
item.pubDate
item.author
item.comments
item.source
item.media
item.enclosure
item.dc
```

**Atom**
```
feed.id
feed.title
feed.updated
feed.items
feed.links
feed.authors
feed.contributors
feed.categories
feed.generator
feed.icon
feed.logo
feed.rights
feed.subtitle

AtomItem item = feed.items.first;
item.id
item.title
item.updated
item.authors
item.links
item.categories
item.contributors
item.source
item.published
item.content
item.summary
item.rights
item.media
```

## License

WebFeed is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
