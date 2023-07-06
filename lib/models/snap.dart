import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'save.dart';

class Snap extends Save {
  String? ID;
  String? title;
  String titleID;
  String userID;
  int snapMs;
  String ref;
  int createdAt;
  MemoryImage? coverImage;

  Snap({
    this.ID,
    this.title,
    required this.titleID,
    required this.userID,
    required this.snapMs,
    required this.ref,
    required this.createdAt,
    this.coverImage
  }) : super(titleID, userID, ref, createdAt);

  factory Snap.fromJson(Map<String, dynamic> json, { ID: "" }) {
    Uint8List? imageData;
    if (json['coverImage'] != null && json['coverImage'] is String) {
      String imageString = json['coverImage'].toString();
      imageString = imageString.replaceAll('[', '').replaceAll(r']', '');
      List<int> values = imageString.split(',').map((e) => int.parse(e)).toList();
      imageData = Uint8List.fromList(values);
    }

    return Snap(
      ID: ID,
      title: json['title'],
      titleID: json['titleID'],
      userID: json['userID'],
      snapMs: json['snapMs'],
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
      'snapMs': snapMs,
      'ref': ref,
      'createdAt': createdAt,
      'coverImage': coverImage != null ? '[${coverImage!.bytes.join(",")}]' : null
    };
  }
}
