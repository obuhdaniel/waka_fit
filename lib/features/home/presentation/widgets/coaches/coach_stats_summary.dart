// lib/features/coaches/components/coach_stats_summary.dart
import 'package:flutter/material.dart';
import 'package:waka_fit/core/theme/app_colors.dart';

class CoachStatsSummary extends StatelessWidget {
  final int totalCoaches;
  final int activeCoaches;
  final double averageRating;

  const CoachStatsSummary({
    Key? key,
    required this.totalCoaches,
    required this.activeCoaches,
    required this.averageRating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            value: totalCoaches.toString(),
            label: 'Total Coaches',
            icon: Icons.group_outlined,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          _buildStat(
            value: activeCoaches.toString(),
            label: 'Active Now',
            icon: Icons.online_prediction_outlined,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          _buildStat(
            value: averageRating.toStringAsFixed(1),
            label: 'Avg Rating',
            icon: Icons.star_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}