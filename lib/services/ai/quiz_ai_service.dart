import 'dart:convert';
import '../../models/learning/quiz_model.dart';
import 'ai_provider_manager.dart';

class QuizAIService {
  static Future<List<QuestionModel>> generateQuiz({
    required String text,
    int count = 5,
    QuizDifficulty difficulty = QuizDifficulty.medium,
    List<QuestionType> types = const [QuestionType.mcq],
    String? topicId,
  }) async {
    try {
      final prompt = """
Act as an expert EdTech content creator. Generate exactly $count quiz questions based on the following text.
Difficulty: ${difficulty.name}
Types: ${types.map((e) => e.name).join(", ")}

Return ONLY a valid JSON list of objects with this structure:
[
  {
    "id": "q_1",
    "question": "Sample Question?",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctAnswer": "Option A",
    "explanation": "Explanation here",
    "type": "${types[0].name}",
    "difficulty": "${difficulty.name}"
  }
]

For True/False, provide exactly 2 options: ["True", "False"].
For MCQs, provide exactly 4 options.
Ensure the explanation is educational and helpful.

Text:
$text
""";

      final content = await AiProviderManager().generateResponse(
        prompt: prompt,
        feature: AiFeature.quiz,
      );

      final jsonStart = content.indexOf("[");
      final jsonEnd = content.lastIndexOf("]");
      if (jsonStart == -1 || jsonEnd == -1) return [];

      final jsonString = content.substring(jsonStart, jsonEnd + 1);
      final List parsed = jsonDecode(jsonString);

      return parsed.map((e) {
        final map = Map<String, dynamic>.from(e);
        if (topicId != null) map['topicId'] = topicId;
        return QuestionModel.fromMap(map);
      }).toList();
    } catch (e) {
      print("Quiz Gen Error: $e");
      return [];
    }
  }
}
