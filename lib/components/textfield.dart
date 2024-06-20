import 'package:flutter/material.dart';
import '../models/component.dart';

class TextFieldComponent extends StatelessWidget {
  final Component component;

  const TextFieldComponent({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: TextField( 
        controller: component.content['controller'],
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: component.content['label'],
          hintText: component.content['hint'],
        ),
        onChanged: (value) {
        },
      ),
    );
  }
}