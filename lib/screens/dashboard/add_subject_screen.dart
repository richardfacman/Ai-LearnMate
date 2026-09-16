import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/learning_provider.dart';

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color gold = Color(0xFFF0A93E);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x1AF4EFE6);

  final List<Map<String, dynamic>> _predefinedSubjects = [
    {
      'name': 'Mathematics',
      'color': const Color(0xFFA78BFA),
      'icon': Icons.calculate_outlined,
    },
    {
      'name': 'Chemistry',
      'color': const Color(0xFF4FD1C5),
      'icon': Icons.science_outlined,
    },
    {
      'name': 'History',
      'color': const Color(0xFFD08794),
      'icon': Icons.account_balance_outlined,
    },
    {
      'name': 'Languages',
      'color': const Color(0xFF6EE7B7),
      'icon': Icons.translate_outlined,
    },
    {
      'name': 'Programming',
      'color': const Color(0xFF5FB8E0),
      'icon': Icons.code_outlined,
    },
    {
      'name': 'Art',
      'color': const Color(0xFFF0879E),
      'icon': Icons.palette_outlined,
    },
    {
      'name': 'Geography',
      'color': const Color(0xFF7BC08A),
      'icon': Icons.public_outlined,
    },
    {
      'name': 'Literature',
      'color': const Color(0xFF8FA8C7),
      'icon': Icons.menu_book_outlined,
    },
    {
      'name': 'Music',
      'color': const Color(0xFFC79BE0),
      'icon': Icons.music_note_outlined,
    },
    {
      'name': 'Business',
      'color': const Color(0xFF9AA6B8),
      'icon': Icons.business_center_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final learningProvider = Provider.of<LearningProvider>(context);

    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        backgroundColor: ink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: paper),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Add a subject", style: TextStyle(color: paper, fontSize: 15, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pick something to master",
              style: TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            const Text(
              "What are you studying?",
              style: TextStyle(
                color: paper,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Add a subject and Ai Learn Mate builds a plan, quizzes, and flashcards around it.",
              style: TextStyle(color: muted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
              ),
              itemCount: _predefinedSubjects.length,
              itemBuilder: (context, index) {
                final subj = _predefinedSubjects[index];
                final String name = subj['name'];
                final Color color = subj['color'];
                final IconData icon = subj['icon'];

                final isAdded = learningProvider.subjects.any((s) => s.name.toLowerCase() == name.toLowerCase());

                return InkWell(
                  onTap: () async {
                    if (!isAdded) {
                      await learningProvider.addSubject(name);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("$name added to your subjects!"),
                            backgroundColor: color,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isAdded ? color.withOpacity(0.5) : hairline),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(icon, color: color, size: 20),
                            ),
                            Text(
                              name,
                              style: const TextStyle(
                                color: paper,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: hairline),
                              color: isAdded ? color.withOpacity(0.2) : Colors.transparent,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              isAdded ? Icons.check : Icons.add,
                              color: isAdded ? color : muted,
                              size: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
