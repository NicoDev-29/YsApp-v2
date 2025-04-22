import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFDE2B73);
  static const Color secondary = Color.fromARGB(255, 222, 43, 115);
  static const Color gradient1 = Color.fromARGB(255, 239, 157, 189);
  static const Color gradient2 = Color.fromARGB(255, 232, 113, 163);
  static const Color gradient3 = Color.fromARGB(255, 222, 43, 115);
  static const Color black = Colors.black;
  static const Color white = Colors.white;
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.white,
    primaryColor: AppColors.primary,

    appBarTheme: const AppBarTheme(
      color: AppColors.primary,
      iconTheme: IconThemeData(color: AppColors.white),
      titleTextStyle: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 20),
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
        foregroundColor: AppColors.white,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    ),
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.black,

    appBarTheme: const AppBarTheme(
      color: AppColors.secondary,
      iconTheme: IconThemeData(color: AppColors.white),
    ),
  );
}
