import 'package:flutter/material.dart';

class AppTheme {
  // Ana renkler - Sarı ve Beyaz teması
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkYellow = Color(0xFFFFA000);
  static const Color lightYellow = Color(0xFFFFECB3);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFF5F5F5);

  // Açık tema
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryYellow,
    scaffoldBackgroundColor: white,
    colorScheme: const ColorScheme.light(
      primary: primaryYellow,
      secondary: darkYellow,
      surface: white,
      background: white,
      error: Colors.red,
      onPrimary: black,
      onSecondary: white,
      onSurface: black,
      onBackground: black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryYellow,
      foregroundColor: black,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: primaryYellow,
      unselectedItemColor: grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
    cardTheme: const CardThemeData(
      color: white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryYellow,
        foregroundColor: black,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  // Koyu tema
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryYellow,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: primaryYellow,
      secondary: darkYellow,
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      error: Colors.red,
      onPrimary: black,
      onSecondary: white,
      onSurface: white,
      onBackground: white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: primaryYellow,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: primaryYellow,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: primaryYellow,
      unselectedItemColor: grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF1E1E1E),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryYellow,
        foregroundColor: black,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}