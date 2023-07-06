import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/arc.dart';
import '../models/titil.dart';
import '../organizers/app_manager.dart';
import 'arc_screen.dart';

enum MOVE { FORWARD, BACKWARD }

class AnimeScreen extends StatefulWidget {
  RouteSettings settings;
  AnimeScreen({Key? key, required this.settings}) : super(key: key);

  @override
  State<AnimeScreen> createState() => _AnimeScreenState();
}


class _AnimeScreenState extends State<AnimeScreen> {
  final Reference storageRef = FirebaseStorage.instance.ref();

  final arcsRef = FirebaseFirestore.instance.collection('arcs')
      .withConverter<Arc>(
        fromFirestore: (snapshot, _) => Arc.fromJson(snapshot.data()!, ID: snapshot.id),
        toFirestore: (episode, _) => {},
      );

  bool isFetching = false;
  List<Arc> arcs = [];
  bool isScaling = false;

  Future<void> fetchArcs(String titleID) async {
    setState(() => isFetching = true);
    List<QueryDocumentSnapshot<Arc>> arcsList = await arcsRef
        .where('titleID', isEqualTo: titleID)
        .get().then((snapshot) => snapshot.docs);
    setState(() => isFetching = false);
    if (arcsList.isNotEmpty) {
      List<Arc> arcObjects = arcsList.map((e) => e.data()).toList();
      arcObjects.sort((a, b) => a.order - b.order);
      setState(() => arcs = arcObjects);
    }
  }

  @override
  void initState() {
    AppManager appManager = Provider.of<AppManager>(context, listen: false);
    Titil currentTitle = appManager.currentTitle!;
    fetchArcs(currentTitle.ID);
    super.initState();
    // fetchEpisodes(100, 200);
  }

  void toggleScrolling(bool state) {
    setState(() {isScaling = state;});
  }

  @override
  Widget build(BuildContext context) {
    AppManager appManager = Provider.of<AppManager>(context, listen: false);


    Titil currentTitle = appManager.currentTitle!;

    return OrientationBuilder(builder: (context, o) {
      Orientation orientation = MediaQuery.of(context).orientation;
      if (orientation == Orientation.portrait) {
        List<Widget> layoutWidgets = [];
        if (currentTitle.arcsLayout != null) {
          int counter = 0;
          while (counter < currentTitle.arcsLayout!.length) {
            if (currentTitle.arcsLayout![counter].crossAxisFraction == 1) {
              layoutWidgets.add(
                  ArcTile(
                    settings: widget.settings,
                    arc: arcs.length > counter ? arcs[counter] : null,
                    height: (currentTitle.arcsLayout![counter].mainAxisScale) * MediaQuery.of(context).size.width,
                  )
              );
              counter = counter + 1;
            } else if (currentTitle.arcsLayout![counter].crossAxisFraction < 1) {
              layoutWidgets.add(Row(
                children: [
                  ArcTile(
                    settings: widget.settings,
                    arc: arcs.length > counter ? arcs[counter] : null,
                    height: currentTitle.arcsLayout![counter].mainAxisScale * MediaQuery.of(context).size.width / 2,
                    width: currentTitle.arcsLayout![counter].crossAxisFraction * MediaQuery.of(context).size.width,
                  ),
                  ArcTile(
                    settings: widget.settings,
                    arc: arcs.length >= counter + 1 ? arcs[counter + 1] : null,
                    height: currentTitle.arcsLayout![counter + 1].mainAxisScale * MediaQuery.of(context).size.width / 2,
                    width: currentTitle.arcsLayout![counter + 1].crossAxisFraction * MediaQuery.of(context).size.width,
                  )
                ],
              ));
              counter = counter + 2;
            }
          }
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: layoutWidgets
          )
        );
    } else {
        List<Widget> layoutWidgets = [];
        if (currentTitle.arcsLayout != null) {
          int counter = 0;
          while (counter < currentTitle.arcsLayout!.length) {
            if (currentTitle.arcsLayout![counter].crossAxisFraction == 1) {
              layoutWidgets.add(
                  ArcTile(
                    settings: widget.settings,
                    arc: arcs.length > counter ? arcs[counter] : null,
                    width: (currentTitle.arcsLayout![counter].mainAxisScale - 0.14) * MediaQuery.sizeOf(context).width,
                  )
              );
              counter = counter + 1;
            } else if (currentTitle.arcsLayout![counter].crossAxisFraction < 1) {
              layoutWidgets.add(Column(
                children: [
                  ArcTile(
                    settings: widget.settings,
                    arc: arcs.length > counter ? arcs[counter] : null,
                    width: currentTitle.arcsLayout![counter].mainAxisScale * MediaQuery.of(context).size.width / 2.8,
                    height: currentTitle.arcsLayout![counter].crossAxisFraction * MediaQuery.sizeOf(context).height,
                  ),
                  ArcTile(
                    settings: widget.settings,
                    arc: arcs.length >= counter + 1 ? arcs[counter + 1] : null,
                    width: currentTitle.arcsLayout![counter + 1].mainAxisScale * MediaQuery.of(context).size.width / 2.8,
                    height: currentTitle.arcsLayout![counter + 1].crossAxisFraction * MediaQuery.sizeOf(context).height,
                  )
                ],
              ));
              counter = counter + 2;
            }
          }
        }
        return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
                children: layoutWidgets
            )
        );
      }
    });
  }
}

class ArcTile extends StatefulWidget {
  Arc? arc;
  double? height;
  double? width;
  RouteSettings settings;
  ArcTile({Key? key, this.arc, this.height, this.width, required this.settings}) : super(key: key);

  @override
  State<ArcTile> createState() => _ArcTileState();
}

class _ArcTileState extends State<ArcTile> {

  double? tileWidth;
  double? tileHeight;
  double horizontalScale = 1.0;


  String? arcImageUrl;

  @override
  void initState() {
    super.initState();
    tileHeight = widget.height;
    tileWidth = widget.width;
  }


  @override
  Widget build(BuildContext context) {
    AppManager appManager = Provider.of(context, listen: true);
    if (widget.arc is Arc) {

      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Navigator.push(context, MaterialPageRoute(builder: (context) => ArcScreen(arc: arc)),);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return ArcScreen(currentArc: widget.arc!);
              },
              fullscreenDialog: true,
              settings: widget.settings
            )
          );
        },
        child: Hero(
            tag: 'arcTile',
            flightShuttleBuilder: (BuildContext flightContext,
                Animation<double> animation,
                HeroFlightDirection flightDirection,
                BuildContext fromHeroContext,
                BuildContext toHeroContext,) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, value) {
                  return Container(
                    color: Color.lerp(Colors.white, Colors.black87, animation.value),
                  );
                },
              );
            },
            child: SizedBox(
            // color: const Color.fromARGB(255, 227, 186, 75),
              height: tileHeight,
              width: tileWidth,
              child: Stack(
                children: [
                  Opacity(
                    opacity: 0.8,
                    child: FutureBuilder<FileImage?>(
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                          return Center(child: Text(snapshot.error.toString()));
                        }

                        if (snapshot.data != null) {
                          return Container(
                              constraints: const BoxConstraints.expand(),
                              child: Image(image: FileImage(snapshot.data!.file), fit: BoxFit.cover,)
                          );
                        }

                        return const Center(child: Text('...'));
                      },
                      future: widget.arc?.getImageResource().getImage(),
                    ),
                  ),
                  Positioned.directional(
                    textDirection: TextDirection.ltr,
                    // alignment: Alignment.bottomCenter,
                    bottom: 5,
                    end: 5,
                    child: Container(
                      color: Theme.of(context).shadowColor,
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                      child: Text(widget.arc!.name.toUpperCase(),
                        style: GoogleFonts.voltaire(textStyle: Theme.of(context).textTheme.headline3)
                      ),
                    ),
                  )
                ],
              )
          ),
        ),
      );
    }
    return SizedBox(
      height: tileHeight,
      width: tileWidth,
      child: Container(
          decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.black)),
          // color: Colors.blueGrey,
          child: const Center(child: Text("..."),)
      ),
    );
  }
}