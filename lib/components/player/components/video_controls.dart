import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/video_action.dart';
import '../../../organizers/party_manager.dart';
import '../../../organizers/video_manager.dart';
import '../controls/basic_controls.dart';
import 'magnify_controls.dart';
import 'position_slider.dart';
import 'speed_dragger.dart';
import 'volume_grid.dart';

class VideoControls extends StatefulWidget {
  const VideoControls({Key? key}) : super(key: key);


  @override
  State<VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls> {
  FirebaseAuth auth = FirebaseAuth.instance;
  OControls displayControl = OControls.POSITION;

  List<Widget> listSecondaryControls(VideoManager videoManager) {
    return [
      CircleAvatar(
        backgroundColor: displayControl == OControls.VOLUME
            ? Theme.of(context).primaryColor
            : Theme.of(context).shadowColor,
        radius: 22,
        child: InkWell(
          onTap: () {
            setState(() {
              if (displayControl == OControls.VOLUME) {
                displayControl = OControls.POSITION;
              } else {
                displayControl = OControls.VOLUME;
              }
            });
          },
          child: Icon(
            videoManager.isMuted ? Icons.volume_off : Icons.volume_up,
            size: 28,
            color: displayControl == OControls.VOLUME
                ? Theme.of(context).shadowColor
                : Theme.of(context).primaryColor,
          ),
        ),
      ),
      CircleAvatar(
        backgroundColor: displayControl == OControls.PLAYBACK
            ? Theme.of(context).primaryColor
            : Theme.of(context).shadowColor,
        radius: 22,
        child: IconButton(
            color: displayControl == OControls.PLAYBACK
                ? Theme.of(context).shadowColor
                : Theme.of(context).primaryColor,
            // padding: const EdgeInsets.all(10),
            isSelected: displayControl == OControls.PLAYBACK,
            splashColor: Theme.of(context).shadowColor,
            icon: Icon(
              Icons.speed_rounded,
              size: 28,
              color: displayControl == OControls.PLAYBACK
                  ? Theme.of(context).shadowColor
                  : Theme.of(context).primaryColor,
            ),
            onPressed: () {
              setState(() {
                if (displayControl == OControls.PLAYBACK) {
                  displayControl = OControls.POSITION;
                } else {
                  displayControl = OControls.PLAYBACK;
                }
              });
            }
        ),
      ),
      CircleAvatar(
        backgroundColor: displayControl == OControls.MAGNIFIER
            ? Theme.of(context).primaryColor
            : Theme.of(context).shadowColor,
        radius: 22,
        child: InkWell(
          onTap: () {
            setState(() {
              if (displayControl == OControls.MAGNIFIER) {
                displayControl = OControls.POSITION;
              } else {
                displayControl = OControls.MAGNIFIER;
              }
            });
          },
          onLongPress: () {
            // videoManager.toggleMute();
          },
          child: Icon(
            Icons.check_box_outline_blank_outlined,
            size: 28,
            color: displayControl == OControls.MAGNIFIER
                ? Theme.of(context).shadowColor
                : Theme.of(context).primaryColor,
          ),
        ),
      ),
    ];
  }

  Widget buildSecondaryControl() {
    switch (displayControl) {
      case OControls.VOLUME:
        {
          return VolumeGrid(
            startFade: () {},
            stopFade: () {},
          );
        }
      case OControls.PLAYBACK:
        {
          return SizedBox(
            height: 256,
            child: SpeedDragger(
              startFade: () {},
              stopFade: () {},
            ),
          );
        }
      case OControls.MAGNIFIER:
        {
          return MagnifyControls(
            startFade: () {},
            stopFade: () {},
          );
        }
      default:
        {
          return PositionSlider(
            startFade: () {},
            stopFade: () {},
          );
        }
    }
  }

  List<Widget> listPrimaryControls(VideoManager videoManager) {
    PartyManager partyManager = Provider.of<PartyManager>(context, listen: false);
    return [
      CircleAvatar(
        backgroundColor: Theme.of(context).shadowColor,
        radius: 22,
        child: InkWell(
          onTap: () {
            videoManager.movePositionTen(MOVE.BACKWARD, ({position}) {
              partyManager.addAction(VideoAction(
                  action: VAction.BACKWARD,
                  position: position,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                  userID: auth.currentUser!.uid
              ));
            });
          },
          child: Icon(
            Icons.fast_rewind_outlined,
            size: 28,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      CircleAvatar(
        backgroundColor: Theme.of(context).shadowColor,
        radius: 22,
        child: IconButton(
            color: Theme.of(context).primaryColor,
            // padding: const EdgeInsets.all(10),
            isSelected: displayControl == OControls.PLAYBACK,
            splashColor: Theme.of(context).shadowColor,
            icon: Icon(Icons.camera_outlined,
              size: 28,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {

            }
        ),
      ),
      CircleAvatar(
        backgroundColor: Theme.of(context).shadowColor,
        radius: 22,
        child: InkWell(
          onTap: () {
            videoManager.movePositionTen(MOVE.FORWARD, ({position}) {
              partyManager.addAction(VideoAction(
                  action: VAction.FORWARD,
                  position: position,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                  userID: auth.currentUser!.uid
              ));
            });
          },
          child: Icon(
            Icons.fast_forward_outlined,
            size: 28,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: true);

    return OrientationBuilder(
        builder: (context, o) {
          Orientation orientation = MediaQuery.of(context).orientation;
          if (orientation == Orientation.portrait) {
            return SizedBox(
              // width: 356,
              height: 256,
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    borderRadius: BorderRadius.circular(28)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: listSecondaryControls(videoManager),
                    ),
                    buildSecondaryControl(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: listPrimaryControls(videoManager),
                    ),
                  ],
                ),
              ),
            );
          }

          return SizedBox(
            width: 256,
            height: 328,
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  borderRadius: BorderRadius.circular(28)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: listSecondaryControls(videoManager),
                  ),
                  buildSecondaryControl(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: listPrimaryControls(videoManager),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}