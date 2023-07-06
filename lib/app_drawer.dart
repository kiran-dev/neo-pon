import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'models/profile.dart';
import 'organizers/app_manager.dart';


class AppDrawer extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final GlobalKey<NavigatorState> pageNavigationKey;
  const AppDrawer({Key? key, required this.scaffoldKey, required this.pageNavigationKey}) : super(key: key);

  Widget buildUserBadge(BuildContext context, Profile userProfile) {
    return GestureDetector(
      onTap: () {
        pageNavigationKey.currentState!.pushNamed(Screens.userScreen.route);
      },
      child: Container(
        // height: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).shadowColor,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle, size: 128,
              color: Theme.of(context).primaryColor,
            ),
            Column(
              children: [
                Text(userProfile.name),
                Text(userProfile.tag ?? ""),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildOtherPages(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ListTile(
            onTap: () {
              pageNavigationKey.currentState!.pushNamed(Screens.savesScreen.route);
              scaffoldKey.currentState!.closeDrawer();
            },
            title: Text('Saves',
              style: GoogleFonts.lobsterTwo(
                  textStyle: Theme.of(context).textTheme.bodyLarge),
              textAlign: TextAlign.center,
            )
        ),
      ],
    );
  }

  Widget buildAppActions(BuildContext context, Orientation orientation) {
    AppManager appManager = Provider.of<AppManager>(context, listen: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
            icon: const Icon(Icons.home, size: 28),
            onPressed: () {
              pageNavigationKey.currentState!.pushNamed(Screens.homeScreen.route);
              scaffoldKey.currentState!.closeDrawer();
            }
        ),
        IconButton(
            icon: orientation == Orientation.portrait
                    ? const Icon(Icons.landscape, size: 28)
                    : const Icon(Icons.portrait_sharp, size: 28),
            onPressed: () {

              orientation == Orientation.portrait
                  ? appManager.goLandscape() : appManager.goPortrait();
              // scaffoldKey.currentState!.closeDrawer();
            }
        ),
        IconButton(
            icon: const Icon(Icons.format_paint, size: 28),
            onPressed: () {
              appManager.toggleTheme();
            }
        ),
        IconButton(
            icon: const Icon(Icons.ac_unit_outlined, size: 28),
            onPressed: () {
              pageNavigationKey.currentState!.pushNamed(Screens.downloadsScreen.route);
              scaffoldKey.currentState!.closeDrawer();
            }
        ),
      ],
    );
  }

  Widget buildCurrentParty(BuildContext context) {
    return Container(
      height: 128,
      color: Theme.of(context).shadowColor,
      // child:
    );
  }

  Widget buildLogo() {
    return const Center(child: FlutterLogo(size: 100));
  }

  @override
  Widget build(BuildContext context) {
    AppManager appManager = Provider.of<AppManager>(context, listen: true);
    Profile? userProfile = appManager.currentProfile;

    return OrientationBuilder(builder: (context, o) {
      if (userProfile == null) {
        return Center(
          child: buildLogo(),
        );
      }

      Orientation orientation = MediaQuery.of(context).orientation;
      return Container(
        constraints: const BoxConstraints.expand(),
        color: Theme.of(context).canvasColor,
        padding: const EdgeInsets.all(28),
        child: orientation == Orientation.portrait ?
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                buildUserBadge(context, userProfile!),
                buildOtherPages(context),
                buildCurrentParty(context),
                buildAppActions(context, orientation),
                buildLogo(),
              ]
          )
            :
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: appManager.isKirani()
                        ? MainAxisAlignment.spaceAround
                        : MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        buildUserBadge(context, userProfile!),
                        buildLogo(),
                      ]
                  ),
                ),
                const SizedBox(width: 14,),
                Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildCurrentParty(context),
                        buildOtherPages(context),
                        buildAppActions(context, orientation),
                      ]
                    ),
                )
              ]
          ),
        );
      // );
    });
  }
}