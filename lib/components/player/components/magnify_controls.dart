import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/magnify_config.dart';
import '../../../models/video_action.dart';
import '../../../organizers/party_manager.dart';
import '../../../organizers/video_manager.dart';

class MagnifyControls extends StatefulWidget {
  Function stopFade;
  Function startFade;
  MagnifyControls({Key? key, required this.startFade, required this.stopFade}) : super(key: key);

  @override
  State<MagnifyControls> createState() => _MagnifyControlsState();
}

class _MagnifyControlsState extends State<MagnifyControls> {
  bool showHeightControls = true;
  FirebaseAuth auth = FirebaseAuth.instance;

  Widget buildHeightControls(MagnifyConfig config, Orientation o, VideoManager vM) {
    int offsetHeight = (vM.controller!.value.size.height * config.fh).toInt();
    PartyManager partyManager = Provider.of<PartyManager>(context, listen: false);
    relayParty({magnifyConfig}) {
      partyManager.addAction(VideoAction(
          action: VAction.UPDATE_MAGNIFY,
          magnifyConfig: magnifyConfig,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          userID: auth.currentUser!.uid
      ));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RotatedBox(
          quarterTurns: 3,
          child: Slider(
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Theme.of(context).primaryColor,
            thumbColor: Theme.of(context).hintColor,
            min: 0.01, max: 1.43,
            value: config.fh,
            onChanged: (v) {
              vM.setMagnifyConfig(o, config.copyWith(newFH: v), relayParty);
            },
          ),
        ),
        RotatedBox(
          quarterTurns: 1,
          child: Slider(
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Theme.of(context).primaryColor,
            thumbColor: Theme.of(context).hintColor,
            min: -0.2, max: 0.99,
            value: config.fy,
            onChanged: (v) {
              vM.setMagnifyConfig(o, config.copyWith(newFY: v), relayParty);
            },
          ),
        ),
        RotatedBox(
          quarterTurns: 1,
          child: Slider(
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Theme.of(context).primaryColor,
            thumbColor: Theme.of(context).hintColor,
            min: -offsetHeight/2, max: offsetHeight/2,
            value: config.oy.toDouble().clamp(-offsetHeight/2, offsetHeight/2),
            onChanged: (v) {
              vM.setMagnifyConfig(o, config.copyWith(newOY: v.toInt()), relayParty);
            },
          ),
        ),
        RotatedBox(
          quarterTurns: 3,
          child: Slider(
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Theme.of(context).primaryColor,
            thumbColor: Theme.of(context).hintColor,
            min: 0.7, max: 7,
            value: config.scale,
            onChanged: (v) {
              vM.setMagnifyConfig(o, config.copyWith(newScale: v), relayParty);
            },
          ),
        ),
      ],
    );
  }

  Widget buildWidthControls(MagnifyConfig config, Orientation o, VideoManager vM) {
    int offsetWidth = (vM.controller!.value.size.width * config.fw).toInt();
    PartyManager partyManager = Provider.of<PartyManager>(context, listen: false);
    relayParty({magnifyConfig}) {
      partyManager.addAction(VideoAction(
          action: VAction.UPDATE_MAGNIFY,
          magnifyConfig: magnifyConfig,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          userID: auth.currentUser!.uid
      ));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Slider(
          activeColor: Theme.of(context).primaryColor,
          inactiveColor: Theme.of(context).primaryColor,
          thumbColor: Theme.of(context).hintColor,
          min: 0.01, max: 1.43,
          value: config.fw,
          onChanged: (v) {
            vM.setMagnifyConfig(o, config.copyWith(newFW: v), relayParty);
          },
        ),
        Slider(
          activeColor: Theme.of(context).primaryColor,
          inactiveColor: Theme.of(context).primaryColor,
          thumbColor: Theme.of(context).hintColor,
          min: -0.2, max: 0.99,
          value: config.fx,
          onChanged: (v) {
            vM.setMagnifyConfig(o, config.copyWith(newFX: v), relayParty);
          },
        ),
        Slider(
          activeColor: Theme.of(context).primaryColor,
          inactiveColor: Theme.of(context).primaryColor,
          thumbColor: Theme.of(context).hintColor,
          min: -offsetWidth/3, max: offsetWidth/3,
          value: config.ox.toDouble().clamp(-offsetWidth/3, offsetWidth/3),
          onChanged: (v) {
            vM.setMagnifyConfig(o, config.copyWith(newOX: v.toInt()), relayParty);
          },
        ),
        Slider(
          activeColor: Theme.of(context).primaryColor,
          inactiveColor: Theme.of(context).primaryColor,
          thumbColor: Theme.of(context).hintColor,
          min: 0.7, max: 7,
          value: config.scale,
          onChanged: (v) {
            vM.setMagnifyConfig(o, config.copyWith(newScale: v), relayParty);
          },
        ),
      ],
    );
  }

  Widget buildBottomControls() {
    PartyManager partyManager = Provider.of<PartyManager>(context, listen: false);
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: true);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).shadowColor,
            borderRadius: BorderRadius.circular(14)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    widget.startFade();
                  },
                  iconSize: 17,
                  icon: const Icon(Icons.check)
              ),
              IconButton(
                  onPressed: () {
                    setState(() => showHeightControls = true);
                  },
                  iconSize: 17,
                  icon: const Icon(Icons.vertical_distribute)
              ),
              IconButton(
                  onPressed: () {
                    setState(() => showHeightControls = false);
                  },
                  iconSize: 17,
                  icon: const Icon(Icons.horizontal_distribute)
              ),
              IconButton(
                  onPressed: () {
                    videoManager.showMagnifier
                        ? videoManager.setMagnifierInvisible(({magnifyConfig}) {
                            partyManager.addAction(VideoAction(
                                action: VAction.MAGNIFY_OFF,
                                timestamp: DateTime.now().millisecondsSinceEpoch,
                                userID: auth.currentUser!.uid
                            ));
                          })
                        : videoManager.setMagnifierVisible(({magnifyConfig}) {
                            partyManager.addAction(VideoAction(
                                action: VAction.MAGNIFY_ON,
                                magnifyConfig: magnifyConfig,
                                timestamp: DateTime.now().millisecondsSinceEpoch,
                                userID: auth.currentUser!.uid
                            ));
                          });
                  },
                  iconSize: 17,
                  icon: videoManager.showMagnifier
                          ? const Icon(Icons.delete)
                          : const Icon(Icons.add)
              )
            ],
          ),
        ),
      ],
    );
  }
  
  Widget buildScreenPositioner(Orientation orientation) {
    Size screenSize = MediaQuery.of(context).size;
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
    Size videoSize = videoManager.controller!.value.size;
    return GestureDetector(
      onScaleUpdate: (d) {
        print("Outer ${d.pointerCount == 2 ? "Scaling" : "Moving"}");
        print(d);
        if (d.pointerCount == 2) {
          if (d.verticalScale > 2 * d.horizontalScale) {
            print("Outer Vertical Scale ${d.verticalScale}");
          } else if (d.horizontalScale > 2 * d.verticalScale) {
            print("Outer Horizontal Scale ${d.horizontalScale}");
          } else {
            print("Outer All Move - H: ${d.horizontalScale} & V: ${d.verticalScale}");
          }
        } else {
          if (d.verticalScale > 2 * d.horizontalScale) {
            print("Outer Vertical Move ${d.verticalScale}");
          } else if (d.horizontalScale > 2 * d.verticalScale) {
            print("Outer Horizontal Move ${d.horizontalScale}");
          } else {
            print("Outer All Move - H: ${d.horizontalScale} & V: ${d.verticalScale}");
          }
        }
      },
      child: Center(
        child: AspectRatio(
          aspectRatio: screenSize.width / screenSize.height,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor
                ),
                child: GestureDetector(
                  onScaleUpdate: (d) {
                    print("Inner Moving");
                    print(d);
                    if (d.pointerCount == 2) {
                      if (d.verticalScale > 2 * d.horizontalScale) {
                        print("Outer Vertical Scale ${d.verticalScale}");
                      } else if (d.horizontalScale > 2 * d.verticalScale) {
                        print("Outer Horizontal Scale ${d.horizontalScale}");
                      } else {
                        print("Outer All Move - H: ${d.horizontalScale} & V: ${d.verticalScale}");
                      }
                    } else {
                      if (d.verticalScale > 2 * d.horizontalScale) {
                        print("Inner Vertical Move ${d.verticalScale}");
                      } else if (d.horizontalScale > 2 * d.verticalScale) {
                        print("Inner Horizontal Move ${d.horizontalScale}");
                      } else {
                        print("Inner All Move - H: ${d.horizontalScale} & V: ${d.verticalScale}");
                      }
                    }
                  },
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: videoSize.width / videoSize.height,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).shadowColor,
                            ),
                          ),
                          Container(
                            color: Colors.greenAccent,
                            width: 70, height: 70,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                // alignment: FractionalOffset(0.1, 0.7),
                child: FractionallySizedBox(
                  widthFactor: 0.1,
                  heightFactor: 0.07,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildScaleSlider(Orientation orientation) {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
    PartyManager partyManager = Provider.of<PartyManager>(context, listen: false);
    MagnifyConfig currentConfig = videoManager.getMagnifyConfig(orientation)!;
    return Slider(
      activeColor: Theme.of(context).primaryColor,
      inactiveColor: Theme.of(context).hintColor,
      thumbColor: Theme.of(context).hintColor,
      min: 0.4, max: 4,
      value: currentConfig.scale,
      onChanged: (v) {
        videoManager.setMagnifyConfig(
            orientation,
            currentConfig.copyWith(newScale: v),
                ({magnifyConfig}) {
              partyManager.addAction(VideoAction(
                  action: VAction.UPDATE_MAGNIFY,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                  userID: auth.currentUser!.uid,
                  magnifyConfig: magnifyConfig
              ));
            }
        );
      },
    );

  }

  Widget buildVisibilityButton() {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
    PartyManager partyManager = Provider.of<PartyManager>(context, listen: false);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).shadowColor,
        borderRadius: BorderRadius.circular(7)
      ),
      child: IconButton(
        icon: videoManager.showMagnifier
            ? const Icon(Icons.visibility_off)
            : const Icon(Icons.visibility),
        onPressed: () {
          if (videoManager.showMagnifier) {
            videoManager.setMagnifierInvisible(({magnifyConfig}) {
              partyManager.addAction(VideoAction(
                  action: VAction.MAGNIFY_OFF,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                  userID: auth.currentUser!.uid,
                  magnifyConfig: magnifyConfig
              ));
            });
          } else {
            videoManager.setMagnifierVisible(({magnifyConfig}) {
              partyManager.addAction(VideoAction(
                  action: VAction.MAGNIFY_ON,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                  userID: auth.currentUser!.uid,
                  magnifyConfig: magnifyConfig
              ));
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: true);
    PartyManager partyManager = Provider.of<PartyManager>(context, listen: false);
    return OrientationBuilder(
      builder: (context, orientation) {
        // Orientation orientation = MediaQuery.of(context).orientation;
        MagnifyConfig? currentConfig = videoManager.getMagnifyConfig(orientation);

        return SizedBox(
          width: 256,
          height: 256,
          child: Container(
            child: (() {
              if (currentConfig == null) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  iconSize: 121,
                  onPressed: () {
                    videoManager.setMagnifyConfig(
                      orientation,
                      MagnifyConfig.original(),
                      ({magnifyConfig}) {
                        partyManager.addAction(VideoAction(
                          action: VAction.UPDATE_MAGNIFY,
                          timestamp: DateTime.now().millisecondsSinceEpoch,
                          userID: auth.currentUser!.uid,
                          magnifyConfig: magnifyConfig
                        ));
                      }
                    );
                    videoManager.setMagnifierVisible(({magnifyConfig}) {
                      partyManager.addAction(VideoAction(
                        action: VAction.MAGNIFY_ON,
                        timestamp: DateTime.now().millisecondsSinceEpoch,
                        userID: auth.currentUser!.uid,
                      ));
                    });
                  },
                );
              }
              if (orientation == Orientation.landscape) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 1,
                      child: buildScreenPositioner(orientation)
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        borderRadius: BorderRadius.circular(14)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildScaleSlider(orientation),
                          buildVisibilityButton(),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 1,
                      child: buildScreenPositioner(orientation),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).shadowColor,
                          borderRadius: BorderRadius.circular(14)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RotatedBox(
                            quarterTurns: 3,
                            child: buildScaleSlider(orientation)
                          ),
                          buildVisibilityButton()
                        ],
                      ),
                    ),
                  ],
                );
              }
            })(),
          ),
        );
      }
    );
  }
}
