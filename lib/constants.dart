import 'package:flutter/material.dart';

const Color kRose = Color(0xFFE91E8C);
const Color kRoseClair = Color(0xFFFF4DB8);
const Color kRosePale = Color(0xFFFCE4EC);
const String kAdminEmail = "reginatonde44@gmail.com";

ThemeData themeApp() {
  return ThemeData(
    primaryColor: kRose,
    colorScheme: ColorScheme.fromSeed(seedColor: kRose, brightness: Brightness.light),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: kRose,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kRose,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 3,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: kRose, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      errorStyle: const TextStyle(color: Colors.red),
      hintStyle: const TextStyle(color: Colors.grey),
    ),
  );
}

InputDecoration champStyle(String hint, IconData icon, {Widget? suffixIcon, String? errorText}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: kRose),
    suffixIcon: suffixIcon,
    errorText: errorText,
  );
}