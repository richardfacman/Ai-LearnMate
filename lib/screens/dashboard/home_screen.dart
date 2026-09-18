import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/bottom_navbar.dart';
import '../../services/user_provider.dart';
import '../../services/learning_provider.dart';
import '../../services/exam_provider.dart';
import '../../services/mastery_provider.dart';
import '../../services/achievement_provider.dart';
import '../../services/flashcard_provider.dart';
import '../../services/analytics_provider.dart';
import '../../services/planner_provider.dart';
import '../../services/ai/recommendation_service.dart';
import '../../services/theme_service.dart';

import 'chat_screen.dart';
import 'notes_screen.dart';
import 'timer_screen.dart';
import '../profile/profile_screen.dart';
import 'quiz_screen.dart';
import 'flashcard_screen.dart';
import 'mistake_bank_screen.dart';
import 'analytics_screen.dart';
import 'study_planner_screen.dart';
import 'camera_solver_screen.dart';
import 'voice_tutor_screen.dart';
import 'achievement_screen.dart';
import 'add_subject_screen.dart';

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
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        Provider.of<LearningProvider>(context, listen: false).fetchSubjects();
        Provider.of<FlashcardProvider>(context, listen: false).fetchCards();
        Provider.of<MasteryProvider>(context, listen: false).fetchMastery();
        Provider.of<AnalyticsProvider>(context, listen: false).fetchAnalytics();
        Provider.of<ExamProvider>(context, listen: false).fetchExams();
        Provider.of<AchievementProvider>(context, listen: false).fetchAchievements();
        Provider.of<AchievementProvider>(context, listen: false).fetchDailyChallenge();
        Provider.of<PlannerProvider>(context, listen: false).fetchPlan();
      }
    });
  }

  Color _getSubjectAccentColor(int index) {
    const palette = [
      AppColors.cyan,
      AppColors.pink,
      AppColors.violet,
      AppColors.accent,
      Color(0xFF34D399),
      Color(0xFF38BDF8),
    ];
    return palette[index % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final learningProvider = Provider.of<LearningProvider>(context);
    final examProvider = Provider.of<ExamProvider>(context);
    final masteryProvider = Provider.of<MasteryProvider>(context);
    final achievementProvider = Provider.of<AchievementProvider>(context);
    final user = userProvider.user;

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    final recommendation = RecommendationService.getNextActivity(
      subjects: learningProvider.subjects,
      topics: learningProvider.topics,
      mastery: masteryProvider.masteryData,
      exams: examProvider.exams,
      mood: user?.currentMood,
    );

    if (userProvider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    final firstName = user?.name.split(' ')[0] ?? "Foysal";
    final today = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: isDesktop ? 1000 : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Header
                  _buildGreetingHeader(firstName, today),
                  const SizedBox(height: 24),

                  // Mood Check-in
                  _buildMoodCheckin(userProvider, user),
                  const SizedBox(height: 24),

                  // Stats Strip (Streak, XP, Level)
                  _buildStatStrip(user),
                  const SizedBox(height: 20),

                  // Hero Recommendation Banner
                  _buildHeroRecommendation(recommendation),
                  const SizedBox(height: 28),

                  if (achievementProvider.dailyChallenge != null) ...[
                    _buildDailyChallengeCard(achievementProvider.dailyChallenge!),
                    const SizedBox(height: 24),
                  ],

                  // Study Tools Section (12 Tools Bento Grid)
                  const Text("Study tools", style: TextStyle(color: AppColors.primaryText, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                  const SizedBox(height: 14),
                  _buildStudyToolsBentoGrid(isDesktop),
                  const SizedBox(height: 28),

                  // Your Subjects Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Your subjects", style: TextStyle(color: AppColors.primaryText, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                      TextButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSubjectScreen())),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                        icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.accent, size: 16),
                        label: const Text("Add subject", style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSubjectSection(learningProvider),

                  if (examProvider.exams.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text("Upcoming Exams", style: TextStyle(color: AppColors.primaryText, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                    const SizedBox(height: 12),
                    ...examProvider.exams.map((exam) => _buildExamCountdown(exam)),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingHeader(String firstName, String today) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(today, style: const TextStyle(color: AppColors.secondaryText, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                text: "Good day, ",
                style: const TextStyle(color: AppColors.primaryText, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'serif'),
                children: [
                  TextSpan(
                    text: firstName,
                    style: const TextStyle(color: AppColors.accent, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontFamily: 'serif'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Ready to master something new today?",
              style: TextStyle(color: AppColors.secondaryText, fontSize: 13.5),
            ),
          ],
        ),

        // User Avatar Badge
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accent, width: 1.5),
            boxShadow: [
              BoxShadow(color: AppColors.accent.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            firstName.isNotEmpty ? firstName[0].toUpperCase() : "F",
            style: const TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodCheckin(UserProvider provider, user) {
    final moods = ["Stressed", "Tired", "Neutral", "Good", "Confident"];
    final emojis = ["😫", "😴", "😳", "😄", "🚀"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "How are you feeling about studying?",
          style: TextStyle(color: AppColors.primaryText, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: moods.length,
            itemBuilder: (context, i) {
              final isSelected = (user?.currentMood ?? "Neutral") == moods[i];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) const Icon(Icons.check, size: 14, color: AppColors.goldInk),
                      if (isSelected) const SizedBox(width: 4),
                      Text("${emojis[i]} ${moods[i]}"),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (val) => provider.updateMood(moods[i]),
                  selectedColor: AppColors.accent,
                  backgroundColor: AppColors.card,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.goldInk : AppColors.primaryText,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: BorderSide(color: isSelected ? AppColors.accent : AppColors.border, width: isSelected ? 1.5 : 1.0),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatStrip(user) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _statItem("${user?.streak ?? 1}", "day streak"),
          Container(width: 1, height: 44, color: AppColors.border),
          _statItem("${user?.xp ?? 100}", "xp earned"),
          Container(width: 1, height: 44, color: AppColors.border),
          _statItem("${user?.level ?? 1}", "level", isGold: true),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, {bool isGold = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: isGold ? AppColors.accent : AppColors.primaryText,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroRecommendation(String recommendation) {
    String title = recommendation;
    String subtitle = "Personalized for your learning progress";

    if (recommendation.contains(": ")) {
      final parts = recommendation.split(": ");
      subtitle = parts[0];
      title = parts[1];
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 1.2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withValues(alpha: 0.15),
            AppColors.card,
          ],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "What should I study now",
                style: TextStyle(
                  color: AppColors.accent.withValues(alpha: 0.95),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSubjectScreen())),
            icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.goldInk, size: 18),
            label: const Text("Start studying", style: TextStyle(color: AppColors.goldInk, fontWeight: FontWeight.bold, fontSize: 13.5)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallengeCard(dynamic challenge) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's challenge", style: TextStyle(color: AppColors.primaryText, fontSize: 14, fontWeight: FontWeight.bold)),
              Text("+${challenge.xpReward} xp", style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(challenge.title, style: const TextStyle(color: AppColors.secondaryText, fontSize: 12.5)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: challenge.progress,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyToolsBentoGrid(bool isDesktop) {
    final List<Map<String, dynamic>> tools = [
      {"icon": Icons.event_available_outlined, "label": "Quick quiz", "color": AppColors.cyan, "page": const QuizScreen()},
      {"icon": Icons.style_outlined, "label": "Flashcards", "color": AppColors.violet, "page": const FlashcardScreen()},
      {"icon": Icons.timer_outlined, "label": "Pomodoro", "color": AppColors.pink, "page": const TimerScreen()},
      {"icon": Icons.center_focus_strong_rounded, "label": "Focus mode", "color": AppColors.cyan, "page": const TimerScreen()},
      {"icon": Icons.bookmark_border_outlined, "label": "Mistakes", "color": AppColors.accent, "page": const MistakeBankScreen()},
      {"icon": Icons.bar_chart_rounded, "label": "Analytics", "color": AppColors.pink, "page": const AnalyticsScreen()},
      {"icon": Icons.check_box_outlined, "label": "Planner", "color": AppColors.violet, "page": const StudyPlannerScreen()},
      {"icon": Icons.crop_free_rounded, "label": "Scanner", "color": AppColors.cyan, "page": const CameraSolverScreen()},
      {"icon": Icons.mic_none_rounded, "label": "Voice", "color": AppColors.violet, "page": const VoiceTutorScreen()},
      {"icon": Icons.emoji_events_outlined, "label": "Awards", "color": AppColors.accent, "page": const AchievementScreen()},
      {"icon": Icons.chat_bubble_outline_rounded, "label": "AI Tutor", "color": AppColors.cyan, "page": const ChatScreen()},
      {"icon": Icons.description_outlined, "label": "Notes", "color": AppColors.pink, "page": const NotesScreen()},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = isDesktop ? 6 : (constraints.maxWidth > 600 ? 4 : 3);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: isDesktop ? 1.6 : 1.3,
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            final t = tools[index];
            return InkWell(
              onTap: () {
                if (t['page'] != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => t['page'] as Widget));
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(t['icon'] as IconData, color: t['color'] as Color, size: 22),
                    const SizedBox(height: 8),
                    Text(
                      t['label'] as String,
                      style: const TextStyle(color: AppColors.primaryText, fontSize: 12, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubjectSection(LearningProvider provider) {
    if (provider.subjects.isEmpty) {
      return InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSubjectScreen())),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 1.2, style: BorderStyle.solid),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardTop,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 1.5),
                ),
                child: const Icon(Icons.menu_book_rounded, color: AppColors.accent, size: 24),
              ),
              const SizedBox(height: 14),
              const Text.rich(
                TextSpan(
                  text: "No subjects added yet ",
                  style: TextStyle(color: AppColors.primaryText, fontSize: 14, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: "— tap here to add your first subject.",
                      style: TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    int index = 0;
    return Column(
      children: provider.subjects.map((subj) {
        final accent = _getSubjectAccentColor(index++);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.book_outlined, color: accent, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Text(subj.name, style: const TextStyle(color: AppColors.primaryText, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.secondaryText, size: 14),
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
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: daysLeft < 3 ? AppColors.accent : AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exam.title, style: const TextStyle(color: AppColors.primaryText, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(exam.subject, style: const TextStyle(color: AppColors.secondaryText, fontSize: 11.5)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cardTop,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "$daysLeft days left",
              style: TextStyle(color: daysLeft < 3 ? AppColors.accent : AppColors.primaryText, fontSize: 11.5, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
