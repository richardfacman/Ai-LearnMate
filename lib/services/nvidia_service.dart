import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NvidiaService {
  static String get _apiKey => dotenv.env['NVIDIA_API_KEY'] ?? "";
  static const String _baseUrl = "https://integrate.api.nvidia.com/v1/chat/completions";

  /// 🚀 Sends conversation history to NVIDIA
  static Future<String> getChatResponse(List<Map<String, String>> history) async {
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
          "model": "meta/llama-3.1-8b-instruct",
          "messages": [
            {
              "role": "system",
              "content": "You are a helpful AI study assistant for 'Ai Learn Mate'. Provide educational and expert answers."
            },
            ...history,
          ],
          "temperature": 0.2,
          "top_p": 0.7,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        final errorData = jsonDecode(response.body);
        print("NVIDIA API Error: ${response.body}");
        return "NVIDIA Error: ${errorData['error']?['message'] ?? 'Status ${response.statusCode}'}";
      }
    } catch (e) {
      print("NVIDIA Service Exception: $e");
      if (e.toString().contains("XMLHttpRequest")) {
        return "Browser CORS Error: NVIDIA API blocks direct browser requests. Please run as a Windows or Android app.";
      }
      return "Connection Error: $e";
    }
  }
}
