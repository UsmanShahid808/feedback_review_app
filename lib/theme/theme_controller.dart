import 'package:flutter/material.dart';

/// Holds the current theme mode (light/dark) and notifies listeners so the
/// whole app can rebuild with the new theme when the user toggles it from
/// the Profile screen.
class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void setDark(bool dark) {
    _mode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
