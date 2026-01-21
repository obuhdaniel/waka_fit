import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                style: GoogleFonts.inter(
                  color: AppColors.wakaTextPrimary
                )
              ),
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  'See All',
                  style: GoogleFonts.inter(
                    color: AppColors.wakaBlue,
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
    width: 250,
    margin: const EdgeInsets.only(right: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      image: card.imageUrl != null
          ? DecorationImage(
              image: NetworkImage(card.imageUrl!),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4),
                BlendMode.darken,
              ),
            )
          : null,
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // CONTENT OVERLAY
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
               Row(
  children: [
    // Tag / Subtitle chip
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.wakaBlue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.wakaBlue.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text(
        card.subtitle,
        style: GoogleFonts.inter(
          color: AppColors.wakaBlue,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),

    const SizedBox(width: 12),

    if (card.followers != null)
      Row(
        children: [
          Icon(
            Icons.people_alt_rounded,
            color: Colors.white.withOpacity(0.85),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            card.followers!,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
  ],
)
],
            ),
          ),

                ],
      ),
    ),
  );
}
}