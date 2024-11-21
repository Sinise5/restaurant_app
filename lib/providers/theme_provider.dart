import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  ThemeNotifier() {
    _loadThemeFromPreferences();
  }

  void toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
    await _saveThemeToPreferences();
  }

  ThemeData get currentTheme {
    return _isDarkTheme ? darkTheme : lightTheme;
  }

  ThemeData get lightTheme => ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent),
        hintColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.black),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Roboto',
          ),
          bodyMedium: TextStyle(
            color: Colors.black54,
            fontSize: 14,
            fontFamily: 'Roboto',
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        fontFamily: 'Roboto',
      );

  ThemeData get darkTheme => ThemeData(
        primaryColor: Colors.grey[900],
        hintColor: Colors.redAccent,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        iconTheme: const IconThemeData(color: Colors.white),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Courier',
          ),
          bodyMedium: TextStyle(
            color: Colors.white54,
            fontSize: 14,
            fontFamily: 'Courier',
          ),
        ),
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[850],
        fontFamily: 'Courier',
      );

  Color get textColor {
    return _isDarkTheme ? Colors.white : Colors.black;
  }

  Future<void> _loadThemeFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    notifyListeners();
  }

  Future<void> _saveThemeToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDarkTheme);
  }
}
