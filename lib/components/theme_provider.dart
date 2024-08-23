import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Definindo os temas claro e escuro como finais e constantes
  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      displayLarge: TextStyle(color: Colors.black),
      displayMedium: TextStyle(color: Colors.black),
    ),
  );

  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      displayLarge: TextStyle(color: Colors.white),
      displayMedium: TextStyle(color: Colors.white),
    ),
  );

  // Define o tema atual como claro por padrão
  ThemeData _currentTheme;

  ThemeProvider() : _currentTheme = ThemeData.light(); // Inicializa com o tema claro

  ThemeData get currentTheme => _currentTheme;

  void toggleTheme() {
    if (_currentTheme.brightness == Brightness.dark) {
      _currentTheme = _lightTheme;
    } else {
      _currentTheme = _darkTheme;
    }
    notifyListeners();
  }
}
