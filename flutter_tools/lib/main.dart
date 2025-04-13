/**
 * @file      main.dart
 * @author    Eduardo Abdala (eduardo.abdala@perto.com.br)
 * @brief     Main entry point of the Flutter application, which initializes the 
 *            theme and tab management system using providers.
 * @version   1.0
 * @date      2025-02-04
 * @copyright Copyright (c) 2025
 */

/// @addtogroup Application
/// @details   This file contains the main entry point of the Flutter application.
///            It initializes the application with providers for managing themes
///            and tab navigation.
///
/// ============================
/// How to build this component
/// ============================
/// This component initializes the app with necessary providers such as `ThemeNotifier`
/// and `TabManager`, which manage the theme settings and tabs of the application respectively.
///
/// ============================
/// How to use this component
/// ============================
/// - The `ThemeNotifier` allows the toggling between light and dark themes.
/// - The `TabManager` handles the addition, removal, and selection of tabs within the application.
/// @{
library;


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'common/home/views/tab_screen.dart';
import 'core/themes/theme_data.dart';
import 'core/themes/theme_provider.dart';
import 'common/home/models/tab_manager.dart';

/// @brief Main function that runs  Flutter app.
/// 
/// This function initializes the athepplication by providing necessary services, such as
/// theme management and tab management, using `MultiProvider`. It then starts the app
/// with the `MyApp` widget.
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),  ///< Provides theme management functionality
        ChangeNotifierProvider(create: (_) => TabManager()),  ///< Provides tab management functionality
      ],
      child: const MyApp(),  ///< The root widget of the application
    ),
  );
}

/// @brief Main application widget.
/// 
/// The `MyApp` widget is the root of the application. It listens to the `ThemeNotifier`
/// provider to determine whether to use the light or dark theme and then sets the theme
/// accordingly. It also sets the home screen of the application to be the `TabScreen`.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// @brief Builds the widget tree of the application.
  /// 
  /// @param context: The build context used for accessing provider values.
  /// 
  /// @return Widget: The root widget of the application, which includes the theme and
  ///         home screen.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeNotifier>(context);  ///< Get the current theme provider

    return MaterialApp(
      debugShowCheckedModeBanner: false,  ///< Hides the debug banner in the app
      theme: themeProvider.isDarkMode ? CustomTheme.darkTheme() : CustomTheme.lightTheme(),  ///< Apply the selected theme
      home: const TabScreen(),  ///< Set the home screen to the TabScreen widget
    );
  }
}

/** @}*/ // End of Application
