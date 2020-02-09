class EpisodeBrief {
  final String title;
  String description;
  final String pubDate;
  final int enclosureLength;
  final String enclosureUrl;
  final String feedTitle;
  final String imageUrl;
  final String primaryColor;
  final int liked;
  final String downloaded;
  final int duration;
  final int explicit;
  EpisodeBrief(
      this.title,
      this.enclosureUrl,
      this.enclosureLength,
      this.pubDate,
      this.feedTitle,
      this.imageUrl,
      this.primaryColor,
      this.liked,
      this.downloaded, 
      this.duration,
      this.explicit
      );
}
