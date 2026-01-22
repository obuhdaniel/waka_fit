// lib/features/coaches/components/sort_filter_sheet.dart
import 'package:flutter/material.dart';
import 'package:waka_fit/core/theme/app_colors.dart';

enum SortOption {
  relevance,
  rating,
  followers,
  experience,
}

class SortFilterSheet extends StatefulWidget {
  final SortOption initialSort;
  final double initialMinRating;
  final double initialMaxDistance;
  final ValueChanged<Map<String, dynamic>> onApply;

  const SortFilterSheet({
    Key? key,
    this.initialSort = SortOption.relevance,
    this.initialMinRating = 4.0,
    this.initialMaxDistance = 10.0,
    required this.onApply,
  }) : super(key: key);

  @override
  State<SortFilterSheet> createState() => _SortFilterSheetState();
}

class _SortFilterSheetState extends State<SortFilterSheet> {
  late SortOption _selectedSort;
  late double _minRating;
  late double _maxDistance;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.initialSort;
    _minRating = widget.initialMinRating;
    _maxDistance = widget.initialMaxDistance;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
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
                'Sort & Filter',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sort by
          Text(
            'Sort By',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSortOption(
                label: 'Relevance',
                value: SortOption.relevance,
              ),
              _buildSortOption(
                label: 'Highest Rating',
                value: SortOption.rating,
              ),
              _buildSortOption(
                label: 'Most Followers',
                value: SortOption.followers,
              ),
              _buildSortOption(
                label: 'Experience',
                value: SortOption.experience,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Minimum rating
          Text(
            'Minimum Rating',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                _minRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Max distance
          Text(
            'Max Distance (miles)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${_maxDistance.toStringAsFixed(0)} mi',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Slider(
                  value: _maxDistance,
                  min: 1.0,
                  max: 50.0,
                  divisions: 49,
                  label: '${_maxDistance.toStringAsFixed(0)} mi',
                  onChanged: (value) {
                    setState(() {
                      _maxDistance = value;
                    });
                  },
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
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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
    required SortOption value,
  }) {
    final isSelected = _selectedSort == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedSort = value;
          });
        }
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}