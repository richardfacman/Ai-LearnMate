import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/theme_service.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  // Theme Tokens
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color gold = Color(0xFFF0A93E);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x1AF4EFE6);

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text("Theme & Appearance", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: surface,
        foregroundColor: paper,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("THEME MODE", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: hairline),
              ),
              child: Column(
                children: [
                  RadioListTile<bool>(
                    value: true,
                    groupValue: themeService.isDark,
                    activeColor: gold,
                    onChanged: (_) {
                      if (!themeService.isDark) themeService.toggleTheme();
                    },
                    title: const Text("Dark Theme (Lamp-lit Desk)", style: TextStyle(color: paper, fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: const Text("Warm gold & dark ink tones optimized for late night study", style: TextStyle(color: muted, fontSize: 12)),
                  ),
                  const Divider(color: hairline, height: 1),
                  RadioListTile<bool>(
                    value: false,
                    groupValue: themeService.isDark,
                    activeColor: gold,
                    onChanged: (_) {
                      if (themeService.isDark) themeService.toggleTheme();
                    },
                    title: const Text("Light Theme", style: TextStyle(color: paper, fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: const Text("High-contrast light background for daytime reading", style: TextStyle(color: muted, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
