import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/amv.dart';
import '../models/episode.dart';
import '../models/video_resource.dart';
import '../organizers/app_manager.dart';
import '../organizers/video_manager.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({Key? key}) : super(key: key);

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {

  @override
  void initState() {
    AppManager appManager = Provider.of<AppManager>(context, listen: false);
    appManager.readDownloadedRefs();
    super.initState();
  }

  Widget buildClickable(VideoResource vR) {
    if (vR is Episode) {
      Episode e = vR as Episode;
      return Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 7),
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Text(
                    e.episodeNumber.toString(),
                    style: GoogleFonts.voltaire(textStyle: Theme.of(context).textTheme.headlineMedium),
                    textAlign: TextAlign.justify,
                  ),
                ),
                Expanded(
                  child: Text(
                    e.title.split("! ").length > 1
                        ? e.title.split("! ").join("!\n").toString()
                        : e.title.split("? ").join("?\n").toString(),
                    style: GoogleFonts.voltaire(textStyle: Theme.of(context).textTheme.titleMedium),
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                e.airDate.toString(),
                style: GoogleFonts.voltaire(
                    textStyle: Theme.of(context).textTheme.labelMedium,
                    color: Theme.of(context).hintColor
                ),
              ),
            )
          ],
        ),
      );
    } else if (vR is Amv) {
      Amv a = vR as Amv;
      return SizedBox(
        height: 128,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(child: Text(a.title,
              style: GoogleFonts.voltaire(
                textStyle: Theme.of(context).textTheme.titleLarge
              ),
            )),
          ],
        ),
      );
    } else {
      return Container(
        height: 29,
        child: Text(vR.ref),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
    AppManager appManager = Provider.of<AppManager>(context, listen: true);

    if (appManager.downloadedVideos.isEmpty) {
      return Center(
        child: Text("No Downloads",
          style: GoogleFonts.voltaire(
            textStyle: Theme.of(context).textTheme.headlineLarge
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 256,
          child: Stack(
            children: [
              Center(
                child: Text("Downloads",
                  style: GoogleFonts.voltaire(
                    textStyle: Theme.of(context).textTheme.headlineLarge
                  ),
                ),
              ),
              Positioned(
                top: 28,
                left: 28,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).shadowColor
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.chevron_left,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: appManager.downloadedVideos.length,
            physics: const BouncingScrollPhysics(),
            // padding: EdgeInsets.only(bottom: 28),
            itemBuilder: (context, index) {
              VideoResource vR = appManager.downloadedVideos[index];
              bool isDownloaded = appManager.isResourceDownloaded(vR.ref);

              return Container(
                color: Theme.of(context).shadowColor,
                // decoration: BoxDecoration(border: Border.fromBorderSide(BorderSide())),
                margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
                child: InkWell(
                    onTap: () {
                      if (vR is Episode) {
                        videoManager.setEpisode(vR);
                      } else if (vR is Amv) {
                        videoManager.setAmv(vR);
                      }
                      if (!isDownloaded) {
                        videoManager.downloadVideo(vR, appManager.saveDownloadedRef);
                      }
                      // videoManager.downloadVideo(vR, () {})
                      Navigator.pushNamed(context, Screens.playerScreen.route);
                      appManager.setCurrentScreen(Screens.playerScreen);
                    },
                    child: buildClickable(vR),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}