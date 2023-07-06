import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../models/moment.dart';
import '../../organizers/video_manager.dart';

class MomentPlayer extends StatefulWidget {
  Moment currentMoment;

  MomentPlayer({Key? key, required this.currentMoment}) : super(key: key);

  @override
  State<MomentPlayer> createState() => _MomentPlayerState();
}


class _MomentPlayerState extends State<MomentPlayer> {
  final Reference storageRef = FirebaseStorage.instance.ref();
  VideoPlayerController? controller;
  Timer? timeChecker;
  bool pausedPlaying = false;

  @override
  void initState() {
    initializeMoment();
    timeChecker = Timer.periodic(const Duration(milliseconds: 77), (timer) {
      if (controller == null || !controller!.value.isInitialized) return;
      int currentMs = controller!.value.position.inMilliseconds;
      if (currentMs > widget.currentMoment.endMs || currentMs < widget.currentMoment.startMs) {
        controller!.pause().then((value) {
          controller!.seekTo(Duration(milliseconds: widget.currentMoment.startMs)).then((value) {
            controller!.play();
          });
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    timeChecker?.cancel();
    controller!.pause();
    super.dispose();
  }

  void initializeMoment() async {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
    if (videoManager.getMomentController(widget.currentMoment.ID!) != null) {
      setState(() {
        controller = videoManager.getMomentController(widget.currentMoment.ID!)!;
      });
    } else {
      final videoRef = storageRef.child(widget.currentMoment.ref);
      String videoURL = await videoRef.getDownloadURL();
      VideoPlayerController newController = VideoPlayerController.network(videoURL);
      await newController.initialize();
      await newController.seekTo(Duration(milliseconds: widget.currentMoment.startMs));
      videoManager.setMomentController(widget.currentMoment.ID!, newController);
      setState(() {
        controller = newController;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      // initializeMoment();

      return Container(
          // color: Theme.of(context).canvasColor,
          child: Center(
            child: Text("Loading...",
              style: GoogleFonts.voltaire(
                textStyle: Theme.of(context).textTheme.titleLarge,
                color: Theme.of(context).shadowColor,
              ),
            ),
          )
      );
    }

    if (!pausedPlaying && controller!.value.isInitialized && !controller!.value.isPlaying) {
      controller!.play();
    }

    return GestureDetector(
      onTap: () {
        if (controller == null) return;
        pausedPlaying ? controller!.play() : controller!.pause();
        setState(() {
          pausedPlaying = !pausedPlaying;
        });
      },
      child: Container(
        color: Theme.of(context).canvasColor,
        child: OrientationBuilder(
            builder: (context, o) {

              return Center(
                  child: AspectRatio(
                    aspectRatio: controller!.value.aspectRatio ?? 1,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        VideoPlayer(controller!, key: Key(widget.currentMoment.ID!),),
                        if (pausedPlaying)
                          Center(
                            child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Theme.of(context).shadowColor)
                                    ]
                                ),
                                child: Icon(Icons.play_arrow, size: 128,)),
                          ),
                      ],
                    ),
                  )
              );
            }
        ),
      ),
    );

  }
}
