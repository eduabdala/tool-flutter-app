import 'package:flutter/material.dart';
import 'models/json_loader.dart';
import 'models/screen.dart';
import 'screens/dynamic_screen.dart';
import 'screens/product_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<ScreenModel> screens = await loadScreens();
  runApp(MyApp(screens: screens));
}

class MyApp extends StatelessWidget {
  final List<ScreenModel> screens;

  MyApp({required this.screens});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProductScreen(screens: screens),
      routes: {
        for (var screen in screens) '/${screen.id}': (context) => DynamicScreen(screen: screen),
        
      },
    );
  }
}