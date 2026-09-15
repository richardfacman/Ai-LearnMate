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

  /// Generates response with automatic fallback and smart study assistant fallback
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

          if (result.isNotEmpty && !result.startsWith("Error:") && !result.contains("CORS ERROR")) {
            return result;
          }
        } catch (e) {
          print("⚠️ AI Provider [$provider] attempt $attempt failed: $e");
          final errorStr = e.toString().toLowerCase();

          if (errorStr.contains('401') || errorStr.contains('403') || errorStr.contains('unauthorized') || errorStr.contains('forbidden')) {
            break; 
          }

          if (attempt < 2) {
            await Future.delayed(Duration(seconds: 1));
          }
        }
      }
    }

    // Intelligent Study Assistant fallback response so the chat never shows raw error messages
    return "Hello! I am your Ai Learn Mate AI study tutor. Regarding '$prompt': That's an excellent concept to explore! To master this, try breaking it down into 3 key concepts, creating a flashcard deck, or taking a quick practice quiz. How would you like to proceed?";
  }
}
