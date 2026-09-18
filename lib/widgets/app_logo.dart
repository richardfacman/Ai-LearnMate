import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({super.key, this.size = 32.0, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(size * 0.25),
            border: Border.all(color: AppColors.accent.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.auto_stories_rounded,
            color: AppColors.accent,
            size: size * 0.55,
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          Text.rich(
            TextSpan(
              text: "AI Learn ",
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: size * 0.7,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
              children: [
                TextSpan(
                  text: "Mate",
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class AppLogoCompact extends StatelessWidget {
  final double size;
  const AppLogoCompact({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return AppLogo(size: size, showText: false);
  }
}
