import 'ai_config.dart';
import '../groq_service.dart';
import 'gemini_service.dart';
import 'openrouter_service.dart';

enum AiTaskType {
  textChat,
  tutor,
  explanation,
  quiz,
  flashcard,
  summarization,
  documentQa,
  scannerVision,
  OCRQuestion,
  speechToText,
  voiceTutor,
  textToSpeech,
  complexReasoning,
  translation,
}

enum InputType {
  text,
  image,
  pdf,
  document,
  audio,
  liveAudio,
}

class AiRequest {
  final String prompt;
  final AiTaskType taskType;
  final InputType inputType;
  final List<Map<String, String>>? history;
  final bool hasImage;
  final bool hasAudio;
  final String? language;
  final bool requiresLowLatency;
  final double temperature;

  AiRequest({
    required this.prompt,
    this.taskType = AiTaskType.tutor,
    this.inputType = InputType.text,
    this.history,
    this.hasImage = false,
    this.hasAudio = false,
    this.language,
    this.requiresLowLatency = false,
    this.temperature = 0.7,
  });
}

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

  /// Intelligently determines provider & model route based on task requirements
  List<Map<String, String>> selectRoute(AiRequest request) {
    // 1. Multimodal / Vision / Scanner Tasks
    if (request.hasImage ||
        request.inputType == InputType.image ||
        request.taskType == AiTaskType.scannerVision ||
        request.taskType == AiTaskType.OCRQuestion ||
        request.taskType == AiTaskType.documentQa) {
      return [
        {'provider': 'gemini', 'model': AiConfig.geminiVisionModel},
        {'provider': 'openrouter', 'model': AiConfig.openRouterFallbackModel},
        {'provider': 'groq', 'model': AiConfig.groqTextModel},
      ];
    }

    // 2. Speech-to-Text / Audio Tasks
    if (request.hasAudio || request.inputType == InputType.audio || request.taskType == AiTaskType.speechToText) {
      return [
        {'provider': 'gemini', 'model': AiConfig.geminiSttModel},
        {'provider': 'groq', 'model': AiConfig.groqSttModel},
      ];
    }

    // 3. Realtime Voice
    if (request.inputType == InputType.liveAudio || request.taskType == AiTaskType.voiceTutor) {
      return [
        {'provider': 'gemini', 'model': AiConfig.geminiLiveModel},
        {'provider': 'groq', 'model': AiConfig.groqTextModel},
      ];
    }

    // 4. Complex Academic Reasoning
    if (request.taskType == AiTaskType.complexReasoning) {
      return [
        {'provider': 'gemini', 'model': AiConfig.geminiReasoningModel},
        {'provider': 'groq', 'model': AiConfig.groqTextModel},
        {'provider': 'openrouter', 'model': AiConfig.openRouterFallbackModel},
      ];
    }

    // 5. Fast Text / Default Tutor / Quick Explanation
    return [
      {'provider': 'groq', 'model': AiConfig.groqTextModel},
      {'provider': 'gemini', 'model': AiConfig.geminiTextModel},
      {'provider': 'openrouter', 'model': AiConfig.openRouterFallbackModel},
    ];
  }

  /// Executes request through intelligent task-based model router
  Future<String> execute(AiRequest request) async {
    AiConfig.checkProviderHealth();
    final route = selectRoute(request);

    for (final step in route) {
      final provider = step['provider']!;
      final model = step['model']!;

      bool canUse = false;
      if (provider == 'groq') canUse = AiConfig.hasGroqKey;
      if (provider == 'gemini') canUse = AiConfig.hasGeminiKey;
      if (provider == 'openrouter') canUse = AiConfig.hasOpenRouterKey;

      if (!canUse) continue;

      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          String result = '';
          if (provider == 'groq') {
            if (request.history != null && request.history!.isNotEmpty) {
              result = await GroqService.getChatResponse(request.history!, model: model, temperature: request.temperature);
            } else {
              result = await GroqService.getChatCompletion(request.prompt, model: model, temperature: request.temperature);
            }
          } else if (provider == 'gemini') {
            final fullPrompt = request.history != null && request.history!.isNotEmpty
                ? "${request.history!.map((m) => "${m['role']}: ${m['content']}").join('\n')}\nuser: ${request.prompt}"
                : request.prompt;
            result = await GeminiService.generateResponse(fullPrompt, model: model, temperature: request.temperature);
          } else if (provider == 'openrouter') {
            final fullPrompt = request.history != null && request.history!.isNotEmpty
                ? "${request.history!.map((m) => "${m['role']}: ${m['content']}").join('\n')}\nuser: ${request.prompt}"
                : request.prompt;
            result = await OpenRouterService.generateResponse(fullPrompt, model: model, temperature: request.temperature);
          }

          if (result.isNotEmpty && !result.startsWith("Error:") && !result.contains("CORS ERROR")) {
            return result;
          }
        } catch (e) {
          print("⚠️ Task-Based Router [$provider - $model] attempt $attempt failed: $e");
          final errorStr = e.toString().toLowerCase();

          if (errorStr.contains('401') || errorStr.contains('403') || errorStr.contains('unauthorized') || errorStr.contains('forbidden')) {
            break;
          }

          if (attempt < 2) {
            await Future.delayed(const Duration(seconds: 1));
          }
        }
      }
    }

    throw Exception("AI Tutor is temporarily unavailable. Please try again.");
  }

  /// Backward-compatible wrapper for existing feature calls
  Future<String> generateResponse({
    required String prompt,
    AiFeature feature = AiFeature.tutor,
    List<Map<String, String>>? history,
    double temperature = 0.7,
  }) async {
    AiTaskType taskType = AiTaskType.tutor;
    if (feature == AiFeature.imageSolver) taskType = AiTaskType.scannerVision;
    if (feature == AiFeature.documentQa) taskType = AiTaskType.documentQa;
    if (feature == AiFeature.complexReasoning) taskType = AiTaskType.complexReasoning;
    if (feature == AiFeature.quickExplanation) taskType = AiTaskType.explanation;
    if (feature == AiFeature.quiz) taskType = AiTaskType.quiz;
    if (feature == AiFeature.flashcards) taskType = AiTaskType.flashcard;
    if (feature == AiFeature.summarization) taskType = AiTaskType.summarization;

    return execute(AiRequest(
      prompt: prompt,
      taskType: taskType,
      history: history,
      temperature: temperature,
    ));
  }
}
