import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/amv.dart';
import '../organizers/app_manager.dart';
import '../organizers/video_manager.dart';

List<Map<String, dynamic>> amvJsons = [
  { "title": "He is our captain", "ref": "amv/OP - AMV L@mBerT.mp4" },
  { "title": "Royalty", "ref": "amv/One Piece AMV - Royalty.mp4" },
  { "title": "Middle of the night", "ref": "amv/One Piece [AMV] - Luffy vs Kaido  - Episode 1015 -  Middle Of The Night.mp4" },
  { "title": "Greatest story ever told", "ref": "amv/One Piece _ The Greatest Story Ever Told「ASMV」.mp4" },
  { "title": "Unstoppable", "ref": "amv/Unstoppable - Luffy [One Piece] - AMV.mp4" },
];


class AMVScreen extends StatefulWidget {

  const AMVScreen({Key? key}) : super(key: key);

  @override
  State<AMVScreen> createState() => _AMVScreenState();
}

class _AMVScreenState extends State<AMVScreen> {
  final Reference storageRef = FirebaseStorage.instance.ref();
  List<Amv> Amvs = amvJsons.map((e) => Amv.fromJson(e)).toList();

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
    AppManager appManager = Provider.of<AppManager>(context, listen: false);

  return Container(
    color: Colors.blue,
    child: OrientationBuilder(
      builder: (context, o) {
        Orientation orientation = MediaQuery.of(context).orientation;
        return Center(
          child: ListView(
            scrollDirection: orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              for(Map<String, dynamic> amv in amvJsons)
                 InkWell(
                   onTap: () {
                     Amv av = Amv.fromJson(amv);
                     videoManager.downloadVideo(av, appManager.saveDownloadedRef);
                     videoManager.setAmv(av);
                     Navigator.pushNamed(context, Screens.playerScreen.route);
                     appManager.setCurrentScreen(Screens.playerScreen);
                   },
                   child: SizedBox(
                       height: 250,
                       width: 250,
                       child: Center(child: Text(amv["title"]),)
                   )
                 )
            ],
          )
        );
      },
    )
  );
  }
}
