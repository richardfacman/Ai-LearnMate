import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class AppColors {
  static const Color background = Color(0xFF0B0B14); // ink
  static const Color card = Color(0xFF15151F);       // surface
  static const Color accent = Color(0xFFFFB020);     // gold
  static const Color primaryText = Color(0xFFF9FAFB);
  static const Color secondaryText = Color(0xFF9CA3AF);
  static const Color border = Color(0x22F9FAFB);     // hairline
  static const Color purpleGlow = Color(0xFF6C7BFF); // indigo/purple
}

class AppSpacing {
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
}

class AppRadius {
  static const double card = 16.0;
  static const double button = 12.0;
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
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.accent,
      cardColor: AppColors.card,
      dividerColor: AppColors.border,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.inter(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.inter(color: AppColors.primaryText, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.inter(color: AppColors.primaryText, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.inter(color: AppColors.primaryText, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: AppColors.primaryText),
        bodyMedium: const TextStyle(color: AppColors.primaryText),
        bodySmall: const TextStyle(color: AppColors.secondaryText),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.purpleGlow,
        surface: AppColors.card,
        onPrimary: Color(0xFF3A2606),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: const Color(0xFF0B0B14),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
        hintStyle: const TextStyle(color: AppColors.secondaryText),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  ThemeData get lightTheme {
    return darkTheme; // Force dark theme everywhere to match reference exactly for now
  }
}
