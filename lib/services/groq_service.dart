import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  // ✅ Groq API Key loaded from .env
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? "";
  static const String _baseUrl = "https://api.groq.com/openai/v1/chat/completions";

  static Future<String> getChatResponse(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.1-8b-instant", // ✅ Updated to a supported model
          "messages": [
            {
              "role": "system",
              "content": "You are a helpful AI study assistant for the app 'Ai Learn Mate'. Provide concise and educational answers. Use markdown formatting for better readability."
            },
            {
              "role": "user",
              "content": message
            }
          ],
          "temperature": 0.7,
          "max_tokens": 1024,
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else if (response.statusCode == 401) {
        return "Error: Invalid API Key. Please verify your Groq API key.";
      } else {
        final errorData = jsonDecode(response.body);
        return "Groq Error: ${errorData['error']['message'] ?? 'Status ${response.statusCode}'}";
      }
    } catch (e) {
      if (e.toString().contains("XMLHttpRequest")) {
        return "Browser CORS Error: Please run with '--disable-web-security' or use a native device (Android/Windows).";
      }
      return "Connection Error: Please check your internet connection.";
    }
  }
}
