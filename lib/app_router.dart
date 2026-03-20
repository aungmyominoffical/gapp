import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
    '/': (context) => const HomeScreen(),
  };

  static void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }
}
