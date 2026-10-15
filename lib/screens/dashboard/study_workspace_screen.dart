import 'package:flutter/material.dart';
import '../../services/theme_service.dart';
import 'notes_screen.dart';
import 'quiz_screen.dart';
import 'flashcard_screen.dart';
import 'study_planner_screen.dart';
import 'focus_timer_screen.dart';
import 'mistake_bank_screen.dart';
import 'camera_solver_screen.dart';
import 'voice_tutor_screen.dart';

class StudyWorkspaceScreen extends StatefulWidget {
  final int initialTabIndex;
  const StudyWorkspaceScreen({super.key, this.initialTabIndex = 0});

  @override
  State<StudyWorkspaceScreen> createState() => _StudyWorkspaceScreenState();
}

class _StudyWorkspaceScreenState extends State<StudyWorkspaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 8,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 7),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Study Workspace", style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontFamily: 'serif')),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.primaryText,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.secondaryText,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_customize_outlined, size: 18), text: "Overview"),
            Tab(icon: Icon(Icons.description_outlined, size: 18), text: "My Notes"),
            Tab(icon: Icon(Icons.quiz_outlined, size: 18), text: "Quiz Center"),
            Tab(icon: Icon(Icons.style_outlined, size: 18), text: "Flashcards"),
            Tab(icon: Icon(Icons.check_box_outlined, size: 18), text: "Planner"),
            Tab(icon: Icon(Icons.timer_outlined, size: 18), text: "Focus Room"),
            Tab(icon: Icon(Icons.bookmark_border_outlined, size: 18), text: "Mistake Bank"),
            Tab(icon: Icon(Icons.crop_free_rounded, size: 18), text: "Scanner & Voice"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          const NotesScreen(),
          const QuizScreen(),
          const FlashcardScreen(),
          const StudyPlannerScreen(),
          const FocusTimerScreen(),
          const MistakeBankScreen(),
          _buildScannerVoiceTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Study Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.15),
                      AppColors.card,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Today's Study Plan", style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    const Text("Master Mathematics & AI Concepts", style: TextStyle(color: AppColors.primaryText, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                    const SizedBox(height: 4),
                    const Text("3 tasks scheduled • 45 minutes target remaining", style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text("Study Modules", style: TextStyle(color: AppColors.primaryText, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'serif')),
              const SizedBox(height: 14),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _studyToolCard("My Notes", "Summarize & Q&A notes", Icons.description_outlined, AppColors.cyan, 1),
                  _studyToolCard("Quiz Center", "Practice adaptive tests", Icons.quiz_outlined, AppColors.violet, 2),
                  _studyToolCard("Flashcards", "SM-2 Spaced Repetition", Icons.style_outlined, AppColors.pink, 3),
                  _studyToolCard("Study Planner", "Organize tasks & exams", Icons.check_box_outlined, AppColors.accent, 4),
                  _studyToolCard("Focus Room", "25/5 Pomodoro Session", Icons.timer_outlined, AppColors.cyan, 5),
                  _studyToolCard("Mistake Bank", "Review missed questions", Icons.bookmark_border_outlined, AppColors.pink, 6),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _studyToolCard(String title, String desc, IconData icon, Color color, int tabIndex) {
    return InkWell(
      onTap: () => _tabController.animateTo(tabIndex),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(desc, style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerVoiceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: const [
          SizedBox(
            height: 500,
            child: CameraSolverScreen(),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 500,
            child: VoiceTutorScreen(),
          ),
        ],
      ),
    );
  }
}
