import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color.fromRGBO(217, 38, 109, 1); 
  static const Color secondary = Colors.white; 
  static const Color tertiary = Colors.black; 
  static const Color plomo = Color.fromARGB(255, 122, 122, 122); 
  static const Color background2 = Color.fromRGBO(238, 238, 238, 1);
  static const Color gradient1 = Color.fromARGB(255, 228, 135, 171);
  static const Color gradient2 = Color.fromARGB(255, 233, 89, 149);
  static const Color borderGrey = Color(0xFFE0E0E0); // Borde gris claro
  static const Color inputFill = Color(0xFFF5F5F5); // Fondo input gris muy claro
  static const Color textGrey = Color(0xFF757575); // Texto gris
  static const Color activeGreen = Color(0xFF4CAF50); // Verde para "Activo"
  static const Color inactiveRed = Color(0xFFEF5350); // Rojo para "Inactivo"
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.secondary,
    primaryColor: AppColors.primary,
    appBarTheme: const AppBarTheme(
      color: AppColors.secondary,
      iconTheme: IconThemeData(color: AppColors.tertiary),
      titleTextStyle: TextStyle(
        color: AppColors.tertiary,
        fontWeight: FontWeight.bold,
        fontSize: 18,
        letterSpacing: 1.2,
      ),
      elevation: 0,
      centerTitle: true,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.secondary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        foregroundColor: AppColors.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderGrey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderGrey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inactiveRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inactiveRed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: const TextStyle(color: AppColors.textGrey),
      labelStyle: const TextStyle(color: AppColors.textGrey),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.tertiary),
      bodyMedium: TextStyle(color: AppColors.tertiary),
    ),
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.tertiary,
    appBarTheme: const AppBarTheme(
      color: AppColors.secondary,
      iconTheme: IconThemeData(color: AppColors.secondary),
    ),
  );
}