// lib/features/coaches/components/coaches_search_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
import 'package:waka_fit/shared/helpers/preferences_manager.dart';

class GymsSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final VoidCallback onFilterTap;

  const GymsSearchBar({
    Key? key,
    required this.controller,
    required this.onSearch,
    required this.onFilterTap,
  }) : super(key: key);

  @override
  State<GymsSearchBar> createState() => _GymsSearchBarState();
}

class _GymsSearchBarState extends State<GymsSearchBar> {

  String _location = 'Loading location...';

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final prefs = PreferencesManager();
    final location = await prefs.getLocation();

    if (!mounted) return;
    setState(() {
      _location = _formatLocation(location);
    });
  }
    String _formatLocation(String raw) {
    if (raw == 'current_location') return 'Near you';
    return raw;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.wakaSurface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gyms Near You',
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
              Icon(
                Icons.location_on,
                size: 14,
                color: AppColors.wakaTextSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                _location,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.wakaTextSecondary,
                ),
              ),
            ],
          ),


       ],
      ),
    );
  }
}