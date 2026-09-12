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
  String _words = "Tap the mic to start talking...";
  String _response = "";
  bool _isListening = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _voiceService.initSpeech();
  }

  void _toggleListening() async {
    if (_isListening) {
      _voiceService.stopListening();
      setState(() => _isListening = false);
      _sendToAI();
    } else {
      final available = await _voiceService.initSpeech();
      if (available) {
        setState(() {
          _isListening = true;
          _words = "Listening...";
        });
        _voiceService.startListening((val) {
          setState(() => _words = val);
        });
      }
    }
  }

  Future<void> _sendToAI() async {
    if (_words == "Listening..." || _words.isEmpty) return;

    setState(() => _loading = true);

    try {
      final res = await AiProviderManager().generateResponse(
        prompt: _words,
        feature: AiFeature.quickExplanation,
      );
      setState(() => _response = res);
      
      // AI Speaks back
      await _voiceService.speak(res);
    } catch (e) {
      setState(() => _response = "AI is temporarily unavailable. Please try again.");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice AI Tutor"),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Spacer(),
            Text(
              _words,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: _isListening ? const Color(0xFF6C63FF) : Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            if (_loading) const CircularProgressIndicator(),
            if (_response.isNotEmpty) ...[
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _response,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
            ],
            const Spacer(),
            GestureDetector(
              onTap: _toggleListening,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isListening ? Colors.redAccent : const Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.redAccent : const Color(0xFF6C63FF)).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isListening ? "Listening..." : "Tap to speak",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
