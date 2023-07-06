import 'package:neo_pon/models/video_resource.dart';

class Episode extends VideoResource {
  String title;
  String? airDate;
  int episodeNumber;
  String ref;
  Episode? nextEpisode;
  String titleID;
  String arcID;
  String? ID;

  Episode({
    required this.ID,
    required this.title,
    this.airDate,
    required this.episodeNumber,
    required this.ref,
    required this.titleID,
    required this.arcID
  }) : super(ref, titleID);



  factory Episode.fromJson(Map<String, dynamic> json, { ID: "" }) {

    return Episode(
      title: json['title'],
      airDate: json['airDate'],
      episodeNumber: json['episodeNumber'],
      ref: json['ref'],
      arcID: json['arcID'],
      titleID: json['titleID'],
      ID: ID,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'airDate': airDate,
      'episodeNumber': episodeNumber,
      'ref': ref,
      'arcID': arcID,
      'titleID': titleID
    };
  }
}
