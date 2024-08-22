import 'package:flutter/material.dart';
import 'package:flutter_app/screens/generated_screens/cash_recycler.dart';
import 'package:flutter_app/screens/generated_screens/printer.dart';
import 'package:flutter_app/screens/generated_screens/su_chart_app.dart';
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

  const MyApp({super.key, required this.screens});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProductScreen(screens: screens),
      routes: {
        for (var screen in screens) '/${screen.id}': (context) => DynamicScreen(screen: screen),
        '/printer': (context) => Escp(),
        '/cashRecycler': (context) => CashRecycler(),
        '/antiskimmingSu': (context) => SuChartApp()
      },
    );
  }
}