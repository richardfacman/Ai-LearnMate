import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/groq_service.dart';
import '../../services/nvidia_service.dart';
import '../../services/ai/ai_provider_manager.dart';
import '../../widgets/orbital_share_dialog.dart';

enum TutorQuickAction {
  confused,
  summarize,
  example,
  testMe,
  deepDive,
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;
  String _statusMessage = "AI Tutor is thinking...";
  bool _useNvidia = false;
  LearningMode _selectedMode = LearningMode.normal;
  TutorPersona _selectedPersona = TutorPersona.calmMentor;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // Theme Tokens
  static const Color bgNavy = Color(0xFF0B0B14);
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color cardNavy = Color(0xFF15151F);
  static const Color surfaceHi = Color(0xFF181F33);
  static const Color gold = Color(0xFFFFB020);
  static const Color indigo = Color(0xFF6C7BFF);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x1AF4EFE6);

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snap = await _db
          .collection('chats')
          .doc(user.uid)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      if (mounted) {
        setState(() {
          _messages.clear();
          for (var doc in snap.docs) {
            _messages.add({
              'role': doc['role'],
              'text': doc['text'],
              'timestamp': doc['timestamp'],
            });
          }
        });
        _scrollToBottom();
      }
    } catch (_) {}
  }

  Future<void> _saveMessage(String role, String text) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db
          .collection('chats')
          .doc(user.uid)
          .collection('messages')
          .add({
        'role': role,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> _clearChat() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final ref = _db.collection('chats').doc(user.uid).collection('messages');
      final snap = await ref.get();
      final batch = _db.batch();
      for (var doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      setState(() => _messages.clear());
    } catch (_) {}
  }

  Future<void> sendMessage() async {
    final userText = _msgCtrl.text.trim();
    if (userText.isEmpty || _loading) return;

    setState(() {
      _messages.add({'role': 'user', 'text': userText});
      _loading = true;
      _statusMessage = "AI Tutor is thinking...";
    });
    _msgCtrl.clear();
    _scrollToBottom();
    await _saveMessage('user', userText);

    try {
      final history = _messages.map((m) {
        return {
          "role": m['role'] == 'user' ? "user" : "assistant",
          "content": m['text'].toString(),
        };
      }).toList();

      final aiReply = _useNvidia
          ? await NvidiaService.getChatResponse(history)
          : await AiProviderManager().generateResponse(
              prompt: userText,
              feature: AiFeature.tutor,
              history: history,
            );

      if (mounted) {
        setState(() {
          _messages.add({'role': 'ai', 'text': aiReply});
        });
        await _saveMessage('ai', aiReply);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({'role': 'ai', 'text': "AI is temporarily unavailable. Please try again."});
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  Future<void> _executeQuickAction(TutorQuickAction action) async {
    if (_loading) return;

    if (_messages.isEmpty) {
      String emptyHint = "Start a conversation first, then I can assist you.";
      switch (action) {
        case TutorQuickAction.summarize:
          emptyHint = "Start a conversation first, then I can summarize it.";
          break;
        case TutorQuickAction.example:
          emptyHint = "Ask a question first so I know what topic to give an example for.";
          break;
        case TutorQuickAction.testMe:
          emptyHint = "Ask a question first so I know what topic to test you on.";
          break;
        case TutorQuickAction.deepDive:
          emptyHint = "Ask a question first so I know what topic to explore in depth.";
          break;
        case TutorQuickAction.confused:
          emptyHint = "Ask a question first so I know what concept to simplify.";
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emptyHint, style: const TextStyle(color: paper)),
          backgroundColor: surface,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    String actionPrompt = "";
    String status = "AI Tutor is processing...";

    switch (action) {
      case TutorQuickAction.summarize:
        actionPrompt = "TASK: Summarize the educational conversation above concisely into key takeaways.\nCRITICAL: Do NOT summarize this task instruction itself. Focus entirely on summarizing the educational concepts discussed in the conversation history above.";
        status = "Generating summary...";
        break;
      case TutorQuickAction.example:
        actionPrompt = "TASK: Provide a clear, practical, real-life example illustrating the main educational concept discussed in the conversation above.";
        status = "Generating practical example...";
        break;
      case TutorQuickAction.testMe:
        actionPrompt = "TASK: Generate a short 2-question quiz to test my understanding of the concept discussed in the conversation above. Include answers and explanations.";
        status = "Creating practice questions...";
        break;
      case TutorQuickAction.deepDive:
        actionPrompt = "TASK: Provide a detailed, technical, and in-depth breakdown of the concept discussed in the conversation above.";
        status = "Exploring concept in depth...";
        break;
      case TutorQuickAction.confused:
        actionPrompt = "TASK: The student is confused. Explain the main concept discussed in the conversation above in simpler terms using a relatable analogy, step-by-step points, and a short check for understanding.";
        status = "Simplifying explanation...";
        break;
    }

    setState(() {
      _loading = true;
      _statusMessage = status;
    });
    _scrollToBottom();

    try {
      final recentHistory = _messages.sublist(
        _messages.length > 12 ? _messages.length - 12 : 0
      ).map((m) => {
        "role": m['role'] == 'user' ? "user" : "assistant",
        "content": m['text'].toString(),
      }).toList();

      final payloadHistory = [
        ...recentHistory,
        {"role": "user", "content": actionPrompt}
      ];

      final aiReply = _useNvidia
          ? await NvidiaService.getChatResponse(payloadHistory)
          : await AiProviderManager().generateResponse(
              prompt: actionPrompt,
              feature: AiFeature.tutor,
              history: payloadHistory,
            );

      if (mounted) {
        setState(() {
          _messages.add({'role': 'ai', 'text': aiReply});
        });
        await _saveMessage('ai', aiReply);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({'role': 'ai', 'text': "AI is temporarily unavailable. Please try again."});
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _shareConversation() {
    if (_messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Start a conversation first, then you can share it!"),
          backgroundColor: surface,
        ),
      );
      return;
    }

    final StringBuffer sb = StringBuffer();
    sb.writeln("📚 AI Study Tutor Notes & Summary:");
    sb.writeln();
    for (var m in _messages.take(6)) {
      final role = m['role'] == 'user' ? "Student" : "AI Tutor";
      sb.writeln("$role: ${m['text']}");
      sb.writeln();
    }

    OrbitalShareDialog.show(context, shareText: sb.toString().trim());
  }

  void _shareText(String text) {
    OrbitalShareDialog.show(context, shareText: "📚 AI Study Tutor Notes:\n\n$text");
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Scaffold(
      backgroundColor: bgNavy,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: surface,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: surfaceHi,
              shape: BoxShape.circle,
              border: Border.all(color: hairline),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu_rounded, color: paper, size: 18),
              onPressed: () {},
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              _useNvidia ? "NVIDIA AI Assistant" : "AI Study Tutor",
              style: const TextStyle(color: paper, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'serif'),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("✦ ", style: TextStyle(color: gold, fontSize: 10)),
                Text(
                  "${_personaLabel(_selectedPersona, short: true)} • ${_modeLabel(_selectedMode)}",
                  style: const TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Groq / NVIDIA Toggle Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: cardNavy,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: hairline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _useNvidia ? "NVIDIA" : "Groq",
                  style: const TextStyle(color: paper, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  height: 24,
                  width: 36,
                  child: Switch(
                    value: _useNvidia,
                    onChanged: (val) => setState(() => _useNvidia = val),
                    activeColor: gold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Circular Share Button
          Container(
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: surfaceHi,
              shape: BoxShape.circle,
              border: Border.all(color: hairline),
            ),
            child: IconButton(
              icon: const Icon(Icons.share_outlined, color: gold, size: 18),
              tooltip: "Share Conversation",
              onPressed: _shareConversation,
            ),
          ),

          // Circular Delete Button
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: surfaceHi,
              shape: BoxShape.circle,
              border: Border.all(color: hairline),
            ),
            child: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
              tooltip: "Delete conversation",
              onPressed: _confirmClearChat,
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isDesktop ? 900 : double.infinity),
          child: Column(
            children: [
              if (!_useNvidia) ...[
                _buildPersonaSelector(isDesktop),
                _buildModeSelector(isDesktop),
              ],
              Expanded(
                child: _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isUser = msg['role'] == 'user';
                          return _buildMessageBubble(msg['text'], isUser);
                        },
                      ),
              ),
              if (_loading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: gold),
                      ),
                      const SizedBox(width: 10),
                      Text(_statusMessage, style: const TextStyle(color: muted, fontSize: 12)),
                    ],
                  ),
                ),
              _buildQuickActions(),
              _buildInputBar(isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardNavy,
                shape: BoxShape.circle,
                border: Border.all(color: gold, width: 1.5),
                boxShadow: [
                  BoxShadow(color: gold.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.psychology_outlined, color: gold, size: 44),
            ),
            const SizedBox(height: 20),
            const Text(
              "How can I help you study today?",
              style: TextStyle(color: paper, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'serif'),
            ),
            const SizedBox(height: 8),
            const Text(
              "Ask a question, choose a learning persona, or tap a quick action chip below to begin.",
              style: TextStyle(color: muted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonaSelector(bool isDesktop) {
    return Container(
      color: surface,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: isDesktop ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: TutorPersona.values.map((persona) {
            final isSelected = _selectedPersona == persona;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) const Icon(Icons.check, size: 14, color: ink),
                    if (isSelected) const SizedBox(width: 4),
                    Text(_personaLabel(persona)),
                  ],
                ),
                selected: isSelected,
                onSelected: (val) => setState(() => _selectedPersona = persona),
                selectedColor: gold,
                backgroundColor: cardNavy,
                labelStyle: TextStyle(
                  color: isSelected ? ink : paper,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                side: BorderSide(color: isSelected ? gold : hairline, width: isSelected ? 1.5 : 1.0),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _personaLabel(TutorPersona persona, {bool short = false}) {
    switch (persona) {
      case TutorPersona.calmMentor:
        return short ? "Calm Mentor" : "🧘 Calm Mentor";
      case TutorPersona.funnyFriend:
        return short ? "Funny Friend" : "😄 Funny Friend";
      case TutorPersona.strictCoach:
        return short ? "Strict Coach" : "🎓 Strict Coach";
      case TutorPersona.socraticProfessor:
        return short ? "Socratic Prof" : "📜 Socratic Prof";
    }
  }

  Widget _buildModeSelector(bool isDesktop) {
    return Container(
      color: surface,
      padding: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: isDesktop ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: LearningMode.values.map((mode) {
            final isSelected = _selectedMode == mode;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) const Icon(Icons.check, size: 14, color: Colors.white),
                    if (isSelected) const SizedBox(width: 4),
                    Text(_modeLabel(mode)),
                  ],
                ),
                selected: isSelected,
                onSelected: (val) => setState(() => _selectedMode = mode),
                selectedColor: indigo,
                backgroundColor: cardNavy,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : paper,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                side: BorderSide(color: isSelected ? indigo : hairline, width: isSelected ? 1.5 : 1.0),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _modeLabel(LearningMode mode) {
    switch (mode) {
      case LearningMode.beginner:
        return "Beginner";
      case LearningMode.normal:
        return "Normal";
      case LearningMode.deepDive:
        return "Deep Dive";
      case LearningMode.examMode:
        return "Exam Mode";
      case LearningMode.socratic:
        return "Socratic";
      case LearningMode.revision:
        return "Revision";
      case LearningMode.teachBack:
        return "Teach Back";
    }
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _actionChip("🔗 Share", _shareConversation),
            _actionChip("🧐 I'm Confused", () => _executeQuickAction(TutorQuickAction.confused)),
            _actionChip("📝 Summarize", () => _executeQuickAction(TutorQuickAction.summarize)),
            _actionChip("💡 Example", () => _executeQuickAction(TutorQuickAction.example)),
            _actionChip("❓ Test Me", () => _executeQuickAction(TutorQuickAction.testMe)),
            _actionChip("🔍 Deep Dive", () => _executeQuickAction(TutorQuickAction.deepDive)),
          ],
        ),
      ),
    );
  }

  Widget _actionChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(color: paper, fontSize: 12, fontWeight: FontWeight.bold)),
        backgroundColor: cardNavy,
        side: const BorderSide(color: hairline),
        onPressed: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: BoxDecoration(
            color: gold,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(color: gold.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: SelectableText(
            text,
            style: const TextStyle(color: ink, fontSize: 14, height: 1.45, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    // AI Response Card with Top-Left Floating Speech Badge & Bottom-Right Share Button
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: cardNavy,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: gold.withOpacity(0.25), width: 1.2),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 15, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  text,
                  style: const TextStyle(color: paper, fontSize: 14.5, height: 1.55),
                ),
                const SizedBox(height: 16),
                const Divider(color: hairline, height: 1),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () => _shareText(text),
                    icon: const Icon(Icons.file_upload_outlined, color: gold, size: 16),
                    label: const Text("Share", style: TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: gold.withOpacity(0.6), width: 1.2),
                      backgroundColor: surfaceHi,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Speech Bubble Icon Badge
          Positioned(
            left: -12,
            top: -12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: surfaceHi,
                shape: BoxShape.circle,
                border: Border.all(color: gold, width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded, color: gold, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: hairline)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: cardNavy,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: hairline),
                ),
                child: TextField(
                  controller: _msgCtrl,
                  style: const TextStyle(color: paper, fontSize: 14),
                  maxLines: 4,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: "Ask anything...",
                    hintStyle: TextStyle(color: muted, fontSize: 14),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: _loading ? null : sendMessage,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: gold,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: gold.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 3)),
                  ],
                ),
                alignment: Alignment.center,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: ink, strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_rounded, color: ink, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        title: const Text("Delete conversation?", style: TextStyle(color: paper)),
        content: const Text("This will permanently clear your current chat history.", style: TextStyle(color: muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: muted)),
          ),
          ElevatedButton(
            onPressed: () {
              _clearChat();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
