import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NvidiaService {
  static String get _apiKey => dotenv.env['NVIDIA_API_KEY'] ?? "";
  static const String _baseUrl = "https://integrate.api.nvidia.com/v1/chat/completions";

  static Future<String> getChatResponse(String message) async {
    try {
      if (_apiKey.isEmpty) return "Error: NVIDIA API Key is missing in .env";

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "model": "meta/llama-3.1-405b-instruct", // High-end model available via NVIDIA
          "messages": [
            {
              "role": "system",
              "content": "You are a helpful AI study assistant for the app 'Ai Learn Mate'. Provide concise and educational answers."
            },
            {
              "role": "user",
              "content": message
            }
          ],
          "temperature": 0.2,
          "top_p": 0.7,
          "max_tokens": 1024,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        final errorData = jsonDecode(response.body);
        return "NVIDIA Error: ${errorData['error']?['message'] ?? 'Status ${response.statusCode}'}";
      }
    } catch (e) {
      return "Connection Error: Please check your internet connection or API setup.";
    }
  }
}
