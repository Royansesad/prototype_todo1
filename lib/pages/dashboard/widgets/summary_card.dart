import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_text_styles.dart';

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final LinearGradient gradient;
  final int index;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient.colors
              .map((c) => c.withValues(alpha: 0.15))
              .toList(),
          begin: gradient.begin,
          end: gradient.end,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradient.colors.first.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: gradient.colors.first.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: gradient.colors.first),
            ),
            const Spacer(),
            Text(
              value,
              style: AppTextStyles.h2Of(context).copyWith(
                color: gradient.colors.first,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.captionOf(context).copyWith(
                color: gradient.colors.first.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (150 * index).ms, duration: 400.ms)
        .slideX(begin: 0.3, end: 0, delay: (150 * index).ms);
  }
}
