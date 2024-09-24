/***********************************************************************
 * $Id$        theme_provider.dart          2024-09-24
 *//**
 * @file        theme_provider.dart
 * @brief       Theme provider for managing application themes
 * @version     1.0
 * @date        24. Sep. 2024
 * @author      Eduardo Abdala
 *************************************************************************/
/// @addtogroup  ThemeProvider Theme Provider Class
/// @{
library;


import 'package:flutter/material.dart';

/// @brief Manages light and dark themes for the application
/// 
/// This class provides functionality to switch between light and dark
/// themes, allowing the application to respond to user preferences.
class ThemeProvider extends ChangeNotifier {
  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light, ///< Defines the light theme brightness
    primaryColor: Colors.blue, ///< Primary color for the light theme
    scaffoldBackgroundColor: Colors.white, ///< Background color for the scaffold
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black), ///< Text style for body large
      bodyMedium: TextStyle(color: Colors.black), ///< Text style for body medium
      displayLarge: TextStyle(color: Colors.black), ///< Text style for display large
      displayMedium: TextStyle(color: Colors.black), ///< Text style for display medium
    ),
  );

  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark, ///< Defines the dark theme brightness
    primaryColor: Colors.blue, ///< Primary color for the dark theme
    scaffoldBackgroundColor: Colors.black, ///< Background color for the scaffold
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white), ///< Text style for body large
      bodyMedium: TextStyle(color: Colors.white), ///< Text style for body medium
      displayLarge: TextStyle(color: Colors.white), ///< Text style for display large
      displayMedium: TextStyle(color: Colors.white), ///< Text style for display medium
    ),
  );

  ThemeData _currentTheme; ///< Holds the current theme

  /// @brief Constructor for ThemeProvider
  /// 
  /// Initializes the provider with the default light theme.
  ThemeProvider() : _currentTheme = ThemeData.light();

  /// @brief Gets the current theme
  /// 
  /// @return The current ThemeData being used
  ThemeData get currentTheme => _currentTheme;

  /// @brief Toggles between light and dark themes
  /// 
  /// This method switches the current theme based on the 
  /// current brightness and notifies listeners of the change.
  void toggleTheme() {
    if (_currentTheme.brightness == Brightness.dark) {
      _currentTheme = _lightTheme; ///< Switch to light theme
    } else {
      _currentTheme = _darkTheme; ///< Switch to dark theme
    }
    notifyListeners(); ///< Notifies listeners about the theme change
  }
}
/** @} */
