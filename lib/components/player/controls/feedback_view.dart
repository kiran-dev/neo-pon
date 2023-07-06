import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neo_pon/organizers/video_manager.dart';
import 'package:provider/provider.dart';


class FeedbackView extends StatelessWidget {
  const FeedbackView({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: true);
    if (videoManager.isRecording && !videoManager.isRecorded) {
      return const RecordingDisplay();
    }

    return const ActionDisplay();
  }
}

class RecordingDisplay extends StatefulWidget {

  const RecordingDisplay({Key? key}) : super(key: key);

  @override
  State<RecordingDisplay> createState() => _RecordingDisplayState();
}

class _RecordingDisplayState extends State<RecordingDisplay> with TickerProviderStateMixin {
  late Timer refreshTimer;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
    videoManager.controller!.position.then((value) {
      if (value == null) return;
      int seconds = value!.inSeconds;
      int milliseconds = value!.inMilliseconds - (value!.inSeconds * 1000);
      double offset = 128 + (seconds * 111) + (milliseconds / 10);
      if (offset < 256) offset = offset - 128;
      scrollController.jumpTo(offset);
    });
    refreshTimer = Timer.periodic(const Duration(milliseconds: 143), (timer) {
      if (!mounted) return;
      videoManager.controller!.position.then((value) {
        if (value == null) return;
        int seconds = value!.inSeconds;
        int milliseconds = value!.inMilliseconds - (value!.inSeconds * 1000);
        double offset = 128 + (seconds * 111) + (milliseconds * 100/1000);
        if (offset < 256) offset = offset - 128;
        scrollController.animateTo(offset,
            duration: const Duration(milliseconds: 143),
            curve: Curves.linear
        );
      });

    });
    super.initState();
  }

  @override
  void dispose() {
    refreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.camera_outlined,
            size: 128,
            color: Theme.of(context).shadowColor,
          ),
          Positioned(
            bottom: -111,
            left: -64,
            child: Container(
              height: 91,
              width: 256,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                        blurStyle: BlurStyle.outer,
                        color: Theme.of(context).primaryColor,
                        blurRadius: 28
                    )
                  ]
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                controller: scrollController,
                child: const TimeLine(),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TimeLine extends StatelessWidget {
  const TimeLine({Key? key}) : super(key: key);

  Widget buildMinute(BuildContext context, int minute, int numberOfSeconds) {
    return SizedBox(
      width: (111 * numberOfSeconds).toDouble(),
      height: 7,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          for (int i = 0; i < numberOfSeconds; i++)
            Positioned(
              top: 28,
              left: (i * 111) - 17,
              child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                  decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      borderRadius: BorderRadius.circular(7)
                  ),
                  child: Center(
                      child: Text("$minute:${i < 10 ? '0$i' : i}",
                        style: GoogleFonts.voltaire(
                            textStyle: Theme.of(context).textTheme.labelSmall,
                            color: Theme.of(context).primaryColor
                        ),
                      )
                  )
              ),
            ),
          for (int i = 0; i < numberOfSeconds; i++)
            Positioned(
              left: (i * 111) + 28,
              bottom: 0,
              child: Container(
                height: 22,
                width: 2,
                decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor,
                      blurRadius: 7
                    )
                  ]
                ),
              ),
            ),
          for (int i = 0; i < numberOfSeconds; i++)
            Positioned(
              left: (i * 111) + 56,
              top: 0,
              child: Container(
                height: 37,
                width: 3,
                decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context).primaryColor,
                          blurRadius: 7
                      )
                    ]
                ),
              ),
            ),
          for (int i = 0; i < numberOfSeconds; i++)
            Positioned(
              left: (i * 111) + 84,
              bottom: 0,
              child: Container(
                height: 22,
                width: 2,
                decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context).primaryColor,
                          blurRadius: 7
                      )
                    ]
                ),
              ),
            ),
          Container(
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }


  List<Widget> buildTimeLine(BuildContext context, int videoDuration) {
    List<Widget> timeline = [];

    timeline.add(const SizedBox(width: 128,),);
    for (int i = 0; i < videoDuration ~/ 60; i++) {
      timeline.add(buildMinute(context,
          i,
          (videoDuration - i*60).clamp(0, 60)
      ));
    }
    if (videoDuration % 60 > 0) {
      timeline.add(buildMinute(context,
          (videoDuration ~/ 60),
          (videoDuration % 60) + 1
      ));
    }
    timeline.add(const SizedBox(width: 256,),);
    return timeline;
  }

  @override
  Widget build(BuildContext context) {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: buildTimeLine(context, videoManager.controller!.value.duration.inSeconds),
    );

  }

}


class ActionDisplay extends StatefulWidget {

  const ActionDisplay({Key? key}) : super(key: key);

  @override
  State<ActionDisplay> createState() => _ActionDisplayState();
}

class _ActionDisplayState extends State<ActionDisplay> with TickerProviderStateMixin {
  Animation<double>? controller;

  @override
  Widget build(BuildContext context) {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: true);
    Duration movingDuration = videoManager.moveDuration;
    if (movingDuration == Duration.zero) {
      setState(() {
        controller = null;
      });
    } else {
      Duration currentPosition = videoManager.controller!.value.position;
      Duration videoDuration = videoManager.controller!.value.duration;
      Duration finalPosition = videoManager.movingDirection == MOVE.FORWARD
          ? currentPosition + videoManager.moveDuration
          : currentPosition - videoManager.moveDuration;
      setState(() {
        controller = Tween<double>(
          begin: currentPosition.inSeconds / videoDuration.inSeconds,
          end: finalPosition.inSeconds / videoDuration.inSeconds,
        ).animate(AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1700),
        ));
      });
    }

    if (controller?.isCompleted ?? true) {
      return Container();
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 244,
            width: 244,
            child: CircularProgressIndicator(
              value: controller!.value,
              strokeWidth: 14,
              color: Theme.of(context).shadowColor,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).primaryColor,
                      blurRadius: 28,
                      blurStyle: BlurStyle.outer
                  )
                ]
            ),
            width: 257, height: 257,
            child: (() {
              if (videoManager.movingDirection == MOVE.FORWARD) {
                return Center(
                  child: Icon(Icons.fast_forward_outlined,
                    size: 128,
                    color: Theme.of(context).shadowColor,
                    shadows: [
                      Shadow(
                          color: Theme.of(context).primaryColor,
                          blurRadius: 1
                      )
                    ],
                  ),
                );
              } else if (videoManager.movingDirection == MOVE.BACKWARD) {
                return Center(
                  child: Icon(Icons.fast_rewind_outlined,
                    size: 128,
                    color: Theme.of(context).shadowColor,
                    shadows: [
                      Shadow(
                          color: Theme.of(context).primaryColor,
                          blurRadius: 1
                      )
                    ],
                  ),
                );
              }

              return Container();
            })(),
          ),
        ],
      ),
    );
  }
}