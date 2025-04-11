/**
 * @file      tab_model.dart
 * @author    Eduardo Abdala
 * @brief     Defines the model for representing a tab in the application.
 *            This model stores information about the title and widget associated with a tab.
 * @version   1.0
 * @date      2025-02-04
 * @copyright Copyright (c) 2025
 */

/// @addtogroup TabModel
/// @details   This file defines the `TabModel` class, which is used to represent an individual
///            tab in the application. It includes a title for the tab and the widget to be
///            displayed within that tab.
///
/// ============================
/// How to build this component
/// ============================
/// - Create instances of `TabModel` to represent tabs within your app.
/// - Each tab will have a title and a widget, which is used to display the content of that tab.
///
/// ============================
/// How to use this component
/// ============================
/// - Instantiate the `TabModel` by providing a `title` and a `widget` for the tab.
/// - Store instances of `TabModel` in a collection to manage multiple tabs in your application.
/// @{
library;


import 'package:flutter/widgets.dart';

/// @brief Represents a single tab in the application.
/// 
/// This model stores the title of the tab and the widget that is displayed when the tab is selected.
/// It is typically used in tab management systems, such as in a tab bar or tab navigation.
/// 
/// @param title: The title of the tab.
/// @param widget: The widget to be displayed when the tab is selected.
class TabModel {
  final String title; ///< The title of the tab.
  final Widget widget; ///< The widget to display for the tab.

  TabModel({required this.title, required this.widget});
}

/** @}*/ // End of TabModel
