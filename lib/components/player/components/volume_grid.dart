import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/video_action.dart';
import '../../../organizers/party_manager.dart';
import '../../../organizers/video_manager.dart';

class VolumeGrid extends StatefulWidget {
  Function stopFade;
  Function startFade;

  VolumeGrid({Key? key, required this.stopFade, required this.startFade}) : super(key: key);

  @override
  State<VolumeGrid> createState() => _VolumeGridState();
}

class _VolumeGridState extends State<VolumeGrid> {
  int? volume;
  Timer? timer;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(milliseconds: 280), (timer) {
      VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
      int setVolume = (videoManager.controller!.value.volume * 100).toInt();
      if (setVolume == volume) return;

      PartyManager partyManager = Provider.of<PartyManager>(context, listen: false);
      if (volume is int) {
        videoManager.setVolume(volume!, ({value}) {
          partyManager.addAction(VideoAction(
              value: volume!.toDouble(),
              action: VAction.VOLUME,
              timestamp: DateTime.now().millisecondsSinceEpoch,
              userID: auth.currentUser!.uid
          )
          );
        });
      }
    });
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
    setState(() {
      volume = (videoManager.controller!.value.volume * 100).toInt();
    });
    widget.startFade();
    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 256,
      height: 256,
      child: GestureDetector(
        onTapUp: (details) {

        },
        onPanStart: (details) {
          widget.stopFade();
        },
        onPanUpdate: (details) {
          Offset nextPosition = details.localPosition;
          int units = nextPosition.dx ~/ 25.6;
          int tens = (256 - nextPosition.dy) ~/ 25.6;
          setState(() {
            volume = (tens * 10) + units;
            print(volume);
          });
        },
        onPanEnd: (details) {
          widget.startFade();
        },
        child: Container(
          padding: const EdgeInsets.all(28),
          child: GridView.count(
            reverse: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 10,
            children: [
              for (int i = 0; i < 100; i++)
                VolumeUnit(volume: volume ?? 0, value: i)
            ],
          ),
        ),
      ),
    );
  }
}

class VolumeUnit extends StatelessWidget {
  int volume;
  int value;

  VolumeUnit({Key? key, required this.volume, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (value < volume) {
      return const Center(
        child: Magnifier(
          additionalFocalPointOffset: Offset(-14, -14),
          size: Size(14, 14),
        ),
      );
    }
    return Center(
        child: Container(
          width: 14, height: 14,
          decoration: BoxDecoration(
            color: Theme.of(context).shadowColor,
            borderRadius: BorderRadius.circular(14)
          ),
        ),
    );

  }

}