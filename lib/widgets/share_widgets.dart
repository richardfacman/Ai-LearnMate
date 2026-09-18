import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/shared_content.dart';
import '../services/share_service.dart';

const _accent = Color(0xFFFFB020);
const _card = Color(0xFF15151F);
const _bg = Color(0xFF0B0B14);

/// Call this from a note / flashcard-set / quiz detail screen's app bar
/// action to share that item.
Future<void> showShareSheet({
  required BuildContext context,
  required SharedContentType type,
  required String title,
  required String ownerId,
  required String ownerName,
  required Map<String, dynamic> content,
}) async {
  final service = ShareService();
  showModalBottomSheet(
    context: context,
    backgroundColor: _card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _ShareSheet(
      service: service,
      type: type,
      title: title,
      ownerId: ownerId,
      ownerName: ownerName,
      content: content,
    ),
  );
}

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({
    required this.service,
    required this.type,
    required this.title,
    required this.ownerId,
    required this.ownerName,
    required this.content,
  });
  final ShareService service;
  final SharedContentType type;
  final String title;
  final String ownerId;
  final String ownerName;
  final Map<String, dynamic> content;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  String? _code;
  bool _loading = false;

  Future<void> _generate() async {
    setState(() => _loading = true);
    final code = await widget.service.shareContent(
      type: widget.type,
      title: widget.title,
      ownerId: widget.ownerId,
      ownerName: widget.ownerName,
      content: widget.content,
    );
    setState(() {
      _code = code;
      _loading = false;
    });
  }

  Future<void> _shareCodeExternal() async {
    if (_code == null) return;
    final shareText = "Join my ${widget.type.name} on AI Learn Mate — code: $_code\nhttps://ai-learn-mate.vercel.app";
    await Clipboard.setData(ClipboardData(text: shareText));

    final Uri mailUri = Uri(
      scheme: 'mailto',
      queryParameters: {
        'subject': 'Shared ${widget.type.name} on AI Learn Mate',
        'body': shareText,
      },
    );

    try {
      await launchUrl(mailUri, mode: LaunchMode.externalApplication);
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Share code and link copied to clipboard!"),
          backgroundColor: _accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Share "${widget.title}"', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Anyone with the code can view it in their app.', style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 20),
          if (_code == null)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                onPressed: _loading ? null : _generate,
                child: _loading
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Color(0xFF0B0E14), strokeWidth: 2))
                    : const Text('Generate share code', style: TextStyle(color: Color(0xFF0B0E14), fontWeight: FontWeight.bold)),
              ),
            )
          else
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _accent.withOpacity(0.4)),
                  ),
                  child: Text(
                    _code!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _accent, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.copy, size: 18, color: Colors.white70),
                        label: const Text('Copy', style: TextStyle(color: Colors.white70)),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _code!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Code copied to clipboard!')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.ios_share, size: 18, color: Colors.white70),
                        label: const Text('Share', style: TextStyle(color: Colors.white70)),
                        onPressed: _shareCodeExternal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Full screen for joining shared content by code, and browsing what's
/// already been shared with the current user.
class JoinSharedContentScreen extends StatefulWidget {
  const JoinSharedContentScreen({super.key, required this.currentUserId});
  final String currentUserId;

  @override
  State<JoinSharedContentScreen> createState() => _JoinSharedContentScreenState();
}

class _JoinSharedContentScreenState extends State<JoinSharedContentScreen> {
  final _service = ShareService();
  final _codeController = TextEditingController();
  String? _error;
  bool _joining = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Enter the 6-character code');
      return;
    }
    setState(() {
      _joining = true;
      _error = null;
    });
    final result = await _service.joinByCode(code, widget.currentUserId);
    setState(() => _joining = false);
    if (result == null) {
      setState(() => _error = 'No shared item found for that code');
    } else if (mounted) {
      _codeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined "${result.title}"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Shared with me', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'serif')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 6,
                    style: const TextStyle(color: Colors.white, letterSpacing: 2),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'Enter share code (e.g. K3F9QZ)',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      filled: true,
                      fillColor: _card,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      errorText: _error,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _accent, padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20)),
                  onPressed: _joining ? null : _join,
                  child: _joining
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Color(0xFF0B0E14), strokeWidth: 2))
                      : const Text('Join', style: TextStyle(color: Color(0xFF0B0E14), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Align(alignment: Alignment.centerLeft, child: Text('Shared with you', style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<SharedContent>>(
                stream: _service.sharedWithMe(widget.currentUserId),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: _accent));
                  final items = snap.data!;
                  if (items.isEmpty) {
                    return const Center(
                      child: Text('Nothing shared with you yet', style: TextStyle(color: Colors.white38)),
                    );
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Icon(_iconFor(item.type), color: _accent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                  Text('by ${item.ownerName}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(SharedContentType type) {
    switch (type) {
      case SharedContentType.note:
        return Icons.description_outlined;
      case SharedContentType.flashcardSet:
        return Icons.style_outlined;
      case SharedContentType.quiz:
        return Icons.quiz_outlined;
    }
  }
}
