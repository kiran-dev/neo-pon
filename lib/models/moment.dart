import 'dart:typed_data';
import 'package:flutter/cupertino.dart';

import 'save.dart';

class Moment extends Save {
  String? ID;
  String titleID;
  String? title;
  String userID;
  int startMs;
  int endMs;
  String ref;
  int createdAt;
  MemoryImage? coverImage;

  Moment({
    this.ID,
    required this.titleID,
    this.title,
    required this.userID,
    required this.startMs,
    required this.endMs,
    required this.ref,
    required this.createdAt,
    this.coverImage
  }) : super(titleID, userID, ref, createdAt);

  factory Moment.fromJson(Map<String, dynamic> json, { ID: "" }) {
    Uint8List? imageData;
    if (json['coverImage'] != null && json['coverImage'] is String) {
      String imageString = json['coverImage'].toString();
      imageString = imageString.replaceAll('[', '').replaceAll(r']', '');
      List<int> values = imageString.split(',').map((e) => int.parse(e)).toList();
      imageData = Uint8List.fromList(values);
    }

    return Moment(
      ID: ID,
      titleID: json['titleID'],
      title: json['title'],
      userID: json['userID'],
      startMs: json['startMs'],
      endMs: json['endMs'],
      ref: json['ref'],
      createdAt: json['createdAt'],
      coverImage: imageData != null ? MemoryImage(imageData) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'titleID': titleID,
      'userID': userID,
      'startMs': startMs,
      'endMs': endMs,
      'ref': ref,
      'createdAt': createdAt,
      'coverImage': coverImage != null ? '[${coverImage!.bytes.join(",")}]' : null
    };
  }
}
