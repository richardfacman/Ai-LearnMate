import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeService with ChangeNotifier {
  final _box = Hive.box('settings');

  bool get isDark => _box.get('darkMode', defaultValue: false);

  ThemeMode get currentTheme => isDark ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    final newMode = !isDark;
    _box.put('darkMode', newMode);
    notifyListeners();
  }
}
