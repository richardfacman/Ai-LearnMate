import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  // Theme Tokens
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color surfaceHi = Color(0xFF1B2230);
  static const Color gold = Color(0xFFFFB020);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x1AF4EFE6);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? '';

    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text("My Submitted Reports", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: surface,
        foregroundColor: paper,
        elevation: 0,
      ),
      body: uid.isEmpty
          ? const Center(child: Text("Please sign in to view your reports.", style: TextStyle(color: muted)))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('feedback')
                  .where('userId', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: gold));
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.rate_review_outlined, color: muted, size: 48),
                          const SizedBox(height: 16),
                          const Text("No Feedback or Reports Yet", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          const Text("Submissions you send to the team will appear here.", style: TextStyle(color: muted, fontSize: 12.5), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(22),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final subject = data['subject'] ?? data['title'] ?? 'Report';
                    final type = data['type'] ?? 'Feedback';
                    final status = data['status'] ?? 'new';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: hairline),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: gold.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.assignment_outlined, color: gold, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(subject, style: const TextStyle(color: paper, fontSize: 14, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(type, style: const TextStyle(color: muted, fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: surfaceHi,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: hairline),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: const TextStyle(color: gold, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
