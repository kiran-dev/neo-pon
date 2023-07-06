import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neo_pon/components/player/controls/party_controls.dart';
import 'package:neo_pon/models/magnify_config.dart';
import 'package:neo_pon/models/video_action.dart';
import 'package:neo_pon/models/video_resource.dart';
import 'package:neo_pon/organizers/party_manager.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../../organizers/video_manager.dart';
import 'controls/basic_controls.dart';
import 'controls/feedback_view.dart';
import 'controls/record_controls.dart';
import 'package:wakelock/wakelock.dart';

class Player extends StatefulWidget {
  final GlobalKey<NavigatorState> pageNavigationKey;

  Player({Key? key, required this.pageNavigationKey}) : super(key: key);

  @override
  State<Player> createState() => _PlayerState();
}


class _PlayerState extends State<Player> {
  MOVE moveDirection = MOVE.FORWARD;
  Offset longPressPrevPosition = Offset.zero;
  String videoPath = "";
  Uint8List? thumbnailImage;
  Stream<double>? longPressMovement;
  CONTROLS displayControls = CONTROLS.NONE;
  bool _isDoubleTapping = false;
  Timer? _tapDebounce;
  FirebaseAuth auth = FirebaseAuth.instance;

  Duration doubleTapVisibleDuration = const Duration(milliseconds: 1111);
  Duration fadeDuration = const Duration(milliseconds: 2800);
  Duration quickFadeDuration = const Duration(milliseconds: 700);
  Duration slowFadeDuration = const Duration(milliseconds: 3700);

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
    videoManager.initializeVideo();
    Wakelock.enable();
    super.initState();
  }

  @override
  void dispose() {
    _tapDebounce?.cancel();
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: true);

    if (videoManager.controller == null || !videoManager.isCurrentVideoInitialized) {
      videoManager.initializeVideo();

      return Container(
        color: Theme.of(context).canvasColor,
        child: const Center(
          child: Text("Initializing Video"),
        )
      );
    }

    PartyManager partyManager = Provider.of<PartyManager>(context, listen: true);
    if (partyManager.inParty()) {
      if (displayControls != CONTROLS.PARTY) {
        setState(() {
          displayControls = CONTROLS.PARTY;
        });
      }
      if (partyManager.videoActions.isNotEmpty) {
        partyManager.applyVideoActions(videoManager);
      }
    }

    return Container(
      color: Theme.of(context).canvasColor,
      child: Stack(
          children: [
            OrientationBuilder(
                builder: (context, o) {
                  Orientation orientation = MediaQuery.of(context).orientation;
                  MagnifyConfig magnifyConfig = videoManager.getMagnifyConfig(orientation) ?? MagnifyConfig.original();
                  Size videoSize = videoManager.controller!.value.size;
                  return Center(
                      child: AspectRatio(
                        aspectRatio: videoManager.controller != null ? videoManager.controller!.value.aspectRatio : 1.0,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            VideoPlayer(videoManager.controller!),
                            if (videoManager.showMagnifier && magnifyConfig != null)
                              Positioned(
                                left: videoSize.width * magnifyConfig.fx,
                                top: videoSize.height * magnifyConfig.fy,
                                child: Container(
                                  // alignment: FractionalOffset(magnifyConfig.fx, magnifyConfig.fy),
                                  child: RawMagnifier(
                                    magnificationScale: magnifyConfig.scale,
                                    focalPointOffset: Offset(magnifyConfig!.ox.toDouble(), magnifyConfig!.oy.toDouble()),
                                    // borderRadius: BorderRadius.circular(14),
                                    size: Size(videoSize!.width * magnifyConfig.fw, videoSize!.height * magnifyConfig.fh),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                  );
                }
            ),
            Container(
              decoration: BoxDecoration(color: Colors.transparent, border: Border.all(width: 4, color: Colors.transparent)),
              child: FeedbackView(),
            ),
            Visibility(
              visible: displayControls == CONTROLS.NONE,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(width: 4, color: Colors.transparent)
                ),
                child: GestureDetector(
                  onTap: () {
                    if (_isDoubleTapping) return;
                    if (videoManager.isRecording) return;
                    if (displayControls == CONTROLS.BASIC) {
                      if (_tapDebounce?.isActive ?? false) _tapDebounce?.cancel();
                      _tapDebounce = Timer(fadeDuration, () {
                        setState(() => displayControls = CONTROLS.NONE );
                      });
                    } else {
                      setState(() => displayControls = CONTROLS.BASIC );
                    }
                  },
                  onDoubleTapDown: (TapDownDetails details) {
                    double screenSize = MediaQuery.of(context).size.width;
                    if (details.globalPosition.dx > screenSize / 2) {
                      setState(() => moveDirection = MOVE.FORWARD );
                    } else {
                      setState(() => moveDirection = MOVE.BACKWARD );
                    }
                  },
                  onDoubleTap: () {
                    if (_tapDebounce?.isActive ?? false) _tapDebounce?.cancel();
                    videoManager.movePositionTen(moveDirection, ({position}) {
                      partyManager.addAction(VideoAction(
                          action: moveDirection == MOVE.BACKWARD ? VAction.BACKWARD : VAction.FORWARD,
                          position: position,
                          timestamp: DateTime.now().millisecondsSinceEpoch,
                          userID: auth.currentUser!.uid
                      ));
                    });
                    if (!_isDoubleTapping) {
                      setState(() => _isDoubleTapping = true);
                    }
                    _tapDebounce = Timer(doubleTapVisibleDuration, () {
                      setState(() => _isDoubleTapping = false);
                      videoManager.resetMoveCounter();
                    });
                  },
                  onLongPressStart: (LongPressStartDetails details) {
                    videoManager.pauseVideo(({position}) {
                      partyManager.addAction(VideoAction(
                          action: VAction.RECORDING_ON,
                          timestamp: DateTime.now().millisecondsSinceEpoch,
                          userID: auth.currentUser!.uid
                      ));
                    });
                    videoManager.recordingOn(() {
                      partyManager.addAction(VideoAction(
                          action: VAction.RECORDING_ON,
                          timestamp: DateTime.now().millisecondsSinceEpoch,
                          userID: auth.currentUser!.uid
                      ));
                    });
                  },
                ),
              ),
            ),
            Visibility(
              visible: displayControls == CONTROLS.BASIC,
              child: BasicControls(
                orientation: MediaQuery.of(context).orientation,
                quickFade: () {
                  if (_tapDebounce?.isActive ?? false) _tapDebounce?.cancel();
                  _tapDebounce = Timer(quickFadeDuration, () {
                    setState(() => displayControls = CONTROLS.NONE);
                  });
                },
                startFade: () {
                  if (_tapDebounce?.isActive ?? false) _tapDebounce?.cancel();
                  _tapDebounce = Timer(fadeDuration, () {
                    setState(() => displayControls = CONTROLS.NONE);
                  });
                },
                stopFade: () {
                  if (_tapDebounce?.isActive ?? false) _tapDebounce?.cancel();
                  _tapDebounce = Timer(fadeDuration, () {});
                },
                slowFade: () {
                  if (_tapDebounce?.isActive ?? false) _tapDebounce?.cancel();
                  _tapDebounce = Timer(slowFadeDuration, () {
                    setState(() => displayControls = CONTROLS.NONE);
                  });
                },
                pageNavigationKey: widget.pageNavigationKey,
              ),
            ),
            Visibility(
              visible: displayControls == CONTROLS.PARTY,
              child: const PartyControls()
            ),
            Visibility(
                visible: videoManager.isRecording,
                child: const RecordControls()
            ),
          ]
      ),
    );

  }
}
