import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_learn_mate/services/learning_provider.dart';
import 'package:ai_learn_mate/services/mastery_provider.dart';
import 'package:ai_learn_mate/models/learning/subject_model.dart';
import 'package:ai_learn_mate/models/learning/topic_model.dart';
import 'package:ai_learn_mate/screens/dashboard/quiz_screen.dart';

class KnowledgeMapScreen extends StatefulWidget {
  final SubjectModel subject;
  const KnowledgeMapScreen({super.key, required this.subject});

  @override
  State<KnowledgeMapScreen> createState() => _KnowledgeMapScreenState();
}

class _KnowledgeMapScreenState extends State<KnowledgeMapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LearningProvider>(context, listen: false).fetchTopics(widget.subject.id);
      Provider.of<MasteryProvider>(context, listen: false).fetchMastery();
    });
  }

  @override
  Widget build(BuildContext context) {
    final learningProvider = Provider.of<LearningProvider>(context);
    final masteryProvider = Provider.of<MasteryProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text("${widget.subject.name} Knowledge Map"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: learningProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildTopicTree(learningProvider.topics, masteryProvider),
    );
  }

  Widget _buildTopicTree(List<TopicModel> topics, MasteryProvider masteryProvider) {
    // Separate root topics and sub-topics
    final rootTopics = topics.where((t) => t.parentId == null).toList();
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: rootTopics.length,
      itemBuilder: (context, index) {
        final root = rootTopics[index];
        final subTopics = topics.where((t) => t.parentId == root.id).toList();
        
        return _buildTopicNode(root, subTopics, masteryProvider);
      },
    );
  }

  Widget _buildTopicNode(TopicModel topic, List<TopicModel> children, MasteryProvider masteryProvider) {
    final mastery = masteryProvider.getTopicMastery(topic.id);
    final masteryPercent = (mastery * 100).toInt();

    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
          child: ExpansionTile(
            leading: _buildMasteryIndicator(mastery),
            title: Text(topic.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Mastery: $masteryPercent%"),
            children: [
              if (children.isEmpty)
                const ListTile(
                  title: Text("No sub-topics", style: TextStyle(color: Colors.grey, fontSize: 14)),
                )
              else
                ...children.map((child) => ListTile(
                      contentPadding: const EdgeInsets.only(left: 40, right: 20),
                      leading: _buildMasteryIndicator(masteryProvider.getTopicMastery(child.id), small: true),
                      title: Text(child.name, style: const TextStyle(fontSize: 14)),
                      trailing: Text("${(masteryProvider.getTopicMastery(child.id) * 100).toInt()}%"),
                      onTap: () {
                        // Navigate to specific topic learning
                      },
                    )),
              Padding(
                padding: const EdgeInsets.all(15),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(summarizedText: "Study more about ${topic.name}"),
                      ),
                    );
                  },
                  child: const Text("Study This Topic"),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildMasteryIndicator(double mastery, {bool small = false}) {
    Color color;
    if (mastery < 0.4) color = Colors.red;
    else if (mastery < 0.6) color = Colors.orange;
    else if (mastery < 0.8) color = Colors.blue;
    else color = Colors.green;

    return Container(
      width: small ? 10 : 15,
      height: small ? 10 : 15,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.5), blurRadius: 4),
        ],
      ),
    );
  }
}
