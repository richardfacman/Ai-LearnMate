import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/learning/quiz_model.dart';

class QuizAIService {
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? "";
  static const String _baseUrl = "https://api.groq.com/openai/v1/chat/completions";

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
    "id": "unique_string",
    "question": "...",
    "options": ["...", "...", "...", "..."],
    "correctAnswer": "...",
    "explanation": "...",
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

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {"role": "system", "content": "You are a specialized quiz generator. Output only JSON."},
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.4,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'].toString().trim();
        
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
      }
      return [];
    } catch (e) {
      print("Quiz Gen Error: $e");
      return [];
    }
  }
}
