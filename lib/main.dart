import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:neo_pon/layout.dart';
import 'package:neo_pon/organizers/app_manager.dart';
import 'package:neo_pon/organizers/party_manager.dart';
import 'package:neo_pon/theme.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_core/firebase_core.dart';

import 'organizers/video_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  FirebaseOptions options = const FirebaseOptions(
    apiKey: "AIzaSyDHAibWAkvNjg-zFeuB8AcAJ-kY-QchegY",
    authDomain: "neo-pon.firebaseapp.com",
    projectId: "neo-pon",
    storageBucket: "neo-pon.appspot.com",
    messagingSenderId: "356120501891",
    appId: "1:356120501891:web:a502d5a5206108d1e485b6",
    measurementId: "G-6YZDH36RZT",
  );
  await Firebase.initializeApp(options: options);
  runApp(MyApp());
}

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AppManager()),
          ChangeNotifierProvider(create: (context) => VideoManager()),
          ChangeNotifierProvider(create: (context) => PartyManager()),
        ],
        child: Builder(
          builder: (BuildContext context) {
            AppManager appManager = Provider.of<AppManager>(context, listen: true);

            return MaterialApp(
              theme: appManager.currentTheme == ViewTheme.LIGHT ? AppTheme.light() : AppTheme.dark(),
              title: 'Words Everyday',
              navigatorObservers: [routeObserver],
              home: Layout(),
              debugShowCheckedModeBanner: false,
            );
          }
        )
        // child: MaterialApp(
        //   theme: AppTheme.dark(),
        //   title: 'Words Everyday',
        //   navigatorObservers: [routeObserver],
        //   // TODO: Replace with Router widget
        //   home: Layout(),
        //   debugShowCheckedModeBanner: false,
        // ),
    );
  }
}

