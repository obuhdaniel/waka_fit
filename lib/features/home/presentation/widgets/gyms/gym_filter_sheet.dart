// lib/features/home/presentation/widgets/gyms/gym_filter_sheet.dart
import 'package:flutter/material.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waka_fit/features/home/presentation/widgets/gyms/gym_screen.dart';

class GymFilterSheet extends StatefulWidget {
  final GymSortOption initialSort;
  final double initialMinRating;
  final double initialMaxDistance;
  final double initialMaxPrice;
  final ValueChanged<Map<String, dynamic>> onApply;

  const GymFilterSheet({
    super.key,
    required this.initialSort,
    required this.initialMinRating,
    required this.initialMaxDistance,
    required this.initialMaxPrice,
    required this.onApply,
  });

  @override
  State<GymFilterSheet> createState() => _GymFilterSheetState();
}

class _GymFilterSheetState extends State<GymFilterSheet> {
  late GymSortOption _selectedSort;
  late double _minRating;
  late double _maxDistance;
  late double _maxPrice;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.initialSort;
    _minRating = widget.initialMinRating;
    _maxDistance = widget.initialMaxDistance;
    _maxPrice = widget.initialMaxPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.wakaSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Gyms',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sort by
          Text(
            'Sort By',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSortOption(
                label: 'Relevance',
                value: GymSortOption.relevance,
              ),
              _buildSortOption(
                label: 'Highest Rating',
                value: GymSortOption.rating,
              ),
              _buildSortOption(
                label: 'Nearest',
                value: GymSortOption.distance,
              ),
              _buildSortOption(
                label: 'Lowest Price',
                value: GymSortOption.price,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Minimum rating
          Text(
            'Minimum Rating',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.wakaBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  _minRating.toStringAsFixed(1),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Slider(
                  value: _minRating,
                  min: 1.0,
                  max: 5.0,
                  divisions: 8,
                  label: _minRating.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      _minRating = value;
                    });
                  },
                  activeColor: AppColors.wakaBlue,
                  inactiveColor: AppColors.wakaStroke,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Max distance
          Text(
            'Max Distance (miles)',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.wakaBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${_maxDistance.toInt()}',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Slider(
                  value: _maxDistance,
                  min: 1.0,
                  max: 50.0,
                  divisions: 49,
                  label: '${_maxDistance.toInt()} mi',
                  onChanged: (value) {
                    setState(() {
                      _maxDistance = value;
                    });
                  },
                  activeColor: AppColors.wakaBlue,
                  inactiveColor: AppColors.wakaStroke,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Max price
          Text(
            'Max Price (\$/month)',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.wakaBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '\$${_maxPrice.toInt()}',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Slider(
                  value: _maxPrice,
                  min: 20.0,
                  max: 300.0,
                  divisions: 28,
                  label: '\$${_maxPrice.toInt()}',
                  onChanged: (value) {
                    setState(() {
                      _maxPrice = value;
                    });
                  },
                  activeColor: AppColors.wakaBlue,
                  inactiveColor: AppColors.wakaStroke,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply({
                  'sort': _selectedSort,
                  'minRating': _minRating,
                  'maxDistance': _maxDistance,
                  'maxPrice': _maxPrice,
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.wakaBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSortOption({
    required String label,
    required GymSortOption value,
  }) {
    final isSelected = _selectedSort == value;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedSort = value;
          });
        }
      },
      selectedColor: AppColors.wakaBlue,
      backgroundColor: AppColors.wakaBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.wakaBlue : AppColors.wakaStroke,
        ),
      ),
    );
  }
}