import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blueGrey,
  scaffoldBackgroundColor:
      const Color(0xFF151718), // Background from carbon.now.sh
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF21252B),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
        color: Color(0xFFE6CD69)), // Syntax highlighting for JSON keys
    bodyMedium:
        TextStyle(color: Color(0xFF55B5DB)), // Syntax highlighting for values
    titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF21252B), // Dark input fields
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF5C6370)), // Borders for inputs
    ),
    labelStyle: TextStyle(color: Color(0xFF5C6370)), // Label text style
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF61AFEF), // Light blue for buttons
    ),
  ),
  expansionTileTheme: const ExpansionTileThemeData(
    backgroundColor: Color(0xFF151718), // Use carbon.now.sh background
    collapsedBackgroundColor: Color(0xFF21252B),
    textColor: Colors.white,
    iconColor: Colors.white,
  ),
);
