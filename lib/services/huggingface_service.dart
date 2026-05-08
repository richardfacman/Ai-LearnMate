import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HuggingFaceService {
  static String get _apiKey => dotenv.env['HUGGING_FACE_API_KEY'] ?? "";

  // 🔹 Generate quiz questions (MCQs)
  static Future<List<Map<String, dynamic>>> generateQuiz(String text) async {
    final prompt = """
Generate exactly 5 multiple-choice questions (MCQs) from this text. 
Each question must have 4 options (A,B,C,D) and indicate the correct answer.
Return JSON list like:
[
  {"question":"...","options":["A","B","C","D"],"answer":"A"}
]
Text: $text
""";

    final res = await http.post(
      Uri.parse("https://api-inference.huggingface.co/models/mistralai/Mixtral-8x7B-Instruct-v0.1"),
      headers: {
        "Authorization": "Bearer $_apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"inputs": prompt}),
    );

    if (res.statusCode == 200) {
      try {
        final data = jsonDecode(res.body);
        final textOut = data is List ? data[0]["generated_text"] : data["generated_text"];
        final jsonStart = textOut.indexOf("[");
        final jsonEnd = textOut.lastIndexOf("]");
        final jsonString = textOut.substring(jsonStart, jsonEnd + 1);
        final parsed = jsonDecode(jsonString) as List;
        return parsed.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }
  static Future<String> summarize(String text) async {
    final url = "https://api-inference.huggingface.co/models/google/pegasus-xsum";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $_apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"inputs": text}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data[0]["summary_text"] ?? "No summary generated.";
    }

    return "Summarization failed.";
  }
}
