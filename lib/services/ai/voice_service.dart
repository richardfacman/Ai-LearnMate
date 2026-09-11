import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  Future<bool> initSpeech() async {
    return await _speech.initialize();
  }

  void startListening(Function(String) onResult) {
    _speech.listen(onResult: (val) => onResult(val.recognizedWords));
  }

  void stopListening() {
    _speech.stop();
  }

  Future speak(String text) async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  bool get isListening => _speech.isListening;
}
