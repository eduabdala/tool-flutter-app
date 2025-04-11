/**
 * @file      screen_model.dart
 * @author    Eduardo Abdala
 * @brief     Contains the `ScreenModel` class that represents a screen/tab in the application.
 *            It stores details like the screen's ID, title, and navigator key.
 * @version   1.0
 * @date      2025-02-04
 * @copyright Copyright (c) 2025
 */

/// @addtogroup ScreenModel
/// @details   This file contains the `ScreenModel` class, which is used to represent a screen or tab 
///            within the application. It holds the title of the tab, the screen widget itself, 
///            and a unique identifier (ID). The class also overrides equality and hash code methods 
///            to ensure unique identification of tabs.
///
/// ============================
/// How to build this component
/// ============================
/// - Use `ScreenModel` to define each tab or screen in the application, specifying its title, 
///   associated widget, and navigator key.
///
/// ============================
/// How to use this component
/// ============================
/// - Create an instance of `ScreenModel` to represent a tab or screen, and pass the necessary 
///   parameters such as the title, screen widget, and a navigator key.
/// @{
library;


import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';  // Make sure to import the uuid package

/// @brief Represents a screen or tab in the application.
/// 
/// The `ScreenModel` class stores the necessary information for a tab or screen in the app, 
/// including a unique identifier, title, the screen widget, and a navigator key for managing 
/// navigation within that tab.
class ScreenModel {
  final String id;  ///< Unique ID for the screen/tab.
  final String title; ///< Title of the screen/tab.
  final Widget screen; ///< The widget representing the screen.
  final GlobalKey<NavigatorState> navigatorKey; ///< Key for the screen's navigator.

  /// @brief Constructor to initialize the screen's title, widget, and navigator key, 
  ///        while generating a unique ID.
  /// 
  /// @param title: The title of the tab or screen.
  /// @param screen: The widget that represents the screen.
  /// @param navigatorKey: The navigator key used to manage navigation within the screen.
  ScreenModel({
    required this.title,
    required this.screen,
    required this.navigatorKey,
  }) : id = const Uuid().v4();  ///< Generating a unique ID for each screen/tab.

  /// @brief Overrides the equality operator to compare two `ScreenModel` instances 
  ///        based on their unique ID.
  /// 
  /// This ensures that two `ScreenModel` instances are considered equal if their 
  /// `id` properties are the same.
  /// 
  /// @param other: The object to compare against.
  /// @return True if the `id` properties are equal; otherwise, false.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScreenModel && other.id == id;
  }

  /// @brief Overrides the hashCode getter to return a hash code based on the screen's unique ID.
  /// 
  /// This is used to ensure that `ScreenModel` instances can be used correctly in collections 
  /// that require hashing (like `Set` or as keys in a `Map`).
  /// 
  /// @return A hash code based on the `id` property.
  @override
  int get hashCode => id.hashCode;
}

/** @}*/ // End of ScreenModel
