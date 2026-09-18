import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../services/analytics_provider.dart';
import '../../services/learning_provider.dart';
import '../../services/mastery_provider.dart';
import '../../services/theme_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsProvider>(context, listen: false).fetchAnalytics();
      Provider.of<LearningProvider>(context, listen: false).fetchSubjects();
      Provider.of<MasteryProvider>(context, listen: false).fetchMastery();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analytics = Provider.of<AnalyticsProvider>(context);
    final learning = Provider.of<LearningProvider>(context);
    final mastery = Provider.of<MasteryProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Learning Insights", style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontFamily: 'serif')),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.primaryText,
      ),
      body: analytics.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryGrid(analytics),
                      const SizedBox(height: 28),
                      _buildWeeklyStudyChart(analytics),
                      const SizedBox(height: 28),
                      _buildSubjectMasteryCard(learning, mastery),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryGrid(AnalyticsProvider analytics) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _statCard("Study Time", "${analytics.weeklyMinutes}m", Icons.timer_outlined, AppColors.cyan),
        _statCard("Quizzes Completed", "${analytics.quizzesTaken}", Icons.assignment_outlined, AppColors.violet),
        _statCard("Average Accuracy", "${analytics.avgAccuracy.toStringAsFixed(1)}%", Icons.track_changes_outlined, Colors.greenAccent),
        _statCard("Active Days", "${analytics.streakDays} days", Icons.local_fire_department_outlined, AppColors.accent),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
          Text(title, style: const TextStyle(fontSize: 11.5, color: AppColors.secondaryText)),
        ],
      ),
    );
  }

  Widget _buildWeeklyStudyChart(AnalyticsProvider analytics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Weekly Study Activity (Minutes)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryText, fontFamily: 'serif')),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 60,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        int idx = v.toInt();
                        if (idx >= 0 && idx < days.length) {
                          return Text(days[idx], style: const TextStyle(color: AppColors.secondaryText, fontSize: 11));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (i) {
                  double val = analytics.weeklyStudyData[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: val > 0 ? val : 5, // minimum height bar for visual
                        color: val > 0 ? AppColors.accent : AppColors.cardTop,
                        width: 16,
                        borderRadius: BorderRadius.circular(6),
                      )
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectMasteryCard(LearningProvider learning, MasteryProvider mastery) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Subject Mastery Breakdown", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryText, fontFamily: 'serif')),
          const SizedBox(height: 16),
          if (learning.subjects.isEmpty)
            const Text("Add your first subject to see mastery breakdown.", style: TextStyle(color: AppColors.secondaryText, fontSize: 13))
          else
            Column(
              children: learning.subjects.map((subj) {
                double score = mastery.getTopicMastery(subj.id);
                if (score == 0) score = 0.45; // Default initial mastery for new subject
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(subj.name, style: const TextStyle(color: AppColors.primaryText, fontSize: 13.5, fontWeight: FontWeight.bold)),
                          Text("${(score * 100).toStringAsFixed(0)}%", style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: score,
                          backgroundColor: AppColors.background,
                          color: AppColors.accent,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
