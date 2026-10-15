import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../config/app_contact_config.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 236,
      decoration: const BoxDecoration(
        color: Color(0xEC0A0D1A),
        border: Border(right: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Brand
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 1.5),
                  ),
                  child: const Icon(Icons.school_rounded, color: AppColors.accent, size: 16),
                ),
                const SizedBox(width: 10),
                const Text.rich(
                  TextSpan(
                    text: "AI Learn ",
                    style: TextStyle(color: AppColors.primaryText, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif'),
                    children: [
                      TextSpan(text: "Mate", style: TextStyle(color: AppColors.accent)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Navigation Links
          _navItem(0, Icons.home_filled, "Home"),
          _navItem(1, Icons.smart_toy_outlined, "AI Tutor"),
          _navItem(2, Icons.menu_book_rounded, "Study"),
          _navItem(3, Icons.insights_rounded, "Progress"),
          _navItem(4, Icons.person_outline, "Profile"),

          const Spacer(),

          // User Profile Footer
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    AppContactConfig.ownerPhotoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      AppContactConfig.ownerAssetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text("F", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text("Foysal Ahmed", style: TextStyle(color: AppColors.primaryText, fontSize: 12.5, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      Text("Owner & Developer", style: TextStyle(color: AppColors.secondaryText, fontSize: 11), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => onDestinationSelected(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent.withValues(alpha: 0.16) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.accent.withValues(alpha: 0.4) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? AppColors.accent : AppColors.secondaryText, size: 18),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.accent : AppColors.primaryText,
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
