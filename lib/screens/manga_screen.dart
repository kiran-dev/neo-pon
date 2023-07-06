import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neo_pon/models/volume.dart';
import 'package:neo_pon/organizers/app_manager.dart';
import 'package:provider/provider.dart';

enum MOVE { FORWARD, BACKWARD }

class MangaScreen extends StatefulWidget {
  RouteSettings settings;
  MangaScreen({Key? key, required this.settings}) : super(key: key);

  @override
  State<MangaScreen> createState() => _MangaScreenState();
}

class _MangaScreenState extends State<MangaScreen> {

  final volumesRef = FirebaseFirestore.instance.collection('volumes')
      .withConverter<Volume>(
    fromFirestore: (snapshot, _) => Volume.fromJson(snapshot.data()!, ID: snapshot.id),
    toFirestore: (v, _) => v.toJson(),
  );

  List<Volume> allVolumes = [];

  @override
  void initState() {
    fetchVolumes();
    super.initState();
  }


  Future<void> fetchVolumes() async {
    AppManager appManager = Provider.of<AppManager>(context, listen: false);

    List<QueryDocumentSnapshot<Volume>> volumes = await volumesRef
        .where("titleID", isEqualTo: appManager.currentTitle!.ID)
        .get().then((snapshot) => snapshot.docs);
    List<Volume> listVolumes = volumes.map((e) => e.data()).toList();
    setState(() {
      allVolumes = listVolumes;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GridView.count(
          physics: const BouncingScrollPhysics(),
          crossAxisCount: 2,
          children: [
            for (Volume v in allVolumes)
              SizedBox(
                  child: GestureDetector(
                  onTap: () {
                    if (v.chapters.length > 1) {
                      Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return VolumePopup(popupVolume: v);
                            },
                            fullscreenDialog: false,
                            settings: widget.settings,
                          )
                      );
                    } else {
                      Navigator.pushNamed(context, Screens.readerScreen.route,
                          arguments: v.chapters[0]);
                    }
                  },
                  child: FutureBuilder<FileImage?>(
                    builder: (context, snapshot) {
                      if (snapshot.data != null && snapshot.connectionState == ConnectionState.done) {
                        return Container(
                          height: 100,
                          decoration: BoxDecoration(
                              image: DecorationImage(image: FileImage(snapshot.data!.file), fit: BoxFit.cover,),
                          ),
                          child: Center(
                            child: Text(v.name),
                          ),
                        );
                      } else {
                        return Container(
                          height: 100,
                          child: Align(
                            child: Text(v.name),
                          ),
                        );
                      }
                    },
                    future: v.getImageResource().getImage(),
                  ),
              ))
          ],
        ),
      ]
    );


  }
}

class VolumePopup extends StatefulWidget {
  Volume popupVolume;

  VolumePopup({Key? key, required this.popupVolume}) : super(key: key);

  @override
  State<VolumePopup> createState() => _VolumePopupState();
}

class _VolumePopupState extends State<VolumePopup> {
  Size? imageSize;

  fetchImageAgain() async {
    FileImage? image = await widget.popupVolume.getImageResource().getImage();
    if (image == null) return;
    ImageStreamListener listener = ImageStreamListener((imageInfo, synchronousCall) {
      setState(() {
        imageSize = Size(
            MediaQuery.of(context).size.width,
            imageInfo.image.height * (MediaQuery.of(context).size.width / imageInfo.image.width).toDouble()
        );
      });
    });
    image!.resolve(const ImageConfiguration()).addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, o) {
        Orientation orientation = MediaQuery.of(context).orientation;
        return Container(
          padding: orientation == Orientation.landscape
                    ? const EdgeInsets.symmetric(horizontal: 60)
                    : const EdgeInsets.symmetric(vertical: 60),
          color: Theme.of(context).canvasColor,
          child: FutureBuilder<FileImage?>(
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              if (snapshot.data != null) {
                Image image = Image(image: FileImage(snapshot.data!.file));
                if (imageSize == null) fetchImageAgain();
                return OrientationBuilder(
                  builder: (context, o) {
                    Orientation orientation = MediaQuery.of(context).orientation;
                    fetchImageAgain();
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        if (orientation == Orientation.portrait)
                          image,
                        if (imageSize != null)
                          Container(
                            width: imageSize!.width,
                            height: imageSize!.height,
                            color: Theme.of(context).shadowColor,
                            child: ListView(
                              physics: const BouncingScrollPhysics(),
                              children: [
                                for (Chapter c in widget.popupVolume!.chapters)
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(Screens.readerScreen.route, arguments: c);

                                    },
                                    child: SizedBox(
                                      height: 84,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                c.number.toString(),
                                                style: GoogleFonts.voltaire(
                                                    textStyle: Theme.of(context).textTheme.headlineMedium,
                                                    color: Theme.of(context).primaryColor

                                                ),
                                                overflow: TextOverflow.fade,
                                              ),
                                              const SizedBox(width: 28,),
                                              Text(
                                                c.name,
                                                style: GoogleFonts.voltaire(
                                                    textStyle: Theme.of(context).textTheme.headlineMedium,
                                                    color: Theme.of(context).primaryColor
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                // softWrap: true,
                                                maxLines: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ),
                          if (orientation == Orientation.landscape)
                            Align(child: image, alignment: Alignment.centerLeft,),
                      ],
                    );
                  }
                );
              }

              return const Center(child: Text('...'));
            },
            future: widget.popupVolume.getImageResource().getImage(),
          ),
        );
      }
    );
  }
}


