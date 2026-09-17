import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../../services/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _photoUrlCtrl = TextEditingController();

  bool _loading = false;
  String _selectedGraphicAvatar = "🤖 AI Neural";
  String _selectedGraphicBanner = "🌌 Deep Space Nebula";
  Color _selectedAccentColor = const Color(0xFFF0A93E);

  // Theme Tokens
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color surfaceHi = Color(0xFF181F33);
  static const Color gold = Color(0xFFF0A93E);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x1AF4EFE6);

  final List<Map<String, dynamic>> _graphicAvatars = [
    {"name": "🤖 AI Neural", "icon": Icons.smart_toy_rounded, "color": const Color(0xFF00E5FF)},
    {"name": "🎨 Cyber Scholar", "icon": Icons.palette_rounded, "color": const Color(0xFFB388FF)},
    {"name": "🎓 Gold Fellow", "icon": Icons.school_rounded, "color": const Color(0xFFF0A93E)},
    {"name": "🌟 Starlight", "icon": Icons.star_rounded, "color": const Color(0xFFFFD54F)},
    {"name": "🚀 Cosmic Voyager", "icon": Icons.rocket_launch_rounded, "color": const Color(0xFFFF80AB)},
    {"name": "📜 Socratic Sage", "icon": Icons.menu_book_rounded, "color": const Color(0xFF34D399)},
    {"name": "⚡ Quantum Genius", "icon": Icons.bolt_rounded, "color": const Color(0xFF00E5FF)},
    {"name": "🧘 Zen Mentor", "icon": Icons.self_improvement_rounded, "color": const Color(0xFF81C784)},
  ];

  final List<Color> _graphicAccentColors = [
    const Color(0xFFF0A93E), // Gold
    const Color(0xFF00E5FF), // Cyan
    const Color(0xFFB388FF), // Violet
    const Color(0xFF34D399), // Emerald
    const Color(0xFFFF80AB), // Rose
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  void _loadCurrentUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final fbUser = _auth.currentUser;

    if (user != null) {
      _nameCtrl.text = user.name;
      _emailCtrl.text = user.email;
      _photoUrlCtrl.text = user.photoUrl ?? '';
    } else if (fbUser != null) {
      _nameCtrl.text = fbUser.displayName ?? '';
      _emailCtrl.text = fbUser.email ?? '';
      _photoUrlCtrl.text = fbUser.photoURL ?? '';
    }

    try {
      final box = Hive.box('settings');
      setState(() {
        _selectedGraphicAvatar = box.get('graphic_avatar', defaultValue: "🤖 AI Neural");
        _selectedGraphicBanner = box.get('graphic_banner', defaultValue: "🌌 Deep Space Nebula");
      });
    } catch (_) {}
  }

  Future<void> _saveProfile() async {
    final newName = _nameCtrl.text.trim();
    final photoUrl = _photoUrlCtrl.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name cannot be empty!", style: TextStyle(color: paper)),
          backgroundColor: surface,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
        if (photoUrl.isNotEmpty) {
          try {
            await user.updatePhotoURL(photoUrl);
          } catch (_) {}
        }

        final uid = user.uid;

        await _db.collection('users').doc(uid).set({
          'name': newName,
          'phone': _phoneCtrl.text.trim(),
          'photoUrl': photoUrl.isNotEmpty ? photoUrl : user.photoURL,
          'graphicAvatar': _selectedGraphicAvatar,
          'graphicBanner': _selectedGraphicBanner,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        try {
          final box = Hive.box('settings');
          await box.put('graphic_avatar', _selectedGraphicAvatar);
          await box.put('graphic_banner', _selectedGraphicBanner);
        } catch (_) {}

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: ink, size: 20),
                  SizedBox(width: 8),
                  Text("Profile & Graphic Setup Saved!", style: TextStyle(color: ink, fontWeight: FontWeight.bold)),
                ],
              ),
              backgroundColor: gold,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating profile: $e"), backgroundColor: surface),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _photoUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text("Edit Profile & Graphic Setup", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: surface,
        foregroundColor: paper,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Graphic Avatar Selection Section
                Text("USER GRAPHIC DESIGN SETUP", style: TextStyle(color: _selectedAccentColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: hairline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Select Graphic Avatar Badge", style: TextStyle(color: paper, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text("Choose an avatar style for your study profile", style: TextStyle(color: muted, fontSize: 12)),
                      const SizedBox(height: 16),

                      // Graphic Avatar Badges Grid
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _graphicAvatars.map((a) {
                          final isSelected = _selectedGraphicAvatar == a['name'];
                          final Color avatarColor = a['color'] as Color;

                          return InkWell(
                            onTap: () => setState(() => _selectedGraphicAvatar = a['name'] as String),
                            borderRadius: BorderRadius.circular(14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? avatarColor.withOpacity(0.18) : surfaceHi,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: isSelected ? avatarColor : hairline, width: isSelected ? 1.5 : 1.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(a['icon'] as IconData, color: avatarColor, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    a['name'] as String,
                                    style: TextStyle(
                                      color: isSelected ? avatarColor : paper,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Accent Theme Color Picker
                      const Text("Graphic Accent Theme", style: TextStyle(color: paper, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        children: _graphicAccentColors.map((color) {
                          final isSelected = _selectedAccentColor == color;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              onTap: () => setState(() => _selectedAccentColor = color),
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2.5),
                                  boxShadow: [
                                    if (isSelected) BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
                                  ],
                                ),
                                child: isSelected ? const Icon(Icons.check, color: ink, size: 18) : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Personal Info Section
                const Text("PERSONAL INFORMATION", style: TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: hairline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Full Name", style: TextStyle(color: muted, fontSize: 12)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: surfaceHi,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: hairline),
                        ),
                        child: TextField(
                          controller: _nameCtrl,
                          style: const TextStyle(color: paper, fontSize: 14),
                          decoration: const InputDecoration(border: InputBorder.none, hintText: "Enter full name", hintStyle: TextStyle(color: muted)),
                        ),
                      ),
                      const SizedBox(height: 18),

                      const Text("Email Address (Verified)", style: TextStyle(color: muted, fontSize: 12)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: surfaceHi.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: hairline),
                        ),
                        child: TextField(
                          controller: _emailCtrl,
                          enabled: false,
                          style: const TextStyle(color: muted, fontSize: 14),
                          decoration: const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                      const SizedBox(height: 18),

                      const Text("Profile Photo Image URL (Optional)", style: TextStyle(color: muted, fontSize: 12)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: surfaceHi,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: hairline),
                        ),
                        child: TextField(
                          controller: _photoUrlCtrl,
                          style: const TextStyle(color: paper, fontSize: 14),
                          decoration: const InputDecoration(border: InputBorder.none, hintText: "https://example.com/photo.jpg", hintStyle: TextStyle(color: muted)),
                        ),
                      ),
                      const SizedBox(height: 18),

                      const Text("Phone Number (Optional)", style: TextStyle(color: muted, fontSize: 12)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: surfaceHi,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: hairline),
                        ),
                        child: TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: paper, fontSize: 14),
                          decoration: const InputDecoration(border: InputBorder.none, hintText: "+1 (555) 000-0000", hintStyle: TextStyle(color: muted)),
                        ),
                      ),
                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedAccentColor,
                            foregroundColor: ink,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: _loading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: ink, strokeWidth: 2))
                              : const Text("Save Profile & Graphic Setup", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
