import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app_drawer.dart';
import 'bottom_deck.dart';
import 'models/profile.dart';
import 'models/arc.dart';
import 'models/volume.dart';
import 'organizers/app_manager.dart';
import 'screens/amv_screen.dart';
import 'screens/anime_screen.dart';
import 'screens/arc_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/home_screen.dart';
import 'screens/manga_screen.dart';
import 'screens/moments_screen.dart';
import 'screens/player_screen.dart';
import 'screens/reader_screen.dart';
import 'screens/user_screen.dart';
import 'utils/my_route_observer.dart';


class Layout extends StatefulWidget {
  late AnimationController controller;
  late Animation<double> animation;

  Layout({Key? key}) : super(key: key);

  @override
  _LayoutState createState() => _LayoutState();
}

class _LayoutState extends State<Layout> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<NavigatorState> _pageNavigationKey = GlobalKey<NavigatorState>();
  Screens currentScreen = Screens.homeScreen;
  FirebaseAuth auth = FirebaseAuth.instance;

  final profilesRef = FirebaseFirestore.instance.collection('profiles')
      .withConverter<Profile>(
    fromFirestore: (snapshot, _) => Profile.fromJson(snapshot.data()!, ID: snapshot.id),
    toFirestore: (p, _) => p.toJson(),
  );

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    widget.controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    widget.animation = Tween<double>(begin: 0, end: 300).animate(widget.controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // routeObserver.subscribe(this, ModalRoute.of(context) as ModalRoute<dynamic>);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  didPopRoute() {
    if (_pageNavigationKey.currentState!.canPop()) {
      _pageNavigationKey.currentState!.maybePop();
      return Future(() => true);
    }

    return Future(() => false);
  }

  void fetchSetProfile(AppManager appManager) async {
    String userId = auth.currentUser!.uid;
    List<QueryDocumentSnapshot<Profile>> profiles = await profilesRef
        .where('userID', isEqualTo: userId)
        .get().then((snapshot) => snapshot.docs);
    if (profiles.isNotEmpty) {
      appManager.setCurrentProfile(
          profiles.map((e) => e.data()).toList()[0]
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    AppManager appManager = Provider.of<AppManager>(context, listen: true);
    Orientation orientation = MediaQuery.of(context).orientation;
    Screens defaultScreen = Screens.homeScreen;
    if (auth.currentUser == null) {
      defaultScreen = Screens.homeScreen;

    }

    return Container(
      color: Theme.of(context).canvasColor,
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          body: Stack(
            children: [
              Navigator(
                key: _pageNavigationKey,
                observers: [MyRouteObserver(context)],
                initialRoute: ScreensRouteMapper().getValue(defaultScreen),
                onGenerateRoute: (settings) {
                  Screens screen = ScreensRouteMapper().getKey(settings.name!);
                  if (screen != currentScreen) {
                    setState(() { currentScreen = screen; });
                  }

                  if (auth.currentUser == null || screen == Screens.userScreen) {
                    return MaterialPageRoute(builder: (context) => const UserScreen(), settings: settings,);
                  }

                  if (appManager.currentProfile == null) {
                      fetchSetProfile(appManager);
                  }

                  if (screen == Screens.homeScreen) {
                    return MaterialPageRoute(builder: (context) => HomeScreen(), settings: settings,);
                  } else if (screen == Screens.animeScreen && appManager.currentTitle != null) {
                    return MaterialPageRoute(builder: (context) => AnimeScreen(settings: settings), settings: settings,);
                  } else if (screen == Screens.mangaScreen) {
                    return MaterialPageRoute(builder: (context) => MangaScreen(settings: settings), settings: settings,);
                  } else if (screen == Screens.playerScreen) {
                    return MaterialPageRoute(builder: (context) => PlayerScreen(pageNavigationKey: _pageNavigationKey,), settings: settings,);
                  } else if (screen == Screens.amvScreen) {
                    return MaterialPageRoute(builder: (context) => const AMVScreen(), settings: settings,);
                  } else if (screen == Screens.savesScreen) {
                    return MaterialPageRoute(builder: (context) => const MomentsScreen(), settings: settings,);
                  } else if (screen == Screens.downloadsScreen) {
                    return MaterialPageRoute(builder: (context) => const DownloadsScreen(), settings: settings,);
                  } else if (screen == Screens.arcScreen) {
                    if (settings.arguments != null) {
                      Arc arcToShow = settings.arguments as Arc;
                      return MaterialPageRoute(builder: (context) => ArcScreen(currentArc: arcToShow,), settings: settings,);
                    }
                  } else if (screen == Screens.readerScreen) {
                    if (settings.arguments != null) {
                      Chapter chapterToShow = settings.arguments as Chapter;
                      return MaterialPageRoute(builder: (context) => ReaderScreen(chapter: chapterToShow,), settings: settings,);
                    }
                  }
                },
              ),
              BottomDeck(
                orientation: orientation,
                scaffoldKey: _scaffoldKey,
                pageNavigationKey: _pageNavigationKey,
                currentScreen: appManager.currentScreen,
                userLoggedIn: auth.currentUser != null,
              ),
            ]
          ),
          drawer: Drawer(
            width: orientation == Orientation.landscape ? 500 : 250,
            child: AppDrawer(
              scaffoldKey: _scaffoldKey,
              pageNavigationKey: _pageNavigationKey,
            )
          ),
        ),
      ),
    );
  }
}


