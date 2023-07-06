
import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:neo_pon/models/amv.dart';
import 'package:neo_pon/models/episode.dart';

class VideoResource {
  String ref;
  String titleID;
  String? cacheLocation;
  Stream<FileResponse>? fileStream;
  bool isDownloaded = false;
  bool isInitialized = false;
  DownloadProgress? downloadProgress;

  VideoResource(this.ref, this.titleID);

  factory VideoResource.fromJson(Map<String, dynamic> json) {
    try {
      return Episode.fromJson(json);
    } catch (e) {
      return Amv.fromJson(json);
    }
  }

  Map<String, dynamic> toJson() {
    if (this is Episode) {
      return (this as Episode).toJson();
    } else if (this is Amv) {
      return (this as Amv).toJson();
    } else {
      return {};
    }
  }
}
