import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neo_pon/components/player/moment_player.dart';
import 'package:provider/provider.dart';

import '../models/moment.dart';
import '../models/save.dart';
import '../models/snap.dart';
import '../organizers/app_manager.dart';


enum DisplaySaves { ALL, MOMENT, SNAP }

class MomentsScreen extends StatefulWidget {
  const MomentsScreen({Key? key}) : super(key: key);

  @override
  State<MomentsScreen> createState() => _MomentsScreenState();
}

class _MomentsScreenState extends State<MomentsScreen> {
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
  FirebaseAuth auth = FirebaseAuth.instance;
  List<Save> mySaves = [];
  bool displayTitles = false;
  bool showAllTitles = true;
  DisplaySaves displayMode = DisplaySaves.ALL;
  bool showSingleTitle = false;
  String? playingMomentID;
  String? showOnlyTitleID;

  List<String> months = [
    "January", "February", "March",
    "April", "May", "June", "July",
    "August", "September", "October",
    "November", "December",
  ];

  void fetchMoments() async {
    AppManager appManager = Provider.of<AppManager>(context, listen: false);
    Query<Moment> query = momentsRef.where("userID", isEqualTo: auth.currentUser!.uid);
    if (appManager.currentTitle != null) {
      query = query.where("titleID", isEqualTo: appManager.currentTitle!.ID);
      query = query.orderBy("createdAt", descending: true);
      query = query.limit(displayMode == DisplaySaves.ALL ? 10 : 20);
    }
    List<QueryDocumentSnapshot<Moment>> moments = await query.get()
        .then((snapshot) => snapshot.docs);
    setState(() {
      mySaves.addAll(moments.map((m) => m.data()));
    });
  }

  void fetchSnaps() async {
    AppManager appManager = Provider.of<AppManager>(context, listen: false);
    Query<Snap> query = snapsRef.where("userID", isEqualTo: auth.currentUser!.uid);
    if (appManager.currentTitle != null) {
      query = query.where("titleID", isEqualTo: appManager.currentTitle!.ID);
      query = query.orderBy("createdAt", descending: true);
      query = query.limit(displayMode == DisplaySaves.ALL ? 10 : 20);
    }
    List<QueryDocumentSnapshot<Snap>> snaps = await query.get()
        .then((snapshot) => snapshot.docs);
    setState(() {
      mySaves.addAll(snaps.map((s) => s.data()));
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMoments();
    fetchSnaps();
  }

  String timeText(int ms) {
    DateTime recordTime = DateTime.fromMillisecondsSinceEpoch(ms);
    DateTime nowTime = DateTime.now();

    Duration difference = nowTime.difference(recordTime);
    if (difference < const Duration(hours: 1)) {
      return "${difference.inMinutes}m ago";
    } else if (difference < const Duration(hours: 24)) {
      return "${difference.inHours}hrs ago";
    } else if (difference < const Duration(hours: 48)) {
      return "A day ago";
    } else {
      return "${recordTime.day} ${months[recordTime.month]}";
    }
  }

  Widget buildSaved(Save s) {
    Widget detailsRow = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              (() {
                String titleText = "";
                if (s is Moment) {
                  titleText = s.title ?? "";
                } else if (s is Snap) {
                  titleText = s.title ?? "";
                }
                return titleText;
              })(),
              style: GoogleFonts.voltaire(
                textStyle: Theme.of(context).textTheme.titleLarge,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 7),
            child: Text(timeText(s.createdAt),
              style: GoogleFonts.voltaire(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                  color: Theme.of(context).shadowColor,
                  shadows: [
                    Shadow(color: Theme.of(context).primaryColor, blurRadius: 3)
                  ]
              ),
            ),
          ),
        ]
    );

    return GestureDetector(
      onTap: () {
        if (s is Moment) {
          setState(() {
            playingMomentID = s.ID;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
            color: Theme.of(context).shadowColor,
            borderRadius: BorderRadius.circular(7)
        ),
        child: Column(
          children: [
            if (s is Snap)
              Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor
                  ),
                  child: s.coverImage != null
                      ? Image(image: s.coverImage!) : const SizedBox()
              ),
            if (s is Moment)
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).shadowColor
                      ),
                      child: s.coverImage != null
                          ? Image(image: s.coverImage!) : const SizedBox()
                  ),
                  if (playingMomentID != s.ID)
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Theme.of(context).shadowColor)
                          ]
                        ),
                          child: Icon(Icons.play_arrow, size: 128,)),
                    ),
                  if (playingMomentID == s.ID)
                    MomentPlayer(currentMoment: s),
                ],
              ),
            detailsRow,
          ],
        ),
      ),
    );
  }

  Widget buildPanel() {
    return Stack(
      children: [
        Center(
            child: displayTitles
            ? SizedBox()
            : Text("My Saves",
              style: GoogleFonts.voltaire(
                textStyle: Theme.of(context).textTheme.headlineLarge
              ),
            )
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).shadowColor
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_outlined),
              iconSize: 28,
              onPressed: () {
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: showOnlyTitleID == null ? Theme.of(context).highlightColor : Colors.transparent
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_7_sharp),
              iconSize: 28,
              onPressed: () {
                setState(() {
                  displayTitles = !displayTitles;
                });
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor
            ),
            child: IconButton(
              color: Theme.of(context).highlightColor,
              icon: Icon(
                  (() {
                    if (displayMode == DisplaySaves.MOMENT) return Icons.videocam_outlined;
                    else if (displayMode == DisplaySaves.SNAP) return Icons.camera_alt_outlined;
                    else return Icons.select_all_outlined;
                  })()
              ),
              iconSize: 28,
              onPressed: () {
                setState(() {
                  DisplaySaves next;
                  if (displayMode == DisplaySaves.ALL) next = DisplaySaves.MOMENT;
                  else if (displayMode == DisplaySaves.MOMENT) next = DisplaySaves.SNAP;
                  else next = DisplaySaves.ALL;
                  setState(() {
                    displayMode = next;
                  });
                });
              },
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (mySaves.isEmpty) {
      return Center(
        child: Text("Fetching moments...",
          style: GoogleFonts.voltaire(
            textStyle: Theme.of(context).textTheme.displayMedium
          ),
        ),
      );
    }

    List<Save> finalSaves = mySaves.where((s) {
      if (displayMode == DisplaySaves.SNAP) return s is Snap;
      else if (displayMode == DisplaySaves.MOMENT) return s is Moment;
      else return true;
    }).toList();
    finalSaves.sort((sA, sB) => -sA.createdAt.compareTo(sB.createdAt));

    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.portrait) {
        return Column(
          children: [
            Container(
              height: 256,
              color: Colors.greenAccent,
              child: buildPanel()
            ),
            Expanded(
              // padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      for (Save s in finalSaves)
                        buildSaved(s),
                    ],
                  ),
                )
            ),
          ],
        );
      }

      return Row(
        children: [
          Container(
            width: 256,
            color: Colors.greenAccent,
            child: buildPanel(),
          ),
          Expanded(
            // padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    for (Save s in finalSaves)
                      buildSaved(s),
                  ],
                ),
              )
          ),
        ],
      );
    });
  }
}