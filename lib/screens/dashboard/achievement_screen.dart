import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/achievement_provider.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AchievementProvider>(context, listen: false).fetchAchievements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final achievementProvider = Provider.of<AchievementProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text("My Achievements", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: achievementProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: achievementProvider.achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievementProvider.achievements[index];
                return Opacity(
                  opacity: achievement.isUnlocked ? 1.0 : 0.5,
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: achievement.isUnlocked ? Colors.orange.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(achievement.icon, style: const TextStyle(fontSize: 24)),
                      ),
                      title: Text(achievement.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(achievement.description),
                      trailing: achievement.isUnlocked 
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : Text("${achievement.xpReward} XP", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
