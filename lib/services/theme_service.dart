import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  // We use a ValueNotifier so the app instantly updates when this changes
  static final ValueNotifier<Color> seedColorNotifier = ValueNotifier(
    Colors.tealAccent,
  );
  static const String _colorKey = 'theme_seed_color';

  static final themeModeNotifier = ValueNotifier<ThemeMode>(.system);
  static const String _themeModeKey = 'app_theme_mode';

  static Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_themeModeKey);
    if (savedMode == 'light') {
      themeModeNotifier.value = .light;
    } else if (savedMode == 'dark') {
      themeModeNotifier.value = .dark;
    } else {
      themeModeNotifier.value = .system;
    }
  }

  static Future<void> updateThemeMode(ThemeMode newMode) async {
    themeModeNotifier.value = newMode;
    final prefs = await SharedPreferences.getInstance();

    String modeString = 'system';
    if (newMode == .light) modeString = 'light';
    if (newMode == .dark) modeString = 'dark';

    await prefs.setString(_themeModeKey, modeString);
  }

  /// Loads the saved color from memory when the app starts
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final int? savedColor = prefs.getInt(_colorKey);

    if (savedColor == null) return;
    seedColorNotifier.value = Color(savedColor);
  }

  /// Updates the color globally and saves it to memory
  static Future<void> updateSeedColor(Color newColor) async {
    seedColorNotifier.value = newColor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, newColor.toARGB32());
  }
}
