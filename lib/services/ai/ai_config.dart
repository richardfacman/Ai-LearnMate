import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiConfig {
  static const String _g1 = "AQ.Ab8RN6J5djS0uTTbIhM8Vt";
  static const String _g2 = "LbDnhEmvxnPOENWP7w36ix_kFWcA";

  static const String _o1 = "sk-or-v1-cfbe387e2b36394d4b8d553395bb49a742692c431c0";
  static const String _o2 = "bd2d7edcc8da6dcc4f98e";

  static String get groqApiKey {
    try {
      return dotenv.env['GROQ_API_KEY'] ?? '';
    } catch (_) {
      return '';
    }
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

  static String get groqModel {
    try {
      return dotenv.env['GROQ_MODEL'] ?? 'openai/gpt-oss-120b';
    } catch (_) {
      return 'openai/gpt-oss-120b';
    }
  }

  static String get geminiModel {
    try {
      return dotenv.env['GEMINI_MODEL'] ?? 'gemini-3.5-flash';
    } catch (_) {
      return 'gemini-3.5-flash';
    }
  }

  static String get openRouterModel {
    try {
      return dotenv.env['OPENROUTER_MODEL'] ?? 'google/gemini-3.5-flash';
    } catch (_) {
      return 'google/gemini-3.5-flash';
    }
  }

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
