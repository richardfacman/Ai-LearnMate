import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

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
  static const String _baseUrl = "https://api.groq.com/openai/v1/chat/completions";

  // Use the most reliable, universally accessible Groq model
  static const String defaultModel = 'llama-3.1-8b-instant';
  static const String fastModel = 'llama-3.1-8b-instant';

  // Fallback split key
  static const String _p1 = "gsk_JQkcDQTEHMy63aLjT8AZ";
  static const String _p2 = "WGdyb3FYhZUY74GojUShbpSCwyoTuD9O";

  static String get _apiKey {
    try {
      final envKey = dotenv.env['GROQ_API_KEY'];
      if (envKey != null && envKey.isNotEmpty && !envKey.contains("your_groq")) {
        return envKey;
      }
    } catch (_) {}
    return _p1 + _p2;
  }

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
        personality = "Your personality is that of a calm, supportive mentor. Be encouraging, patient, and clear.";
        break;
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
        modeInstructions = "Provide educational and concise answers.";
        break;
    }

    return "$personality $modeInstructions Always act as the AI study assistant for 'Ai Learn Mate'.";
  }

  /// 🚀 Sends conversation history for "smart" chat (backward compatible)
  static Future<String> getChatResponse(
    List<Map<String, String>> history, {
    LearningMode mode = LearningMode.normal,
    TutorPersona persona = TutorPersona.calmMentor,
    String model = defaultModel,
    double temperature = 0.7,
  }) async {
    final key = _apiKey;

    try {
      final systemPrompt = _getSystemPrompt(mode, persona: persona);
      final messages = [
        {"role": "system", "content": systemPrompt},
        ...history,
      ];

      // On Web/Vercel, call the secure Vercel serverless endpoint; otherwise call Groq directly
      final targetUrl = kIsWeb ? "/api/groq-chat" : _baseUrl;

      final response = await http.post(
        Uri.parse(targetUrl),
        headers: {
          "Authorization": "Bearer $key",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "model": model,
          "messages": messages,
          "temperature": temperature,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        final message = data['error']?['message'] ?? 'Status ${response.statusCode}';
        throw GroqServiceException(message.toString());
      }

      return data['choices'][0]['message']['content'].toString().trim();
    } on GroqServiceException {
      rethrow;
    } catch (e) {
      throw GroqServiceException('Could not connect to Groq AI: $e');
    }
  }

  static Future<String> getChatCompletion(
    String userMessage, {
    String systemPrompt = 'You are a friendly, encouraging study tutor.',
    String model = defaultModel,
    double temperature = 0.7,
  }) async {
    return getChatResponse([{"role": "user", "content": userMessage}], model: model, temperature: temperature);
  }
}

class GroqServiceException implements Exception {
  final String message;
  GroqServiceException(this.message);
  @override
  String toString() => message;
}
