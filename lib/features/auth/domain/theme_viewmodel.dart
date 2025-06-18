import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  static const String _themePreferenceKey = "theme_mode";

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeViewModel() {
    _loadThemeFromPreferences();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _saveThemeToPreferences(mode);
  }

  Future<void> _saveThemeToPreferences(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_themePreferenceKey, mode.toString());
  }

  Future<void> _loadThemeFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themePreferenceKey);

    if (themeString != null) {
      switch (themeString) {
        case "ThemeMode.light":
          _themeMode = ThemeMode.light;
          break;
        case "ThemeMode.dark":
          _themeMode = ThemeMode.dark;
          break;
        case "ThemeMode.system":
        default:
          _themeMode = ThemeMode.system;
          break;
      }
      notifyListeners();
    }
  }
}
