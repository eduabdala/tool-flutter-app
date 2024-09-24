/***********************************************************************
 * $Id$        text_field_component.dart   2024-09-24
 *//**
 * @file        text_field_component.dart
 * @brief       Custom widget for displaying a text field component
 * @version     1.0
 * @date        24. Sep. 2024
 * @author      Eduardo Abdala
 *************************************************************************/
/// @addtogroup  TextFieldComponent Custom Text Field Component
/// @{
library;


import 'package:flutter/material.dart';
import '../models/component.dart';

/// @brief A widget that displays a customizable text field
/// 
/// This widget builds a text field based on the provided 
/// Component model. It allows for dynamic labeling and hints.
class TextFieldComponent extends StatelessWidget {
  final Component component; ///< The component model containing configuration data

  /// @brief Constructor for the TextFieldComponent
  /// 
  /// Initializes the widget with a given component model.
  /// 
  /// @param component The component model with properties for the text field
  const TextFieldComponent({super.key, required this.component});

  /// @brief Builds the widget's UI
  /// 
  /// This method constructs the layout for the text field component, 
  /// including its appearance and behavior based on the component model.
  /// 
  /// @param context Current application context
  /// @return Widget Representation of the text field component
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150, ///< Sets the width of the container
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16), ///< Adds padding around the text field
      child: TextField(
        controller: component.content['controller'], ///< Sets the text field controller
        decoration: InputDecoration(
          border: const OutlineInputBorder(), ///< Applies an outline border to the text field
          labelText: component.content['label'], ///< Sets the label text
          hintText: component.content['hint'], ///< Sets the hint text
        ),
        onChanged: (value) {
          // Callback for when the text field value changes
        },
      ),
    );
  }
}
/** @} */
