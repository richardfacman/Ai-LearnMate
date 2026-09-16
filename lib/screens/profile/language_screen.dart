import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = "English (US)";
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // Theme Tokens
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color surfaceHi = Color(0xFF1B2230);
  static const Color gold = Color(0xFFF0A93E);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x1AF4EFE6);

  final List<Map<String, String>> _allLanguages = [
    // Suggested
    {"name": "English (US)", "code": "en_US", "region": "United States", "tag": "SUGGESTED"},
    {"name": "English (UK)", "code": "en_UK", "region": "United Kingdom", "tag": "SUGGESTED"},
    {"name": "Bangla (বাংলা)", "code": "bn", "region": "Bangladesh", "tag": "SUGGESTED"},
    {"name": "Banglish (Mixed)", "code": "bn_en", "region": "Bangladesh / Global", "tag": "SUGGESTED"},

    // All Global Languages
    {"name": "Spanish (Español)", "code": "es", "region": "Spain / Latin America", "tag": "OTHERS"},
    {"name": "French (Français)", "code": "fr", "region": "France / Global", "tag": "OTHERS"},
    {"name": "Arabic (العربية)", "code": "ar", "region": "Middle East / North Africa", "tag": "OTHERS"},
    {"name": "Hindi (हिंदी)", "code": "hi", "region": "India", "tag": "OTHERS"},
    {"name": "Mandarin / Chinese (中文)", "code": "zh", "region": "China / Taiwan", "tag": "OTHERS"},
    {"name": "German (Deutsch)", "code": "de", "region": "Germany / Europe", "tag": "OTHERS"},
    {"name": "Portuguese (Português)", "code": "pt", "region": "Brazil / Portugal", "tag": "OTHERS"},
    {"name": "Russian (Русский)", "region": "Russia / Eurasia", "code": "ru", "tag": "OTHERS"},
    {"name": "Japanese (日本語)", "code": "ja", "region": "Japan", "tag": "OTHERS"},
    {"name": "Korean (한국어)", "code": "ko", "region": "South Korea", "tag": "OTHERS"},
    {"name": "Italian (Italiano)", "code": "it", "region": "Italy", "tag": "OTHERS"},
    {"name": "Turkish (Türkçe)", "code": "tr", "region": "Turkey", "tag": "OTHERS"},
    {"name": "Vietnamese (Tiếng Việt)", "code": "vi", "region": "Vietnam", "tag": "OTHERS"},
    {"name": "Indonesian (Bahasa Indonesia)", "code": "id", "region": "Indonesia", "tag": "OTHERS"},
    {"name": "Urdu (اردو)", "code": "ur", "region": "Pakistan / South Asia", "tag": "OTHERS"},
    {"name": "Swahili (Kiswahili)", "code": "sw", "region": "East Africa", "tag": "OTHERS"},
    {"name": "Persian / Farsi (فارسی)", "code": "fa", "region": "Iran / Middle East", "tag": "OTHERS"},
    {"name": "Polish (Polski)", "code": "pl", "region": "Poland", "tag": "OTHERS"},
    {"name": "Dutch (Nederlands)", "code": "nl", "region": "Netherlands / Belgium", "tag": "OTHERS"},
    {"name": "Thai (ไทย)", "code": "th", "region": "Thailand", "tag": "OTHERS"},
    {"name": "Malay (Bahasa Melayu)", "code": "ms", "region": "Malaysia", "tag": "OTHERS"},
    {"name": "Tamil (தமிழ்)", "code": "ta", "region": "India / Sri Lanka", "tag": "OTHERS"},
    {"name": "Telugu (తెలుగు)", "code": "te", "region": "India", "tag": "OTHERS"},
    {"name": "Marathi (मराठी)", "code": "mr", "region": "India", "tag": "OTHERS"},
    {"name": "Punjabi (ਪੰਜਾਬੀ)", "code": "pa", "region": "India / Pakistan", "tag": "OTHERS"},
    {"name": "Tagalog / Filipino", "code": "fil", "region": "Philippines", "tag": "OTHERS"},
    {"name": "Greek (Ελληνικά)", "code": "el", "region": "Greece", "tag": "OTHERS"},
    {"name": "Hebrew (עברית)", "code": "he", "region": "Israel", "tag": "OTHERS"},
    {"name": "Swedish (Svenska)", "code": "sv", "region": "Sweden", "tag": "OTHERS"},
    {"name": "Ukrainian (Українська)", "code": "uk", "region": "Ukraine", "tag": "OTHERS"},
    {"name": "Romanian (Română)", "code": "ro", "region": "Romania", "tag": "OTHERS"},
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: ink, size: 20),
            const SizedBox(width: 8),
            Text("Language set to $langName", style: const TextStyle(color: ink, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: gold,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = _allLanguages.where((l) {
      final nameMatches = l['name']!.toLowerCase().contains(query);
      final regionMatches = l['region']!.toLowerCase().contains(query);
      final codeMatches = l['code']!.toLowerCase().contains(query);
      return nameMatches || regionMatches || codeMatches;
    }).toList();

    final suggested = filtered.where((l) => l['tag'] == 'SUGGESTED').toList();
    final others = filtered.where((l) => l['tag'] == 'OTHERS').toList();

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
            // Search Input Field
            Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: hairline),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: paper, fontSize: 14),
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: "Search language or country...",
                  hintStyle: const TextStyle(color: muted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: gold, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, color: muted, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = "");
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (suggested.isNotEmpty) ...[
              const Text("SUGGESTED LANGUAGES", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              _buildLanguageCard(suggested),
              const SizedBox(height: 24),
            ],

            if (others.isNotEmpty) ...[
              const Text("ALL GLOBAL LANGUAGES", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              _buildLanguageCard(others),
            ],

            if (filtered.isEmpty) ...[
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.language_rounded, color: muted, size: 48),
                    const SizedBox(height: 12),
                    Text("No languages found for '$_searchQuery'", style: const TextStyle(color: paper, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text("Try searching with English name or region", style: TextStyle(color: muted, fontSize: 12)),
                  ],
                ),
              ),
            ],
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
          final region = lang['region']!;
          final isSelected = _selectedLanguage == name;

          return Column(
            children: [
              InkWell(
                onTap: () => _saveLanguage(name),
                borderRadius: BorderRadius.vertical(
                  top: index == 0 ? const Radius.circular(16) : Radius.zero,
                  bottom: index == langList.length - 1 ? const Radius.circular(16) : Radius.zero,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? gold.withOpacity(0.08) : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: name,
                        groupValue: _selectedLanguage,
                        activeColor: gold,
                        onChanged: (val) {
                          if (val != null) _saveLanguage(val);
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: isSelected ? gold : paper,
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              region,
                              style: TextStyle(
                                color: isSelected ? gold.withOpacity(0.8) : muted,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: gold,
                          ),
                          child: const Icon(Icons.check, color: ink, size: 14),
                        ),
                    ],
                  ),
                ),
              ),
              if (index < langList.length - 1) const Divider(color: hairline, height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}
