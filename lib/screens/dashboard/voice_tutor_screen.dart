import 'package:flutter/material.dart';
import 'package:ai_learn_mate/services/ai/voice_service.dart';
import 'package:ai_learn_mate/services/ai/ai_provider_manager.dart';

class VoiceTutorScreen extends StatefulWidget {
  const VoiceTutorScreen({super.key});

  @override
  State<VoiceTutorScreen> createState() => _VoiceTutorScreenState();
}

class _VoiceTutorScreenState extends State<VoiceTutorScreen> {
  final VoiceService _voiceService = VoiceService();
  final TextEditingController _textCtrl = TextEditingController();

  String _words = "Tap the mic to start speaking...";
  String _response = "";
  bool _isListening = false;
  bool _loading = false;

  // Theme Tokens
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color surfaceHi = Color(0xFF1B2230);
  static const Color gold = Color(0xFFFFB020);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x1AF4EFE6);

  @override
  void initState() {
    super.initState();
    _voiceService.initSpeech();
  }

  void _toggleListening() async {
    if (_isListening) {
      _voiceService.stopListening();
      setState(() => _isListening = false);
      _sendToAI(_words);
    } else {
      final available = await _voiceService.initSpeech();
      if (available) {
        setState(() {
          _isListening = true;
          _words = "Listening...";
        });
        _voiceService.startListening((val) {
          setState(() {
            _words = val;
            _textCtrl.text = val;
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Microphone is not enabled or available on this device. You can type below!", style: TextStyle(color: paper)),
            backgroundColor: surface,
          ),
        );
      }
    }
  }

  Future<void> _sendToAI(String promptText) async {
    final query = promptText.trim();
    if (query.isEmpty || query == "Listening..." || query == "Tap the mic to start speaking...") return;

    setState(() => _loading = true);

    try {
      final res = await AiProviderManager().generateResponse(
        prompt: query,
        feature: AiFeature.quickExplanation,
      );
      setState(() => _response = res);
      
      // Speak AI response back if TTS is supported
      await _voiceService.speak(res);
    } catch (e) {
      setState(() => _response = "AI is temporarily unavailable. Please try again.");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text("Voice AI Tutor", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: surface,
        foregroundColor: paper,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: hairline),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _words,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: _isListening ? gold : paper,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _textCtrl,
                                  style: const TextStyle(color: paper, fontSize: 14),
                                  decoration: const InputDecoration(
                                    hintText: "Or type your question here...",
                                    hintStyle: TextStyle(color: muted, fontSize: 13),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (val) => _sendToAI(val),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send_rounded, color: gold, size: 20),
                                onPressed: () => _sendToAI(_textCtrl.text),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_loading) const CircularProgressIndicator(color: gold),
                    if (_response.isNotEmpty) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("AI Tutor Explanation:", style: TextStyle(color: gold, fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: hairline),
                        ),
                        child: SelectableText(
                          _response,
                          style: const TextStyle(color: paper, fontSize: 14, height: 1.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _toggleListening,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: _isListening ? Colors.redAccent : gold,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.redAccent : gold).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 4,
                    )
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 36,
                  color: ink,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isListening ? "Listening... Tap to stop" : "Tap microphone to speak",
              style: const TextStyle(color: muted, fontSize: 12),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
