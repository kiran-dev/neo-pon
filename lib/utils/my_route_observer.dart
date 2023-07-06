import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../organizers/app_manager.dart';
import '../organizers/video_manager.dart';

class MyRouteObserver extends RouteObserver<MaterialPageRoute<dynamic>> {
  final BuildContext _context;

  MyRouteObserver(this._context);


  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is MaterialPageRoute && previousRoute is MaterialPageRoute) {
      if (previousRoute.settings.name == Screens.playerScreen.route) {
        VideoManager videoManager = Provider.of<VideoManager>(_context, listen: false);
        videoManager.unloadVideo();
      }

      var screenRoute = route.settings.name;
      if (screenRoute != null) {
        Screens routeCurrentScreen = ScreensRouteMapper().getKey(screenRoute!);
        AppManager appManager = Provider.of<AppManager>(_context, listen: false);
        appManager.setCurrentScreen(routeCurrentScreen);
      }
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is MaterialPageRoute) {
      var screenRoute = newRoute.settings.name;
      if (screenRoute != null) {
        Screens routeCurrentScreen = ScreensRouteMapper().getKey(screenRoute!);
        AppManager appManager = Provider.of<AppManager>(_context, listen: false);
        appManager.setCurrentScreen(routeCurrentScreen);
      }
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is MaterialPageRoute && route is MaterialPageRoute) {
      var screenRoute = previousRoute.settings.name;
      var newScreenRoute = route.settings.name;
      if (newScreenRoute != null) {
        Screens routeCurrentScreen = ScreensRouteMapper().getKey(newScreenRoute!);
        AppManager appManager = Provider.of<AppManager>(_context, listen: false);
        appManager.setCurrentScreen(routeCurrentScreen);
      }
      if (screenRoute == Screens.playerScreen.route) {
        VideoManager videoManager = Provider.of<VideoManager>(_context, listen: false);
        videoManager.unloadVideo();
      }
    }
  }
}