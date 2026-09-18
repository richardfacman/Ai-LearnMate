import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Notification Toggles
  bool _studyReminders = true;
  bool _quizReminders = true;
  bool _flashcardReminders = true;
  bool _plannerReminders = true;
  bool _achievementAlerts = true;
  bool _appUpdates = false;

  // Theme Tokens
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color gold = Color(0xFFFFB020);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x1AF4EFE6);

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  void _loadNotificationPreferences() {
    try {
      final box = Hive.box('settings');
      setState(() {
        _studyReminders = box.get('notif_study', defaultValue: true);
        _quizReminders = box.get('notif_quiz', defaultValue: true);
        _flashcardReminders = box.get('notif_flashcard', defaultValue: true);
        _plannerReminders = box.get('notif_planner', defaultValue: true);
        _achievementAlerts = box.get('notif_achievement', defaultValue: true);
        _appUpdates = box.get('notif_updates', defaultValue: false);
      });
    } catch (_) {}
  }

  void _savePreference(String key, bool val) {
    try {
      final box = Hive.box('settings');
      box.put(key, val);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: surface,
        foregroundColor: paper,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("STUDY & LEARNING REMINDERS", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: hairline),
              ),
              child: Column(
                children: [
                  _switchTile("Daily Study Reminders", "Get notified for your scheduled daily study goals", _studyReminders, (val) {
                    setState(() => _studyReminders = val);
                    _savePreference('notif_study', val);
                  }),
                  const Divider(color: hairline, height: 1),
                  _switchTile("Quiz & Practice Alerts", "Nudges when a practice quiz is due for revision", _quizReminders, (val) {
                    setState(() => _quizReminders = val);
                    _savePreference('notif_quiz', val);
                  }),
                  const Divider(color: hairline, height: 1),
                  _switchTile("Flashcard Review Due", "Spaced repetition notifications for review cards", _flashcardReminders, (val) {
                    setState(() => _flashcardReminders = val);
                    _savePreference('notif_flashcard', val);
                  }),
                  const Divider(color: hairline, height: 1),
                  _switchTile("Planner Schedule Alerts", "Reminders for scheduled study tasks & exams", _plannerReminders, (val) {
                    setState(() => _plannerReminders = val);
                    _savePreference('notif_planner', val);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text("ACHIEVEMENTS & UPDATES", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: hairline),
              ),
              child: Column(
                children: [
                  _switchTile("Achievement & Level Alerts", "Celebrations when you earn XP or level up", _achievementAlerts, (val) {
                    setState(() => _achievementAlerts = val);
                    _savePreference('notif_achievement', val);
                  }),
                  const Divider(color: hairline, height: 1),
                  _switchTile("App Updates & Tips", "New feature announcements and study suggestions", _appUpdates, (val) {
                    setState(() => _appUpdates = val);
                    _savePreference('notif_updates', val);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(String title, String subtitle, bool val, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      value: val,
      onChanged: onChanged,
      activeColor: gold,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(title, style: const TextStyle(color: paper, fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(color: muted, fontSize: 12)),
    );
  }
}
