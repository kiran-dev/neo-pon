
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class Manga {
  String title;
  String? airDate;
  int number;
  String ref;
  List<ImageResource> pages = [];


  Manga({
    required this.title,
    this.airDate,
    required this.number,
    required this.ref,
    required this.pages
  });

}

class ImageResource {
  Reference ref;
  String cacheLocation;

  ImageResource({ required this.ref, required this.cacheLocation });

  String getCacheLocation() {
    return ref.name;
  }

  Future<FileImage?> getImage() async {
    try {
      FileInfo? fileInfo = await DefaultCacheManager().getFileFromCache(cacheLocation);
      if (fileInfo == null) {
        String downloadUrl = await ref.getDownloadURL();
        return FileImage(await DefaultCacheManager().getSingleFile(downloadUrl, key: cacheLocation));
      } else {
        return FileImage(fileInfo!.file);
      }
    } catch (error) {
      print("Error fetching ref: $ref");
      print(error.toString());
    }
  }

}
