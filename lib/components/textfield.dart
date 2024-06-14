import 'package:flutter/material.dart';
import '../models/component.dart';

class TextFieldComponent extends StatelessWidget {
final Component component;

TextFieldComponent({required this.component});

@override
Widget build(BuildContext context) {
return Padding(
padding: const EdgeInsets.all(8.0),
child: TextField(
decoration: InputDecoration(
labelText: component.content['label'],
hintText: component.content['hint'],
),
onChanged: (value) {
// Implementar alguma lógica
},
),
);
}
}