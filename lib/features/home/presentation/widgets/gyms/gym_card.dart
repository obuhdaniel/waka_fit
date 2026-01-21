// lib/features/home/presentation/widgets/gyms/gym_card.dart
import 'package:flutter/material.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class GymCard extends StatelessWidget {
  final String name;
  final String type;
  final String rating;
  final String distance;
  final String price;
  final List<String> amenities;
  final String imageUrl;
  final VoidCallback onTap;
  final VoidCallback onSave;

  const GymCard({
    super.key,
    required this.name,
    required this.type,
    required this.rating,
    required this.distance,
    required this.price,
    required this.amenities,
    required this.imageUrl,
    required this.onTap,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            // Image with save button
            Stack(
              children: [
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
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: onSave,
                      icon: const Icon(
                        Icons.bookmark_border,
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              ],
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Type
            Text(
              type,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.wakaBlue.withOpacity(0.8),
              ),
            ),

            const SizedBox(height: 10),

            // Rating and Distance
            Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: _statText(),
                    ),
                  ],
                ),
                _dot(),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.wakaBlue),
                    const SizedBox(width: 4),
                    Text(
                      distance,
                      style: _statText(),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Price
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.wakaBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.wakaBlue.withOpacity(0.3),
                ),
              ),
              child: Text(
                price,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.wakaBlue,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Amenities (first 2)
            if (amenities.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: amenities.take(2).map((amenity) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.wakaBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      amenity,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  );
                }).toList(),
              ),

            const Spacer(),

            // View Details button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.wakaBlue,
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'View Details',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.wakaBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _statText() {
    return GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: Colors.white.withOpacity(0.8),
    );
  }

  Widget _dot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      );
}