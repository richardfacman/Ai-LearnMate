import 'dart:convert';
import 'ai/ai_provider_manager.dart';

class HuggingFaceService {
  // 🔹 Generate quiz questions (MCQs)
  static Future<List<Map<String, dynamic>>> generateQuiz(String text) async {
    final prompt = """
Generate exactly 5 multiple-choice questions (MCQs) from this text. 
Each question must have 4 options (A,B,C,D) and indicate the correct answer.
Return JSON list like:
[
  {"question":"...","options":["A","B","C","D"],"answer":"A"}
]
Text: $text
""";

    try {
      final textOut = await AiProviderManager().generateResponse(
        prompt: prompt,
        feature: AiFeature.quiz,
      );

      final jsonStart = textOut.indexOf("[");
      final jsonEnd = textOut.lastIndexOf("]");
      if (jsonStart == -1 || jsonEnd == -1) return [];
      final jsonString = textOut.substring(jsonStart, jsonEnd + 1);
      final List parsed = jsonDecode(jsonString);
      return parsed.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      print("Quiz Gen Error: $e");
      return [];
    }
  }

  static Future<String> summarize(String text) async {
    try {
      final summary = await AiProviderManager().generateResponse(
        prompt: "Provide a clear, well-structured, concise summary of the following study text:\n\n$text",
        feature: AiFeature.summarization,
      );
      return summary;
    } catch (e) {
      return "Error generating summary: $e";
    }
  }
}
