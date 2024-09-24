/***********************************************************************
 * $Id$        main.dart                2024-09-24
 *//**
 * @file        main.dart
 * @brief       Main entry point for the Flutter application
 * @version     1.0
 * @date        24. Sep. 2024
 * @author      Eduardo Abdala
 *************************************************************************/
/// @addtogroup  Main Main Application
/// @{
library;

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

/// @brief Main entry point of the application
/// 
/// This function initializes the Flutter framework and loads the screen 
/// models before running the application. It sets up a theme provider 
/// for managing light and dark modes.
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); ///< Ensures proper initialization of widgets
  List<ScreenModel> screens = await loadScreens(); ///< Loads the screen models from a JSON source
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(), ///< Provides theme management to the widget tree
      child: MyApp(screens: screens), ///< Starts the main application widget
    ),
  );
}

/// @brief Main application widget
/// 
/// This widget builds the overall structure of the application, 
/// including the material theme and routing for various screens.
class MyApp extends StatelessWidget {
  final List<ScreenModel> screens; ///< List of screen models to be used in the app

  /// @brief Constructor for the MyApp class
  /// 
  /// Initializes the application with the given screen models.
  /// 
  /// @param screens List of screen models
  const MyApp({super.key, required this.screens});

  /// @brief Builds the main widget for the application
  /// 
  /// This method constructs the MaterialApp widget that defines the 
  /// application's theme, home screen, and routes.
  /// 
  /// @param context Current application context
  /// @return Widget Representation of the application
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); ///< Accesses the current theme provider
    return MaterialApp(
      debugShowCheckedModeBanner: false, ///< Hides the debug banner in the app
      theme: themeProvider.currentTheme, ///< Applies the current theme
      home: ProductScreen(screens: screens), ///< Sets the home screen to ProductScreen
      routes: {
        for (var screen in screens) '/${screen.id}': (context) => DynamicScreen(screen: screen), ///< Dynamic routes for each screen
        '/printer': (context) => Escp(), ///< Route for the printer screen
        '/cashRecycler': (context) => CashRecycler(), ///< Route for the cash recycler screen
        '/antiskimmingSu': (context) => SuChartApp() ///< Route for the anti-skimming chart screen
      },
    );
  }
}
/** @} */
