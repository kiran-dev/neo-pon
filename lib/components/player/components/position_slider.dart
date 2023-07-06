import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../../organizers/video_manager.dart';
import '../../../models/video_action.dart';
import '../../../organizers/party_manager.dart';

class PositionSlider extends StatefulWidget {
  Function stopFade;
  Function startFade;
  PositionSlider({Key? key, required this.startFade, required this.stopFade }) : super(key: key);


  @override
  State<PositionSlider> createState() => _PositionSliderState();
}

class _PositionSliderState extends State<PositionSlider> {
  String progressInString = "- / -";
  Timer? timer;
  double previousAngle = 0;
  double currentAngle = 0;
  bool stoppedByRotation = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  String moveString = "";

  @override
  void initState() {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
    PartyManager partyManager = Provider.of<PartyManager>(context, listen: false);
    progressInString = "${videoManager.getPositionString()} / ${videoManager.getDurationString()}";
    timer = Timer.periodic(const Duration(milliseconds: 72), (Timer t) {
      if (!mounted) return;

      double panRotation;
      if (currentAngle > 0 && previousAngle < 0) {
        double d1 = currentAngle > 88 ? 180 - currentAngle.abs() : currentAngle.abs();
        double d2 = previousAngle < -88 ? 180 - previousAngle.abs() : previousAngle.abs();
        int sign = previousAngle > -88 ? 1 : -1;
        panRotation = sign * (d1 + d2).clamp(-47, 47);
      } else if (currentAngle < 0 && previousAngle > 0) {
        double d1 = previousAngle > 88 ? 180 - previousAngle.abs() : previousAngle.abs();
        double d2 = currentAngle < -88 ? 180 - currentAngle.abs() : currentAngle.abs();
        int sign = previousAngle > 88 ? 1 : -1;
        panRotation = sign * (d1 + d2).clamp(-47, 47);
      } else {
        panRotation = (currentAngle.abs() - previousAngle.abs()).clamp(-47, 47);
      }

      // panRotation = (d1-d2).clamp(-49, 49);

      if (panRotation.abs() > 29) {
        int seconds = panRotation.abs() ~/ 7;
        videoManager.moveByDuration(
            panRotation > 0 ? MOVE.FORWARD : MOVE.BACKWARD,
            Duration(seconds: seconds),
                ({position}) {
              partyManager.addAction(VideoAction(
                  action: panRotation > 0 ? VAction.FORWARD : VAction.BACKWARD,
                  position: position,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                  userID: auth.currentUser!.uid
              ));
            }
        );
      } else if (panRotation.abs() > 17) {
        int seconds = panRotation.abs() ~/ 4;
        // if (videoManager.isPlaying()) videoManager.pauseVideo();
        videoManager.moveByDuration(
            panRotation > 0 ? MOVE.FORWARD : MOVE.BACKWARD,
            Duration(seconds: seconds),
            ({position}) {
              partyManager.addAction(VideoAction(
                  action: panRotation > 0 ? VAction.FORWARD : VAction.BACKWARD,
                  position: position,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                  userID: auth.currentUser!.uid
              ));
            }
        );
      } else if (panRotation.abs() > 4) {
        int seconds = panRotation.abs() ~/ 2;
        int milliSeconds = ((panRotation.abs() - seconds) * 1000).toInt();
        // if (videoManager.isPlaying()) videoManager.pauseVideo();
        videoManager.moveByDuration(
            panRotation > 0 ? MOVE.FORWARD : MOVE.BACKWARD,
            Duration(seconds: seconds, milliseconds: milliSeconds),
            ({position}) {
              partyManager.addAction(VideoAction(
                  action: panRotation > 0 ? VAction.FORWARD : VAction.BACKWARD,
                  position: position,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                  userID: auth.currentUser!.uid
              ));
            }
        );
      } else if (panRotation.abs() > 1) {
        int milliSeconds = (panRotation.abs() * 128).toInt();
        // .;
        videoManager.moveByDuration(
            panRotation > 0 ? MOVE.FORWARD : MOVE.BACKWARD,
            Duration(milliseconds: milliSeconds),
                ({position}) {
              partyManager.addAction(VideoAction(
                  action: panRotation > 0 ? VAction.FORWARD : VAction.BACKWARD,
                  position: position,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                  userID: auth.currentUser!.uid
              ));
            }
        );
      }

      setState(() {
        progressInString = "${videoManager.getPositionString()} / ${videoManager.getDurationString()}";
        previousAngle = currentAngle;
      });

      if (panRotation == 0 && stoppedByRotation && !videoManager.isPlaying()) {
        videoManager.playVideo(({position}) {
          partyManager.addAction(VideoAction(
              action: VAction.PLAY,
              position: position,
              timestamp: DateTime.now().millisecondsSinceEpoch,
              userID: auth.currentUser!.uid
          ));
        });
      } else if (panRotation != 0 && videoManager.isPlaying()) {
        videoManager.pauseVideo(({position}) {
          partyManager.addAction(VideoAction(
              action: VAction.PAUSE,
              position: position,
              timestamp: DateTime.now().millisecondsSinceEpoch,
              userID: auth.currentUser!.uid
          ));
        });
        setState(() {
          stoppedByRotation = true;
        });
      }
    });
    // widget.startFade();
    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) timer!.cancel();
    super.dispose();
  }

  Widget buildPlayControl() {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
    PartyManager partyManager = Provider.of<PartyManager>(context, listen: false);
    return GestureDetector(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              videoManager.isPlaying() ? Icons.pause : Icons.play_arrow,
              size: 128,
              color: Theme.of(context).primaryColor,
              shadows: [
                Shadow(
                  blurRadius: 28.0,
                  color: Theme.of(context).shadowColor,
                  // offset: Offset(5.0, 5.0),
                )
              ],
            ),
            Text(progressInString,
              style: GoogleFonts.voltaire(
                color: Theme.of(context).primaryColor,
                fontSize: 20,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Theme.of(context).shadowColor,
                    // offset: Offset(5.0, 5.0),
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          videoManager.isPlaying()
              ? videoManager.pauseVideo(({position}) {
                  partyManager.addAction(VideoAction(
                      action: VAction.PAUSE,
                      position: position,
                      timestamp: DateTime.now().millisecondsSinceEpoch,
                      userID: auth.currentUser!.uid
                  ));
              })
              : videoManager.playVideo(({position}) {
                  partyManager.addAction(VideoAction(
                      action: VAction.PAUSE,
                      position: position,
                      timestamp: DateTime.now().millisecondsSinceEpoch,
                      userID: auth.currentUser!.uid
                  ));
              });
          widget.startFade();
          setState(() {
            stoppedByRotation = false;
          });
        }
    );
  }

  Widget buildSlider(double ss) {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
    PartyManager partyManager = Provider.of<PartyManager>(context, listen: false);
    // Size boxSize = MediaQuery.of(context).size;
    return SleekCircularSlider(
      appearance: CircularSliderAppearance(
          size: ss,
          angleRange: 170,
          startAngle: 280,
          animationEnabled: false,
          customColors: CustomSliderColors(
            trackColor: Theme.of(context).shadowColor,
            progressBarColor: Theme.of(context).primaryColor,
            shadowColor: Theme.of(context).shadowColor,
            dotColor: Colors.transparent,
          ),
          customWidths: CustomSliderWidths(
            trackWidth: 2 * ss / 100,
            progressBarWidth: 2 * ss / 100,
            handlerSize: 2 * ss / 100,
            shadowWidth: 4 * ss / 100,
          )
        // startAngle: 0,
      ),
      onChangeStart: (value) {
        widget.stopFade();
      },
      onChangeEnd: (value) {
        videoManager.seekPosition(Duration(
          seconds: value.toInt(),
          milliseconds: ((value - value.toInt()) * 1000).toInt(),
        ), ({position}) {
          partyManager.addAction(VideoAction(
              action: VAction.MOVETO,
              position: position,
              timestamp: DateTime.now().millisecondsSinceEpoch,
              userID: auth.currentUser!.uid
          ));
        });
        widget.startFade();
      },
      min: 0,
      max: videoManager.getDuration().inSeconds.toDouble(),
      initialValue:  videoManager.getPosition().inSeconds.toDouble(),
      // innerWidget: (value) {
      //   return buildPlayControl();
      // },
      innerWidget: (value) => SizedBox(),
    );
  }

  Widget buildTrack(double ss) {
    return SizedBox(
      // constraints: BoxConstraints.expand(),
      child: GestureDetector(
        onLongPressStart: (details) {
          setState(() {
            previousAngle = details.localPosition.translate(-ss/2, -ss/2).direction * 57.28;
            widget.stopFade();
          });
        },
        onLongPressMoveUpdate: (details) {
          setState(() {
            currentAngle = details.localPosition.translate(-ss/2, -ss/2).direction * 57.28;
          });
        },
        onLongPressUp: () {
          widget.startFade();
        },
        onPanStart: (details) {
          setState(() {
            previousAngle = details.localPosition.translate(-ss/2, -ss/2).direction * 57.28;
            widget.stopFade();
          });
        },
        onPanUpdate: (details) {
          setState(() {
            currentAngle = details.localPosition.translate(-ss/2, -ss/2).direction * 57.28;
          });
        },
        onPanEnd: (details) {
          widget.startFade();
        },
        child: Container(
          // constraints: const BoxConstraints.expand(),
          margin: EdgeInsets.all(3 * ss / 100),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              // borderRadius: BorderRadius.circular(128),
              color: Theme.of(context).shadowColor
          ),
          child: Center(child: buildPlayControl(),),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);

    Size size = MediaQuery.of(context).size;
    print(size);
    return Container(
      // color: Colors.greenAccent,
      // constraints: BoxConstraints.expand(),
      width: size.shortestSide,
      height: size.shortestSide,
      child: Stack(
        
        alignment: Alignment.bottomRight,
        children: [
          buildSlider(size.shortestSide),
          buildTrack(size.shortestSide),
        ],
      ),
    );

    // return buildSlider();
  }
}