import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';


import '../../../models/moment.dart';
import '../../../models/snap.dart';
import '../../../models/video_action.dart';
import '../../../organizers/video_manager.dart';
import '../../../organizers/party_manager.dart';
import '../../../organizers/app_manager.dart';
import '../components/keyboard.dart';

enum MODE { SNAP, ROLL }

class RecordControls extends StatefulWidget {
  const RecordControls({Key? key}) : super(key: key);

  @override
  State<RecordControls> createState() => _RecordControlsState();
}

class _RecordControlsState extends State<RecordControls> {
  MODE currentMode = MODE.SNAP;
  MOVE moveDirection = MOVE.FORWARD;
  bool _isDoubleTapping = false;
  Timer? _tapDebounce;
  Timer? seekerTimer;
  int panMovement = 0;
  bool isRolling = false;
  bool showTextField = false;
  bool showKeyboard = false;
  bool isLooping = false;
  Duration? recordStartPosition;
  Moment? currentMoment;
  Snap? currentSnap;
  Future? delayedSeek;
  TextEditingController textController = TextEditingController();
  Uint8List? coverImage;

  FirebaseAuth auth = FirebaseAuth.instance;

  final momentsRef = FirebaseFirestore.instance.collection('moments')
      .withConverter<Moment>(
    fromFirestore: (snapshot, _) => Moment.fromJson(snapshot.data()!, ID: snapshot.id),
    toFirestore: (moment, _) => moment.toJson(),
  );
  final snapsRef = FirebaseFirestore.instance.collection('snaps')
      .withConverter<Snap>(
    fromFirestore: (snapshot, _) => Snap.fromJson(snapshot.data()!, ID: snapshot.id),
    toFirestore: (snap, _) => snap.toJson(),
  );

  @override
  void initState() {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
    PartyManager partyManager = Provider.of<PartyManager>(context, listen: false);
    seekerTimer = Timer.periodic(const Duration(milliseconds: 143), (Timer t) {
      if (!mounted) return;

      if (currentMoment != null && isLooping && delayedSeek == null) {
        Duration currentPosition = videoManager.controller!.value.position;
        Duration difference = Duration(milliseconds: currentMoment!.endMs)! - currentPosition;
        if (difference < Duration.zero) {
          videoManager.seekPosition(Duration(milliseconds: currentMoment!.startMs), ({position}) {});
        } else if (difference < const Duration(seconds: 1)) {
          setState(() {
            delayedSeek = Future.delayed(difference, () {
              videoManager.seekPosition(Duration(milliseconds: currentMoment!.startMs), ({position}) {
                setState(() {
                  delayedSeek = null;
                });
              });
            });
          });
        }
      }

      if (panMovement == 0) return;
      videoManager.moveByDuration(
          panMovement > 0 ? MOVE.FORWARD : MOVE.BACKWARD,
          Duration(milliseconds: panMovement.abs()),
          ({position}) {
            partyManager.addAction(VideoAction(
                action: panMovement > 0 ? VAction.FORWARD : VAction.BACKWARD,
                position: position,
                timestamp: DateTime.now().millisecondsSinceEpoch,
                userID: auth.currentUser!.uid
            ));
            setState(() {
              panMovement = 0;
            });
          }
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    _tapDebounce?.cancel();
    seekerTimer?.cancel();
    super.dispose();
  }

  Widget buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).shadowColor,
        borderRadius: BorderRadius.circular(14)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            iconSize: 37,
            onPressed: () {
              setState(() {
                showKeyboard = false;
                showTextField = false;
                if (currentMoment != null) {
                  currentMoment!.title = textController.text;
                } else if (currentSnap != null && currentSnap!.ID != null) {
                  currentSnap!.title = textController.text;
                }
              });
            },
          ),
          SizedBox(
            width: 328,
            height: 57,
            child: TextField(
              textAlign: TextAlign.start,
              maxLines: 1,
              decoration: const InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding: EdgeInsets.all(7)
              ),
              controller: textController,
              readOnly: true,
              autofocus: true,
              style: GoogleFonts.voltaire(
                textStyle: Theme.of(context).textTheme.displayMedium
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildControls() {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: true);
    PartyManager partyManager = Provider.of<PartyManager>(context, listen: false);
    AppManager appManager = Provider.of<AppManager>(context, listen: false);
    if (currentMoment != null || currentSnap != null) {
      Widget doneButton = GestureDetector(
          onTap: () {
            if (currentMoment != null) {
              momentsRef.add(currentMoment!);
            } else if (currentSnap != null) {
              snapsRef.add(currentSnap!);
            }
            videoManager.recordingOff(() {
              partyManager.addAction(VideoAction(
                  action: VAction.RECORDING_OFF,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                  userID: auth.currentUser!.uid
              ));
            });
          },
          child: Container(
            width: 57, height: 57,
            decoration: BoxDecoration(
                color: Theme.of(context).shadowColor,
                shape: BoxShape.circle
            ),
            child: Center(child: Icon(Icons.check_circle_outline_outlined,
              size: 51,
              color: Theme.of(context).primaryColor,
            )),
          )
      );
      Widget textButton = GestureDetector(
          onTap: () {
            setState(() {
              showTextField = true;
              showKeyboard = true;
            });
          },
          child: Container(
            width: 57, height: 57,
            decoration: BoxDecoration(
                color: Theme.of(context).shadowColor,
                shape: BoxShape.circle
            ),
            padding: const EdgeInsets.only(top: 3),
            child: Center(
                child: Icon(
                  Icons.text_fields_outlined,
                  size: 51,
                  color: Theme.of(context).primaryColor,
                )
            ),
          )
      );
      Widget deleteButton = GestureDetector(
          onTap: () {
            setState(() {
              currentMoment = null;
              currentSnap = null;
              currentMode = MODE.SNAP;
            });
            videoManager.deleteRecorded(() {
              partyManager.addAction(VideoAction(
                  action: VAction.DELETE_RECORDED,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                  userID: auth.currentUser!.uid
              ));
            });
          },
          child: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).shadowColor
            ),
            height: 57,
            width: 57,
            child: Icon(
              Icons.delete_forever_outlined,
              size: 51,
              color: Theme.of(context).primaryColor,
            ),
          )
      );
      Widget replayButton = GestureDetector(
          onTap: () {
            if (currentMoment == null) return;
            setState(() {
              isLooping = true;
            });
            videoManager.seekPosition(Duration(milliseconds: currentMoment!.startMs), ({position}) {});
            videoManager.playVideo(({position}) {
              partyManager.addAction(VideoAction(
                action: VAction.LOOP_RECORDED,
                timestamp: DateTime.now().millisecondsSinceEpoch,
                userID: auth.currentUser!.uid,
                recordedSave: currentMoment,
              ));
            });
          },
          child: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLooping ? Theme.of(context).primaryColor : Theme.of(context).shadowColor
            ),
            height: 57,
            width: 57,
            child: Icon(
              Icons.loop,
              size: 51,
              color: isLooping ? Theme.of(context).shadowColor : Theme.of(context).primaryColor,
            ),
          )
      );

      return [
        doneButton,
        deleteButton,
        if (currentMoment != null) replayButton,
        textButton,
      ];
    }

    Widget closeButton = GestureDetector(
        onTap: () {
          videoManager.recordingOff(() {
            partyManager.addAction(VideoAction(
                action: VAction.RECORDING_OFF,
                timestamp: DateTime.now().millisecondsSinceEpoch,
                userID: auth.currentUser!.uid
            ));
          });
        },
        child: Container(
          width: 57, height: 57,
          decoration: BoxDecoration(
            color: Theme.of(context).shadowColor,
            shape: BoxShape.circle
          ),
          child: Center(child: Icon(Icons.highlight_remove_rounded,
            size: 51,
            color: Theme.of(context).primaryColor,
          )),
        )
    );
    Widget modeButton = GestureDetector(
      onTap: () {
        setState(() {
          currentMode = currentMode == MODE.ROLL
              ? MODE.SNAP : MODE.ROLL;
        });
      },
      child: Container(
        width: 57, height: 57,
        decoration: BoxDecoration(
          color: Theme.of(context).shadowColor,
          shape: BoxShape.circle
        ),
        child: Center(
          child: Icon(
            currentMode == MODE.ROLL
                ? Icons.videocam_outlined : Icons.camera_alt_outlined,
            size: 51,
            color: Theme.of(context).primaryColor,
          )
        ),
      )
    );
    Widget startButton = GestureDetector(
        onTap: () async {
          if (isRolling) return;

          FileInfo? fileInfo = await DefaultCacheManager().getFileFromMemory(videoManager.currentVideo!.ref);
          if (fileInfo == null) return;
          final uint8list = await VideoThumbnail.thumbnailData(
            video: fileInfo.file.path,
            imageFormat: ImageFormat.PNG,
            // maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
            quality:100,
            timeMs: videoManager.controller!.value.position.inMilliseconds
          );
          if (currentMode == MODE.SNAP) {
            Snap newSnap = Snap(
              titleID: appManager.currentTitle != null
                  ? appManager.currentTitle!.ID : videoManager.currentVideo!.titleID,
              userID: auth.currentUser!.uid,
              ref: videoManager.currentVideo!.ref,
              snapMs: videoManager.controller!.value.position.inMilliseconds,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              coverImage: MemoryImage(uint8list!),
            );
            setState(() {
              currentSnap = newSnap;
            });
            videoManager.setRecorded(newSnap, () {
              partyManager.addAction(VideoAction(
                  action: VAction.SET_RECORDED,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                  userID: auth.currentUser!.uid,
                  recordedSave: newSnap,
              ));
            });
          } else {
            setState(() {
              isRolling = true;
              recordStartPosition = videoManager.controller!.value.position;
              coverImage = uint8list!;
            });
            videoManager.playVideo(({position}) {
              partyManager.addAction(VideoAction(
                  action: VAction.PLAY,
                  position: position,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                  userID: auth.currentUser!.uid
              ));
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).shadowColor
          ),
          height: 111,
          width: 111,
          child: isRolling ? Center(
            child: Text("Pan and Release to Stop.",
              textAlign: TextAlign.center,
              maxLines: 3,
              style: GoogleFonts.voltaire(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                  color: Theme.of(context).primaryColor
              ),
            ),
          ) : const SizedBox(),
        )
    );
    return [
      closeButton,
      startButton,
      modeButton,
    ];
  }

  @override
  Widget build(BuildContext context) {
    AppManager appManager = Provider.of<AppManager>(context, listen: false);
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
    PartyManager partyManager = Provider.of<PartyManager>(context, listen: true);
    return Stack(
      children: [
        Container(
          child: GestureDetector(

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
              _tapDebounce = Timer(const Duration(milliseconds: 1111), () {
                setState(() => _isDoubleTapping = false);
                videoManager.resetMoveCounter();
              });
            },
            onPanStart: (d) {
              if (isRolling) {
                videoManager.pauseVideo(({position}) {
                  partyManager.addAction(VideoAction(
                    action: VAction.PAUSE,
                    position: position,
                    timestamp: DateTime.now().millisecondsSinceEpoch,
                    userID: auth.currentUser!.uid
                  ));
                });
              }
            },
            onPanUpdate: (DragUpdateDetails details) {
              if (details.delta.dx.abs() > 1.44) {
                setState(() => panMovement = panMovement + (details.delta.dx * 111).toInt());
              } else if (details.delta.dx.abs() >= 0.77) {
                setState(() => panMovement = panMovement + (details.delta.dx * 49).toInt());
              } else if (details.delta.dx.abs() >= 0.2) {
                setState(() => panMovement = panMovement + (details.delta.dx * 37).toInt());
              }
            },
            onPanEnd: (d) {
              if (!isRolling) return;
              Moment newMoment = Moment(
                userID: auth.currentUser!.uid,
                ref: videoManager.currentVideo!.ref,
                titleID: appManager.currentTitle!.ID,
                startMs: recordStartPosition!.inMilliseconds,
                endMs: videoManager.controller!.value.position.inMilliseconds,
                createdAt: DateTime.now().millisecondsSinceEpoch,
                coverImage: MemoryImage(coverImage!)
              );
              setState(() {
                isRolling = false;
                currentMoment = newMoment;
              });
              videoManager.setRecorded(newMoment, () {
                partyManager.addAction(VideoAction(
                  action: VAction.SET_RECORDED,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                  userID: auth.currentUser!.uid,
                  recordedSave: currentMoment,
                ));
              });
              videoManager.pauseVideo(({position}) {
                partyManager.addAction(VideoAction(
                  action: VAction.PAUSE,
                  position: position,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                  userID: auth.currentUser!.uid
                ));
              });
            },
            onLongPress: () { return; },
            onLongPressEnd: (d) { return; },
            onLongPressStart: (d) { return; },
            onLongPressMoveUpdate: (d) { return; },
          ),
        ),
        if (MediaQuery.of(context).orientation == Orientation.portrait)
          ...[
            if (!showKeyboard)
              Positioned(
                bottom: 56,
                right: 14,
                left: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: buildControls().reversed.toList(),
                )
              ),
            if (showKeyboard)
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Keyboard(
                    textController: textController,
                    allowNewLine: false,
                  ),
              ),
            if (showTextField)
              Positioned(
                top: 14,
                left: 14,
                child: buildTitleField()
              ),
          ],
        if (MediaQuery.of(context).orientation == Orientation.landscape)
          ...[
            if (!showKeyboard)
              Positioned(
                top: 14,
                bottom: 14,
                right: 28,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: buildControls(),
                ),
              ),
            if (showKeyboard)
              Positioned(
                bottom: 14,
                top: 14,
                right: 7,
                child: Keyboard(
                  textController: textController,
                  allowNewLine: false,
                ),
              ),
            if (showTextField)
              Positioned(
                top: 56,
                left: 14,
                child: buildTitleField()
              ),
          ]
      ],
    );

  }
}
