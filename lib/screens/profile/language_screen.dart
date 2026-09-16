import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = "English (US)";

  // Theme Tokens
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color gold = Color(0xFFF0A93E);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x1AF4EFE6);

  final List<Map<String, String>> _languages = [
    {"name": "English (US)", "code": "en_US", "tag": "SUGGESTED"},
    {"name": "English (UK)", "code": "en_UK", "tag": "SUGGESTED"},
    {"name": "Bangla (বাংলা)", "code": "bn", "tag": "SUGGESTED"},
    {"name": "Banglish (Mixed)", "code": "bn_en", "tag": "SUGGESTED"},
    {"name": "Spanish (Español)", "code": "es", "tag": "OTHERS"},
    {"name": "French (Français)", "code": "fr", "tag": "OTHERS"},
    {"name": "Arabic (العربية)", "code": "ar", "tag": "OTHERS"},
    {"name": "Hindi (हिंदी)", "code": "hi", "tag": "OTHERS"},
    {"name": "Mandarin (中文)", "code": "zh", "tag": "OTHERS"},
    {"name": "German (Deutsch)", "code": "de", "tag": "OTHERS"},
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  void _loadLanguagePreference() {
    try {
      final box = Hive.box('settings');
      setState(() {
        _selectedLanguage = box.get('selected_language', defaultValue: "English (US)");
      });
    } catch (_) {}
  }

  void _saveLanguage(String langName) {
    setState(() => _selectedLanguage = langName);
    try {
      final box = Hive.box('settings');
      box.put('selected_language', langName);
    } catch (_) {}

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Language updated to $langName"),
        backgroundColor: gold,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggested = _languages.where((l) => l['tag'] == 'SUGGESTED').toList();
    final others = _languages.where((l) => l['tag'] == 'OTHERS').toList();

    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text("Language", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: surface,
        foregroundColor: paper,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("SUGGESTED LANGUAGES", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            _buildLanguageCard(suggested),
            const SizedBox(height: 24),
            const Text("OTHER LANGUAGES", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            _buildLanguageCard(others),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(List<Map<String, String>> langList) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hairline),
      ),
      child: Column(
        children: langList.asMap().entries.map((entry) {
          final index = entry.key;
          final lang = entry.value;
          final name = lang['name']!;
          final isSelected = _selectedLanguage == name;

          return Column(
            children: [
              RadioListTile<String>(
                value: name,
                groupValue: _selectedLanguage,
                activeColor: gold,
                onChanged: (val) {
                  if (val != null) _saveLanguage(val);
                },
                title: Text(name, style: TextStyle(color: isSelected ? gold : paper, fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
              ),
              if (index < langList.length - 1) const Divider(color: hairline, height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}
