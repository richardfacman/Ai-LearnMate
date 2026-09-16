import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_contact_config.dart';
import 'feedback_screen.dart';
import 'report_problem_screen.dart';

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

  Future<void> _emailOwner(BuildContext context) async {
    final Uri mailUri = Uri(
      scheme: 'mailto',
      path: AppContactConfig.ownerEmail,
      queryParameters: {
        'subject': 'AI Learn Mate Support Request',
        'body': 'Hello Foysal,\n\nI need help with AI Learn Mate.\n\nProblem:\n\nThank you.',
      },
    );

    try {
      if (await canLaunchUrl(mailUri)) {
        await launchUrl(mailUri, mode: LaunchMode.externalApplication);
      } else {
        await _copyToClipboard(context, AppContactConfig.ownerEmail, "Email copied! Opening mail client failed.");
      }
    } catch (_) {
      await _copyToClipboard(context, AppContactConfig.ownerEmail, "Email address copied to clipboard!");
    }
  }

  Future<void> _openLinkedIn(BuildContext context) async {
    final Uri url = Uri.parse(AppContactConfig.ownerLinkedIn);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await _copyToClipboard(context, AppContactConfig.ownerLinkedIn, "LinkedIn link copied!");
      }
    } catch (_) {
      await _copyToClipboard(context, AppContactConfig.ownerLinkedIn, "LinkedIn link copied to clipboard!");
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: gold, duration: const Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text("Contact Owner", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: surface,
        foregroundColor: paper,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            // Owner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: gold.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: gold.withOpacity(0.2),
                    child: const Icon(Icons.person, color: gold, size: 48),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    AppContactConfig.ownerName,
                    style: const TextStyle(color: paper, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppContactConfig.ownerRole,
                    style: const TextStyle(color: gold, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Email Box
            _contactCard(
              icon: Icons.email_outlined,
              title: "Direct Email",
              value: AppContactConfig.ownerEmail,
              buttonLabel: "Email Owner",
              onPrimaryTap: () => _emailOwner(context),
              onCopyTap: () => _copyToClipboard(context, AppContactConfig.ownerEmail, "Email address copied to clipboard!"),
            ),
            const SizedBox(height: 16),

            // LinkedIn Box
            _contactCard(
              icon: Icons.link,
              title: "LinkedIn Profile",
              value: AppContactConfig.ownerLinkedIn,
              buttonLabel: "Open LinkedIn",
              onPrimaryTap: () => _openLinkedIn(context),
              onCopyTap: () => _copyToClipboard(context, AppContactConfig.ownerLinkedIn, "LinkedIn URL copied to clipboard!"),
            ),
            const SizedBox(height: 28),

            // Need Help Quick Links
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("NEED DIRECT ASSISTANCE?", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportProblemScreen())),
                    icon: const Icon(Icons.bug_report_outlined, size: 18),
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
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen())),
                    icon: const Icon(Icons.rate_review_outlined, size: 18),
                    label: const Text("Send Feedback"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: ink,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required String title,
    required String value,
    required String buttonLabel,
    required VoidCallback onPrimaryTap,
    required VoidCallback onCopyTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: gold, size: 20),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(
            value,
            style: const TextStyle(color: paper, fontSize: 13.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onPrimaryTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: ink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.copy_outlined, color: paper, size: 18),
                tooltip: "Copy to clipboard",
                onPressed: onCopyTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
