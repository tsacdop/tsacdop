class SubHistory {
  /// POdcast subscribe date.
  DateTime subDate;

  /// Podcast remove date.
  DateTime delDate;

  /// If podcast still on user device.
  bool status;

  /// POdcast title.
  String title;

  /// POdcast rss link.
  String rssUrl;

  SubHistory(this.status, this.delDate, this.subDate, this.rssUrl, this.title);
}
