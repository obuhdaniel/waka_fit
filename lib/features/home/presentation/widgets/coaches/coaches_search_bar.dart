// lib/features/coaches/components/coaches_search_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waka_fit/core/theme/app_colors.dart';

class CoachesSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final VoidCallback onFilterTap;

  const CoachesSearchBar({
    Key? key,
    required this.controller,
    required this.onSearch,
    required this.onFilterTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.wakaSurface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Expert Coaches',
          style: GoogleFonts.inter(
            color: AppColors.wakaTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
          
          ),

          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.wakaSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.wakaStroke,
                      width: 2
                    )
                  
                  ),
                  child: TextField(
                    controller: controller,
                    onChanged: onSearch,
                    style: GoogleFonts.inter(
                      backgroundColor: Colors.transparent,
                      color: AppColors.wakaTextPrimary
                      
                    ),
                    decoration: InputDecoration(
                      fillColor: AppColors.wakaSurface,
                      hintText: 'Search coaches, specialties...',
                      hintStyle: GoogleFonts.inter(color: AppColors.wakaTextSecondary, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: AppColors.wakaTextSecondary),
                     border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              
            ],
          ),
        ],
      ),
    );
  }
}