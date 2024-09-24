/***********************************************************************
 * $Id$        button_component.dart          2024-09-24
 *//**
 * @file        button_component.dart
 * @brief       A widget for creating button components in the application
 * @version     1.0
 * @date        24. Sep. 2024
 * @author      Eduardo Abdala
 *************************************************************************/
/// @addtogroup  ButtonComponent Button Widget
/// @{
library;


import 'package:flutter/material.dart';
import '../models/component.dart';
import '.../../../services/python_service.dart';

/// @brief A widget that represents a button component
/// 
/// This widget can be configured to navigate to another screen 
/// or to execute a Python function when pressed.
class ButtonComponent extends StatelessWidget {
  final Component? component; ///< Optional component model
  final String? label; ///< Optional label for the button
  final String? target; ///< Optional target screen for navigation
  final String? pythonScriptPath; ///< Optional Python script path
  final String? pythonFunction; ///< Optional Python function name
  final String? pythonArg; ///< Optional argument for the Python function

  /// @brief Constructor for ButtonComponent
  /// 
  /// Initializes the button component with optional parameters.
  /// 
  /// @param component The component model containing button details
  /// @param label The label text for the button
  /// @param target The target screen ID for navigation
  /// @param pythonScriptPath The path to the Python script
  /// @param pythonFunction The name of the Python function to execute
  /// @param pythonArg The argument to pass to the Python function
  const ButtonComponent({
    super.key, 
    this.component,
    this.label,
    this.target,
    this.pythonScriptPath,
    this.pythonFunction,
    this.pythonArg
  });

  /// @brief Builds the button widget
  /// 
  /// This method constructs the ElevatedButton widget with the 
  /// appropriate label and action based on the provided parameters.
  /// 
  /// @param context The build context for the widget
  /// @return Widget Returns an ElevatedButton widget
  @override
  Widget build(BuildContext context) {
    String buttonLabel;
    void Function()? onPressed;

    // Determine the button label and action
    if (component != null) {
      buttonLabel = component!.content['label'];
      if (component!.action?['type'] == 'navigate') {
        String targetScreenId = component!.action!['target'];
        onPressed = () => Navigator.pushNamed(context, '/$targetScreenId');
      } else if (component!.action?['type'] == 'python') {
        onPressed = () => runPythonFunction(
          component!.action!['path'],
          component!.action!['function'],
          component!.action!['arg1']
        );
      }
    } else {
      buttonLabel = label!;
      if (target != null) {
        onPressed = () => Navigator.pushNamed(context, '/$target');
      } else if (pythonFunction != null) {
        onPressed = () => runPythonFunction(pythonScriptPath!, pythonFunction!, pythonArg!);
      }
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, ///< Sets the button background color
        foregroundColor: Colors.white, ///< Sets the button text color
        fixedSize: const Size(100, 40) ///< Sets a fixed size for the button
      ),
      onPressed: onPressed, ///< Sets the button action
      child: Text(buttonLabel), ///< Displays the button label
    );
  }
}
/** @} */
