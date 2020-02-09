import 'package:webfeed/domain/media/category.dart';
import 'package:webfeed/domain/media/community.dart';
import 'package:webfeed/domain/media/content.dart';
import 'package:webfeed/domain/media/copyright.dart';
import 'package:webfeed/domain/media/credit.dart';
import 'package:webfeed/domain/media/description.dart';
import 'package:webfeed/domain/media/embed.dart';
import 'package:webfeed/domain/media/group.dart';
import 'package:webfeed/domain/media/hash.dart';
import 'package:webfeed/domain/media/license.dart';
import 'package:webfeed/domain/media/peer_link.dart';
import 'package:webfeed/domain/media/player.dart';
import 'package:webfeed/domain/media/price.dart';
import 'package:webfeed/domain/media/rating.dart';
import 'package:webfeed/domain/media/restriction.dart';
import 'package:webfeed/domain/media/rights.dart';
import 'package:webfeed/domain/media/scene.dart';
import 'package:webfeed/domain/media/status.dart';
import 'package:webfeed/domain/media/text.dart';
import 'package:webfeed/domain/media/thumbnail.dart';
import 'package:webfeed/domain/media/title.dart';
import 'package:webfeed/util/helpers.dart';
import 'package:xml/xml.dart';

class Media {
  final Group group;
  final List<Content> contents;
  final List<Credit> credits;
  final Category category;
  final Rating rating;
  final Title title;
  final Description description;
  final String keywords;
  final List<Thumbnail> thumbnails;
  final Hash hash;
  final Player player;
  final Copyright copyright;
  final Text text;
  final Restriction restriction;
  final Community community;
  final List<String> comments;
  final Embed embed;
  final List<String> responses;
  final List<String> backLinks;
  final Status status;
  final List<Price> prices;
  final License license;
  final PeerLink peerLink;
  final Rights rights;
  final List<Scene> scenes;

  Media({
    this.group,
    this.contents,
    this.credits,
    this.category,
    this.rating,
    this.title,
    this.description,
    this.keywords,
    this.thumbnails,
    this.hash,
    this.player,
    this.copyright,
    this.text,
    this.restriction,
    this.community,
    this.comments,
    this.embed,
    this.responses,
    this.backLinks,
    this.status,
    this.prices,
    this.license,
    this.peerLink,
    this.rights,
    this.scenes,
  });

  factory Media.parse(XmlElement element) {
    return new Media(
      group: new Group.parse(
        findElementOrNull(element, "media:group"),
      ),
      contents: element.findElements("media:content").map((e) {
        return new Content.parse(e);
      }).toList(),
      credits: element.findElements("media:credit").map((e) {
        return new Credit.parse(e);
      }).toList(),
      category: new Category.parse(
        findElementOrNull(element, "media:category"),
      ),
      rating: new Rating.parse(
        findElementOrNull(element, "media:rating"),
      ),
      title: new Title.parse(
        findElementOrNull(element, "media:title"),
      ),
      description: new Description.parse(
        findElementOrNull(element, "media:description"),
      ),
      keywords: findElementOrNull(element, "media:keywords")?.text,
      thumbnails: element.findElements("media:thumbnail").map((e) {
        return new Thumbnail.parse(e);
      }).toList(),
      hash: new Hash.parse(
        findElementOrNull(element, "media:hash"),
      ),
      player: new Player.parse(
        findElementOrNull(element, "media:player"),
      ),
      copyright: new Copyright.parse(
        findElementOrNull(element, "media:copyright"),
      ),
      text: new Text.parse(
        findElementOrNull(element, "media:text"),
      ),
      restriction: new Restriction.parse(
        findElementOrNull(element, "media:restriction"),
      ),
      community: new Community.parse(
        findElementOrNull(element, "media:community"),
      ),
      comments: findElementOrNull(element, "media:comments")
              ?.findElements("media:comment")
              ?.map((e) {
            return e.text;
          })?.toList() ??
          [],
      embed: new Embed.parse(
        findElementOrNull(element, "media:embed"),
      ),
      responses: findElementOrNull(element, "media:responses")
              ?.findElements("media:response")
              ?.map((e) {
            return e.text;
          })?.toList() ??
          [],
      backLinks: findElementOrNull(element, "media:backLinks")
              ?.findElements("media:backLink")
              ?.map((e) {
            return e.text;
          })?.toList() ??
          [],
      status: new Status.parse(
        findElementOrNull(element, "media:status"),
      ),
      prices: element.findElements("media:price").map((e) {
        return new Price.parse(e);
      }).toList(),
      license: new License.parse(
        findElementOrNull(element, "media:license"),
      ),
      peerLink: new PeerLink.parse(
        findElementOrNull(element, "media:peerLink"),
      ),
      rights: new Rights.parse(
        findElementOrNull(element, "media:rights"),
      ),
      scenes: findElementOrNull(element, "media:scenes")
              ?.findElements("media:scene")
              ?.map((e) {
            return new Scene.parse(e);
          })?.toList() ??
          [],
    );
  }
}
