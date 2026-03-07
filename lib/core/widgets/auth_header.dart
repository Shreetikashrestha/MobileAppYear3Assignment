import 'package:flutter/material.dart';
import '../../app/theme/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.subtitleColor,
    super.key,
  });

  final String title;
  final String subtitle;
  final Color? titleColor;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading2.copyWith(
            color: titleColor ?? AppTextStyles.heading2.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: AppTextStyles.bodyLarge.copyWith(
            color: subtitleColor ?? AppTextStyles.bodyLarge.color,
          ),
        ),
      ],
    );
  }
}
