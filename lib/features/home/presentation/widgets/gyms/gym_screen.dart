// lib/features/gyms/screens/gym_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
import 'package:waka_fit/features/home/data/models/gym_model.dart';
import 'package:waka_fit/features/home/presentation/widgets/gyms/gym_card.dart';
import 'package:waka_fit/features/home/presentation/widgets/gyms/gym_detail_screen.dart';
import 'package:waka_fit/features/home/presentation/widgets/gyms/gym_filter_sheet.dart';
import 'package:waka_fit/features/home/presentation/widgets/gyms/gym_search_bar.dart';
import 'package:waka_fit/features/home/presentation/widgets/gyms/gym_specialty_chips.dart';
import 'package:waka_fit/features/home/providers/gym_providers.dart';

enum GymSortOption {
  relevance,
  rating,
  distance,
  price,
}

class GymScreen extends StatefulWidget {
  const GymScreen({Key? key}) : super(key: key);

  @override
  State<GymScreen> createState() => _GymScreenState();
}

class _GymScreenState extends State<GymScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedSpecialtyIndex = 0;
  String _searchQuery = '';
  GymSortOption _currentSort = GymSortOption.relevance;
  double _minRating = 4.0;
  double _maxDistance = 10.0;
  double _maxPrice = 200.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGyms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGyms() async {
    final provider = Provider.of<GymProvider>(context, listen: false);
    await provider.fetchAllGyms();
  }

  Future<void> _refreshGyms() async {
    await _loadGyms();
  }

  List<String> _getSpecialtyList() {
    return [
      'All',
      'Weight Loss',
      'Bodybuilding',
      'Cardio',
      'Yoga',
      'CrossFit',
      'Premium',
      'Budget',
      'Family',
      'Community',
    ];
  }

  List<GymModel> _filterGyms(List<GymModel> allGyms) {
    List<GymModel> filtered = List.from(allGyms);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((gym) {
        return gym.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            gym.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            gym.specialtyTags.any(
                (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Apply specialty filter (skip "All")
    if (_selectedSpecialtyIndex > 0) {
      final specialty = _getSpecialtyList()[_selectedSpecialtyIndex];
      filtered = filtered.where((gym) {
        return gym.specialtyTags.any(
            (tag) => tag.toLowerCase().contains(specialty.toLowerCase()));
      }).toList();
    }

    // Apply rating filter
    filtered = filtered.where((gym) => gym.rating >= _minRating).toList();

    // Apply distance filter
    filtered = filtered.where((gym) => gym.distance <= _maxDistance).toList();

    // Apply price filter
    filtered = filtered.where((gym) => gym.price <= _maxPrice).toList();

    // Apply sorting
    filtered.sort((a, b) {
      switch (_currentSort) {
        case GymSortOption.rating:
          return b.rating.compareTo(a.rating);
        case GymSortOption.distance:
          return a.distance.compareTo(b.distance);
        case GymSortOption.price:
          return a.price.compareTo(b.price);
        case GymSortOption.relevance:
        default:
          return 0; // Keep original order for relevance
      }
    });

    return filtered;
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GymFilterSheet(
          initialSort: _currentSort,
          initialMinRating: _minRating,
          initialMaxDistance: _maxDistance,
          initialMaxPrice: _maxPrice,
          onApply: (filters) {
            setState(() {
              _currentSort = filters['sort'];
              _minRating = filters['minRating'];
              _maxDistance = filters['maxDistance'];
              _maxPrice = filters['maxPrice'];
            });
          },
        );
      },
    );
  }

  void _navigateToGymDetail(GymModel gym) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GymDetailScreen(gym: gym.toGymDetail()),
      ),
    );
  }

  Future<void> _toggleSave(GymModel gym, GymProvider provider) async {
    try {
      await provider.toggleSaveGym(gym.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update saved status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _getResponsiveCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1200) return 4; // Large desktop
    if (width >= 900) return 3; // Desktop/tablet landscape
    if (width >= 600) return 1; // Tablet portrait
    return 1; // Mobile
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GymProvider>(
      builder: (context, provider, child) {
        final filteredGyms = _filterGyms(provider.gyms);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            GymsSearchBar(
              controller: _searchController,
              onSearch: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              onFilterTap: _showFilterSheet,
            ),

            // Specialty Chips
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.wakaSurface,
                border: Border.symmetric(
                  horizontal: BorderSide(color: AppColors.wakaStroke, width: 2),
                ),
              ),
              child: GymSpecialtyChips(
                specialties: _getSpecialtyList(),
                onSpecialtySelected: (index) {
                  setState(() {
                    _selectedSpecialtyIndex = index;
                  });
                },
                initialIndex: _selectedSpecialtyIndex,
              ),
            ),

            const SizedBox(height: 8),

            // Results count and loading/error states
            _buildStatusSection(provider, filteredGyms),

            const SizedBox(height: 8),

            // Gyms Grid
            _buildGymsGrid(provider, filteredGyms),
          ],
        );
      },
    );
  }
Widget _buildStatusSection(GymProvider provider, List<GymModel> filteredGyms) {
  // 1. Loading State: Use a smoother transition or themed indicator
  if (provider.isLoading && provider.gyms.isEmpty) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: SizedBox(
          height: 2,
          child: LinearProgressIndicator(
            backgroundColor: AppColors.wakaSurface,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.wakaBlue),
          ),
        ),
      ),
    );
  }

  // 2. Error State: Added an icon and better visual grouping
  if (provider.error != null && provider.gyms.isEmpty) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 28),
          const SizedBox(height: 8),
          Text(
            'Ops! Failed to load gyms',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          Text(
            provider.error.toString(), // Brief error detail
            style: GoogleFonts.inter(fontSize: 12, color: Colors.red[300]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _refreshGyms,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try Again'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.wakaBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Success State: Adding a "Badge" feel to the results count
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Nearby Gyms',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.wakaBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${filteredGyms.length}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.wakaBlue,
                ),
              ),
            ),
          ],
        ),
        if (provider.isLoading) // Small spinner if refreshing in background
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    ),
  );
}
  Widget _buildGymsGrid(GymProvider provider, List<GymModel> filteredGyms) {
    if (filteredGyms.isEmpty && !provider.isLoading && provider.error == null) {
      return _buildEmptyState(provider);
    }

    return RefreshIndicator(
      onRefresh: _refreshGyms,
      backgroundColor: AppColors.wakaBackground,
      color: AppColors.wakaBlue,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: filteredGyms.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getResponsiveCrossAxisCount(context),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.6,
        ),
        itemBuilder: (context, index) {
          final gym = filteredGyms[index];
          return GymCard(
            name: gym.name,
            type: gym.type,
            rating: gym.rating.toStringAsFixed(1),
            distance: '${gym.distance} mi',
            price: '\$${gym.price.toInt()}/mo',
            amenities: gym.amenities.take(3).toList(),
            imageUrl: gym.imageUrl,
            onTap: () => _navigateToGymDetail(gym),
            onSave: () => _toggleSave(gym, provider),
            isSaved: gym.isSaved,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(GymProvider provider) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 48),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // 🔑 don't try to fill height
        children: [
          if (provider.gyms.isEmpty && !provider.isLoading)
            _buildNoGymsState()
          else
            _buildNoResultsState(),
        ],
      ),
    ),
  );
}


  Widget _buildNoGymsState() {
    return Column(
      children: [
        Icon(
          Icons.fitness_center_outlined,
          size: 80,
          color: AppColors.wakaBlue.withOpacity(0.5),
        ),
        const SizedBox(height: 20),
        Text(
          'No gyms available',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Be the first to add a gym in your area!',
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // TODO: Navigate to create gym screen
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.wakaBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Add Your Gym'),
        ),
      ],
    );
  }

  Widget _buildNoResultsState() {
    return Column(
      children: [
        Icon(
          Icons.search_off_outlined,
          size: 80,
          color: AppColors.wakaBlue.withOpacity(0.5),
        ),
        const SizedBox(height: 20),
        Text(
          'No matching gyms found',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Try adjusting your filters or search terms',
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Clear filters
            setState(() {
              _selectedSpecialtyIndex = 0;
              _searchQuery = '';
              _searchController.clear();
              _minRating = 4.0;
              _maxDistance = 10.0;
              _maxPrice = 200.0;
              _currentSort = GymSortOption.relevance;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.wakaBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Clear All Filters'),
        ),
      ],
    );
  }
}