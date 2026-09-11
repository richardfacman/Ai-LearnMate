import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/planner_provider.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final planner = Provider.of<PlannerProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text("Study Planner"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: planner.isLoading
          ? const Center(child: CircularProgressIndicator())
          : planner.sessions.isEmpty
              ? _buildEmptyState()
              : _buildPlannerList(planner.sessions),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_note, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text("No study plan generated yet."),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Action to generate plan
            },
            child: const Text("Generate Prep Plan"),
          ),
        ],
      ),
    );
  }

  Widget _buildPlannerList(List<StudySessionModel> sessions) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: _sessionIcon(session.type),
            title: Text(session.topicName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${session.type.name.toUpperCase()} • ${session.durationMinutes} min"),
            trailing: Checkbox(
              value: session.isCompleted,
              onChanged: (val) {
                // Toggle completion
              },
            ),
          ),
        );
      },
    );
  }

  Widget _sessionIcon(SessionType type) {
    switch (type) {
      case SessionType.learn: return const Icon(Icons.school, color: Colors.blue);
      case SessionType.practice: return const Icon(Icons.edit, color: Colors.orange);
      case SessionType.quiz: return const Icon(Icons.quiz, color: Colors.purple);
      case SessionType.flashcards: return const Icon(Icons.style, color: Colors.green);
      default: return const Icon(Icons.book, color: Colors.grey);
    }
  }
}
