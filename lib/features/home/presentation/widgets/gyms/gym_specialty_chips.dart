import 'package:flutter/material.dart';
import 'package:waka_fit/core/theme/app_colors.dart';

class GymSpecialtyChips extends StatefulWidget {
  final List<String> specialties;
  final ValueChanged<int> onSpecialtySelected;
  final int initialIndex;

  const GymSpecialtyChips({
    Key? key,
    this.specialties = const ['All', 'Weight Loss', 'Bodybuilding', 'CrossFit ', 'Yoga'],
    required this.onSpecialtySelected,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<GymSpecialtyChips> createState() => _GymSpecialtyChipsState();
}

class _GymSpecialtyChipsState extends State<GymSpecialtyChips> {
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
          widget.specialties.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 20 : 8,
              right: index == widget.specialties.length - 1 ? 20 : 0,
            ),
            child: ChoiceChip(
              label: Text(
                widget.specialties[index],
                style: TextStyle(
                  color: _selectedIndex == index
                      ? AppColors.wakaBackground
                      : AppColors.wakaTextSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              selected: _selectedIndex == index,
              selectedColor: AppColors.wakaGreen,
              backgroundColor: AppColors.wakaField,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  widget.onSpecialtySelected(index);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}