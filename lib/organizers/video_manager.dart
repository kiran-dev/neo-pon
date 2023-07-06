import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

import '../models/episode.dart';
import '../models/amv.dart';
import '../models/magnify_config.dart';
import '../models/save.dart';
import '../models/video_resource.dart';
enum CONTROLS { BASIC, FEEDBACK, RECORD, PARTY, NONE }
enum MOVE { FORWARD, BACKWARD }


class VideoManager extends ChangeNotifier {
  final Reference storageRef = FirebaseStorage.instance.ref();

  VideoResource? currentVideo;
  VideoPlayerController? controller;
  Map<String, VideoPlayerController?> momentControllers = {};

  MOVE movingDirection = MOVE.FORWARD;
  Duration moveDuration = const Duration(seconds: 0);
  bool isCurrentVideoInitialized = false;
  double playbackSpeed = 1.0;
  double playVolume = 100;
  bool isMuted = false;
  bool isRecording = false;
  bool isRecorded = false;
  bool preventDownload = false;
  bool notifyOnComplete = false;
  Map<String, DownloadProgress> currentlyDownloading = {};
  MagnifyConfig? magnifyConfigPortrait;
  MagnifyConfig? magnifyConfigLandscape;
  bool showMagnifier = false;

  // Property Methods

  String getTitle() {
    if (currentVideo == null) return "";
    if (currentVideo is Episode) {
      String eTitle = (currentVideo as Episode).title;
      return eTitle.replaceFirst(RegExp(r'! '), '!\n');
    } else if (currentVideo is Amv) {
      return (currentVideo as Amv).title;
    }
    return "";
  }

  bool isPlaying() {
    if(controller == null) return false;
    return controller!.value.isPlaying;
  }

  // bool isDownloadingNext() {
  //   if(currentVideo == null) return false;
  //   return currentVideo;
  // }

  Duration getPosition() {
    if(controller == null) return Duration.zero;
    return Duration(seconds: controller!.value.position.inSeconds);
  }

  Duration getDuration() {
    if(controller == null) return Duration.zero;
    return Duration(seconds: controller!.value.duration.inSeconds);
  }

  String getPositionString() {
    if(controller == null) return "-";
    return durationToTime(controller!.value.position);
  }

  String getDurationString() {
    if(controller == null) return "-";
    return durationToTime(controller!.value.duration);
  }

  String durationToTime(Duration duration) {
    int minutes = 0, seconds = 0;
    minutes = duration.inMinutes;
    seconds = duration.inSeconds - (60 * minutes);

    String minuteString = minutes < 10 ? "0$minutes" : "$minutes";
    String secondString = seconds < 10 ? "0$seconds" : "$seconds";

    return "$minuteString:$secondString";
  }


  // Action Methods

  void setEpisode(Episode e) {
    if (currentVideo != null && currentVideo!.isInitialized) {
      // controller?.dispose();
    }
    currentVideo = e;
    isCurrentVideoInitialized = false;
    notifyListeners();
  }

  void setAmv(Amv a) {
    currentVideo = a;
    isCurrentVideoInitialized = false;
    notifyListeners();
  }

  void downloadVideo(VideoResource videoResource, Function(String, VideoResource) saveCallback) async {
    final videoRef = storageRef.child(videoResource.ref);

    print("Loading video - $videoRef");
    videoRef.getDownloadURL().then((downloadUrl) {
      videoResource.fileStream = DefaultCacheManager().getFileStream(
        downloadUrl,
        withProgress: true,
        key: videoResource.ref
      );
      videoResource.cacheLocation = videoResource.ref;

      videoResource.fileStream!.listen((FileResponse event) {
          if (event is DownloadProgress) {
            DownloadProgress dp = event as DownloadProgress;
            videoResource.downloadProgress = dp;
            notifyListeners();
          }
        },
        onError: (Object o) {
          print("something went wrong");
        },
        onDone: () {
          videoResource.isDownloaded = true;
          saveCallback("", videoResource);
          notifyListeners();
        }
      );
    });
  }

  Future<bool> isVideoDownloaded(String ref) async {
    FileInfo? f = await DefaultCacheManager().getFileFromMemory(ref)
        .timeout(const Duration(seconds: 2800));
    if (f != null) {
      return true;
    }
    return false;
  }

  void notifyComplete() {
    preventDownload = true;
    notifyOnComplete = true;
    notifyListeners();
  }

  void initializeVideo() {
    if(currentVideo == null || !currentVideo!.isDownloaded) return;

    // controller?.dispose();
    DefaultCacheManager().getFileFromCache(currentVideo!.ref).then((fileInfo) {
      if (fileInfo != null) {
        controller = VideoPlayerController.file(fileInfo.file)..initialize().then((_) {
          controller!.setPlaybackSpeed(playbackSpeed);
          controller!.play();
          currentVideo!.isInitialized = true;
          isCurrentVideoInitialized = true;
          notifyListeners();
        });
      }
      return false;
    });
  }

  Future<bool> checkIfDownloaded(String ref) async {
    FileInfo? fileInfo = await DefaultCacheManager().getFileFromCache(ref);
    if (fileInfo != null) return true;
    return false;
  }

  void unloadVideo() {
    controller?.pause();
    // controller?.dispose();
    controller == null;
    notifyListeners();
  }

  // Player Methods



  void increaseSpeed(Function relayParty) {
    if(playbackSpeed > 2) return;
    setSpeed(playbackSpeed + 0.1, relayParty);
    notifyListeners();
  }

  void decreaseSpeed(Function relayParty) {
    if(playbackSpeed < 0.1) return;
    setSpeed(playbackSpeed - 0.1, relayParty);
    notifyListeners();
  }

  void setSpeed(double speed, Function relayParty) {
    double finalSpeed = double.parse(speed.toStringAsFixed(2));
    controller?.setPlaybackSpeed(finalSpeed).then((value) {
      playbackSpeed = finalSpeed;
      relayParty(value: finalSpeed);
      notifyListeners();
    });
  }

  void setVolume(int volume, Function relayParty) {
    if(controller == null) return;
    double finalVolume = volume / 100;
    controller!.setVolume(finalVolume).then((value) {
      playVolume = finalVolume;
      relayParty(value: finalVolume);
      notifyListeners();
    });
  }

  void toggleMute(Function relayParty) {
    double finalVolume = isMuted ? playVolume : 0;
    controller?.setVolume(finalVolume).then((value) {
      if (finalVolume == 0) {
        isMuted = true;
        playVolume = 0;
      } else {
        isMuted = false;
        playVolume = finalVolume;
      }
      relayParty(volume: playVolume);
      notifyListeners();
    });
  }

  void pauseVideo(Function relayParty) {
    if (controller == null) return;
    controller!.pause();
    relayParty(position: controller!.value.position);
    notifyListeners();
  }

  void playVideo(Function relayParty) {
    if (controller == null) return;
    controller!.play();
    relayParty(position: controller!.value.position);
    notifyListeners();
  }

  void movePositionTen(MOVE moveDirection, Function relayParty) {
    if (controller == null) return;

    if (movingDirection != moveDirection) {
      movingDirection = moveDirection;
      moveDuration = const Duration(seconds: 10);
    } else {
      moveDuration = moveDuration + const Duration(seconds: 10);
    }
    notifyListeners();

    controller!.position.then((value) {
      int positionInSeconds = value != null ? value.inSeconds : 0;
      int newPositionInSeconds = moveDirection == MOVE.FORWARD
          ? min(10 + positionInSeconds, controller!.value.duration.inSeconds)
          : max(positionInSeconds - 10, 0);
      Duration finalPosition = Duration(seconds: newPositionInSeconds);
      controller!.seekTo(finalPosition).then((value) {
        relayParty(position: finalPosition);
        moveDuration = moveDuration - const Duration(seconds: 0);
        notifyListeners();
      });
    });
  }

  void resetMoveCounter() {
    moveDuration = Duration.zero;
    notifyListeners();
  }

  void seekPosition(Duration newPosition, Function relayParty) {
    if (controller == null) return;

    controller!.seekTo(newPosition).then((value) {
      relayParty(position: newPosition);
      notifyListeners();
    });
    // notifyListeners();
  }


  void moveByDuration(MOVE direction, Duration movement, Function relayParty) {
    if (controller == null) return;
    controller!.position.then((value) {
      if (value == null) return;

      Duration newPosition = direction == MOVE.FORWARD
                    ? value + movement
                    : value - movement;
      controller!.seekTo(newPosition).then((value) {
        print(newPosition);
        relayParty(position: newPosition);
        notifyListeners();
      });
    });
    // notifyListeners();
  }

  // Magnifier methods

  MagnifyConfig? getMagnifyConfig(Orientation? o) {
    if (o == Orientation.portrait) {
      return magnifyConfigPortrait ?? magnifyConfigLandscape;
    }
    return magnifyConfigLandscape ?? magnifyConfigPortrait;
  }

  void setMagnifyConfig(Orientation o, MagnifyConfig mc, Function relayParty) {
    if (o == Orientation.portrait) {
      magnifyConfigPortrait = mc;
      // magnifyConfigLandscape ??= mc;
    } else {
      magnifyConfigLandscape = mc;
      // magnifyConfigPortrait ??= mc;
    }
    relayParty(magnifyConfig: mc);
    notifyListeners();
  }

  void setMagnifierVisible(Function relayParty) {
    showMagnifier = true;
    relayParty(magnifyConfig: magnifyConfigLandscape ?? magnifyConfigPortrait);
    notifyListeners();
  }

  void setMagnifierInvisible(Function relayParty) {
    showMagnifier = false;
    relayParty(magnifyConfig: null);
    notifyListeners();
  }

  // Recording methods
  void recordingOn(Function relayParty) {
    isRecording = true;
    notifyListeners();
  }

  void recordingOff(Function relayParty) {
    isRecording = false;
    isRecorded = false;
    notifyListeners();
  }

  void setRecorded(Save s, Function relayParty) {
    isRecorded = true;
    notifyListeners();
  }

  void deleteRecorded(Function relayParty) {
    isRecorded = false;
    notifyListeners();
  }

  // Moments methods

  setMomentController(String ID, VideoPlayerController? controller) {
    if (momentControllers[ID] != null && controller == null) {
      momentControllers[ID]?.dispose();
      momentControllers[ID] = null;
    } else {
      momentControllers[ID] = controller!;
    }
    notifyListeners();
  }

  VideoPlayerController? getMomentController(String ID) {
    return momentControllers[ID];
  }
}

