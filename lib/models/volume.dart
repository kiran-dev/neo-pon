import 'package:firebase_storage/firebase_storage.dart';
import 'package:neo_pon/models/manga.dart';

class Volume {
  List<Chapter> chapters;
  String? imageRef;
  String name;
  String ID;
  String titleID;
  int order;

  ImageResource? _imageResource;

  Volume({
    required this.ID,
    required this.name,
    required this.chapters,
    this.imageRef,
    required this.order,
    required this.titleID,
  }) : super();

  final Reference storageRef = FirebaseStorage.instance.ref();

  ImageResource getImageResource() {
    ImageResource imageResource = ImageResource(ref: storageRef.child(imageRef ?? ""), cacheLocation: imageRef ?? "");
    _imageResource ??= _imageResource;
    return imageResource;
  }

  factory Volume.fromJson(Map<String, dynamic> json, { ID: "" }) {
    List<Chapter> chapters = [];
    if (json['chapters'] != null) {
      List<Map<String, dynamic>> chaptersList = List<Map<String, dynamic>>.from(json['chapters']);
      for (Map<String, dynamic> map in chaptersList) {
        chapters.add(Chapter.fromJson(map));
      }
    }
    return Volume(
        ID: ID,
        imageRef: json['imageRef'] ?? "",
        order: json['order'],
        name: json['name'],
        titleID: json['titleID'],
        chapters: chapters,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      // 'thumbnailRef': thumbnailRef,
      'titleID': titleID,
      'order': order,
      'chapters': chapters,
    };
  }
}

class Chapter {
  String name;
  int number;
  String ref;

  Chapter({
    required this.name,
    required this.ref,
    required this.number,
  }) : super();

  factory Chapter.fromJson(Map<String, dynamic> json, { ID: "" }) {

    return Chapter(
      ref: json['ref'],
      name: json['name'],
      number: json['number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': number,
      'ref': ref,
    };
  }
}