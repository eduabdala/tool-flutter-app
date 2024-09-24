/***********************************************************************
 * $Id$        component.dart              2024-09-24
 *//**
 * @file        component.dart
 * @brief       Definition of the Component class for UI elements
 * @version     1.0
 * @date        24. Sep. 2024
 * @author      Eduardo Abdala
 *************************************************************************/
/** @addtogroup  Component Component Class
 * @{
 */

/// @brief Represents a UI component in the application
/// 
/// This class encapsulates the properties of a UI component, including 
/// its type, content, optional style, and actions associated with it.
class Component {
  final String type; ///< The type of the component (e.g., button, textbox)
  final Map<String, dynamic> content; ///< The content of the component
  final Map<String, dynamic>? style; ///< Optional styling for the component
  final Map<String, dynamic>? action; ///< Optional action to be performed by the component

  /// @brief Constructor for the Component class
  /// 
  /// Initializes a Component instance with the specified type, content,
  /// optional style, and action.
  /// 
  /// @param type The type of the component
  /// @param content The content of the component
  /// @param style Optional styling for the component
  /// @param action Optional action to be performed
  Component({required this.type, required this.content, this.style, this.action});

  /// @brief Creates a Component instance from a JSON map
  /// 
  /// This factory method parses the provided JSON map and returns a 
  /// Component instance populated with the corresponding data.
  /// 
  /// @param json A map representing the JSON object
  /// @return A Component instance
  factory Component.fromJson(Map<String, dynamic> json) {
    return Component(
      type: json['type'], ///< Assigns the type from JSON
      content: json['content'], ///< Assigns the content from JSON
      style: json['style'], ///< Assigns the style from JSON (if present)
      action: json['action'], ///< Assigns the action from JSON (if present)
    );
  }
}
/** @} */
