/***********************************************************************
 * $Id$        component_factory.dart            2024-09-24
 *//**
 * @file        component_factory.dart
 * @brief       Factory class for creating UI components
 * @version     1.0
 * @date        24. Sep. 2024
 * @author      Eduardo Abdala
 *************************************************************************/
/// @addtogroup  ComponentFactory Component Factory
/// @{
library;


import 'package:flutter/material.dart';
import '../models/component.dart';
import 'button.dart';
import 'text.dart';
import 'textfield.dart';

/// @brief A factory class for creating UI components
/// 
/// This class provides a static method to create different types of UI
/// components based on the type specified in the provided Component model.
class ComponentFactory {
  /// @brief Creates a UI component based on the provided Component model
  /// 
  /// This method takes a Component object and returns the corresponding
  /// widget based on its type. Supported types are 'text', 'button', and
  /// 'textfield'.
  /// 
  /// @param component The Component model containing type and content
  /// @param context The BuildContext for the widget tree
  /// @return Widget The created UI component
  static Widget createComponent(Component component, BuildContext context) {
    switch (component.type) {
      case 'text':
        return TextComponent(component: component); ///< Create a TextComponent
      case 'button':
        return ButtonComponent(component: component); ///< Create a ButtonComponent
      case 'textfield':
        return TextFieldComponent(component: component); ///< Create a TextFieldComponent
      default:
        return Container(); ///< Return an empty container for unknown types
    }
  }
}
/** @} */
