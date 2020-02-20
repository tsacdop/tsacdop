
import 'package:uuid/uuid.dart';

class PodcastLocal {
  final String title;
  final String imageUrl;
  final String rssUrl;
  final String author;
  String description;
  final String primaryColor;
  final String id; 
  PodcastLocal(this.title, this.imageUrl, this.rssUrl, this.primaryColor, this.author,{String id}) : id = id ?? Uuid().v4();
}

