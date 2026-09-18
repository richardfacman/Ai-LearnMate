import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  static const Color bgNavy = Color(0xFF0B0B14);
  static const Color cardNavy = Color(0xFF15151F);
  static const Color gold = Color(0xFFFFB020);
  static const Color muted = Color(0xFF8B93A6);

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: cardNavy,
        border: Border(top: BorderSide(color: Color(0x1AF4EFE6), width: 1.0)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: gold,
        unselectedItemColor: muted,
        backgroundColor: cardNavy,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: 'AI Tutor'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Study'),
          BottomNavigationBarItem(icon: Icon(Icons.insights_rounded), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
