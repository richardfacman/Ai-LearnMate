import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiConfig {
  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static String get openRouterApiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';

  static String get groqModel => dotenv.env['GROQ_MODEL'] ?? 'llama-3.3-70b-versatile';

  static String get geminiModel => dotenv.env['GEMINI_MODEL'] ?? 'gemini-2.5-flash';

  static String get openRouterModel => dotenv.env['OPENROUTER_MODEL'] ?? 'google/gemini-2.5-flash';

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
