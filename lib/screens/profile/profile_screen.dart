import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/user_provider.dart';
import '../../services/theme_service.dart';
import '../../widgets/share_widgets.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'language_screen.dart';
import 'security_screen.dart';
import 'theme_screen.dart';
import 'help_support_screen.dart';
import 'contact_owner_screen.dart';
import 'feedback_screen.dart';
import 'report_problem_screen.dart';
import 'feature_request_screen.dart';
import 'my_reports_screen.dart';
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
  static const Color gold = Color(0xFFFFB020);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x1AF4EFE6);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeService = Provider.of<ThemeService>(context);
    final user = userProvider.user;

    final name = user?.name ?? "Foysal Ahmed";
    final email = user?.email ?? "foysal@example.com";
    final photoUrl = user?.photoUrl;

    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text("Profile & Settings", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.w600)),
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
              children: [
                // User Profile Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: hairline),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: surfaceHi,
                          border: Border.all(color: gold, width: 2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: photoUrl != null && photoUrl.isNotEmpty
                            ? Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _avatarFallback(name))
                            : _avatarFallback(name),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(color: paper, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(email, style: const TextStyle(color: muted, fontSize: 13)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: gold.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: gold.withOpacity(0.4)),
                              ),
                              child: Text(
                                "Streak: ${user?.streak ?? 0} days • Level ${user?.level ?? 1}",
                                style: const TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 1: ACCOUNT & CONTENT
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("ACCOUNT & CONTENT", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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
                    icon: Icons.folder_shared_outlined,
                    title: "Shared Content",
                    subtitle: "Join by code or view notes shared with you",
                    onTap: () {
                      final uid = _auth.currentUser?.uid ?? '';
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => JoinSharedContentScreen(currentUserId: uid)),
                      );
                    },
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
                    icon: Icons.contact_support_outlined,
                    title: "Contact Owner",
                    subtitle: "Foysal Ahmed — Email, Facebook, LinkedIn & X",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactOwnerScreen())),
                  ),
                  _settingsTile(
                    icon: Icons.help_outline,
                    title: "Help & Support",
                    subtitle: "FAQs, AI Tutor guides, and troubleshooting",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
                  ),
                  _settingsTile(
                    icon: Icons.rate_review_outlined,
                    title: "Send Feedback",
                    subtitle: "Share your experience and thoughts",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen())),
                  ),
                  _settingsTile(
                    icon: Icons.bug_report_outlined,
                    title: "Report a Problem",
                    subtitle: "Submit bug reports or technical issues",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportProblemScreen())),
                  ),
                  _settingsTile(
                    icon: Icons.lightbulb_outline,
                    title: "Suggest Feature",
                    subtitle: "Request new features for AI Learn Mate",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeatureRequestScreen())),
                  ),
                  _settingsTile(
                    icon: Icons.assignment_outlined,
                    title: "My Submitted Reports",
                    subtitle: "View status of your bug & feedback reports",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyReportsScreen())),
                  ),
                  _settingsTile(
                    icon: Icons.policy_outlined,
                    title: "Privacy Policy",
                    subtitle: "Data privacy and terms of service",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                  ),
                ]),
                const SizedBox(height: 32),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await _auth.signOut();
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                    label: const Text("Log Out", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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

  Widget _avatarFallback(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : "F",
        style: const TextStyle(color: gold, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hairline),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final widget = entry.value;
          return Column(
            children: [
              widget,
              if (index < children.length - 1) const Divider(color: hairline, height: 1),
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
      leading: Icon(icon, color: gold, size: 20),
      title: Text(title, style: const TextStyle(color: paper, fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: muted, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: muted, size: 20),
      onTap: onTap,
    );
  }
}
