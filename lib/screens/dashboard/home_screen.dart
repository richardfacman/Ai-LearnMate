import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ai_learn_mate/widgets/bottom_navbar.dart';
import 'package:ai_learn_mate/widgets/learning_card.dart';
import 'package:ai_learn_mate/services/user_provider.dart';
import 'package:ai_learn_mate/services/learning_provider.dart';
import 'package:ai_learn_mate/services/ai/recommendation_service.dart';
import 'package:ai_learn_mate/services/exam_provider.dart';
import 'package:ai_learn_mate/services/mastery_provider.dart';
import 'package:ai_learn_mate/services/achievement_provider.dart';
import 'package:ai_learn_mate/screens/dashboard/chat_screen.dart';
import 'package:ai_learn_mate/screens/dashboard/notes_screen.dart';
import 'package:ai_learn_mate/screens/dashboard/quiz_screen.dart';
import 'package:ai_learn_mate/screens/dashboard/timer_screen.dart';
import 'package:ai_learn_mate/screens/dashboard/flashcard_screen.dart';
import 'package:ai_learn_mate/screens/dashboard/knowledge_map_screen.dart';
import 'package:ai_learn_mate/screens/dashboard/study_planner_screen.dart';
import 'package:ai_learn_mate/screens/dashboard/analytics_screen.dart';
import 'package:ai_learn_mate/screens/dashboard/achievement_screen.dart';
import 'package:ai_learn_mate/screens/profile/profile_screen.dart';
import 'package:ai_learn_mate/screens/dashboard/mistake_bank_screen.dart';
import 'package:ai_learn_mate/screens/dashboard/camera_solver_screen.dart';
import 'package:ai_learn_mate/screens/dashboard/voice_tutor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final List<Widget> _pages = const [
    HomeDashboard(),
    ChatScreen(),
    NotesScreen(),
    TimerScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070B),
      body: _pages[_index],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  // Colors from the concept
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color surfaceHi = Color(0xFF1B2230);
  static const Color gold = Color(0xFFF0A93E);
  static const Color goldSoft = Color(0xFFF7C978);
  static const Color indigo = Color(0xFF6C7BFF);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x17F4EFE6);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final masteryProvider = Provider.of<MasteryProvider>(context, listen: false);
      Provider.of<LearningProvider>(context, listen: false).fetchSubjects();
      Provider.of<ExamProvider>(context, listen: false).fetchExams(masteryProvider: masteryProvider);
      masteryProvider.fetchMastery();
      Provider.of<AchievementProvider>(context, listen: false).fetchDailyChallenge();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final learningProvider = Provider.of<LearningProvider>(context);
    final examProvider = Provider.of<ExamProvider>(context);
    final masteryProvider = Provider.of<MasteryProvider>(context);
    final achievementProvider = Provider.of<AchievementProvider>(context);
    final user = userProvider.user;

    final recommendation = RecommendationService.getNextActivity(
      subjects: learningProvider.subjects,
      topics: learningProvider.topics,
      mastery: masteryProvider.masteryData,
      exams: examProvider.exams,
      mood: user?.currentMood,
    );

    if (userProvider.isLoading) {
      return const Scaffold(
        backgroundColor: ink,
        body: Center(child: CircularProgressIndicator(color: gold)),
      );
    }

    final firstName = user?.name.split(' ')[0] ?? "Student";
    final today = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: ink,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(today, style: const TextStyle(color: muted, fontSize: 12)),
              const SizedBox(height: 6),
              Text(
                "Good morning, $firstName",
                style: const TextStyle(
                  color: paper,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  // fontFamily: 'Fraunces', // Fallback to system font
                ),
              ),
              const Text(
                "Ready to master something new?",
                style: TextStyle(color: muted, fontSize: 14),
              ),
              const SizedBox(height: 22),

              _buildMoodCheckin(userProvider, user),
              const SizedBox(height: 22),

              _buildStatStrip(user),
              const SizedBox(height: 18),

              _buildHeroRecommendation(recommendation),
              const SizedBox(height: 18),

              if (achievementProvider.dailyChallenge != null) ...[
                _buildDailyChallengeCard(achievementProvider.dailyChallenge!),
                const SizedBox(height: 22),
              ],

              const Text("Study tools", style: TextStyle(color: paper, fontSize: 13.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _buildToolChips(),
              const SizedBox(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Your subjects", style: TextStyle(color: paper, fontSize: 13.5, fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text("View all", style: TextStyle(color: indigo, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSubjectSection(learningProvider),
              
              if (examProvider.exams.isNotEmpty) ...[
                const SizedBox(height: 22),
                const Text("Upcoming Exams", style: TextStyle(color: paper, fontSize: 13.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                ...examProvider.exams.map((exam) => _buildExamCountdown(exam)).toList(),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatStrip(user) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: hairline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _statItem("${user?.streak ?? 0}", "day streak"),
          Container(width: 1, height: 40, color: hairline),
          _statItem("${user?.xp ?? 0}", "xp earned"),
          Container(width: 1, height: 40, color: hairline),
          _statItem("${user?.level ?? 1}", "level"),
        ],
      ),
    );
  }

  Widget _buildMoodCheckin(UserProvider provider, user) {
    final moods = ["Stressed", "Tired", "Neutral", "Good", "Confident"];
    final emojis = ["😰", "😴", "😐", "🙂", "🚀"];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("How are you feeling about studying?", style: TextStyle(color: paper, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: moods.length,
            itemBuilder: (context, i) {
              final isSelected = user?.currentMood == moods[i];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text("${emojis[i]} ${moods[i]}", style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : muted)),
                  selected: isSelected,
                  onSelected: (val) => provider.updateMood(moods[i]),
                  selectedColor: gold.withOpacity(0.3),
                  backgroundColor: surface,
                  side: BorderSide(color: isSelected ? gold : hairline),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: gold, fontSize: 19, fontWeight: FontWeight.w600)),
            Text(label, style: const TextStyle(color: muted, fontSize: 10.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroRecommendation(String recommendation) {
    String title = recommendation;
    String subtitle = "Personalized for your progress";
    
    if (recommendation.contains(": ")) {
      final parts = recommendation.split(": ");
      subtitle = parts[0];
      title = parts[1];
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.35)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [gold.withOpacity(0.14), Colors.transparent],
          stops: const [0.0, 0.65],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What should I study now", style: TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: paper, fontSize: 19, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: muted, fontSize: 13)),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: const Color(0xFF3A2606),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            child: const Text("Start studying"),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallengeCard(challenge) {
    double progress = challenge.currentValue / challenge.targetValue;
    if (progress > 1.0) progress = 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: hairline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's challenge", style: TextStyle(color: paper, fontSize: 14, fontWeight: FontWeight.w600)),
              Text("+${challenge.xpReward} xp", style: const TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "${challenge.description} · ${challenge.currentValue} of ${challenge.targetValue} done",
            style: const TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Container(
            height: 6,
            decoration: BoxDecoration(color: surfaceHi, borderRadius: BorderRadius.circular(4)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [gold, goldSoft]),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolChips() {
    return SizedBox(
      height: 85,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _toolChip(Icons.style, "Flashcards", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashcardScreen()))),
          _toolChip(Icons.help_outline, "Quick quiz", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen(summarizedText: "General knowledge quiz")))),
          _toolChip(Icons.history, "Mistakes", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MistakeBankScreen()))),
          _toolChip(Icons.bar_chart, "Analytics", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()))),
          _toolChip(Icons.emoji_events, "Awards", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementScreen()))),
          _toolChip(Icons.calendar_today, "Planner", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyPlannerScreen()))),
          _toolChip(Icons.camera_alt, "Scanner", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraSolverScreen()))),
          _toolChip(Icons.mic, "Voice", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceTutorScreen()))),
        ],
      ),
    );
  }

  Widget _toolChip(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: surface,
                border: Border.all(color: hairline),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: paper, size: 20),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: muted, fontSize: 10.5), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectSection(learningProvider) {
    if (learningProvider.subjects.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: hairline),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(Icons.menu_book, color: muted, size: 32),
            const SizedBox(height: 12),
            const Text("No subjects yet", style: TextStyle(color: paper, fontSize: 13.5, fontWeight: FontWeight.w500)),
            const Text("Add a subject and Ai Learn Mate\nbuilds a plan around it.", 
                style: TextStyle(color: muted, fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text("Add your first subject", style: TextStyle(color: indigo, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: learningProvider.subjects.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final subject = learningProvider.subjects[index];
        return _buildSubjectCard(subject);
      },
    );
  }

  Widget _buildSubjectCard(subject) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => KnowledgeMapScreen(subject: subject)));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.science, color: indigo, size: 24),
            const Spacer(),
            Text(subject.name, style: const TextStyle(color: paper, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: subject.overallMastery,
                backgroundColor: ink,
                color: indigo,
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamCountdown(exam) {
    final daysLeft = exam.date.difference(DateTime.now()).inDays;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hairline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exam.name, style: const TextStyle(color: paper, fontWeight: FontWeight.w600)),
              Text("Readiness: ${(exam.readinessScore * 100).toInt()}%", style: const TextStyle(color: muted, fontSize: 12)),
            ],
          ),
          Text(
            "$daysLeft Days",
            style: TextStyle(
              color: daysLeft < 3 ? Colors.redAccent : gold,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
