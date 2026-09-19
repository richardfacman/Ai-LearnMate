import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/user_provider.dart';
import '../../config/app_contact_config.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'theme_screen.dart';
import 'contact_owner_screen.dart';
import 'feedback_screen.dart';
import 'report_problem_screen.dart';
import 'privacy_policy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;

  // Exact Theme Tokens from ai-learn-mate-profile.html
  static const Color ink = Color(0xFF05070F);
  static const Color cardBg = Color(0xFF101426);
  static const Color cardTop = Color(0xFF1C203A);
  static const Color field = Color(0xCC060914);
  static const Color gold = Color(0xFFFFC44D);
  static const Color goldDark = Color(0xFFEE9F16);
  static const Color goldInk = Color(0xFF1D1404);
  static const Color paper = Color(0xFFF1F4FC);
  static const Color muted = Color(0xFF8D9AC2);
  static const Color hairline = Color(0x248CA0FF);
  static const Color cyan = Color(0xFF4FC3E8);
  static const Color violet = Color(0xFF8C86FF);
  static const Color pink = Color(0xFFFF80B8);
  static const Color danger = Color(0xFFFF6B6B);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    final name = user?.name ?? "Foysal Ahmed";
    final streak = user?.streak ?? 0;
    final level = user?.level ?? 1;
    final xp = user?.xp ?? 0;

    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif')),
        backgroundColor: ink,
        foregroundColor: paper,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: muted, size: 20),
            tooltip: "Settings",
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemeScreen())),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: hairline, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Header
                _buildProfileHeader(name, streak, level),
                const SizedBox(height: 22),

                // Glass Stat Row
                _buildStatsRow(xp, level),
                const SizedBox(height: 28),

                // Study Progress Section
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("STUDY PROGRESS", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
                const SizedBox(height: 10),
                _buildProgressCard(),
                const SizedBox(height: 28),

                // Account Section
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("ACCOUNT", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
                const SizedBox(height: 10),
                _buildGlassGroup([
                  _rowTile(
                    icon: Icons.person_outline,
                    color: cyan,
                    title: "Edit Profile",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                  ),
                  _rowTile(
                    icon: Icons.notifications_none_outlined,
                    color: violet,
                    title: "Notification Settings",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                  ),
                  _rowTile(
                    icon: Icons.tune_outlined,
                    color: gold,
                    title: "Study Preferences",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemeScreen())),
                  ),
                  _rowTile(
                    icon: Icons.shield_outlined,
                    color: cyan,
                    title: "Privacy & Data",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                  ),
                  _rowTile(
                    icon: Icons.info_outline,
                    color: pink,
                    title: "About & Contact Owner",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactOwnerScreen())),
                  ),
                ]),
                const SizedBox(height: 28),

                // Support Section
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("SUPPORT", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
                const SizedBox(height: 10),
                _buildGlassGroup([
                  _rowTile(
                    icon: Icons.bug_report_outlined,
                    color: danger,
                    title: "Report Bug",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportProblemScreen())),
                  ),
                  _rowTile(
                    icon: Icons.rate_review_outlined,
                    color: gold,
                    title: "Send Feedback",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen())),
                  ),
                  _rowTile(
                    icon: Icons.star_border_rounded,
                    color: cyan,
                    title: "Rate the App",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Thank you for rating AI Learn Mate! ★★★★★"), backgroundColor: gold),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 32),

                // Log Out Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () async {
                      await _auth.signOut();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: danger.withValues(alpha: 0.08),
                      side: BorderSide(color: danger.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("Log Out", style: TextStyle(color: danger, fontWeight: FontWeight.bold, fontSize: 14.5)),
                  ),
                ),
                const SizedBox(height: 16),

                const Text("AI Learn Mate v1.0.0", style: TextStyle(color: muted, fontSize: 12)),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, int streak, int level) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [gold, goldDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(color: gold.withValues(alpha: 0.45), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              AppContactConfig.ownerPhotoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                AppContactConfig.ownerAssetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: cardTop,
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "F",
                      style: const TextStyle(color: gold, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          style: const TextStyle(color: paper, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Fraunces', letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Text("Student · Level $level", style: const TextStyle(color: muted, fontSize: 13.5, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: gold.withValues(alpha: 0.35)),
          ),
          child: Text("🔥 $streak day streak", style: const TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildStatsRow(int xp, int level) {
    return Container(
      decoration: BoxDecoration(
        color: hairline,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: hairline),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            _statCol("$xp XP", "EARNED"),
            Container(width: 1, height: 50, color: hairline),
            _statCol("$level", "LEVEL"),
            Container(width: 1, height: 50, color: hairline),
            _statCol("0", "BADGES"),
          ],
        ),
      ),
    );
  }

  Widget _statCol(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [cardTop, cardBg],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: gold, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Fraunces')),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [cardTop, cardBg], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: hairline),
      ),
      child: Column(
        children: [
          _progressRow("Mathematics", 0.45, cyan, Icons.attach_money_rounded),
          const Divider(color: hairline, height: 1),
          _progressRow("Computer Science", 0.80, violet, Icons.laptop_chromebook_rounded),
          const Divider(color: hairline, height: 1),
          _progressRow("Physics & AI", 0.30, pink, Icons.science_outlined),
        ],
      ),
    );
  }

  Widget _progressRow(String label, double val, Color icColor, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: field, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: icColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: const TextStyle(color: paper, fontSize: 13, fontWeight: FontWeight.bold)),
                    Text("${(val * 100).toInt()}%", style: const TextStyle(color: gold, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: val,
                    backgroundColor: field,
                    color: gold,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [cardTop, cardBg], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: hairline),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return Column(
            children: [
              item,
              if (idx < children.length - 1) const Divider(color: hairline, height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _rowTile({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: field, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(title, style: const TextStyle(color: paper, fontSize: 13.5, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded, color: muted, size: 18),
    );
  }
}
