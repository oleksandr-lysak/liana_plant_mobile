import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color.fromRGBO(184, 255, 91, 1),
    indicatorColor: const Color.fromRGBO(184, 255, 91, 1),
    scaffoldBackgroundColor: const Color(0xFF121212),
    focusColor: const Color.fromRGBO(184, 255, 91, 1), // Підбираємо для фокусу
    hoverColor: const Color(0xFF424242), // Підбираємо для ховера

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF333333), // Темний фон для AppBar
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white70, // Світлий відтінок для заголовків
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: Colors.white60,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: Colors.white60,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: Colors.white60,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: Colors.white54,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        color: Color.fromRGBO(184, 255, 91, 1),
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: Color.fromRGBO(184, 255, 91, 1),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      fillColor: Color(0xFF424242), // Темний фон для текстових полів
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        borderSide: BorderSide.none, // Без бордеру
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color.fromRGBO(184, 255, 91, 1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF64B5F6)),
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: const Color.fromRGBO(184, 255, 91, 1), // Колір кнопок
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all(const Color.fromRGBO(184, 255, 91, 1)),
      checkColor: WidgetStateProperty.all(Colors.black),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color.fromRGBO(184, 255, 91, 1),
      foregroundColor: Colors.black,
    ),
  );

  // Темна тема
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    indicatorColor: Colors.black,
    primaryColor: const Color.fromRGBO(155, 183, 255, 1),
    scaffoldBackgroundColor:
        const Color(0xFFFFFFFF), // Білий фон для світлої теми
    focusColor:
        const Color.fromRGBO(81, 135, 255, 1.0), // Підбираємо для фокусу
    hoverColor: Colors.grey[300],
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFDDDDDD), // Світлий фон для AppBar
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.black),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.black87, // Темний відтінок для заголовків
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: Colors.grey,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: TextStyle(
        color: Colors.black, // Колір акценту
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        color: Color.fromRGBO(155, 183, 255, 1),
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: Color.fromRGBO(155, 183, 255, 1),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      fillColor: Color(0xFFF5F5F5), // Світлий фон для текстових полів
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color.fromRGBO(155, 183, 255, 1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF64B5F6)),
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: const Color.fromRGBO(155, 183, 255, 1), // Колір кнопок
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all(const Color.fromRGBO(155, 183, 255, 1)),
      checkColor: WidgetStateProperty.all(Colors.black),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color.fromRGBO(155, 183, 255, 1),
      foregroundColor: Colors.black,
    ),
  );
}
