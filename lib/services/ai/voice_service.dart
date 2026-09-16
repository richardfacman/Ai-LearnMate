import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _speechInitialized = false;

  Future<bool> initSpeech() async {
    if (_speechInitialized) return true;
    try {
      _speechInitialized = await _speech.initialize(
        onError: (e) => debugPrint("Speech error: $e"),
        onStatus: (s) => debugPrint("Speech status: $s"),
      );
      return _speechInitialized;
    } catch (e) {
      debugPrint("Speech init Exception: $e");
      return false;
    }
  }

  void startListening(Function(String) onResult) {
    try {
      _speech.listen(onResult: (val) => onResult(val.recognizedWords));
    } catch (e) {
      debugPrint("Start listening error: $e");
    }
  }

  void stopListening() {
    try {
      _speech.stop();
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setPitch(1.0);
      await _tts.speak(text);
    } catch (e) {
      debugPrint("TTS error: $e");
    }
  }

  bool get isListening => _speech.isListening;
}
