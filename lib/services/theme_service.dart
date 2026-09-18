import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class AppColors {
  static const Color background = Color(0xFF05070F); // Near-black navy
  static const Color card = Color(0xFF101426);       // Frosted card
  static const Color cardTop = Color(0xFF1C203A);    // Card gradient top
  static const Color accent = Color(0xFFFFC44D);     // Gold accent
  static const Color goldDark = Color(0xFFEE9F16);   // Gold gradient bottom
  static const Color goldInk = Color(0xFF1D1404);    // Gold button text color
  static const Color primaryText = Color(0xFFF1F4FC);// Off-white
  static const Color secondaryText = Color(0xFF8D9AC2); // Muted slate blue
  static const Color border = Color(0x248CA0FF);     // Hairline border
  static const Color field = Color(0xCC060914);      // Input field background
  static const Color cyan = Color(0xFF4FC3E8);
  static const Color violet = Color(0xFF8C86FF);
  static const Color pink = Color(0xFFFF80B8);
  static const Color purpleGlow = Color(0xFF5A60FF);
}

class AppSpacing {
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
}

class AppRadius {
  static const double card = 20.0;
  static const double button = 14.0;
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
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.fraunces(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.fraunces(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.fraunces(color: AppColors.primaryText, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.fraunces(color: AppColors.primaryText, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.plusJakartaSans(color: AppColors.primaryText, fontWeight: FontWeight.w700),
        bodyLarge: GoogleFonts.plusJakartaSans(color: AppColors.primaryText),
        bodyMedium: GoogleFonts.plusJakartaSans(color: AppColors.primaryText),
        bodySmall: GoogleFonts.plusJakartaSans(color: AppColors.secondaryText),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.cyan,
        surface: AppColors.card,
        onPrimary: AppColors.goldInk,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.goldInk,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.field,
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
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
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
    return darkTheme; // Force dark theme everywhere to match reference exactly
  }
}
