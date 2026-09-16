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

    test('runChatSelfTest verifies context preservation for Quick Actions', () {
      final result = RecommendationService.runChatSelfTest();
      expect(result['status'], equals('PASS'));
      expect(result['contextIntact'], isTrue);
    });

    test('runTaskRouterDiagnostics verifies dynamic model selection per task', () {
      final routerResult = RecommendationService.runTaskRouterDiagnostics();
      expect(routerResult['status'], equals('PASS'));
      expect(routerResult['visionPrimary'], equals('gemini'));
      expect(routerResult['textPrimary'], equals('groq'));
    });

    test('runAiLearnMateSelfTest verifies system health matrix', () {
      final matrix = RecommendationService.runAiLearnMateSelfTest();
      expect(matrix['AUTH'], equals('PASS'));
      expect(matrix['SCANNER'], equals('PASS'));
      expect(matrix['VOICE'], equals('PASS'));
      expect(matrix['NAVIGATION'], equals('PASS'));
    });
  });
}
