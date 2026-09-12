import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NvidiaService {
  static const String _baseUrl = 'https://integrate.api.nvidia.com/v1/chat/completions';

  static const String defaultModel = 'meta/llama-3.1-70b-instruct'; // heavier, better quality
  static const String lightModel = 'meta/llama-3.1-8b-instruct'; // cheaper / faster

  static String get _apiKey => dotenv.env['NVIDIA_API_KEY'] ?? '';

  /// 🚀 Sends conversation history to NVIDIA (backward compatible)
  static Future<String> getChatResponse(
    List<Map<String, String>> history, {
    String model = defaultModel,
    double temperature = 0.7,
    int maxTokens = 1024,
  }) async {
    if (_apiKey.isEmpty) {
      throw NvidiaServiceException('NVIDIA API key is missing. Add NVIDIA_API_KEY to your .env file.');
    }

    try {
      final messages = [
        {"role": "system", "content": "You are a helpful AI study assistant for 'Ai Learn Mate'. Provide educational and expert answers."},
        ...history,
      ];

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': messages,
          'temperature': temperature,
          'max_tokens': maxTokens,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        final message = data['error']?['message'] ?? data['detail'] ?? 'Unknown NVIDIA API error.';
        throw NvidiaServiceException(message.toString());
      }

      return data['choices'][0]['message']['content'].toString().trim();
    } on NvidiaServiceException {
      rethrow;
    } catch (e) {
      if (e.toString().contains("XMLHttpRequest")) {
        return "Browser CORS Error: NVIDIA API blocks direct browser requests. Please run as a Windows or Android app.";
      }
      throw NvidiaServiceException('Could not reach NVIDIA AI right now. Check your connection and try again.');
    }
  }

  static Future<String> getChatCompletion(
    String userMessage, {
    String systemPrompt = 'You are a friendly, encouraging study tutor.',
    String model = defaultModel,
    double temperature = 0.7,
    int maxTokens = 1024,
  }) async {
    return getChatResponse([{"role": "user", "content": userMessage}], model: model, temperature: temperature, maxTokens: maxTokens);
  }
}

class NvidiaServiceException implements Exception {
  final String message;
  NvidiaServiceException(this.message);
  @override
  String toString() => message;
}
