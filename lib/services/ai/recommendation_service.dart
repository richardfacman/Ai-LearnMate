import '../../models/learning/subject_model.dart';
import '../../models/learning/topic_model.dart';
import '../../models/learning/mastery_model.dart';
import '../../models/learning/exam_model.dart';

class RecommendationService {
  static String getNextActivity({
    required List<SubjectModel> subjects,
    required List<TopicModel> topics,
    required Map<String, MasteryModel> mastery,
    required List<ExamModel> exams,
    String? mood,
  }) {
    if (subjects.isEmpty) return "Add your first subject to start learning!";

    String moodPrefix = "";
    if (mood == "Stressed" || mood == "Tired") {
      moodPrefix = "Light session: ";
    } else if (mood == "Confident" || mood == "Good") {
      moodPrefix = "Challenge: ";
    }

    // 1. Check for urgent exams (next 7 days)
    final now = DateTime.now();
    final urgentExams = exams.where((e) => e.date.difference(now).inDays <= 7 && e.date.isAfter(now)).toList();
    
    if (urgentExams.isNotEmpty) {
      final exam = urgentExams.first;
      // Find weakest topic in this exam
      TopicModel? weakest;
      double lowestScore = 1.1;
      
      for (var tid in exam.topicIds) {
        final score = mastery[tid]?.score ?? 0.0;
        if (score < lowestScore) {
          lowestScore = score;
          weakest = topics.firstWhere((t) => t.id == tid, orElse: () => TopicModel(id: tid, subjectId: exam.subjectId, name: "Topic"));
        }
      }
      
      if (weakest != null) {
        return "$moodPrefix Review ${weakest.name} for your upcoming ${exam.name} exam.";
      }
    }

    // 2. Check for weak topics (Mastery < 40%)
    TopicModel? weakestOverall;
    double minScore = 1.1;
    for (var topic in topics) {
      final score = mastery[topic.id]?.score ?? 0.0;
      if (score < minScore) {
        minScore = score;
        weakestOverall = topic;
      }
    }

    if (weakestOverall != null && minScore < 0.4) {
      return "$moodPrefix Your mastery in ${weakestOverall.name} is low. Try a practice quiz.";
    }

    // Default
    if (topics.isNotEmpty) {
      return "$moodPrefix Continue learning ${topics.first.name}.";
    }

    return "Ready for a new study session?";
  }
}
