import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color.fromRGBO(217, 38, 109, 1); 
  static const Color secondary = Colors.white; 
  static const Color tertiary = Colors.black; 
  static const Color gradient1 = Color.fromARGB(255, 228, 135, 171);
  static const Color gradient2 = Color.fromARGB(255, 233, 89, 149);
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.secondary,
    primaryColor: AppColors.primary,
    appBarTheme: const AppBarTheme(
      color: AppColors.gradient1,
      iconTheme: IconThemeData(color: AppColors.secondary),
      titleTextStyle: TextStyle(
        color: AppColors.secondary,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      elevation: 4,
      centerTitle: false,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: const StadiumBorder(),
        elevation: 1,
        foregroundColor: AppColors.secondary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.secondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
