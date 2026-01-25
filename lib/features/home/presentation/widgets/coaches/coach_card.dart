import 'package:flutter/material.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CoachCard extends StatelessWidget {
  final String name;
  final String specialties;
  final String followers;
  final double rating;
  final int posts;
  final int plans;
  final String imageUrl;
  final bool isFollowing;
  final VoidCallback onFollowTap;
  final VoidCallback onCoachTap;

  const CoachCard({
    super.key,
    required this.name,
    required this.specialties,
    required this.followers,
    required this.rating,
    required this.posts,
    required this.plans,
    required this.imageUrl,
    required this.isFollowing,
    required this.onFollowTap,
    required this.onCoachTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCoachTap,
      child: Container(
        width: 240,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.wakaSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Name
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 4),

            // Specialties
            Text(
              specialties.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.wakaBlue,
                letterSpacing: 0.6,
              ),
            ),

            const SizedBox(height: 10),

            // Stats
            Row(
              children: [
                Text(
                  followers,
                  style: _statText(),
                ),
                _dot(),
                Text(
                  rating.toStringAsFixed(1),
                  style: _statText(),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.star, size: 14, color: Colors.amber),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              '$posts posts • $plans plans',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),

            const Spacer(),

            // Follow button
            // SizedBox(
            //   width: double.infinity,
            //   height: 40,
            //   child: OutlinedButton(
            //     onPressed: onFollowTap,
            //     style: OutlinedButton.styleFrom(
            //       side: BorderSide(
            //         color: AppColors.wakaBlue,
            //         width: 1.2,
            //       ),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(24),
            //       ),
            //     ),
            //     child: Text(
            //       isFollowing ? 'Following' : 'Follow',
            //       style: GoogleFonts.inter(
            //         fontSize: 14,
            //         fontWeight: FontWeight.w600,
            //         color: AppColors.wakaBlue,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  TextStyle _statText() {
    return GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
  }

  Widget _dot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          '•',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      );
}


