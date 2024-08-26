import 'package:flutter/material.dart';
import '../models/component.dart';
import '../services/python_service.dart';

class ButtonComponent extends StatelessWidget {
  final Component? component;
  final String? label;
  final String? target;
  final String? pythonScriptPath;
  final String? pythonFunction;
  final String? pythonArg;

  const ButtonComponent({
    super.key, 
    this.component,
    this.label,
    this.target,
    this.pythonScriptPath,
    this.pythonFunction,
    this.pythonArg
    });

  @override
  Widget build(BuildContext context) {
    String buttonLabel;
    void Function()? onPressed;

    if (component != null) {
      buttonLabel = component!.content['label'];
      if (component!.action?['type'] == 'navigate') {
        String targetScreenId = component!.action!['target'];
        onPressed = () => Navigator.pushNamed(context, '/$targetScreenId');
      } else if (component!.action?['type'] == 'python') {
        onPressed = () => runPythonFunction(component!.action!['path'],component!.action!['function'],component!.action!['arg1']);
      }
    } else {
      buttonLabel = label!;
      if (target != null) {
        onPressed = () => Navigator.pushNamed(context, '/$target');
      } else if (pythonFunction != null) {
        onPressed = () => runPythonFunction(pythonScriptPath!,pythonFunction!,pythonArg!);
      }
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        fixedSize: const Size(100, 40)
      ),
      onPressed: onPressed,
      child: Text(buttonLabel),
    );
  }
}
