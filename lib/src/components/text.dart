/***********************************************************************
 * $Id$        text_component.dart          2024-09-24
 *//**
 * @file        text_component.dart
 * @brief       Custom widget for displaying a text component
 * @version     1.0
 * @date        24. Sep. 2024
 * @author      Eduardo Abdala
 *************************************************************************/
/// @addtogroup  TextComponent Custom Text Component
/// @{
library;


import 'package:flutter/material.dart';
import '../models/component.dart';

/// @brief A widget that displays a customizable text
/// 
/// This widget renders a text based on the provided Component model, 
/// allowing for dynamic styling and content.
class TextComponent extends StatelessWidget {
  final Component component; ///< The component model containing configuration data

  /// @brief Constructor for the TextComponent
  /// 
  /// Initializes the widget with a given component model.
  /// 
  /// @param component The component model with properties for the text
  const TextComponent({super.key, required this.component});

  /// @brief Builds the widget's UI
  /// 
  /// This method constructs the layout for the text component, 
  /// including its styling and content based on the component model.
  /// 
  /// @param context Current application context
  /// @return Widget Representation of the text component
  @override
  Widget build(BuildContext context) {
    return Text(
      component.content['text'], ///< The text to be displayed
      style: TextStyle(
        fontSize: component.style?['fontSize']?.toDouble() ?? 14, ///< Sets the font size
        color: Color(int.parse(component.style?['color']?.substring(1, 7) ?? '000000', radix: 16) + 0xFF000000), ///< Sets the text color
      ),
    );
  }
}
/** @} */
