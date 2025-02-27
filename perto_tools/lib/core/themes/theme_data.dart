import 'package:flutter/material.dart';

class CustomTheme {
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
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
              vertical: 12, horizontal: 24),
          elevation: 5,
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
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 6, 120, 212),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        elevation: 5, // Sombra do botão
        disabledBackgroundColor: const Color.fromARGB(255, 49, 47, 47),
        disabledForegroundColor: Color.fromARGB(255, 82, 82, 82),
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
