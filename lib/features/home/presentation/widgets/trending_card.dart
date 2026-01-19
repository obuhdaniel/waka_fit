import 'package:flutter/material.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
class TrendingCard {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String type; // 'coach', 'gym', 'post'
  final String? followers;
  final Color? gradientStart;
  final Color? gradientEnd;

  TrendingCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.type,
    this.followers,
    this.gradientStart,
    this.gradientEnd,
  });
}

class TrendingSection extends StatelessWidget {
  final String title;
  final List<TrendingCard> items;
  final VoidCallback onSeeAll;

  const TrendingSection({
    Key? key,
    required this.title,
    required this.items,
    required this.onSeeAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildTrendingCard(items[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCard(TrendingCard card) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            card.gradientStart ?? AppColors.primary,
            card.gradientEnd ?? AppColors.darkPrimary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.2),
                  BlendMode.darken,
                ),
                child: Container(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  card.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  card.subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (card.followers != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.group,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        card.followers!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (card.type == 'coach')
            const Positioned(
              top: 12,
              right: 12,
              child: Chip(
                label: Text('Coach'),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              ),
            ),
        ],
      ),
    );
  }
}