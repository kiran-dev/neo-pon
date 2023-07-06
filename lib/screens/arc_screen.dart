import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/arc.dart';
import '../models/episode.dart';
import '../organizers/video_manager.dart';
import '../organizers/app_manager.dart';

class ArcScreen extends StatefulWidget {
  Arc currentArc;
  ArcScreen({Key? key, required this.currentArc}) : super(key: key);

  @override
  State<ArcScreen> createState() => _ArcScreenState();
}


class _ArcScreenState extends State<ArcScreen> {
  final episodesRef = FirebaseFirestore.instance.collection('episodes')
      .withConverter<Episode>(
    fromFirestore: (snapshot, _) => Episode.fromJson(snapshot.data()!, ID: snapshot.id),
    toFirestore: (episode, _) => episode.toJson(),
  );

  bool isFetching = false;
  List<Episode> episodesList = [];
  // Arc? currentArc;


  Future<void> fetchEpisodes(int from, int to) async {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
    setState(() => isFetching = true);
    List<QueryDocumentSnapshot<Episode>> episodes = await episodesRef
        .where('arcID', isEqualTo: widget.currentArc.ID)
        // .where('episodeNumber', isLessThanOrEqualTo: to)
        .orderBy('episodeNumber', descending: false)
        .get().then((snapshot) => snapshot.docs);
    if (episodes.isNotEmpty) {
      List<Episode> listEpisodes = episodes.map((e) => e.data()).toList();
      listEpisodes.asMap().forEach((i, e) {
        if (i+1 < listEpisodes.length) e.nextEpisode = listEpisodes[i+1];
      });
      for (Episode e in listEpisodes) {
        e.isDownloaded = await videoManager.checkIfDownloaded(e.ref);
      }
      setState(() {
        episodesList = listEpisodes;
      });
    }
    setState(() => isFetching = false);
  }

  @override
  void initState() {
    fetchEpisodes(widget.currentArc.from, widget.currentArc.to);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, o) {
      Orientation orientation = MediaQuery.of(context).orientation;
      Size screenSize = MediaQuery.of(context).size;
      print(screenSize);
      if (orientation == Orientation.landscape) {
        return Row(
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: ArcPanel(currentArc: widget.currentArc, width: screenSize.width ~/ 2.4),
            ),
            ArcEpisodes(episodesList: episodesList),
            const SizedBox(width: 60,)
          ],
        );
      }

      return Column(
        children: [
          ArcPanel(currentArc: widget.currentArc, height: screenSize.height ~/ 2.4),
          ArcEpisodes(episodesList: episodesList),
          const SizedBox(height: 60,)
        ],
      );
    });
  }
}

class ArcPanel extends StatelessWidget {
  final Arc currentArc;
  final int? width;
  final int? height;

  const ArcPanel({Key? key, required this.currentArc, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'arcTitle',
      flightShuttleBuilder: (BuildContext flightContext,
          Animation<double> animation,
          HeroFlightDirection flightDirection,
          BuildContext fromHeroContext,
          BuildContext toHeroContext,) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, value) {
            return Container(
              color: Color.lerp(Colors.black87, Colors.white, animation.value),
            );
          },
        );
      },
      child: SizedBox(
        height: height?.toDouble(),
        width: width?.toDouble(),
        child: Stack(
          children: [
            FutureBuilder<FileImage?>(
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                if (snapshot.data != null) {
                  return Container(
                      constraints: const BoxConstraints.expand(),
                      child: Image(image: FileImage(snapshot.data!.file), fit: BoxFit.contain,)
                  );
                }

                return const Center(child: Text('...'));
              },
              future: currentArc.getImageResource().getImage(),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                color: Theme.of(context).shadowColor,
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: Text(currentArc.name.toUpperCase(),
                    style: GoogleFonts.voltaire(textStyle: Theme.of(context).textTheme.headlineLarge)
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }
}

class ArcEpisodes extends StatelessWidget {
  final List<Episode> episodesList;

  const ArcEpisodes({Key? key, required this.episodesList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: true);
    AppManager appManager = Provider.of<AppManager>(context, listen: true);

    return Expanded(
      child: ListView.builder(
        itemCount: episodesList.length,
        physics: const BouncingScrollPhysics(),
        // padding: EdgeInsets.only(bottom: 28),
        itemBuilder: (context, index) {
          bool isEpisodeDownloaded = appManager.isResourceDownloaded(episodesList[index].ref);
          return Container(
            color: Theme.of(context).shadowColor,
            // decoration: BoxDecoration(border: Border.fromBorderSide(BorderSide())),
            margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
            child: InkWell(
                onTap: () {
                  videoManager.downloadVideo(episodesList[index], appManager.saveDownloadedRef);
                  videoManager.setEpisode(episodesList[index]);
                  Navigator.pushNamed(context, Screens.playerScreen.route);
                  appManager.setCurrentScreen(Screens.playerScreen);
                },
                onLongPress: () {
                  videoManager.downloadVideo(episodesList[index], appManager.saveDownloadedRef);
                },
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 7),
                                padding: const EdgeInsets.symmetric(horizontal: 7),
                                child: Text(
                                  episodesList[index].episodeNumber.toString(),
                                  style: GoogleFonts.voltaire(textStyle: Theme.of(context).textTheme.headlineMedium),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  episodesList[index].title.split("! ").length > 1
                                      ? episodesList[index].title.split("! ").join("!\n").toString()
                                      : episodesList[index].title.split("? ").join("?\n").toString(),
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
                              episodesList[index].airDate.toString(),
                              style: GoogleFonts.voltaire(
                                textStyle: Theme.of(context).textTheme.labelMedium,
                                color: Theme.of(context).hintColor
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    if (episodesList[index].downloadProgress != null && !isEpisodeDownloaded)
                      Positioned(
                          right: 10,
                          top: 10,
                          child: SizedBox(
                            width: 28,
                            height: 7,
                            child: LinearProgressIndicator(
                              value: episodesList[index].downloadProgress!.progress,
                              color: Theme.of(context).primaryColor,
                              backgroundColor: Theme.of(context).canvasColor,
                            )
                          )
                      ),
                    if (isEpisodeDownloaded)
                      const Positioned(
                          right: 10,
                          top: 10,
                          child: SizedBox(
                              width: 28,
                              height: 7,
                              child: Icon(Icons.ac_unit_outlined, size: 17,),
                          )
                      ),
                  ],
                )
            ),
          );
        },
      ),
    );
  }

}
