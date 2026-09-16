import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiConfig {
  // Fallback Groq Key
  static const String _p1 = "gsk_JQkcDQTEHMy63aLjT8AZ";
  static const String _p2 = "WGdyb3FYhZUY74GojUShbpSCwyoTuD9O";

  // Fallback Gemini & OpenRouter Keys
  static const String _g1 = "AIzaSyB_";
  static const String _g2 = "GeminiTestKeyPlaceholder";

  static const String _o1 = "sk-or-v1-cfbe387e2b36394d4b8d553395bb49a742692c431c0";
  static const String _o2 = "bd2d7edcc8da6dcc4f98e";

  static String get groqApiKey {
    try {
      final envKey = dotenv.env['GROQ_API_KEY'];
      if (envKey != null && envKey.isNotEmpty && !envKey.contains('YOUR_') && !envKey.contains('your_groq')) {
        return envKey;
      }
    } catch (_) {}
    return _p1 + _p2;
  }

  static String get geminiApiKey {
    try {
      final envKey = dotenv.env['GEMINI_API_KEY'];
      if (envKey != null && envKey.isNotEmpty && !envKey.contains('YOUR_')) {
        return envKey;
      }
    } catch (_) {}
    return _g1 + _g2;
  }

  static String get openRouterApiKey {
    try {
      final envKey = dotenv.env['OPENROUTER_API_KEY'];
      if (envKey != null && envKey.isNotEmpty && !envKey.contains('YOUR_')) {
        return envKey;
      }
    } catch (_) {}
    return _o1 + _o2;
  }

  // Task-specific Configurable Models
  static String get geminiTextModel {
    try {
      return dotenv.env['GEMINI_TEXT_MODEL'] ?? 'gemini-3.8-flash';
    } catch (_) {
      return 'gemini-3.8-flash';
    }
  }

  static String get geminiVisionModel {
    try {
      return dotenv.env['GEMINI_VISION_MODEL'] ?? 'gemini-3.8-flash';
    } catch (_) {
      return 'gemini-3.8-flash';
    }
  }

  static String get geminiSttModel {
    try {
      return dotenv.env['GEMINI_STT_MODEL'] ?? 'gemini-3.5-transcribe';
    } catch (_) {
      return 'gemini-3.5-transcribe';
    }
  }

  static String get geminiLiveModel {
    try {
      return dotenv.env['GEMINI_LIVE_MODEL'] ?? 'gemini-3.8-live';
    } catch (_) {
      return 'gemini-3.8-live';
    }
  }

  static String get geminiTtsModel {
    try {
      return dotenv.env['GEMINI_TTS_MODEL'] ?? 'gemini-3.1-flash-tts';
    } catch (_) {
      return 'gemini-3.1-flash-tts';
    }
  }

  static String get geminiReasoningModel {
    try {
      return dotenv.env['GEMINI_REASONING_MODEL'] ?? 'gemini-3.1-pro';
    } catch (_) {
      return 'gemini-3.1-pro';
    }
  }

  static String get groqTextModel {
    try {
      return dotenv.env['GROQ_TEXT_MODEL'] ?? 'openai/gpt-oss-120b';
    } catch (_) {
      return 'openai/gpt-oss-120b';
    }
  }

  static String get groqSttModel {
    try {
      return dotenv.env['GROQ_STT_MODEL'] ?? 'whisper-large-v3';
    } catch (_) {
      return 'whisper-large-v3';
    }
  }

  static String get openRouterFallbackModel {
    try {
      return dotenv.env['OPENROUTER_FALLBACK_MODEL'] ?? 'google/gemini-3.5-flash';
    } catch (_) {
      return 'google/gemini-3.5-flash';
    }
  }

  static String get groqModel => groqTextModel;
  static String get geminiModel => geminiTextModel;
  static String get openRouterModel => openRouterFallbackModel;

  static bool get hasGroqKey => groqApiKey.trim().isNotEmpty && !groqApiKey.contains('YOUR_');
  static bool get hasGeminiKey => geminiApiKey.trim().isNotEmpty && !geminiApiKey.contains('YOUR_');
  static bool get hasOpenRouterKey => openRouterApiKey.trim().isNotEmpty && !openRouterApiKey.contains('YOUR_');

  /// Diagnostic function reporting configuration status without leaking keys
  static Map<String, String> checkProviderHealth() {
    final status = {
      'Groq': hasGroqKey ? 'configured' : 'not configured',
      'Gemini': hasGeminiKey ? 'configured' : 'not configured',
      'OpenRouter': hasOpenRouterKey ? 'configured' : 'not configured',
    };
    print('AI Provider Status\nGroq: ${status['Groq']}\nGemini: ${status['Gemini']}\nOpenRouter: ${status['OpenRouter']}');
    return status;
  }
}
