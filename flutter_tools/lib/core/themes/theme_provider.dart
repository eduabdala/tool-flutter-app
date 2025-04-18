import 'package:flutter/foundation.dart';

class ThemeNotifier extends ChangeNotifier implements ValueListenable<bool> {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  set isDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  @override
  bool get value => isDarkMode;
}
