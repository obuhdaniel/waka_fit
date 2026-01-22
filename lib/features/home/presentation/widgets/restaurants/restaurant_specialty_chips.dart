// lib/features/restaurants/widgets/cuisine_chips.dart
import 'package:flutter/material.dart';
import 'package:waka_fit/core/theme/app_colors.dart';

class CuisineChips extends StatefulWidget {
  final List<String> cuisines;
  final ValueChanged<int> onCuisineSelected;
  final int initialIndex;

  const CuisineChips({
    super.key,
    required this.cuisines,
    required this.onCuisineSelected,
    this.initialIndex = 0,
  });

  @override
  State<CuisineChips> createState() => _CuisineChipsState();
}

class _CuisineChipsState extends State<CuisineChips> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          widget.cuisines.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 20 : 8,
              right: index == widget.cuisines.length - 1 ? 20 : 0,
            ),
            child: ChoiceChip(
              label: Text(
                widget.cuisines[index],
                style: TextStyle(
                  color: _selectedIndex == index
                      ? Colors.white
                      : AppColors.wakaTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: _selectedIndex == index,
              selectedColor: AppColors.wakaBlue,
              backgroundColor: AppColors.wakaSurface,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  widget.onCuisineSelected(index);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}