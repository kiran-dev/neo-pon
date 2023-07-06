import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/amv.dart';
import '../../../models/episode.dart';
import '../../../organizers/video_manager.dart';
import '../../../organizers/party_manager.dart';
import '../components/magnify_controls.dart';
import '../components/position_slider.dart';
import '../components/party_view.dart';
import '../components/speed_dragger.dart';
import '../components/volume_grid.dart';
import '../../../organizers/app_manager.dart';

enum OControls { POSITION, PARTY, PLAYBACK, VOLUME, MAGNIFIER }

class BasicControls extends StatefulWidget {
  Orientation orientation;
  Function quickFade;
  Function startFade;
  Function stopFade;
  Function slowFade;
  final GlobalKey<NavigatorState> pageNavigationKey;

  BasicControls({Key? key,
    required this.orientation,
    required this.quickFade,
    required this.startFade,
    required this.stopFade,
    required this.slowFade,
    required this.pageNavigationKey,
  }) : super(key: key);

  @override
  State<BasicControls> createState() => _BasicControlsState();
}

class _BasicControlsState extends State<BasicControls> {
  OControls displayControl = OControls.POSITION;

  @override
  void initState() {
    super.initState();
    widget.startFade();
  }

  List<Widget> listSecondaryControls(VideoManager videoManager) {
    return [
      CircleAvatar(
        backgroundColor: Theme.of(context).shadowColor,
        radius: 22,
        child: InkWell(
          onTap: () {
            setState(() {
              if (displayControl == OControls.VOLUME) {
                displayControl = OControls.POSITION;
                widget.startFade();
              } else {
                displayControl = OControls.VOLUME;
                widget.stopFade();
              }
            });
          },
          child: Icon(
            videoManager.isMuted ? Icons.volume_off : Icons.volume_up,
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
            icon: Icon(Icons.speed_rounded, size: 28, color: Theme.of(context).primaryColor,),
            onPressed: () {
              setState(() {
                if (displayControl == OControls.PLAYBACK) {
                  displayControl = OControls.POSITION;
                  widget.startFade();
                } else {
                  displayControl = OControls.PLAYBACK;
                  widget.stopFade();
                }
              });
            }
        ),
      ),
      CircleAvatar(
        backgroundColor: Theme.of(context).shadowColor,
        radius: 22,
        child: InkWell(
          onTap: () {
            setState(() {
              if (displayControl == OControls.MAGNIFIER) {
                displayControl = OControls.POSITION;
                widget.startFade();
              } else {
                displayControl = OControls.MAGNIFIER;
                widget.stopFade();
              }
            });
          },
          onLongPress: () {
            // videoManager.toggleMute();
          },
          child: Icon(
            Icons.check_box_outline_blank_outlined,
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
            isSelected: displayControl == OControls.PARTY,
            splashColor: Theme.of(context).shadowColor,
            icon: Icon(
              Icons.people_alt_outlined,
              size: 28,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              setState(() {
                if (displayControl == OControls.PARTY) {
                  displayControl = OControls.POSITION;
                  widget.startFade();
                } else {
                  displayControl = OControls.PARTY;
                  widget.stopFade();
                }
              });
            })
        ),
    ];
  }

  Widget buildSecondaryControl(PartyManager partyManager, VideoManager videoManager) {
    switch(displayControl) {
      case OControls.VOLUME: {
        return VolumeGrid(
          startFade: widget.startFade,
          stopFade: widget.slowFade,
        );
      }
      case OControls.PLAYBACK: {
        return SpeedDragger(
          startFade: widget.startFade,
          stopFade: widget.slowFade,
        );
      }
      case OControls.PARTY: {
        return PartyView(

        );
      }
      case OControls.MAGNIFIER: {
        return MagnifyControls(
          startFade: widget.startFade,
          stopFade: widget.slowFade,
        );
      }
      default: {
        return PositionSlider(
          startFade: widget.startFade,
          stopFade: widget.stopFade,
        );
      }
    }

  }

  Widget buildVideoTitle(VideoManager videoManager) {
    return InkWell(
      onTap: () {
        if(widget.pageNavigationKey.currentState!.canPop()) {
          widget.pageNavigationKey.currentState!.pop();
          videoManager.unloadVideo();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
        color: Theme.of(context).shadowColor,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        child: Text(
          videoManager.getTitle().split("! ").length > 1
              ? videoManager.getTitle().split("! ").join("!\n").toString()
              : videoManager.getTitle().split("? ").join("?\n").toString(),
          style: GoogleFonts.voltaire(
              textStyle: Theme.of(context).textTheme.displaySmall,
              color: Theme.of(context).primaryColor
          ),
          maxLines: 2,
          overflow: TextOverflow.fade,
        ),
      ),
    );
  }

  Widget? buildNextButton(VideoManager videoManager, AppManager appManager) {

    if (videoManager.currentVideo is Amv) return null;
    Episode? nextEpisode = (videoManager.currentVideo as Episode).nextEpisode;

    if (nextEpisode == null) return null;

    bool isDownloading = !nextEpisode.isDownloaded && nextEpisode.downloadProgress != null;

    return InkWell(
        child: Container(
          width: 160,
          height: 40,
          color: Theme.of(context).shadowColor,
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Stack(
            children: [
              if (isDownloading)
                SizedBox(
                    height: 60,
                    child: LinearProgressIndicator(
                      value: nextEpisode.downloadProgress!.progress,
                      color: Theme.of(context).primaryColor,
                      backgroundColor: Theme.of(context).canvasColor,
                    )
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (nextEpisode.isDownloaded)
                    Icon(Icons.ac_unit_outlined, size: 28, color: Theme.of(context).primaryColor,),
                  Text("Next Episode",
                    style: GoogleFonts.voltaire(
                        color: isDownloading
                                  ? Theme.of(context).shadowColor
                                  : Theme.of(context).primaryColor,
                    ),
                  ),
                  if (!nextEpisode.isDownloaded && nextEpisode.downloadProgress == null)
                    Icon(Icons.navigate_next, size: 28, color: Theme.of(context).primaryColor,)
                ],
              ),
            ],
          ),
        ),
        onTap: () {
          widget.startFade();
          videoManager.setEpisode(nextEpisode);
          videoManager.unloadVideo();
          if (!nextEpisode.isDownloaded && nextEpisode.downloadProgress == null) {
            videoManager.downloadVideo(nextEpisode, appManager.saveDownloadedRef);
          }
        },
        onLongPress: () {
          widget.stopFade();
          if (!nextEpisode.isDownloaded && nextEpisode.downloadProgress == null) {
            videoManager.downloadVideo(nextEpisode, appManager.saveDownloadedRef);
          }
          widget.startFade();
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: true);
    PartyManager partyManager = Provider.of<PartyManager>(context, listen: true);
    AppManager appManager = Provider.of<AppManager>(context, listen: true);

    if (widget.orientation == Orientation.landscape) {
      return Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(width: 4, color: Colors.transparent)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildVideoTitle(videoManager),
                      buildNextButton(videoManager, appManager) ?? SizedBox(),
                    ],
                  ),
                ),
              ),
              const Expanded(flex: 1, child: SizedBox()),
              Expanded(
                  flex: 7,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const SizedBox(width: 28,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: listSecondaryControls(videoManager),
                        ),
                        Expanded(
                            child: SizedBox(
                              child: GestureDetector(
                                onTap: () {
                                  widget.startFade();
                                },
                              ),
                            )
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: buildSecondaryControl(partyManager, videoManager),
                        ),
                        const SizedBox(width: 28,),
                      ]
                  )
              ),
            ],
          )
      );
    }


    return Container(
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(width: 4, color: Colors.transparent)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildVideoTitle(videoManager),
                buildNextButton(videoManager, appManager) ?? SizedBox(),
              ],
            ),
          ),
          Expanded(
              flex: 3,
              child: SizedBox(
                child: GestureDetector(
                  onTap: () {
                    widget.startFade();
                  },
                ),
              )
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: listSecondaryControls(videoManager),
                  ),
                ),
                Expanded(child: SizedBox()),
                Expanded(
                  flex: 5,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Center(child: buildSecondaryControl(partyManager, videoManager))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


