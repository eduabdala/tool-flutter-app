/***********************************************************************
 * $Id$        screen.dart                2024-09-24
 *//**
 * @file        screen.dart
 * @brief       Model for application screens
 * @version     1.0
 * @date        24. Sep. 2024
 * @author      Eduardo Abdala
 *************************************************************************/
/// @addtogroup  ScreenModel Screen Model
/// @{
library;

import 'component.dart';

/// @brief Represents a screen in the application
/// 
/// This class encapsulates the properties of a screen, including its 
/// ID, title, and components. It provides a factory method for 
/// creating an instance from a JSON object.
class ScreenModel {
  final String id; ///< The unique identifier for the screen.
  final String title; ///< The title of the screen.
  final List<Component> components; ///< A list of components that the screen contains.

  /// @brief Constructor for the ScreenModel class
  /// 
  /// Initializes the screen with the specified ID, title, and components.
  /// 
  /// @param id Unique identifier for the screen.
  /// @param title Title of the screen.
  /// @param components List of components to be displayed on the screen.
  ScreenModel({required this.id, required this.title, required this.components});

  /// @brief Creates a ScreenModel instance from a JSON object
  /// 
  /// This factory method takes a JSON representation of a screen and 
  /// constructs a ScreenModel instance.
  /// 
  /// @param json A map containing screen properties, including 'id',
  /// 'title', and 'components'.
  /// @return A ScreenModel instance populated with data from the JSON.
  factory ScreenModel.fromJson(Map<String, dynamic> json) {
    var componentsFromJson = json['components'] as List; ///< Extracts components from JSON
    List<Component> componentsList = componentsFromJson.map((i) => Component.fromJson(i)).toList(); ///< Converts to a list of Component

    return ScreenModel(
      id: json['id'], ///< Sets the screen ID
      title: json['title'], ///< Sets the screen title
      components: componentsList, ///< Sets the list of components
    );
  }
}
/** @} */
