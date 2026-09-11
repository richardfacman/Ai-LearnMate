import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class AppColors {
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color surfaceHi = Color(0xFF1B2230);
  static const Color gold = Color(0xFFF0A93E);
  static const Color goldSoft = Color(0xFFF7C978);
  static const Color indigo = Color(0xFF6C7BFF);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x17F4EFE6);
}

class ThemeService with ChangeNotifier {
  final _box = Hive.box('settings');

  bool get isDark => _box.get('darkMode', defaultValue: true);

  ThemeMode get currentTheme => isDark ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    final newMode = !isDark;
    _box.put('darkMode', newMode);
    notifyListeners();
  }

  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.ink,
      primaryColor: AppColors.gold,
      cardColor: AppColors.surface,
      dividerColor: AppColors.hairline,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.fraunces(color: AppColors.paper, fontWeight: FontWeight.w600),
        displayMedium: GoogleFonts.fraunces(color: AppColors.paper, fontWeight: FontWeight.w600),
        displaySmall: GoogleFonts.fraunces(color: AppColors.paper, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.fraunces(color: AppColors.paper, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: AppColors.paper),
        bodyMedium: const TextStyle(color: AppColors.paper),
        bodySmall: const TextStyle(color: AppColors.muted),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.indigo,
        surface: AppColors.surface,
        onPrimary: Color(0xFF3A2606),
      ),
    );
  }

  ThemeData get lightTheme {
    // For now, keeping a standard light theme or a "paper" themed light version
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFDFDFE),
      primaryColor: const Color(0xFF007BFF),
    );
  }
}
