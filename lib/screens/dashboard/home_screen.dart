import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/bottom_navbar.dart';
import '../../services/user_provider.dart';
import '../../services/learning_provider.dart';
import '../../services/exam_provider.dart';
import '../../services/mastery_provider.dart';
import '../../services/achievement_provider.dart';
import '../../services/ai/recommendation_service.dart';
import 'chat_screen.dart';
import 'notes_screen.dart';
import 'timer_screen.dart';
import '../profile/profile_screen.dart';
import 'quiz_screen.dart';
import 'flashcard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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
  // Theme Tokens from v2 spec
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color surfaceHi = Color(0xFF1B2230);
  static const Color gold = Color(0xFFF0A93E);
  static const Color indigo = Color(0xFF6C7BFF);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0xFF1F2633);

  String _getGreeting(String firstName) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Good morning, $firstName";
    } else if (hour >= 12 && hour < 17) {
      return "Good afternoon, $firstName";
    } else if (hour >= 17 && hour < 21) {
      return "Good evening, $firstName";
    } else {
      return "Good night, $firstName";
    }
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
                _getGreeting(firstName),
                style: const TextStyle(
                  color: paper,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
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
                ...examProvider.exams.map((exam) => _buildExamCountdown(exam)),
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
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.4), width: 1.2),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            gold.withOpacity(0.12),
            surface,
          ],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: gold,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "What should I study now",
                style: TextStyle(
                  color: gold.withOpacity(0.9),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: paper,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: ink,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Start studying", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallengeCard(dynamic challenge) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's challenge", style: TextStyle(color: paper, fontSize: 13, fontWeight: FontWeight.w600)),
              Text("+${challenge.xpReward} xp", style: const TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(challenge.title, style: const TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: challenge.progress,
              backgroundColor: surfaceHi,
              valueColor: const AlwaysStoppedAnimation<Color>(gold),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _toolChip(Icons.help_outline, "Quick quiz", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen(summarizedText: "General knowledge study test")))),
          _toolChip(Icons.style_outlined, "Flashcards", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashcardScreen()))),
          _toolChip(Icons.timer_outlined, "Pomodoro", () => {}),
          _toolChip(Icons.center_focus_strong, "Focus mode", () => {}),
        ],
      ),
    );
  }

  Widget _toolChip(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: hairline),
          ),
          child: Row(
            children: [
              Icon(icon, color: gold, size: 16),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: paper, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectSection(LearningProvider provider) {
    if (provider.subjects.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: hairline),
        ),
        child: const Column(
          children: [
            Text("No subjects added yet", style: TextStyle(color: paper, fontSize: 14, fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text("Add a subject from notes or study planner to track topic mastery.", style: TextStyle(color: muted, fontSize: 11.5), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return Column(
      children: provider.subjects.map((subj) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: hairline),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: surfaceHi,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.book_outlined, color: indigo, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(subj.name, style: const TextStyle(color: paper, fontSize: 13.5, fontWeight: FontWeight.w500)),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, color: muted, size: 12),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExamCountdown(dynamic exam) {
    final daysLeft = exam.date.difference(DateTime.now()).inDays;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: daysLeft < 3 ? gold : hairline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exam.title, style: const TextStyle(color: paper, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(exam.subject, style: const TextStyle(color: muted, fontSize: 11.5)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: surfaceHi,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "$daysLeft days left",
              style: TextStyle(color: daysLeft < 3 ? gold : paper, fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
