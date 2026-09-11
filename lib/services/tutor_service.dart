import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TutorService {
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? "";
  static const String _baseUrl = "https://api.groq.com/openai/v1/chat/completions";

  static Future<String> _groqRequest(String prompt) async {
    try {
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
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      }
      return "Error: ${response.statusCode}";
    } catch (e) {
      return "Error: $e";
    }
  }

  static Future<String> generateKeyPoints(String text) async {
    final prompt = "Extract the key points and important definitions from the following text in a structured bullet-point format:\n\n$text";
    return await _groqRequest(prompt);
  }

  static Future<List<Map<String, String>>> generateFlashcards(String text) async {
    final prompt = """
Generate 5 flashcards from this text. 
Return exactly in JSON format: [{"question": "...", "answer": "..."}]
Text: $text
""";
    final response = await _groqRequest(prompt);
    try {
      final jsonStart = response.indexOf("[");
      final jsonEnd = response.lastIndexOf("]");
      if (jsonStart == -1 || jsonEnd == -1) return [];
      final jsonString = response.substring(jsonStart, jsonEnd + 1);
      final List parsed = jsonDecode(jsonString);
      return parsed.map((e) => Map<String, String>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<String> askAboutNote(String noteText, String question) async {
    final prompt = """
You are an AI tutor. Answer the following question based ONLY on the provided notes. 
If the information is not in the notes, say 'I couldn't find that in your notes, but generally...'.

Notes:
$noteText

Question: $question
""";
    return await _groqRequest(prompt);
  }
}
