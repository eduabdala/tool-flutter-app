/***********************************************************************
 * $Id$        dynamic_screen.dart        2024-09-24
 *//**
 * @file        dynamic_screen.dart
 * @brief       Dynamic screen that displays components based on the provided model
 * @version     1.0
 * @date        24. Sep. 2024
 * @author      Eduardo Abdala
 *************************************************************************/
/// @addtogroup  DynamicScreen Dynamic Screen
/// @ingroup screens
/// @{
library;

import 'package:flutter/material.dart';
import '../models/screen.dart';
import '../components/component_factory.dart';

/// @brief Class representing a dynamic screen
/// 
/// This class is responsible for displaying a screen with UI components 
/// defined in the provided `ScreenModel`. It creates and organizes 
/// these UI elements based on the components specified in the model.
class DynamicScreen extends StatelessWidget {
  final ScreenModel screen; ///< Model of the screen containing components

  /// @brief Constructor for the DynamicScreen class
  /// 
  /// Initializes the dynamic screen with the given screen model.
  /// 
  /// @param screen Model of the screen with components to be displayed
  const DynamicScreen({super.key, required this.screen});

  /// @brief Builds the user interface for the dynamic screen
  /// 
  /// This method constructs the overall layout of the dynamic screen, 
  /// including an app bar and a scrollable area for the components.
  /// 
  /// @param context Current application context
  /// @return Widget Representation of the dynamic screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(screen.title), ///< Title of the dynamic screen, derived from the screen model
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(), ///< Adds space above the components
            SingleChildScrollView(
              child: Column(
                children: screen.components.map((component) {
                  return _buildComponent(context, component); ///< Build each component using a helper method
                }).toList(),
              ),
            ),
            const Spacer(), ///< Adds space below the components
          ],
        ),
      ),
    );
  }

  /// @brief Builds a component widget
  /// 
  /// This helper method creates a widget for each component defined in the 
  /// `ScreenModel`. It ensures that each component is wrapped in padding 
  /// and has a consistent width.
  /// 
  /// @param context Current application context
  /// @param component The component model to be created
  /// @return Widget Representation of the component
  Widget _buildComponent(BuildContext context, dynamic component) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), ///< Adds vertical spacing around the component
      child: SizedBox(
        width: 250, ///< Fixed width for the component
        child: ComponentFactory.createComponent(component, context), ///< Create the component using a factory method
      ),
    );
  }
}
/** @} */
