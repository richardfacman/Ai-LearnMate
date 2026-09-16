import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/user_provider.dart';
import '../../services/theme_service.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'language_screen.dart';
import 'security_screen.dart';
import 'theme_screen.dart';
import 'help_support_screen.dart';
import 'contact_us_screen.dart';
import 'privacy_policy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;

  // Theme Tokens
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color surfaceHi = Color(0xFF1B2230);
  static const Color gold = Color(0xFFF0A93E);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x1AF4EFE6);

  Future<void> _confirmSignOut() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        title: const Text("Sign Out?", style: TextStyle(color: paper, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to sign out of Ai Learn Mate?", style: TextStyle(color: muted, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: muted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _auth.signOut();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Sign Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeService = Provider.of<ThemeService>(context);
    final user = userProvider.user;
    final fbUser = _auth.currentUser;

    final displayName = user?.name ?? fbUser?.displayName ?? "Student";
    final email = user?.email ?? fbUser?.email ?? "student@ilearnmate.app";
    final photoUrl = user?.photoUrl ?? fbUser?.photoURL;

    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text("Profile & Settings", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: surface,
        foregroundColor: paper,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isDesktop ? 800 : double.infinity),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                // Profile Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: hairline),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: gold.withOpacity(0.2),
                        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                        child: photoUrl == null
                            ? Text(
                                displayName.isNotEmpty ? displayName[0].toUpperCase() : "S",
                                style: const TextStyle(color: gold, fontSize: 24, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(color: paper, fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: const TextStyle(color: muted, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: gold, size: 20),
                        tooltip: "Edit Profile",
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 1: ACCOUNT / GENERAL
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("ACCOUNT & GENERAL", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
                const SizedBox(height: 10),
                _buildSettingsGroup([
                  _settingsTile(
                    icon: Icons.person_outline,
                    title: "Edit Profile Information",
                    subtitle: "Update your name and profile details",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                  ),
                  _settingsTile(
                    icon: Icons.notifications_none_outlined,
                    title: "Notifications",
                    subtitle: "Manage study and quiz reminders",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                  ),
                  _settingsTile(
                    icon: Icons.language_outlined,
                    title: "Language",
                    subtitle: "English (US) / Bangla (বাংলা)",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageScreen())),
                  ),
                ]),
                const SizedBox(height: 24),

                // Section 2: SECURITY & APPEARANCE
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("SECURITY & APPEARANCE", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
                const SizedBox(height: 10),
                _buildSettingsGroup([
                  _settingsTile(
                    icon: Icons.security_outlined,
                    title: "Security & Password",
                    subtitle: "Update password and account security",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityScreen())),
                  ),
                  _settingsTile(
                    icon: Icons.palette_outlined,
                    title: "Theme & Appearance",
                    subtitle: themeService.isDark ? "Dark Theme (Lamp-lit Desk)" : "Light Theme",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemeScreen())),
                  ),
                ]),
                const SizedBox(height: 24),

                // Section 3: SUPPORT & PRIVACY
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("SUPPORT & PRIVACY", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
                const SizedBox(height: 10),
                _buildSettingsGroup([
                  _settingsTile(
                    icon: Icons.help_outline,
                    title: "Help & Support",
                    subtitle: "FAQs, AI Tutor guides, and troubleshooting",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
                  ),
                  _settingsTile(
                    icon: Icons.mail_outline,
                    title: "Contact Us & Feedback",
                    subtitle: "Send feedback or report an issue",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen())),
                  ),
                  _settingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: "Privacy Policy",
                    subtitle: "How AI Learn Mate handles your data",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                  ),
                ]),
                const SizedBox(height: 32),

                // Sign Out Button
                OutlinedButton.icon(
                  onPressed: _confirmSignOut,
                  icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                  label: const Text("Sign Out", style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hairline),
      ),
      child: Column(
        children: tiles.asMap().entries.map((entry) {
          final index = entry.key;
          final tile = entry.value;
          return Column(
            children: [
              tile,
              if (index < tiles.length - 1) const Divider(color: hairline, height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: surfaceHi,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: gold, size: 18),
      ),
      title: Text(title, style: const TextStyle(color: paper, fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(color: muted, fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, color: muted, size: 12),
      onTap: onTap,
    );
  }
}
