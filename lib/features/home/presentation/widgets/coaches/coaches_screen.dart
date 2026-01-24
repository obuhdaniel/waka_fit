// lib/features/coaches/screens/coaches_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
import 'package:waka_fit/features/home/data/models/coach_model.dart';
import 'package:waka_fit/features/home/presentation/widgets/coaches/coach_card.dart';
import 'package:waka_fit/features/home/presentation/widgets/coaches/coach_details_screen.dart';
import 'package:waka_fit/features/home/presentation/widgets/coaches/coach_stats_summary.dart';
import 'package:waka_fit/features/home/presentation/widgets/coaches/coaches_search_bar.dart';
import 'package:waka_fit/features/home/presentation/widgets/coaches/sort_filter_sheet.dart';
import 'package:waka_fit/features/home/presentation/widgets/coaches/specialty_chips.dart';
import 'package:waka_fit/features/home/providers/coach_provider.dart';

class CoachesScreen extends StatefulWidget {
  const CoachesScreen({Key? key}) : super(key: key);

  @override
  State<CoachesScreen> createState() => _CoachesScreenState();
}

class _CoachesScreenState extends State<CoachesScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedSpecialtyIndex = 0;
  String _searchQuery = '';
  SortOption _currentSort = SortOption.relevance;
  double _minRating = 4.0;
  double _maxDistance = 10.0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    final provider = Provider.of<CoachProvider>(context, listen: false);
    if (provider.coaches.isEmpty) {
      await provider.fetchAllCoaches();
    }
  }

  void _navigateToCoachDetail(CoachData coach) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoachDetailScreen(coach: coach),
      ),
    );
  }

  void _filterCoaches(List<CoachData> allCoaches, List<CoachData> filteredCoaches) {
    List<CoachData> filtered = List.from(allCoaches);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((coach) {
        return coach.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            coach.specialties.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            coach.specialtyTags.any(
              (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()),
            );
      }).toList();
    }

    // Apply specialty filter (skip "All")
    if (_selectedSpecialtyIndex > 0) {
      final specialty = _getSpecialtyList()[_selectedSpecialtyIndex];
      filtered = filtered.where((coach) {
        return coach.specialtyTags.any(
          (tag) => tag.toLowerCase().contains(specialty.toLowerCase()),
        );
      }).toList();
    }

    // Apply rating filter
    filtered = filtered.where((coach) => coach.rating >= _minRating).toList();

    // Apply distance filter
    filtered = filtered
        .where((coach) => coach.distance <= _maxDistance)
        .toList();

    // Apply sorting
    filtered.sort((a, b) {
      switch (_currentSort) {
        case SortOption.rating:
          return b.rating.compareTo(a.rating);
        case SortOption.followers:
          final aFollowers = _parseFollowers(a.followers);
          final bFollowers = _parseFollowers(b.followers);
          return bFollowers.compareTo(aFollowers);
        case SortOption.experience:
          return b.experience.compareTo(a.experience);
        case SortOption.relevance:
        default:
          return 0; // Keep original order for relevance
      }
    });

    // Update filtered list
    filteredCoaches.clear();
    filteredCoaches.addAll(filtered);
  }

  double _parseFollowers(String followers) {
    final clean = followers.replaceAll('K', '').replaceAll('M', '');
    final value = double.tryParse(clean) ?? 0;
    if (followers.contains('K')) return value * 1000;
    if (followers.contains('M')) return value * 1000000;
    return value;
  }

  List<String> _getSpecialtyList() {
    return ['All', 'Strength', 'Cardio', 'Yoga', 'Nutrition', 'Meditation'];
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SortFilterSheet(
          initialSort: _currentSort,
          initialMinRating: _minRating,
          initialMaxDistance: _maxDistance,
          onApply: (filters) {
            setState(() {
              _currentSort = filters['sort'];
              _minRating = filters['minRating'];
              _maxDistance = filters['maxDistance'];
            });
          },
        );
      },
    );
  }

  Future<void> _toggleFollow(CoachData coach, CoachProvider provider) async {
    await provider.toggleFollowCoach(coach.id);
  }

  int _getResponsiveCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= 1200) return 4;      // Large desktop
    if (width >= 900) return 3;       // Desktop/tablet landscape
    if (width >= 600) return 2;       // Tablet portrait
    return 2;                          // Mobile
  }

  double _getResponsiveAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = _getResponsiveCrossAxisCount(context);
    
    // Calculate card width accounting for padding and spacing
    final totalHorizontalPadding = 32.0; // 16 * 2
    final totalSpacing = 12.0 * (crossAxisCount - 1);
    final cardWidth = (width - totalHorizontalPadding - totalSpacing) / crossAxisCount;
    
    // Desired card height (adjust this value based on your CoachCard design)
    final desiredCardHeight = cardWidth * 2.4;
    
    return cardWidth / desiredCardHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoachProvider>(
      builder: (context, provider, child) {
        // Apply filters to get the displayed coaches
        List<CoachData> displayedCoaches = [];
        _filterCoaches(provider.coaches, displayedCoaches);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CoachesSearchBar(
              controller: _searchController,
              onSearch: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              onFilterTap: _showFilterSheet,
            ),

            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.wakaSurface,
                border: Border.symmetric(
                  horizontal: BorderSide(color: AppColors.wakaStroke, width: 2),
                ),
              ),
              child: SpecialtyChips(
                specialties: _getSpecialtyList(),
                onSpecialtySelected: (index) {
                  setState(() {
                    _selectedSpecialtyIndex = index;
                  });
                },
                initialIndex: _selectedSpecialtyIndex,
              ),
            ),

            const SizedBox(height: 16),

            // Loading state
            if (provider.isLoading && displayedCoaches.isEmpty)
              _buildLoadingState()
            // Error state
            else if (provider.error != null && displayedCoaches.isEmpty)
              _buildErrorState(provider.error!, provider)
            // Empty state
            else if (displayedCoaches.isEmpty)
              _buildEmptyState()
            // Data state
            else
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: displayedCoaches.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getResponsiveCrossAxisCount(context),
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: _getResponsiveAspectRatio(context),
                ),
                itemBuilder: (context, index) {
                  final coach = displayedCoaches[index];
                  return CoachCard(
                    name: coach.name,
                    specialties: coach.specialties,
                    followers: coach.followers,
                    rating: coach.rating,
                    posts: coach.posts,
                    plans: coach.plans,
                    imageUrl: coach.imageUrl,
                    isFollowing: coach.isFollowing,
                    onFollowTap: () => _toggleFollow(coach, provider),
                    onCoachTap: () => _navigateToCoachDetail(coach),
                  );
                },
              )
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 20),
          Text(
            'Loading coaches...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, CoachProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: 20),
          Text(
            'Failed to load coaches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              provider.clearError();
              _initializeData();
            },
            child: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: AppColors.textTertiary),
          const SizedBox(height: 20),
          Text(
            'No coaches found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            style: TextStyle(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}