import 'package:flutter/material.dart';

class CustomTheme {
  // Tema Claro (Light Mode)
  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue, // Cor do texto
          shape: RoundedRectangleBorder(
            // Bordas arredondadas
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
              vertical: 12, horizontal: 24), // Padding
          elevation: 5, // Sombra do botão
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.blue,
        textTheme: ButtonTextTheme.primary,
      ),
      iconTheme: const IconThemeData(
        color: Colors.blue,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        labelStyle: TextStyle(color: Colors.blue),
      ),
    );
  }

  // Tema Escuro (Dark Mode)
// Tema Escuro (Dark Mode)
// Tema Escuro (Dark Mode)
// Tema Escuro (Dark Mode)
static ThemeData darkTheme() {
  return ThemeData(
    primaryColor: const Color.fromARGB(255, 6, 120, 212),
    scaffoldBackgroundColor: const Color.fromARGB(255, 15, 15, 15),

    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, // Cor do texto (branca para boa visibilidade)
        backgroundColor: const Color.fromARGB(255, 6, 120, 212), // Cor de fundo azul mais clara
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Bordas arredondadas
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24), // Padding
        elevation: 5, // Sombra do botão
        disabledBackgroundColor: const Color.fromARGB(255, 49, 47, 47), // Cor de fundo quando o botão está desativado
        disabledForegroundColor: Color.fromARGB(255, 82, 82, 82), // Cor do texto quando o botão está desativado
      ),
    ),

    buttonTheme: const ButtonThemeData(
      buttonColor: Color.fromARGB(255, 6, 120, 212),
      textTheme: ButtonTextTheme.primary,
    ),

    iconTheme: const IconThemeData(
      color: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 6, 120, 212),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),

    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      labelStyle: TextStyle(color: Color.fromARGB(255, 6, 120, 212)),
    ),
  );
}


}
