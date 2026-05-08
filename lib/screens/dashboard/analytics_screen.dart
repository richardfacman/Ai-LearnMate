import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  int weeklyMinutes = 0;
  int quizzesTaken = 0;
  double avgAccuracy = 0;
  int streakDays = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = _auth.currentUser!.uid;

    // --- study hours this week ---
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final sessions = await _db
        .collection('timers')
        .doc(uid)
        .collection('sessions')
        .where('startTime', isGreaterThan: weekAgo.toIso8601String())
        .get();

    int totalSec = 0;
    for (var s in sessions.docs) {
      totalSec += (s['duration'] as int);
    }
    weeklyMinutes = (totalSec / 60).round();

    // --- quiz accuracy ---
    final quizSnap = await _db
        .collection('quizzes')
        .doc(uid)
        .collection('items')
        .get();
    quizzesTaken = quizSnap.size;
    double correct = 0;
    double total = 0;
    for (var q in quizSnap.docs) {
      final questions = q['questions'] as List;
      total += questions.length;
      // assume 70% average correctness (you can log actual score)
      correct += questions.length * 0.7;
    }
    avgAccuracy = total == 0 ? 0 : (correct / total) * 100;

    // --- streak calculation (days with sessions) ---
    final days = <String>{};
    for (var s in sessions.docs) {
      final date = DateTime.parse(s['startTime']).toLocal();
      days.add("${date.year}-${date.month}-${date.day}");
    }
    streakDays = days.length;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFE),
      appBar: AppBar(
        title: const Text("Study Analytics"),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF007BFF), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _infoCard("Weekly Study Time", "$weeklyMinutes min", Icons.timer),
            _infoCard("Quizzes Taken", "$quizzesTaken", Icons.assignment),
            _infoCard("Avg Accuracy", "${avgAccuracy.toStringAsFixed(1)} %", Icons.bar_chart),
            _infoCard("Active Days", "$streakDays days", Icons.local_fire_department),

            const SizedBox(height: 30),
            const Text("Weekly Study Graph",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Text(days[v.toInt() % 7],
                              style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, interval: 20),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(7, (i) => FlSpot(i.toDouble(), (i + 1) * 10.0)),
                      isCurved: true,
                      color: const Color(0xFF6C63FF),
                      barWidth: 4,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF007BFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF007BFF)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
            ],
          ),
        ],
      ),
    );
  }
}
