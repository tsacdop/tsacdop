import 'package:intl/intl.dart';

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
      this.imagePath
      );

  String dateToString(){
    DateTime date =  DateTime.fromMillisecondsSinceEpoch(pubDate);
    var diffrence = DateTime.now().difference(date);
    if(diffrence.inHours < 24) {
      return '${diffrence.inHours} hours ago';
    } else if (diffrence.inDays < 7){
      return '${diffrence.inDays} days ago';}
        else {
          return DateFormat.yMMMd().format( DateTime.fromMillisecondsSinceEpoch(pubDate));
        }
    }
}
