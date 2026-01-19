// lib/features/home/components/top_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
class TopBar extends StatelessWidget {
  final String location;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationTap;

  const TopBar({
    Key? key,
    required this.location,
    required this.onLocationTap,
    required this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.wakaSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo

         
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Waka Fit',
                style: GoogleFonts.inter(
                  color: AppColors.wakaGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.w700
                )
              ),

              SizedBox(
                height: 5,
              ),
                 // Location
          GestureDetector(
            onTap: onLocationTap,
            child: Row(
              children: [
                 Icon(
                  Icons.location_on,
                  color: AppColors.wakaBlue,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  location,
                  style: GoogleFonts.inter(
                    color: AppColors.wakaTextSecondary,
                    fontSize: 12
                  )
                ),
              ],
            ),
          ),
          

            ],
          ),
          const Spacer(),
          
          // Notification
          IconButton(
            onPressed: onNotificationTap,
            icon: Badge(
              backgroundColor: AppColors.wakaTextPrimary,
              smallSize: 8,
              child:  Icon(
                Icons.notifications,
                color: AppColors.wakaTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}