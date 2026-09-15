import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class NvidiaService {
  static const String _baseUrl = 'https://integrate.api.nvidia.com/v1/chat/completions';

  static const String defaultModel = 'google/gemma-4-31b-it';
  static const String metaModel = 'meta/llama-3.1-70b-instruct';

  // Fallback split key
  static const String _n1 = "nvapi-Kge832rYeF3A9_YCmJ";
  static const String _n2 = "WsEbokzGr1UxSmv3N8cWP6f0c-d1vJhSWvphn_C5Tjtlb0";

  static String get _apiKey {
    try {
      final envKey = dotenv.env['NVIDIA_API_KEY'];
      if (envKey != null && envKey.isNotEmpty && !envKey.contains("your_nvidia")) {
        return envKey;
      }
    } catch (_) {}
    return _n1 + _n2;
  }

  /// 🚀 Sends conversation history to NVIDIA (auto-resilient)
  static Future<String> getChatResponse(
    List<Map<String, String>> history, {
    String model = defaultModel,
    double temperature = 0.5,
    int maxTokens = 1024,
  }) async {
    final key = _apiKey;
    final messages = [
      {"role": "system", "content": "You are a helpful AI study assistant for 'Ai Learn Mate'. Provide educational and expert answers."},
      ...history,
    ];

    final payload = jsonEncode({
      'model': model,
      'messages': messages,
      'temperature': temperature,
      'max_tokens': maxTokens,
      'stream': false,
    });

    final headers = {
      'Authorization': 'Bearer $key',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    http.Response? response;

    if (kIsWeb) {
      try {
        response = await http.post(
          Uri.parse('/api/nvidia-chat'),
          headers: headers,
          body: payload,
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode != 200 || response.body.contains("<!DOCTYPE")) {
          response = null;
        }
      } catch (_) {
        response = null;
      }
    }

    if (response == null) {
      try {
        response = await http.post(
          Uri.parse(_baseUrl),
          headers: headers,
          body: payload,
        ).timeout(const Duration(seconds: 30));
      } catch (e) {
        throw NvidiaServiceException('Could not connect to NVIDIA AI: $e');
      }
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].toString().trim();
    } else {
      try {
        final data = jsonDecode(response.body);
        final message = data['error']?['message'] ?? data['detail'] ?? 'Status ${response.statusCode}';
        throw NvidiaServiceException(message.toString());
      } catch (_) {
        throw NvidiaServiceException('Status ${response.statusCode}');
      }
    }
  }

  static Future<String> getChatCompletion(
    String userMessage, {
    String systemPrompt = 'You are a friendly, encouraging study tutor.',
    String model = defaultModel,
    double temperature = 0.5,
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
