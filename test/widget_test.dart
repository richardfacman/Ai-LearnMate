import 'package:flutter_test/flutter_test.dart';
import 'package:ai_learn_mate/services/ai/ai_config.dart';
import 'package:ai_learn_mate/services/ai/recommendation_service.dart';

void main() {
  group('AiConfig Tests', () {
    test('checkProviderHealth returns provider health map', () {
      final status = AiConfig.checkProviderHealth();
      expect(status, contains('Groq'));
      expect(status, contains('Gemini'));
      expect(status, contains('OpenRouter'));
    });
  });

  group('RecommendationEngine Tests', () {
    test('getNextActivity provides initial subject recommendation when list is empty', () {
      final rec = RecommendationService.getNextActivity(
        subjects: [],
        topics: [],
        mastery: {},
        exams: [],
      );
      expect(rec, contains('Add your first subject to start learning!'));
    });
  });
}
