import 'package:flutter/material.dart';
import '../models/component.dart';
import 'button.dart';
import 'text.dart';
import 'textfield.dart';

class ComponentFactory {
  static Widget createComponent(Component component, BuildContext context) {
    switch (component.type) {
      case 'text':
        return TextComponent(component: component);
      case 'button':
        return ButtonComponent(component: component);
      case 'textfield':
        return TextFieldComponent(component: component);
      default:
        return Container();
    }
  }
}
