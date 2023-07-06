import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/video_action.dart';
import '../../../organizers/party_manager.dart';
import '../../../organizers/video_manager.dart';

class SpeedDragger extends StatefulWidget {
  Function stopFade;
  Function startFade;

  SpeedDragger({Key? key, required this.startFade, required this.stopFade}) : super(key: key);

  @override
  State<SpeedDragger> createState() => _SpeedDraggerState();
}

class _SpeedDraggerState extends State<SpeedDragger> {
  late ScrollController speedScroller;
  double panMovementX = 0;
  double panMovementY = 0;
  Timer? timer;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(milliseconds: 143), (timer) {
      if (panMovementY.abs() < 10 && panMovementX.abs() < 10) return;
      VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
      PartyManager partyManager = Provider.of<PartyManager>(context, listen: false);

      double initialSpeed = videoManager.playbackSpeed;
      double finalSpeed = initialSpeed;
      if (panMovementY.abs() > 10) {
        int speedInto100 = (finalSpeed * 100).toInt();
        finalSpeed = (speedInto100 - panMovementY) / 100;
      }
      if (panMovementX.abs() > 10) {
        int speedInto10 = (finalSpeed * 10).toInt();
        finalSpeed = (speedInto10 + panMovementX ~/ 10) / 10;
      }

      videoManager.setSpeed(finalSpeed.clamp(0.1, 7.0), ({value}) {
        partyManager.addAction(VideoAction(
            value: value,
            action: VAction.SPEED,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            userID: auth.currentUser!.uid
          )
        );
        setState(() {
          panMovementX = 0;
          panMovementY = 0;
        });
        widget.startFade();
      });
    });
    widget.startFade();
    super.initState();
  }

  @override
  void dispose() {
    if(timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: true);
    PartyManager partyManager = Provider.of<PartyManager>(context, listen: true);

    return GestureDetector(
      onPanStart: (d) => widget.stopFade(),
      onPanUpdate: (details) {
        setState(() {
          if (details.delta.dx.abs() > 1) panMovementX = panMovementX + details.delta.dx;
          if (details.delta.dy.abs() > 1) panMovementY = panMovementY + details.delta.dy;
        });
      },
      child: SizedBox(
        width: 256,
        height: 256,
        child: Center(
          child: Text("\n ${videoManager.playbackSpeed.toStringAsFixed(2)}x \n",
            style: GoogleFonts.voltaire(
              textStyle: Theme.of(context).textTheme.displayLarge,
              color: Theme.of(context).primaryColor,
              shadows: [
                Shadow(
                  blurRadius: 14.0,
                  color: Theme.of(context).shadowColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}