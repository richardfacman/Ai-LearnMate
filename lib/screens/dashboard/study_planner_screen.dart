import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/planner_provider.dart';
import '../../services/learning_provider.dart';
import '../../services/theme_service.dart';
import '../../models/learning/study_plan_model.dart';

class StudyPlannerScreen extends StatefulWidget {
  const StudyPlannerScreen({super.key});

  @override
  State<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends State<StudyPlannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlannerProvider>(context, listen: false).fetchPlan();
      Provider.of<LearningProvider>(context, listen: false).fetchSubjects();
    });
  }

  void _openAddTaskDialog(BuildContext context) {
    final planner = Provider.of<PlannerProvider>(context, listen: false);
    final learning = Provider.of<LearningProvider>(context, listen: false);

    final topicCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: "30");
    SessionType selectedType = SessionType.learn;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Add Study Task", style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: topicCtrl,
                  style: const TextStyle(color: AppColors.primaryText),
                  decoration: const InputDecoration(hintText: "Topic / Goal Title"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: durationCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.primaryText),
                  decoration: const InputDecoration(hintText: "Duration (minutes)"),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<SessionType>(
                  value: selectedType,
                  dropdownColor: AppColors.card,
                  style: const TextStyle(color: AppColors.primaryText),
                  decoration: const InputDecoration(filled: true, fillColor: AppColors.field),
                  items: SessionType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
                  onChanged: (val) {
                    if (val != null) setDlgState(() => selectedType = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text("Cancel", style: TextStyle(color: AppColors.secondaryText)),
            ),
            ElevatedButton(
              onPressed: () async {
                final topicName = topicCtrl.text.trim();
                final dur = int.tryParse(durationCtrl.text.trim()) ?? 30;
                if (topicName.isEmpty) return;

                Navigator.pop(dialogCtx);
                final subjectId = learning.subjects.isNotEmpty ? learning.subjects.first.id : "gen";
                await planner.generatePlan(subjectId, ["$topicName ($dur mins)"]);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              child: const Text("Save Task", style: TextStyle(color: AppColors.goldInk, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planner = Provider.of<PlannerProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Study Planner", style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontFamily: 'serif')),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.accent),
            onPressed: () => _openAddTaskDialog(context),
          ),
        ],
      ),
      body: planner.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : planner.sessions.isEmpty
              ? _buildEmptyState()
              : _buildPlannerList(planner.sessions),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.card),
              child: const Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.violet),
            ),
            const SizedBox(height: 20),
            const Text("No study tasks scheduled yet.", style: TextStyle(color: AppColors.primaryText, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Create custom study tasks or generate an AI preparation plan for upcoming exams.", style: TextStyle(color: AppColors.secondaryText, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openAddTaskDialog(context),
              icon: const Icon(Icons.add_task_rounded, size: 18),
              label: const Text("Add Study Task"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlannerList(List<StudySessionModel> sessions) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: session.isCompleted ? Colors.green.withValues(alpha: 0.4) : AppColors.border),
          ),
          child: Row(
            children: [
              _sessionIcon(session.type),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.topicName, style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontSize: 14.5, decoration: session.isCompleted ? TextDecoration.lineThrough : null)),
                    const SizedBox(height: 4),
                    Text("${session.type.name.toUpperCase()} • ${session.durationMinutes} min", style: const TextStyle(color: AppColors.secondaryText, fontSize: 11.5)),
                  ],
                ),
              ),
              Checkbox(
                value: session.isCompleted,
                activeColor: AppColors.accent,
                checkColor: AppColors.goldInk,
                onChanged: (val) {
                  setState(() {
                    session.isCompleted = val ?? false;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sessionIcon(SessionType type) {
    switch (type) {
      case SessionType.learn:
        return const Icon(Icons.school_outlined, color: AppColors.cyan, size: 22);
      case SessionType.practice:
        return const Icon(Icons.edit_outlined, color: AppColors.accent, size: 22);
      case SessionType.quiz:
        return const Icon(Icons.quiz_outlined, color: AppColors.pink, size: 22);
      case SessionType.flashcards:
        return const Icon(Icons.style_outlined, color: AppColors.violet, size: 22);
      default:
        return const Icon(Icons.book_outlined, color: AppColors.secondaryText, size: 22);
    }
  }
}
