import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum LearningMode {
  beginner,
  normal,
  deepDive,
  examMode,
  socratic,
  revision,
  teachBack
}

enum TutorPersona {
  calmMentor,
  funnyFriend,
  strictCoach,
  socraticProfessor
}

class GroqService {
  // ✅ Groq API Key loaded from .env
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? "";
  static const String _baseUrl = "https://api.groq.com/openai/v1/chat/completions";

  static String _getSystemPrompt(LearningMode mode, {TutorPersona persona = TutorPersona.calmMentor}) {
    String personality = "";
    switch (persona) {
      case TutorPersona.funnyFriend:
        personality = "Your personality is that of a funny, relatable friend. Use modern slang occasionally, keep it light, and use emojis.";
        break;
      case TutorPersona.strictCoach:
        personality = "Your personality is that of a strict, disciplined coach. Focus on hard work, no excuses, and pushing the student to their limits.";
        break;
      case TutorPersona.socraticProfessor:
        personality = "Your personality is that of a traditional Socratic professor. You are wise, patient, and almost always answer with a question to guide the student.";
        break;
      case TutorPersona.calmMentor:
      default:
        personality = "Your personality is that of a calm, supportive mentor. Be encouraging, patient, and clear.";
    }

    String modeInstructions = "";
    switch (mode) {
      case LearningMode.beginner:
        modeInstructions = "Use very simple language and relatable real-life examples suitable for a beginner.";
        break;
      case LearningMode.deepDive:
        modeInstructions = "Provide detailed, in-depth technical explanations with advanced terminology and concepts.";
        break;
      case LearningMode.examMode:
        modeInstructions = "Provide concise, point-wise, exam-oriented answers focusing on what is most likely to be asked.";
        break;
      case LearningMode.socratic:
        modeInstructions = "Do not provide direct answers. Instead, guide the student by asking thought-provoking questions.";
        break;
      case LearningMode.revision:
        modeInstructions = "Provide key points, formulas, and quick summary questions for rapid review.";
        break;
      case LearningMode.teachBack:
        modeInstructions = "The student will explain a concept to you. Your job is to listen, grade their clarity (0-100), identify gaps in their understanding, and gently correct them.";
        break;
      case LearningMode.normal:
      default:
        modeInstructions = "Provide educational and concise answers.";
    }

    return "$personality $modeInstructions Always act as the AI study assistant for 'Ai Learn Mate'.";
  }

  /// 🚀 Sends conversation history for "smart" chat
  static Future<String> getChatResponse(List<Map<String, String>> history, {LearningMode mode = LearningMode.normal, TutorPersona persona = TutorPersona.calmMentor}) async {
    try {
      if (_apiKey.isEmpty) return "Error: Groq API Key is missing in .env";

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content": _getSystemPrompt(mode, persona: persona)
            },
            ...history,
          ],
          "temperature": 0.7,
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        final errorData = jsonDecode(response.body);
        print("Groq Error: ${response.body}");
        return "Groq Error: ${errorData['error']?['message'] ?? 'Status ${response.statusCode}'}";
      }
    } catch (e) {
      if (e.toString().contains("XMLHttpRequest")) {
        return "CORS ERROR: Web browsers block direct AI calls. \n\nFIX: Use 'flutter run -d edge --web-browser-flag \"--disable-web-security\"' or run as a Windows app.";
      }
      return "Connection Error: Please check your internet.";
    }
  }
}
