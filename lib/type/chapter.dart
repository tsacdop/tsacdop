class ChapterInfo {
  List<Chapters>? chapters;
  String? version;

  ChapterInfo({this.chapters, this.version});

  ChapterInfo.fromJson(Map<String, dynamic> json) {
    if (json['chapters'] != null) {
      chapters = <Chapters>[];
      json['chapters'].forEach((v) {
        chapters!.add(Chapters.fromJson(v));
      });
    }
    version = json['version'];
  }
}

class Chapters {
  String? img;
  int? startTime;
  String? title;
  String? url;

  Chapters({this.img, this.startTime, this.title, this.url});

  Chapters.fromJson(Map<String, dynamic> json) {
    img = json['img'];
    startTime = json['startTime'];
    title = json['title'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['img'] = img;
    data['startTime'] = startTime;
    data['title'] = title;
    data['url'] = url;
    return data;
  }
}
