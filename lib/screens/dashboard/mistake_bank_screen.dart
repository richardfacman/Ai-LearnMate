import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ai_learn_mate/models/learning/mistake_model.dart';

class MistakeBankScreen extends StatelessWidget {
  const MistakeBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text("Mistake Bank", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('mistakes')
            .doc(user?.uid)
            .collection('items')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                  SizedBox(height: 20),
                  Text("No mistakes yet! Keep it up."),
                ],
              ),
            );
          }

          final mistakes = snapshot.data!.docs.map((doc) => MistakeModel.fromMap(doc.data() as Map<String, dynamic>)).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: mistakes.length,
            itemBuilder: (context, index) {
              final m = mistakes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.help_outline, color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(m.question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text("Your Answer: ${m.studentAnswer}", style: const TextStyle(color: Colors.redAccent)),
                      Text("Correct Answer: ${m.correctAnswer}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text("AI Explanation:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(m.explanation, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
