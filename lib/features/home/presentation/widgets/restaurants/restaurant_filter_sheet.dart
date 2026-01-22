// lib/features/restaurants/widgets/restaurant_filter_sheet.dart
import 'package:flutter/material.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waka_fit/features/home/presentation/widgets/restaurants/restaurant_screen.dart';

class RestaurantFilterSheet extends StatefulWidget {
  final RestaurantSortOption initialSort;
  final double initialMinRating;
  final double initialMaxDistance;
  final double initialMaxPrice;
  final List<String> initialDietary;
  final ValueChanged<Map<String, dynamic>> onApply;

  const RestaurantFilterSheet({
    super.key,
    required this.initialSort,
    required this.initialMinRating,
    required this.initialMaxDistance,
    required this.initialMaxPrice,
    required this.initialDietary,
    required this.onApply,
  });

  @override
  State<RestaurantFilterSheet> createState() => _RestaurantFilterSheetState();
}

class _RestaurantFilterSheetState extends State<RestaurantFilterSheet> {
  late RestaurantSortOption _selectedSort;
  late double _minRating;
  late double _maxDistance;
  late double _maxPrice;
  late List<String> _selectedDietary;

  final List<String> _dietaryOptions = [
    'Vegan',
    'Vegetarian',
    'Gluten-Free',
    'Dairy-Free',
    'Organic',
    'High-Protein',
    'Low-Carb',
    'Low-Calorie',
  ];

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.initialSort;
    _minRating = widget.initialMinRating;
    _maxDistance = widget.initialMaxDistance;
    _maxPrice = widget.initialMaxPrice;
    _selectedDietary = List.from(widget.initialDietary);
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
                'Filter Restaurants',
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
                value: RestaurantSortOption.relevance,
              ),
              _buildSortOption(
                label: 'Highest Rating',
                value: RestaurantSortOption.rating,
              ),
              _buildSortOption(
                label: 'Nearest',
                value: RestaurantSortOption.distance,
              ),
              _buildSortOption(
                label: 'Lowest Price',
                value: RestaurantSortOption.price,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Dietary preferences
          Text(
            'Dietary Preferences',
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
            children: _dietaryOptions.map((option) {
              return FilterChip(
                label: Text(
                  option,
                  style: GoogleFonts.inter(
                    color: _selectedDietary.contains(option)
                        ? Colors.white
                        : Colors.white.withOpacity(0.7),
                  ),
                ),
                selected: _selectedDietary.contains(option),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDietary.add(option);
                    } else {
                      _selectedDietary.remove(option);
                    }
                  });
                },
                selectedColor: AppColors.wakaGreen,
                backgroundColor: AppColors.wakaBackground,
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
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
            'Max Price Per Meal',
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
                  min: 5.0,
                  max: 50.0,
                  divisions: 45,
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
                  'dietary': _selectedDietary,
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
    required RestaurantSortOption value,
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