import 'package:flutter/material.dart';
import 'package:flutter_app/src/screens/generated_screens/cash_recycler.dart';
import 'package:flutter_app/src/screens/generated_screens/printer.dart';
import 'package:flutter_app/src/screens/generated_screens/su_chart_app.dart';
import 'src/models/json_loader.dart';
import 'src/models/screen.dart';
import 'src/screens/dynamic_screen.dart';
import 'src/screens/product_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/components/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<ScreenModel> screens = await loadScreens();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(screens: screens),
    ),
  );
}

class MyApp extends StatelessWidget {
  final List<ScreenModel> screens;

  const MyApp({super.key, required this.screens});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
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
