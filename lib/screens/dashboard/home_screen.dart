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
      backgroundColor: const Color(0xFF0B0B14),
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
  // Theme Tokens
  static const Color bgNavy = Color(0xFF0B0B14);
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color cardNavy = Color(0xFF15151F);
  static const Color surfaceHi = Color(0xFF181F33);
  static const Color gold = Color(0xFFFFB020);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x1AF4EFE6);

  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentViolet = Color(0xFFB388FF);
  static const Color accentPink = Color(0xFFFF80AB);

  Color _getSubjectAccentColor(int index) {
    const palette = [
      accentCyan,
      accentPink,
      accentViolet,
      gold,
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
        backgroundColor: bgNavy,
        body: Center(child: CircularProgressIndicator(color: gold)),
      );
    }

    final firstName = user?.name.split(' ')[0] ?? "Foysal";
    final today = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: bgNavy,
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
                  const Text("Study tools", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                  const SizedBox(height: 14),
                  _buildStudyToolsBentoGrid(isDesktop),
                  const SizedBox(height: 28),

                  // Your Subjects Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Your subjects", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                      TextButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSubjectScreen())),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                        icon: const Icon(Icons.add_circle_outline_rounded, color: gold, size: 16),
                        label: const Text("Add subject", style: TextStyle(color: gold, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSubjectSection(learningProvider),

                  if (examProvider.exams.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text("Upcoming Exams", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif')),
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
            Text(today, style: const TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                text: "Good evening, ",
                style: const TextStyle(color: paper, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'serif'),
                children: [
                  TextSpan(
                    text: firstName,
                    style: const TextStyle(color: gold, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontFamily: 'serif'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Ready to master something new?",
              style: TextStyle(color: muted, fontSize: 13.5),
            ),
          ],
        ),

        // User Avatar Badge
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: surfaceHi,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: gold, width: 1.5),
            boxShadow: [
              BoxShadow(color: gold.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            firstName.isNotEmpty ? firstName[0].toUpperCase() : "F",
            style: const TextStyle(color: gold, fontSize: 18, fontWeight: FontWeight.bold),
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
          style: TextStyle(color: paper, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: moods.length,
            itemBuilder: (context, i) {
              final isSelected = (user?.currentMood ?? "Tired") == moods[i];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) const Icon(Icons.check, size: 14, color: ink),
                      if (isSelected) const SizedBox(width: 4),
                      Text("${emojis[i]} ${moods[i]}"),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (val) => provider.updateMood(moods[i]),
                  selectedColor: gold,
                  backgroundColor: cardNavy,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? ink : paper,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: BorderSide(color: isSelected ? gold : hairline, width: isSelected ? 1.5 : 1.0),
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
        color: cardNavy,
        border: Border.all(color: hairline),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _statItem("${user?.streak ?? 0}", "day streak"),
          Container(width: 1, height: 44, color: hairline),
          _statItem("${user?.xp ?? 0}", "xp earned"),
          Container(width: 1, height: 44, color: hairline),
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
                color: isGold ? gold : paper,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: muted, fontSize: 11)),
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
        color: cardNavy,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold.withOpacity(0.4), width: 1.2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gold.withOpacity(0.15),
            cardNavy,
          ],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 15, offset: const Offset(0, 5)),
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
                  color: gold,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "What should I study now",
                style: TextStyle(
                  color: gold.withOpacity(0.95),
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
              color: paper,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: muted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSubjectScreen())),
            icon: const Icon(Icons.arrow_forward_rounded, color: ink, size: 18),
            label: const Text("Start studying", style: TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 13.5)),
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
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
        color: cardNavy,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's challenge", style: TextStyle(color: paper, fontSize: 14, fontWeight: FontWeight.bold)),
              Text("+${challenge.xpReward} xp", style: const TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(challenge.title, style: const TextStyle(color: muted, fontSize: 12.5)),
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

  Widget _buildStudyToolsBentoGrid(bool isDesktop) {
    final List<Map<String, dynamic>> tools = [
      {"icon": Icons.event_available_outlined, "label": "Quick quiz", "color": accentCyan, "page": const QuizScreen(summarizedText: "General study test")},
      {"icon": Icons.style_outlined, "label": "Flashcards", "color": accentViolet, "page": const FlashcardScreen()},
      {"icon": Icons.timer_outlined, "label": "Pomodoro", "color": accentPink, "page": const TimerScreen()},
      {"icon": Icons.center_focus_strong_rounded, "label": "Focus mode", "color": accentCyan, "page": const TimerScreen()},
      {"icon": Icons.access_time_filled_rounded, "label": "Mistakes", "color": gold, "page": const MistakeBankScreen()},
      {"icon": Icons.bar_chart_rounded, "label": "Analytics", "color": accentPink, "page": const AnalyticsScreen()},
      {"icon": Icons.check_box_outlined, "label": "Planner", "color": accentViolet, "page": const StudyPlannerScreen()},
      {"icon": Icons.crop_free_rounded, "label": "Scanner", "color": accentCyan, "page": const CameraSolverScreen()},
      {"icon": Icons.mic_none_rounded, "label": "Voice", "color": accentViolet, "page": const VoiceTutorScreen()},
      {"icon": Icons.emoji_events_outlined, "label": "Awards", "color": gold, "page": const AchievementScreen()},
      {"icon": Icons.access_time_rounded, "label": "Timer", "color": accentCyan, "page": const TimerScreen()},
      {"icon": Icons.check_circle_outline_rounded, "label": "Daily goal", "color": accentPink, "page": const AchievementScreen()},
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
                  color: cardNavy,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: hairline),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(t['icon'] as IconData, color: t['color'] as Color, size: 22),
                    const SizedBox(height: 8),
                    Text(
                      t['label'] as String,
                      style: const TextStyle(color: paper, fontSize: 12, fontWeight: FontWeight.bold),
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
            color: cardNavy,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: gold.withOpacity(0.4), width: 1.2, style: BorderStyle.solid),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surfaceHi,
                  shape: BoxShape.circle,
                  border: Border.all(color: gold, width: 1.5),
                ),
                child: const Icon(Icons.menu_book_rounded, color: gold, size: 24),
              ),
              const SizedBox(height: 14),
              const Text.rich(
                TextSpan(
                  text: "No subjects yet ",
                  style: TextStyle(color: paper, fontSize: 14, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: "— tap here to add your first one.",
                      style: TextStyle(color: muted, fontWeight: FontWeight.normal),
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
            color: cardNavy,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: hairline),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.book_outlined, color: accent, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Text(subj.name, style: const TextStyle(color: paper, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: muted, size: 14),
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
        color: cardNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: daysLeft < 3 ? gold : hairline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exam.title, style: const TextStyle(color: paper, fontSize: 14, fontWeight: FontWeight.bold)),
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
              style: TextStyle(color: daysLeft < 3 ? gold : paper, fontSize: 11.5, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
