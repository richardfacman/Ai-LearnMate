import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class OrbitalShareDialog extends StatefulWidget {
  final String shareText;
  final String shareUrl;

  const OrbitalShareDialog({
    super.key,
    required this.shareText,
    this.shareUrl = "https://ai-learn-mate.vercel.app",
  });

  static void show(BuildContext context, {required String shareText, String shareUrl = "https://ai-learn-mate.vercel.app"}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (ctx) => OrbitalShareDialog(shareText: shareText, shareUrl: shareUrl),
    );
  }

  @override
  State<OrbitalShareDialog> createState() => _OrbitalShareDialogState();
}

class _OrbitalShareDialogState extends State<OrbitalShareDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  static const Color gold = Color(0xFFFFB020);
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);

  final List<Map<String, dynamic>> _platforms = [
    {
      "name": "Reddit",
      "color": const Color(0xFFFF4500),
      "iconText": "r/",
      "isCustom": true,
      "url": "https://reddit.com/submit?url={URL}&title={TEXT}",
    },
    {
      "name": "Twitter / X",
      "color": const Color(0xFF14171A),
      "iconText": "𝕏",
      "isCustom": true,
      "url": "https://x.com/intent/tweet?text={TEXT}%20{URL}",
    },
    {
      "name": "Discord",
      "color": const Color(0xFF5865F2),
      "iconData": Icons.discord,
      "url": "https://discord.com",
    },
    {
      "name": "WhatsApp",
      "color": const Color(0xFF25D366),
      "iconData": Icons.chat_bubble_outline_rounded,
      "url": "https://wa.me/?text={TEXT}%20{URL}",
    },
    {
      "name": "Snapchat",
      "color": const Color(0xFFFFFC00),
      "iconText": "👻",
      "isCustom": true,
      "textColor": Colors.black,
      "url": "https://snapchat.com",
    },
    {
      "name": "Instagram",
      "color": const Color(0xFFE4405F),
      "iconData": Icons.camera_alt_outlined,
      "url": "https://instagram.com",
    },
    {
      "name": "Pinterest",
      "color": const Color(0xFFE60023),
      "iconText": "P",
      "isCustom": true,
      "url": "https://pinterest.com/pin/create/button/?url={URL}&description={TEXT}",
    },
    {
      "name": "Messenger",
      "color": const Color(0xFF0084FF),
      "iconData": Icons.facebook,
      "url": "https://www.facebook.com/sharer/sharer.php?u={URL}&quote={TEXT}",
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _shareToPlatform(Map<String, dynamic> platform) async {
    final String encodedText = Uri.encodeComponent(widget.shareText);
    final String encodedUrl = Uri.encodeComponent(widget.shareUrl);

    String rawUrl = platform['url'] as String;
    rawUrl = rawUrl.replaceAll("{TEXT}", encodedText).replaceAll("{URL}", encodedUrl);

    // Always copy formatted text & link to clipboard first
    final fullPayload = "${widget.shareText}\n\nStudy on AI Learn Mate: ${widget.shareUrl}";
    await Clipboard.setData(ClipboardData(text: fullPayload));

    final Uri? uri = Uri.tryParse(rawUrl);
    if (uri != null) {
      try {
        bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      } catch (_) {}
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Shared via ${platform['name']}! Text copied to clipboard."),
          backgroundColor: gold,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _copyDirectLink() async {
    final fullPayload = "${widget.shareText}\n\nhttps://ai-learn-mate.vercel.app";
    await Clipboard.setData(ClipboardData(text: fullPayload));
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: ink, size: 20),
              SizedBox(width: 8),
              Text("Conversation link copied to clipboard!", style: TextStyle(color: ink, fontWeight: FontWeight.bold)),
            ],
          ),
          backgroundColor: gold,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double radius = 110;
    const double centerSize = 64;
    const double itemSize = 48;
    final int count = _platforms.length;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 320,
            height: 320,
            alignment: Alignment.center,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Orbital Platform Buttons
                for (int i = 0; i < count; i++) ...[
                  Builder(
                    builder: (context) {
                      final double angle = -pi / 2 + (2 * pi * i / count);
                      final double dx = radius * cos(angle);
                      final double dy = radius * sin(angle);
                      final p = _platforms[i];

                      return Positioned(
                        left: 160 + dx - (itemSize / 2),
                        top: 160 + dy - (itemSize / 2),
                        child: Tooltip(
                          message: "Share to ${p['name']}",
                          child: InkWell(
                            onTap: () => _shareToPlatform(p),
                            borderRadius: BorderRadius.circular(itemSize / 2),
                            child: Container(
                              width: itemSize,
                              height: itemSize,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: p['isCustom'] == true
                                  ? Text(
                                      p['iconText'] ?? "",
                                      style: TextStyle(
                                        color: p['textColor'] ?? p['color'],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    )
                                  : Icon(
                                      p['iconData'] as IconData? ?? Icons.share,
                                      color: p['color'] as Color?,
                                      size: 22,
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],

                // Center Main Share / Copy Hub
                Tooltip(
                  message: "Copy Link & Share",
                  child: InkWell(
                    onTap: _copyDirectLink,
                    borderRadius: BorderRadius.circular(centerSize / 2),
                    child: Container(
                      width: centerSize,
                      height: centerSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: gold, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: gold.withOpacity(0.5),
                            blurRadius: 18,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.share_rounded,
                        color: ink,
                        size: 28,
                      ),
                    ),
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
