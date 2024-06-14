import 'package:flutter/material.dart';
import '../models/component.dart';

class TextComponent extends StatelessWidget {
  final Component component;

  TextComponent({required this.component});

  @override
  Widget build(BuildContext context) {
    return Text(
      component.content['text'],
      style: TextStyle(
        fontSize: component.style?['fontSize']?.toDouble() ?? 14,
        color: Color(int.parse(component.style?['color']?.substring(1, 7) ?? '000000', radix: 16) + 0xFF000000),
      ),
    );
  }
}