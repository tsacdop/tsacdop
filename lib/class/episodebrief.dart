import 'package:intl/intl.dart';
import 'package:audio_service/audio_service.dart';

class EpisodeBrief {
  final String title;
  String description;
  final int pubDate;
  final int enclosureLength;
  final String enclosureUrl;
  final String feedTitle;
  final String primaryColor;
  final int liked;
  final String downloaded;
  final int duration;
  final int explicit;
  final String imagePath;
  final String mediaId;
  final int isNew;
  final int skipSeconds;
  EpisodeBrief(
      this.title,
      this.enclosureUrl,
      this.enclosureLength,
      this.pubDate,
      this.feedTitle,
      this.primaryColor,
      this.liked,
      this.downloaded,
      this.duration,
      this.explicit,
      this.imagePath,
      this.mediaId,
      this.isNew,
      this.skipSeconds);

  String dateToString() {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(pubDate,isUtc: true);
    var diffrence = DateTime.now().toUtc().difference(date);
    if (diffrence.inHours < 1) {
      return '1 hour ago';
    } else if (diffrence.inHours < 24) {
      return '${diffrence.inHours} hours ago';
    } else if (diffrence.inHours == 24) {
      return '1 day ago';
    } else if (diffrence.inDays < 7) {
      return '${diffrence.inDays} days ago';
    } else {
      return DateFormat.yMMMd().format(
          DateTime.fromMillisecondsSinceEpoch(pubDate, isUtc: true).toLocal());
    }
  }

  MediaItem toMediaItem() {
    return MediaItem(
        id: mediaId,
        title: title,
        artist: feedTitle,
        album: feedTitle,
        artUri: 'file://$imagePath',
        extras: {'skip': skipSeconds});
  }
}
