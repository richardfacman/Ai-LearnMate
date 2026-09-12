import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/groq_service.dart';
import '../../services/nvidia_service.dart';
import '../../services/ai/ai_provider_manager.dart';

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
  bool _useNvidia = false; 
  LearningMode _selectedMode = LearningMode.normal;
  TutorPersona _selectedPersona = TutorPersona.calmMentor;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
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
  }

  Future<void> _saveMessage(String role, String text) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('chats')
        .doc(user.uid)
        .collection('messages')
        .add({
      'role': role,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _clearChat() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _db.collection('chats').doc(user.uid).collection('messages');
    final snap = await ref.get();
    final batch = _db.batch();
    for (var doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    setState(() => _messages.clear());
  }

  Future<void> sendMessage() async {
    final userText = _msgCtrl.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': userText});
      _loading = true;
    });
    _msgCtrl.clear();
    _scrollToBottom();
    await _saveMessage('user', userText);

    try {
      // 🚀 Prepare history (last 10 messages) for the AI
      final history = _messages.map((m) {
        return {
          "role": m['role'] == 'user' ? "user" : "assistant",
          "content": m['text'].toString(),
        };
      }).toList();

      final aiReply = _useNvidia
          ? await NvidiaService.getChatResponse(history)
          : await AiProviderManager().generateResponse(
              prompt: history.isNotEmpty ? history.last['content']! : 'Hello',
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Column(
          children: [
            Text(
              _useNvidia ? "NVIDIA AI Assistant" : "AI Tutor",
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (!_useNvidia)
              Text(
                _selectedMode.name.toUpperCase(),
                style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 10, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        centerTitle: true,
        actions: [
          Switch(
            value: _useNvidia,
            onChanged: (val) => setState(() => _useNvidia = val),
            activeColor: const Color(0xFF6C63FF),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmClearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_useNvidia) ...[
            _buildPersonaSelector(),
            _buildModeSelector(),
          ],
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return _buildMessageBubble(msg['text'], isUser);
              },
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                ),
              ),
            ),
          _buildQuickActions(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildPersonaSelector() {
    return Container(
      height: 40,
      color: Colors.white,
      padding: const EdgeInsets.only(top: 5),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        children: TutorPersona.values.map((persona) {
          final isSelected = _selectedPersona == persona;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(_personaLabel(persona), style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black87)),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedPersona = persona),
              selectedColor: Colors.orange,
              backgroundColor: Colors.grey[100],
              padding: EdgeInsets.zero,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _personaLabel(TutorPersona persona) {
    switch (persona) {
      case TutorPersona.calmMentor: return "Calm Mentor";
      case TutorPersona.funnyFriend: return "Funny Friend";
      case TutorPersona.strictCoach: return "Strict Coach";
      case TutorPersona.socraticProfessor: return "Socratic Prof";
    }
  }

  Widget _buildModeSelector() {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        children: LearningMode.values.map((mode) {
          final isSelected = _selectedMode == mode;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(mode.name[0].toUpperCase() + mode.name.substring(1)),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedMode = mode),
              selectedColor: const Color(0xFF6C63FF),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _actionChip("😕 I'm Confused", Colors.orange, () => _handleQuickAction("I am confused about your previous explanation. Please simplify it with an analogy.")),
          _actionChip("📝 Summarize", Colors.blue, () => _handleQuickAction("Summarize our discussion so far.")),
          _actionChip("💡 Example", Colors.green, () => _handleQuickAction("Give me a real-life example of this.")),
          _actionChip("❓ Test Me", Colors.purple, () => _handleQuickAction("Ask me a question to test my understanding.")),
          _actionChip("🔍 Deep Dive", Colors.red, () => _handleQuickAction("Tell me more technical details about this.")),
        ],
      ),
    );
  }

  Widget _actionChip(String label, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        backgroundColor: color,
        onPressed: onTap,
      ),
    );
  }

  void _handleQuickAction(String prompt) {
    _msgCtrl.text = prompt;
    sendMessage();
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF6C63FF) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F8),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _msgCtrl,
                  decoration: const InputDecoration(
                    hintText: "Ask anything...",
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _loading ? null : sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
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
        title: const Text("Clear Chat?"),
        content: const Text("This will permanently delete your conversation."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _clearChat();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Clear", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
