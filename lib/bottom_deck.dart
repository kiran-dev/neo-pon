import 'package:flutter/material.dart';
import 'package:neo_pon/organizers/app_manager.dart';
import 'package:provider/provider.dart';

class BottomDeck extends StatelessWidget {
  final Screens currentScreen;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final GlobalKey<NavigatorState> pageNavigationKey;
  final Orientation orientation;
  final bool userLoggedIn;
  const BottomDeck({Key? key,
    required this.currentScreen,
    required this.scaffoldKey,
    required this.pageNavigationKey,
    required this.orientation,
    required this.userLoggedIn
  }) : super(key: key);

  final List<Screens> deckHiders = const [
    Screens.readerScreen,
    Screens.playerScreen,
    Screens.homeScreen,
    Screens.downloadsScreen,
    Screens.savesScreen,
  ];

  List<Widget> buildDeckItems(Orientation orientation, AppManager appManager) {

    Widget backButton = BottomDeckItem(
        text: "",
        icon: Icons.keyboard_arrow_left,
        orientaion: orientation,
        onPressed: () {
          if(pageNavigationKey.currentState!.canPop()) {
            pageNavigationKey.currentState!.pop();
            pageNavigationKey.currentState!.context;
          }
        },
        isSelected: false
    );
    
    Widget drawerButton = BottomDeckItem(
      text: "",
      icon: Icons.sort,
      orientaion: orientation,
      onPressed: () => scaffoldKey.currentState?.openDrawer(),
      isSelected: false,
    );
    
    List<Widget> titleItems = [];
    if (appManager.currentTitle != null) {
      if (appManager.currentTitle!.resources.contains("MANGA")) {
        titleItems.add(
            BottomDeckItem(
              text: "MANGA",
              icon: Icons.art_track,
              orientaion: orientation,
              onPressed: () {
                pageNavigationKey.currentState!.pushNamed(Screens.mangaScreen.route);
                appManager.setCurrentScreen(Screens.mangaScreen);
              },
              isSelected: currentScreen == Screens.mangaScreen,
            )
        );
      }
      if (appManager.currentTitle!.resources.contains("EPISODES")) {
        titleItems.add(BottomDeckItem(
          text: "EPISODES",
          icon: Icons.subscriptions,
          orientaion: orientation,
          onPressed: () {
            appManager.setCurrentScreen(Screens.animeScreen);
            pageNavigationKey.currentState!.pushNamed(Screens.animeScreen.route);
          },
          isSelected: currentScreen == Screens.animeScreen,
        ));
      }

      if (appManager.currentTitle!.resources.contains("AMV")) {
        titleItems.add(BottomDeckItem(
          text: "AMV",
          icon: Icons.headset_mic,
          orientaion: orientation,
          onPressed: () {
            appManager.setCurrentScreen(Screens.amvScreen);
            pageNavigationKey.currentState!.pushNamed(Screens.amvScreen.route);
          },
          isSelected: currentScreen == Screens.amvScreen,
        ));
      }
    }

    Widget? screenItem;
    if (appManager.currentScreen == Screens.userScreen) {
      screenItem = BottomDeckItem(
        text: "PROFILE",
        icon: Icons.person,
        orientaion: orientation,
        onPressed: () {},
        isSelected: appManager.currentScreen == Screens.userScreen,
      );
    } else if (appManager.currentScreen == Screens.savesScreen) {
      screenItem = BottomDeckItem(
        text: "SAVES",
        icon: Icons.photo_library,
        orientaion: orientation,
        onPressed: () {},
        isSelected: currentScreen == Screens.savesScreen,
      );
    }

    List<Widget> buttonsInBetween = [];
    for (Widget w in titleItems) {
      buttonsInBetween.add(w);
      buttonsInBetween.add(SizedBox(
        height: orientation == Orientation.landscape ? 20 : 1,
        width: orientation == Orientation.portrait ? 20 : 1,
      ));
    }
    if (screenItem != null) {
      buttonsInBetween.add(screenItem);
    }

    if (orientation == Orientation.landscape) {
      return [
        drawerButton,
        Column(children: buttonsInBetween,),
        backButton,
      ];
    }
    return [
      backButton,
      Row(children: buttonsInBetween,),
      drawerButton,
    ];
  }

  @override
  Widget build(BuildContext context) {
    AppManager appManager = Provider.of<AppManager>(context, listen: true);
    bool hideDeck = deckHiders.contains(appManager.currentScreen) || !userLoggedIn;

    if (orientation == Orientation.landscape) {
      return Positioned(
        right: hideDeck ? -60 : 0,
        child: Container(
          width: 60,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            border: const Border(top: BorderSide(color: Colors.grey, width: 2)),
            color: Theme.of(context).canvasColor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: buildDeckItems(orientation, appManager),
          )
        ),
      );
    } else {
      return Positioned(
        bottom: hideDeck ? -60 : 0,
        child: Container(
          height: 60,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            border: const Border(top: BorderSide(color: Colors.grey, width: 2)),
            color: Theme.of(context).canvasColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: buildDeckItems(orientation, appManager),
          ),
        ),
      );
    }
  }
}


enum DeckItemPositions { Left, Middle, Right }

class BottomDeckItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isSelected;
  final Orientation orientaion;
  // final DeckItemPositions position;

  const BottomDeckItem({Key? key, required this.icon, required this.text,
    required this.onPressed,
    required this.isSelected, required this.orientaion,
    // required this.position,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Material(
      borderRadius: BorderRadius.circular(30),
      color: isSelected
          ? Theme.of(context).primaryColor
          : Colors.transparent,
      // shape: BoxShape.circle,
      child: InkWell(
          borderRadius: BorderRadius.circular(30),
          splashColor: Colors.grey,
          highlightColor: Theme.of(context).primaryColor,
          // customBorder: Border.(),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 30, color: isSelected
                ? Theme.of(context).highlightColor
                : Theme.of(context).primaryColor,
            ),
          )
      ),
    );
  }

}