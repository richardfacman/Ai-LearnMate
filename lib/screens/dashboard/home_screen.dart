import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/bottom_navbar.dart';
import 'chat_screen.dart';
import 'notes_screen.dart';
import 'quiz_screen.dart';
import 'timer_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final List<Widget> _pages = const [
    HomeDashboard(),
    ChatScreen(),
    NotesScreen(),
    TimerScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final String _fullText = "Hi, welcome to Ai Learn Mate";
  String _currentText = "";
  Timer? _typewriterTimer;

  @override
  void initState() {
    super.initState();
    _startTypewriterEffect();
  }

  void _startTypewriterEffect() {
    _typewriterTimer?.cancel();
    int charIndex = 0;
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (charIndex < _fullText.length) {
        if (mounted) {
          setState(() {
            _currentText = _fullText.substring(0, charIndex + 1);
          });
        }
        charIndex++;
      } else {
        timer.cancel();
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _currentText = "";
            });
            _startTypewriterEffect();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121417), // Match dark theme
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section (Buttons removed)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Ai Learn Mate",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Hero Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    SizedBox(
                      height: 120, // Enough height for wrapped text
                      child: Text(
                        _currentText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Ai Learn Mate is your personal AI study companion\ndesigned for smarter and faster learning.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        // Action for Join/Get Started
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Get Started Now",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),

              // Feature Quick Links
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    _featureCard(
                      context,
                      icon: Icons.chat_bubble_outline,
                      title: "AI Chat",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                    ),
                    _featureCard(
                      context,
                      icon: Icons.note_alt_outlined,
                      title: "Notes",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesScreen())),
                    ),
                    _featureCard(
                      context,
                      icon: Icons.quiz_outlined,
                      title: "Quiz",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen(summarizedText: ""))),
                    ),
                    _featureCard(
                      context,
                      icon: Icons.timer_outlined,
                      title: "Timer",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimerScreen())),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureCard(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E2126),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF00B0FF), size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
