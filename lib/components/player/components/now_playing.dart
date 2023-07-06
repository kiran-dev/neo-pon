import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/episode.dart';
import '../../../models/video_resource.dart';
import '../../../organizers/video_manager.dart';

class NowPlaying extends StatefulWidget {
  Function closeParty;
  Orientation orientation;

  NowPlaying({Key? key, required this.closeParty, required this.orientation}) : super(key: key);


  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  bool showAdd = false;

  Widget buildPartyUsers() {
    return Stack(
      children: [
        Positioned(
            top: 0, left: 0,
            child: Container(
              width: 37, height: 37,
              decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  shape: BoxShape.circle
              ),
              child: IconButton(
                onPressed: () { showAdd = true; },
                iconSize: 17,
                icon: Icon(Icons.add,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            )
        ),
        Positioned(
            top: 0, right: 0,
            child: Container(
              width: 37, height: 37,
              decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  shape: BoxShape.circle
              ),

              child: IconButton(
                onPressed: () { widget.closeParty(); },
                iconSize: 17,
                icon: Icon(Icons.exit_to_app_outlined,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            )
        ),
        Container(
          margin: EdgeInsets.all(7),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).shadowColor
          ),
        )
      ],
    );
  }

  Widget buildPlayingInfo() {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
    VideoResource? currentVideo = videoManager.currentVideo;

    if (currentVideo == null) {
      return SizedBox();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(flex: 1,child: SizedBox(),),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: Text("Now Playing",
            style: GoogleFonts.voltaire(
                textStyle: Theme.of(context).textTheme.labelLarge,
                color: Theme.of(context).highlightColor
            ),
          ),
        ),
        const Expanded(flex: 1,child: SizedBox(),),
        Text(videoManager.getTitle(),
          style: GoogleFonts.voltaire(
              textStyle: Theme.of(context).textTheme.headlineSmall
          ),
        ),
        if (currentVideo is Episode && currentVideo.nextEpisode != null)
          GestureDetector(
            onTap: () {
              videoManager.unloadVideo();
              videoManager.downloadVideo(currentVideo.nextEpisode!, (a, b) {});
              videoManager.setEpisode(currentVideo.nextEpisode!);
            },
            child: Container(

              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
              decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  borderRadius: BorderRadius.circular(7)
              ),
              child: Text("Next Episode",
                style: GoogleFonts.voltaire(
                    textStyle: Theme.of(context).textTheme.headlineSmall
                ),
              ),
            ),
          ),
        const Expanded(flex: 1,child: SizedBox(),),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
          color: Theme.of(context).shadowColor,
          borderRadius: BorderRadius.circular(14)
      ),
      child: OrientationBuilder(
          builder: (context, o) {
            Orientation orientation = MediaQuery.of(context).orientation;
            if (orientation == Orientation.portrait) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(flex: 5, child: buildPartyUsers()),
                  const SizedBox(width: 7,),
                  Expanded(flex: 5, child: buildPlayingInfo())
                ],
              );
            }

            return Column(
              children: [
                Expanded(flex: 4, child: buildPartyUsers()),
                const SizedBox(height: 7,),
                Expanded(
                    flex: 3,
                    child: buildPlayingInfo()
                ),
              ],
            );
          }
      ),
    );
  }
}