// navigation/routes.dart
import 'package:flutter/material.dart';
import '../../common/home/views/home_screen.dart';
import '../../common/home/views/tab_screen.dart';

class Routes {
  static const String home = '/home';
  static const String product = '/product';
  static const String tab = '/tab';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case tab:
        return MaterialPageRoute(builder: (_) => TabScreen());
      default:
        return MaterialPageRoute(builder: (_) => HomeScreen()); // Rota padrão
    }
  }
}
