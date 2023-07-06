import 'dart:collection';

import 'package:neo_pon/models/video_resource.dart';

class Amv extends VideoResource {
  String title;
  String ref;

  Amv({
    required this.title,
    required this.ref,
  }) : super(ref, "");



  factory Amv.fromJson(Map<String, dynamic> json, { ID: "" }) {

    return Amv(
      title: json['title'],
      ref: json['ref'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'ref': ref,
    };
  }
}
