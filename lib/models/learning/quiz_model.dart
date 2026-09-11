enum QuestionType { mcq, trueFalse, shortAnswer, scenario }
enum QuizDifficulty { easy, medium, hard, expert }

class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final QuestionType type;
  final String? topicId;
  final QuizDifficulty difficulty;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.type = QuestionType.mcq,
    this.topicId,
    this.difficulty = QuizDifficulty.medium,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'type': type.name,
      'topicId': topicId,
      'difficulty': difficulty.name,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? '',
      explanation: map['explanation'] ?? '',
      type: QuestionType.values.firstWhere((e) => e.name == map['type'], orElse: () => QuestionType.mcq),
      topicId: map['topicId'],
      difficulty: QuizDifficulty.values.firstWhere((e) => e.name == map['difficulty'], orElse: () => QuizDifficulty.medium),
    );
  }
}

class QuizAttemptModel {
  final String id;
  final String userId;
  final String? sourceId; // e.g. Note ID
  final DateTime timestamp;
  final int score;
  final int totalQuestions;
  final List<Map<String, dynamic>> results; // List of {questionId, isCorrect, studentAnswer}
  final Map<String, double> topicPerformance; // topicId -> accuracy

  QuizAttemptModel({
    required this.id,
    required this.userId,
    this.sourceId,
    required this.timestamp,
    required this.score,
    required this.totalQuestions,
    required this.results,
    required this.topicPerformance,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'sourceId': sourceId,
      'timestamp': timestamp.toIso8601String(),
      'score': score,
      'totalQuestions': totalQuestions,
      'results': results,
      'topicPerformance': topicPerformance,
    };
  }

  factory QuizAttemptModel.fromMap(Map<String, dynamic> map) {
    return QuizAttemptModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      sourceId: map['sourceId'],
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      results: List<Map<String, dynamic>>.from(map['results'] ?? []),
      topicPerformance: Map<String, double>.from(map['topicPerformance'] ?? {}),
    );
  }
}
