class PodcastLocal {
  final String title;
  final String imageUrl;
  final String rssUrl;
  final String author;
 
  final String primaryColor;
  final String id;
  final String imagePath;
  final String provider;
  final String link;

  final String description;
  final int upateCount;
  PodcastLocal(
      this.title,
      this.imageUrl,
      this.rssUrl,
      this.primaryColor,
      this.author,
      this.id,
      this.imagePath,
      this.provider,
      this.link,
      {
        this.description ='',
        this.upateCount = 0,
      }
      );
}
