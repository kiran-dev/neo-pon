import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

import '../models/titil.dart';
import '../models/video_resource.dart';
import '../enum_object_mapper.dart';
import '../models/arc.dart';
import '../models/profile.dart';

enum AppView { LANDSCAPE, PORTRAIT, AUTO }
enum ViewTheme { LIGHT, DARK, CUSTOM }

enum Screens {
  animeScreen,
  mangaScreen,
  snapsScreen,
  savesScreen,
  amvScreen,
  userScreen,
  playerScreen,
  arcScreen,
  homeScreen,
  readerScreen,
  downloadsScreen,
}

/// Mapping each [Screens] screen to a [String] route
class ScreensRouteMapper extends EnumStringMapper<Screens> {

  static final Map<Screens, String> _mappings = {
    Screens.animeScreen : '/anime',
    Screens.mangaScreen : '/manga',
    Screens.savesScreen : '/saves',
    Screens.snapsScreen : '/snaps',
    Screens.userScreen : '/user',
    Screens.amvScreen: '/amv',
    Screens.playerScreen: '/player',
    Screens.arcScreen: '/arcs',
    Screens.homeScreen: './home',
    Screens.readerScreen: './reader',
    Screens.downloadsScreen: './downloads',
  };

  ScreensRouteMapper() :  super(Screens.values, stringMappings: _mappings);
}

extension ScreensRouteExtension on Screens {
  String get route {
    return ScreensRouteMapper().getValue(this);
  }
}

class AppManager extends ChangeNotifier {
  Screens currentScreen = Screens.homeScreen;
  AppView currentAppView = AppView.PORTRAIT;
  ViewTheme currentTheme = ViewTheme.LIGHT;
  Titil? currentTitle;
  List<Arc>? currentArcs;
  Map<String, String> imageUrlsCache = {};
  Profile? currentProfile;
  List<VideoResource> downloadedVideos = [];

  bool isKirani() {
    return false;
  }

  void setCurrentProfile(Profile? profile) {
    currentProfile = profile;
    notifyListeners();
  }

  void toggleTheme() {
    if (currentTheme == ViewTheme.LIGHT) {
      setTheme(ViewTheme.DARK);
    } else {
      setTheme(ViewTheme.LIGHT);
    }
  }

  void setTheme(ViewTheme theme) {
    currentTheme = theme;
    notifyListeners();
  }

  void setCurrentTitle(Titil title) {
    currentTitle = title;
    notifyListeners();
  }

  void unsetTitle() {
    currentTitle = null;
  }

  void setCurrentScreen(Screens nextScreen) {
    if (currentScreen != nextScreen) {
      currentScreen = nextScreen;
      notifyListeners();
    }
  }

  void goLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    currentAppView = AppView.LANDSCAPE;
    notifyListeners();
  }

  void goPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    currentAppView = AppView.PORTRAIT;
    notifyListeners();
  }

  void addImageUrlToCache(String key, String value) {
    imageUrlsCache[key] = value;
    notifyListeners();
  }

  void readDownloadedRefs() async {
    List<String> uniquesRefs = [];
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/oott_downloads');
    if (await file.exists()) {
      List<String> downloadJsons = await file.readAsLines().catchError((err) {
        print(err);
      });
      if (downloadJsons == null || downloadJsons.isEmpty) return;

      List<VideoResource> downloads = [];
      for (String j in downloadJsons) {
        VideoResource v = VideoResource.fromJson(jsonDecode(j));
        v.isDownloaded = await DefaultCacheManager().getFileFromCache(v.ref) != null;
        if (v.isDownloaded && !uniquesRefs.contains(v.ref)) {
          downloads.add(v);
          uniquesRefs.add(v.ref);
        }
      }
      downloadedVideos = downloads;
      notifyListeners();
    }

  }

  void saveDownloadedRef(String titleName, VideoResource vR) async {
    if (isResourceDownloaded(vR.ref)) return;

    downloadedVideos.add(vR);
    notifyListeners();
    List<String> downloadJsons = [];
    downloadJsons.add(jsonEncode((vR.toJson())));
    for (VideoResource v in downloadedVideos) {
      downloadJsons.add(jsonEncode(v.toJson()));
    }

    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/oott_downloads');
    await file.writeAsString(downloadJsons.join("\n"));
  }

  bool isResourceDownloaded(String ref) {
    bool isDownloaded = false;

    for (VideoResource v in downloadedVideos) {
      if (v.ref == ref) {
        isDownloaded = true;
        break;
      }
    }
    return isDownloaded;
  }
}

