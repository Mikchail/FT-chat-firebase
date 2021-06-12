import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationService {
  late GlobalKey<NavigatorState> navigatorKey;
  static NavigationService instance = NavigationService();
  NavigationService(){
    navigatorKey = GlobalKey<NavigatorState>();
  }
  Future<dynamic> navigatorToReplacement(String _routeName) {
    return navigatorKey.currentState!.pushReplacementNamed(_routeName);
  }

  Future<dynamic> navigatorTo(String _routeName) {
    return navigatorKey.currentState!.pushNamed(_routeName);
  }

  Future<dynamic> navigatorToRoute(MaterialPageRoute _route) {
    return navigatorKey.currentState!.push(_route);
  }

  void goBack(){
    return navigatorKey.currentState!.pop();
  }
}
