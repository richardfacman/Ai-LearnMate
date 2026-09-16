import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_contact_config.dart';
import 'feedback_screen.dart';
import 'report_problem_screen.dart';
import 'feature_request_screen.dart';

class ContactOwnerScreen extends StatelessWidget {
  const ContactOwnerScreen({super.key});

  // Theme Tokens
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color surfaceHi = Color(0xFF1B2230);
  static const Color gold = Color(0xFFF0A93E);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x1AF4EFE6);

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
          content: Text(message, style: const TextStyle(color: ink, fontWeight: FontWeight.w600)),
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
    final isDesktop = size.width > 800;

    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text("About & Contact Owner", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: surface,
        foregroundColor: paper,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isDesktop ? 900 : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title
                const Text("Hello!", style: TextStyle(color: paper, fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text(
                  "I'm Foysal Ahmed, Project Owner & Developer of AI Learn Mate.",
                  style: TextStyle(color: muted, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 24),

                // Main Reference Layout Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: hairline),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPortraitCard(),
                            const SizedBox(width: 28),
                            Expanded(child: _buildAboutMeSection()),
                            const SizedBox(width: 28),
                            Expanded(child: _buildDetailsSection(context)),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(child: _buildPortraitCard()),
                            const SizedBox(height: 24),
                            _buildAboutMeSection(),
                            const SizedBox(height: 24),
                            _buildDetailsSection(context),
                          ],
                        ),
                ),
                const SizedBox(height: 28),

                // Quick Assistance Row
                const Text("NEED ASSISTANCE OR HAVE FEEDBACK?", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportProblemScreen())),
                        icon: const Icon(Icons.bug_report_outlined, size: 16),
                        label: const Text("Report Bug"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: surface,
                          foregroundColor: paper,
                          side: const BorderSide(color: hairline),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen())),
                        icon: const Icon(Icons.rate_review_outlined, size: 16),
                        label: const Text("Feedback"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: ink,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeatureRequestScreen())),
                        icon: const Icon(Icons.lightbulb_outline, size: 16),
                        label: const Text("Suggest"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: surfaceHi,
                          foregroundColor: paper,
                          side: const BorderSide(color: hairline),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // About AI Learn Mate Features
                const Text("ABOUT AI LEARN MATE", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 10),
                const Text(
                  "AI Learn Mate integrates 10 intelligent study tools into one adaptive learning engine:",
                  style: TextStyle(color: muted, fontSize: 12.5),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _FeatureChip("🤖 AI Tutor"),
                    _FeatureChip("🎴 Smart Flashcards"),
                    _FeatureChip("⚡ Quick Quiz"),
                    _FeatureChip("📅 Study Planner"),
                    _FeatureChip("📊 Analytics"),
                    _FeatureChip("📸 Scanner"),
                    _FeatureChip("🎙️ Voice Tutor"),
                    _FeatureChip("⏱️ Pomodoro"),
                    _FeatureChip("❌ Mistake Bank"),
                    _FeatureChip("📈 Adaptive Learning"),
                  ],
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitCard() {
    return Container(
      width: 200,
      height: 260,
      decoration: BoxDecoration(
        color: surfaceHi,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          AppContactConfig.ownerAssetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.network(
              AppContactConfig.ownerPhotoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: gold.withOpacity(0.2),
                          border: Border.all(color: gold, width: 2),
                        ),
                        child: const Text("FA", style: TextStyle(color: gold, fontSize: 32, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      const Text("Foysal Ahmed", style: TextStyle(color: paper, fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text("Project Owner", style: TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.w600)),
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
        Text("About me", style: TextStyle(color: paper, fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text(
          AppContactConfig.ownerBio,
          style: TextStyle(color: muted, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Details", style: TextStyle(color: paper, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _detailRow("Name:", AppContactConfig.ownerName),
        _detailRow("Role:", AppContactConfig.ownerRole),
        _detailRow("Project:", AppContactConfig.ownerProject),
        _detailRow("Location:", AppContactConfig.ownerLocation),
        const SizedBox(height: 20),

        // Social Action Icons Bar (Facebook, Gmail, LinkedIn, Twitter/X, Share)
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _socialIconTile(
              iconWidget: const Icon(Icons.facebook, color: Colors.white, size: 22),
              backgroundColor: const Color(0xFF1877F2),
              borderColor: const Color(0xFF1877F2),
              tooltip: "Open Facebook Profile",
              onTap: () => _openFacebook(context),
            ),
            _socialIconTile(
              iconWidget: const Icon(Icons.mail_rounded, color: Color(0xFFEA4335), size: 22),
              backgroundColor: surfaceHi,
              borderColor: const Color(0xFFEA4335),
              tooltip: "Send Email (${AppContactConfig.ownerEmail})",
              onTap: () => _emailOwner(context),
            ),
            _socialIconTile(
              iconWidget: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF0077B5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "in",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'sans-serif',
                    height: 1.0,
                  ),
                ),
              ),
              backgroundColor: const Color(0xFF0077B5),
              borderColor: const Color(0xFF0077B5),
              tooltip: "Open LinkedIn Profile",
              onTap: () => _openLinkedIn(context),
            ),
            _socialIconTile(
              iconWidget: const Text(
                "𝕏",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              backgroundColor: const Color(0xFF14171A),
              borderColor: const Color(0xFF1DA1F2),
              tooltip: "Open Twitter / X (@AhmedMdfaisal)",
              onTap: () => _openTwitter(context),
            ),
            _socialIconTile(
              iconWidget: const Icon(Icons.share_rounded, color: gold, size: 20),
              backgroundColor: surfaceHi,
              borderColor: gold.withOpacity(0.6),
              tooltip: "Share Owner Contact Details",
              onTap: () => _shareProfile(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: const TextStyle(color: paper, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: muted, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _socialIconTile({
    required Widget iconWidget,
    required Color backgroundColor,
    required Color borderColor,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: iconWidget,
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  const _FeatureChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF151A24),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x1AF4EFE6)),
      ),
      child: Text(label, style: const TextStyle(color: Color(0xFFF4EFE6), fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}
