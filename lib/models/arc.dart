import 'dart:ffi';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:neo_pon/models/manga.dart';

class Arc {
  String ID;
  String name;
  int from;
  int to;
  String imageRef;
  int order;
  String titleID;
  ImageResource? _imageResource;


  Arc({
    required this.ID,
    required this.name,
    required this.from,
    required this.to,
    required this.imageRef,
    required this.order,
    required this.titleID,
  });

  final Reference storageRef = FirebaseStorage.instance.ref();

  ImageResource getImageResource() {
    ImageResource imageResource = ImageResource(ref: storageRef.child(imageRef), cacheLocation: imageRef);
    _imageResource ??= _imageResource;
    return imageResource;
  }

  factory Arc.fromJson(Map<String, dynamic> json, { ID: "" }) {
    return Arc(
      ID: ID,
      name: json['name'],
      from: json['from'],
      to: json['to'],
      imageRef: json['imageRef'],
      order: json['order'],
      titleID: json['titleID'],
      // arcImage: ImageResource(ref: storageRef.child(json['imageRef'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'from': from,
      'to': to,
      'order': order,
      'imageRef': imageRef,
      'titleID': titleID,
    };
  }
}

class ArcLayoutConfig {
  int arcOrder;
  double mainAxisScale;
  double crossAxisFraction;

  ArcLayoutConfig({
    required this.arcOrder,
    required this.mainAxisScale,
    required this.crossAxisFraction,
  });


  factory ArcLayoutConfig.fromJson(Map<String, dynamic> json, { ID: "" }) {
    return ArcLayoutConfig(
      arcOrder: json['aO'],
      mainAxisScale: double.parse(json['mAS'].toString()),
      crossAxisFraction: double.parse(json['cAF'].toString()) ,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aO': arcOrder,
      'mAS': mainAxisScale,
      'cAF': crossAxisFraction,
    };
  }
}
