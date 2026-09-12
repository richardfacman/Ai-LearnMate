import 'ai_config.dart';
import '../groq_service.dart';
import 'gemini_service.dart';
import 'openrouter_service.dart';

enum AiFeature {
  tutor,
  quickExplanation,
  quiz,
  flashcards,
  summarization,
  documentQa,
  imageSolver,
  complexReasoning,
}

class AiProviderManager {
  static final AiProviderManager _instance = AiProviderManager._internal();
  factory AiProviderManager() => _instance;
  AiProviderManager._internal();

  /// Determines the provider order based on feature routing rules
  List<String> _getProviderOrder(AiFeature feature) {
    if (feature == AiFeature.documentQa ||
        feature == AiFeature.imageSolver ||
        feature == AiFeature.complexReasoning) {
      // Gemini -> Groq -> OpenRouter
      return ['gemini', 'groq', 'openrouter'];
    }
    // Groq -> Gemini -> OpenRouter
    return ['groq', 'gemini', 'openrouter'];
  }

  /// Generates response with automatic fallback and retry mechanism
  Future<String> generateResponse({
    required String prompt,
    AiFeature feature = AiFeature.tutor,
    List<Map<String, String>>? history,
    double temperature = 0.7,
  }) async {
    AiConfig.checkProviderHealth();
    final providerOrder = _getProviderOrder(feature);

    for (final provider in providerOrder) {
      bool canUse = false;
      if (provider == 'groq') canUse = AiConfig.hasGroqKey;
      if (provider == 'gemini') canUse = AiConfig.hasGeminiKey;
      if (provider == 'openrouter') canUse = AiConfig.hasOpenRouterKey;

      if (!canUse) continue;

      // Try up to 2 retries per provider with exponential backoff
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          String result = '';
          if (provider == 'groq') {
            if (history != null && history.isNotEmpty) {
              result = await GroqService.getChatResponse(history, temperature: temperature);
            } else {
              result = await GroqService.getChatCompletion(prompt, temperature: temperature);
            }
          } else if (provider == 'gemini') {
            final fullPrompt = history != null && history.isNotEmpty
                ? "${history.map((m) => "${m['role']}: ${m['content']}").join('\n')}\nuser: $prompt"
                : prompt;
            result = await GeminiService.generateResponse(fullPrompt, temperature: temperature);
          } else if (provider == 'openrouter') {
            final fullPrompt = history != null && history.isNotEmpty
                ? "${history.map((m) => "${m['role']}: ${m['content']}").join('\n')}\nuser: $prompt"
                : prompt;
            result = await OpenRouterService.generateResponse(fullPrompt, temperature: temperature);
          }

          if (result.isNotEmpty && !result.startsWith("Error:")) {
            return result;
          } else {
            throw Exception(result.isNotEmpty ? result : 'Empty response from provider');
          }
        } catch (e) {
          final errorStr = e.toString().toLowerCase();

          // Do not retry invalid API auth errors (401/403)
          if (errorStr.contains('401') || errorStr.contains('403') || errorStr.contains('unauthorized') || errorStr.contains('forbidden')) {
            break; // Skip remaining attempts for this provider, move to next fallback
          }

          if (attempt < 2) {
            // Exponential backoff
            await Future.delayed(Duration(seconds: attempt * 2));
          }
        }
      }
    }

    return "AI is temporarily unavailable. Please try again.";
  }
}
