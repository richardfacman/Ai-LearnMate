import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_contact_config.dart';
import 'feedback_screen.dart';
import 'report_problem_screen.dart';
import 'feature_request_screen.dart';

class ContactOwnerScreen extends StatelessWidget {
  const ContactOwnerScreen({super.key});

  // Exact Theme Tokens from ai-learn-mate-about.html
  static const Color ink = Color(0xFF05070F);
  static const Color cardBg = Color(0xFF101426);
  static const Color cardTop = Color(0xFF1C203A);
  static const Color gold = Color(0xFFFFC44D);
  static const Color goldDark = Color(0xFFEE9F16);
  static const Color goldInk = Color(0xFF1D1404);
  static const Color paper = Color(0xFFF1F4FC);
  static const Color muted = Color(0xFF8D9AC2);
  static const Color hairline = Color(0x248CA0FF);
  static const Color cyan = Color(0xFF4FC3E8);
  static const Color violet = Color(0xFF8C86FF);
  static const Color pink = Color(0xFFFF80B8);

  Future<void> _launchURL(BuildContext context, String urlString, String name) async {
    final Uri? uri = Uri.tryParse(urlString);
    if (uri == null) {
      if (context.mounted) {
        await _copyToClipboard(context, urlString, "$name link copied to clipboard!");
      }
      return;
    }

    try {
      bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      if (!launched && context.mounted) {
        await _copyToClipboard(context, urlString, "$name link copied to clipboard!");
      }
    } catch (_) {
      if (context.mounted) {
        await _copyToClipboard(context, urlString, "$name link copied to clipboard!");
      }
    }
  }

  Future<void> _emailOwner(BuildContext context) async {
    final Uri mailUri = Uri(
      scheme: 'mailto',
      path: AppContactConfig.ownerEmail,
      queryParameters: {
        'subject': 'AI Learn Mate Support / Inquiry',
        'body': 'Hello Foysal,\n\nI am contacting you regarding AI Learn Mate.\n\nThank you.',
      },
    );

    try {
      bool launched = await launchUrl(mailUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        launched = await launchUrl(mailUri, mode: LaunchMode.platformDefault);
      }
      if (!launched && context.mounted) {
        await _copyToClipboard(context, AppContactConfig.ownerEmail, "Email address copied to clipboard!");
      }
    } catch (_) {
      if (context.mounted) {
        await _copyToClipboard(context, AppContactConfig.ownerEmail, "Email address copied to clipboard!");
      }
    }
  }

  Future<void> _openLinkedIn(BuildContext context) async {
    await _launchURL(context, AppContactConfig.ownerLinkedIn, "LinkedIn");
  }

  Future<void> _openFacebook(BuildContext context) async {
    await _launchURL(context, AppContactConfig.ownerFacebook, "Facebook");
  }

  Future<void> _openTwitter(BuildContext context) async {
    await _launchURL(context, AppContactConfig.ownerTwitter, "Twitter / X");
  }

  Future<void> _shareProfile(BuildContext context) async {
    final String shareText = "Connect with ${AppContactConfig.ownerName} (${AppContactConfig.ownerRole}):\n"
        "Email: ${AppContactConfig.ownerEmail}\n"
        "Facebook: ${AppContactConfig.ownerFacebook}\n"
        "LinkedIn: ${AppContactConfig.ownerLinkedIn}\n"
        "X/Twitter: ${AppContactConfig.ownerTwitter}";
    await _copyToClipboard(context, shareText, "Owner contact links copied to clipboard!");
  }

  Future<void> _copyToClipboard(BuildContext context, String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: goldInk, fontWeight: FontWeight.bold)),
          backgroundColor: gold,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 720;

    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text("About & Contact Owner", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: ink,
        foregroundColor: paper,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: hairline, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                const Text(
                  "Hello!",
                  style: TextStyle(
                    color: paper,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Fraunces',
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: muted, fontSize: 15),
                    children: [
                      const TextSpan(text: "I'm "),
                      TextSpan(text: AppContactConfig.ownerName, style: const TextStyle(color: paper, fontWeight: FontWeight.bold)),
                      TextSpan(text: ", ${AppContactConfig.ownerRole} of AI Learn Mate."),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                // Main Glass Profile Card
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [cardTop, cardBg],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: hairline),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, 20)),
                    ],
                  ),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPortraitPhoto(),
                            const SizedBox(width: 26),
                            Expanded(child: _buildAboutMeSection()),
                            const SizedBox(width: 26),
                            _buildDetailsSection(context),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(child: _buildPortraitPhoto()),
                            const SizedBox(height: 24),
                            _buildAboutMeSection(),
                            const SizedBox(height: 24),
                            _buildDetailsSection(context),
                          ],
                        ),
                ),
                const SizedBox(height: 34),

                // Feedback Section
                const Text(
                  "NEED ASSISTANCE OR HAVE FEEDBACK?",
                  style: TextStyle(
                    color: gold,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        icon: Icons.bug_report_outlined,
                        label: "Report bug",
                        isPrimary: false,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportProblemScreen())),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        icon: Icons.rate_review_outlined,
                        label: "Feedback",
                        isPrimary: true,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen())),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        icon: Icons.lightbulb_outline,
                        label: "Suggest",
                        isPrimary: false,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeatureRequestScreen())),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 34),

                // About Product Section
                const Text(
                  "ABOUT AI LEARN MATE",
                  style: TextStyle(
                    color: gold,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "AI Learn Mate integrates 10 intelligent study tools into one adaptive learning engine:",
                  style: TextStyle(color: muted, fontSize: 13.8, height: 1.5),
                ),
                const SizedBox(height: 16),

                // 10 Tool Chips
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: const [
                    _ToolChip(label: "AI Tutor", iconColor: cyan, icon: Icons.psychology_outlined),
                    _ToolChip(label: "Smart Flashcards", iconColor: violet, icon: Icons.style_outlined),
                    _ToolChip(label: "Quick Quiz", iconColor: gold, icon: Icons.bolt_outlined),
                    _ToolChip(label: "Study Planner", iconColor: cyan, icon: Icons.calendar_today_outlined),
                    _ToolChip(label: "Analytics", iconColor: pink, icon: Icons.bar_chart_outlined),
                    _ToolChip(label: "Scanner", iconColor: cyan, icon: Icons.qr_code_scanner_outlined),
                    _ToolChip(label: "Voice Tutor", iconColor: violet, icon: Icons.mic_none_outlined),
                    _ToolChip(label: "Pomodoro", iconColor: pink, icon: Icons.timer_outlined),
                    _ToolChip(label: "Mistake Bank", iconColor: Color(0xFFFF9A9A), icon: Icons.bookmark_border_outlined, isDanger: true),
                    _ToolChip(label: "Adaptive Learning", iconColor: gold, icon: Icons.check_outlined),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitPhoto() {
    return Container(
      width: 180,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold, width: 2),
        boxShadow: [
          BoxShadow(color: gold.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          AppContactConfig.ownerPhotoUrl,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              AppContactConfig.ownerAssetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: cardTop,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: gold,
                        child: Text("FA", style: TextStyle(color: goldInk, fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 12),
                      Text("Foysal Ahmed", style: TextStyle(color: paper, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAboutMeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("About me", style: TextStyle(color: paper, fontSize: 19, fontWeight: FontWeight.w600, fontFamily: 'Fraunces')),
        SizedBox(height: 10),
        Text(
          AppContactConfig.ownerBio,
          style: TextStyle(color: muted, fontSize: 13.8, height: 1.7),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Details", style: TextStyle(color: paper, fontSize: 19, fontWeight: FontWeight.w600, fontFamily: 'Fraunces')),
        const SizedBox(height: 12),
        _detailPair("Name:", AppContactConfig.ownerName),
        _detailPair("Role:", AppContactConfig.ownerRole),
        _detailPair("Project:", AppContactConfig.ownerProject),
        _detailPair("Location:", AppContactConfig.ownerLocation),
        const SizedBox(height: 16),

        // Social Icons Row (Facebook, Mail, LinkedIn, X, Share)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _socialButton(
              bgColor: const Color(0xFF1877F2),
              icon: const Icon(Icons.facebook, color: Colors.white, size: 20),
              onTap: () => _openFacebook(context),
            ),
            const SizedBox(width: 9),
            _socialButton(
              bgColor: const Color(0xFFEA4335),
              icon: const Icon(Icons.mail_rounded, color: Colors.white, size: 18),
              onTap: () => _emailOwner(context),
            ),
            const SizedBox(width: 9),
            _socialButton(
              bgColor: const Color(0xFF0A66C2),
              icon: const Text("in", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              onTap: () => _openLinkedIn(context),
            ),
            const SizedBox(width: 9),
            _socialButton(
              bgColor: Colors.black,
              borderColor: hairline,
              icon: const Text("𝕏", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              onTap: () => _openTwitter(context),
            ),
            const SizedBox(width: 9),
            _socialButton(
              bgColor: Colors.transparent,
              borderColor: gold,
              icon: const Icon(Icons.share_outlined, color: gold, size: 18),
              onTap: () => _shareProfile(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _detailPair(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: const TextStyle(color: muted, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Text(value, style: const TextStyle(color: paper, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _socialButton({
    required Color bgColor,
    Color? borderColor,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor ?? Colors.transparent),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Center(child: icon),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isPrimary
            ? const LinearGradient(
                colors: [gold, goldDark],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null,
        color: isPrimary ? null : cardBg,
        border: isPrimary ? null : Border.all(color: hairline),
        boxShadow: isPrimary
            ? [
                BoxShadow(color: gold.withValues(alpha: 0.4), blurRadius: 18, offset: const Offset(0, 8)),
              ]
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isPrimary ? goldInk : paper),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? goldInk : paper,
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  final String label;
  final Color iconColor;
  final IconData icon;
  final bool isDanger;

  const _ToolChip({
    required this.label,
    required this.iconColor,
    required this.icon,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF101426),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDanger ? const Color(0x66FF6E6E) : const Color(0x248CA0FF),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isDanger ? const Color(0xFFFF9A9A) : const Color(0xFFF1F4FC),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
