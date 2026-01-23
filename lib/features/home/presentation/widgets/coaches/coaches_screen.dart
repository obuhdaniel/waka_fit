// lib/features/coaches/screens/coaches_screen.dart
import 'package:flutter/material.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
import 'package:waka_fit/features/home/models/coach_model.dart';
import 'package:waka_fit/features/home/presentation/widgets/coaches/coach_card.dart';
import 'package:waka_fit/features/home/presentation/widgets/coaches/coach_stats_summary.dart';
import 'package:waka_fit/features/home/presentation/widgets/coaches/coaches_search_bar.dart';
import 'package:waka_fit/features/home/presentation/widgets/coaches/sort_filter_sheet.dart';
import 'package:waka_fit/features/home/presentation/widgets/coaches/specialty_chips.dart';

class CoachesScreen extends StatefulWidget {
  const CoachesScreen({Key? key}) : super(key: key);

  @override
  State<CoachesScreen> createState() => _CoachesScreenState();
}

class _CoachesScreenState extends State<CoachesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<CoachData> _coaches = [];
  List<CoachData> _filteredCoaches = [];
  int _selectedSpecialtyIndex = 0;
  String _searchQuery = '';
  SortOption _currentSort = SortOption.relevance;
  double _minRating = 4.0;
  double _maxDistance = 10.0;

  @override
  void initState() {
    super.initState();
    _loadCoaches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCoaches() {
    // Mock data - replace with API call
    _coaches.addAll([
      CoachData(
        name: 'Sarah Chen',
        specialties: 'HIIT • NUTRITION',
        followers: '8.5K',
        rating: 4.9,
        posts: 120,
        plans: 45,
        imageUrl: 'https://picsum.photos/200/300?random=1',
        isFollowing: false,
        distance: 2.5,
        experience: 5,
        specialtyTags: ['HIIT', 'Nutrition', 'Cardio'],
      ),
      CoachData(
        name: 'Marcus Thompson',
        specialties: 'STRENGTH • SPORTS',
        followers: '12.3K',
        rating: 4.8,
        posts: 215,
        plans: 67,
        imageUrl: 'https://picsum.photos/200/300?random=2',
        isFollowing: true,
        distance: 3.2,
        experience: 8,
        specialtyTags: ['Strength', 'Sports', 'Weightlifting'],
      ),
      CoachData(
        name: 'Alex Johnson',
        specialties: 'YOGA • MEDITATION',
        followers: '6.2K',
        rating: 4.7,
        posts: 89,
        plans: 32,
        imageUrl: 'https://picsum.photos/200/300?random=3',
        isFollowing: false,
        distance: 1.8,
        experience: 4,
        specialtyTags: ['Yoga', 'Meditation', 'Flexibility'],
      ),
      CoachData(
        name: 'Maria Garcia',
        specialties: 'NUTRITION • WEIGHT LOSS',
        followers: '9.8K',
        rating: 4.9,
        posts: 156,
        plans: 52,
        imageUrl: 'https://picsum.photos/200/300?random=4',
        isFollowing: false,
        distance: 5.1,
        experience: 6,
        specialtyTags: ['Nutrition', 'Weight Loss', 'Diet'],
      ),
    ]);

    _filterCoaches();
  }

  void _filterCoaches() {
    List<CoachData> filtered = List.from(_coaches);

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

    setState(() {
      _filteredCoaches = filtered;
    });
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
            _filterCoaches();
          },
        );
      },
    );
  }

  void _toggleFollow(int index) {
    setState(() {
      _filteredCoaches[index].isFollowing =
          !_filteredCoaches[index].isFollowing;
      // Update original list too
      final originalIndex = _coaches.indexWhere(
        (coach) => coach.name == _filteredCoaches[index].name,
      );
      if (originalIndex != -1) {
        _coaches[originalIndex].isFollowing =
            _filteredCoaches[index].isFollowing;
      }
    });
  }

  void _navigateToCoachDetail(int index) {
    // Navigate to coach detail screen
    final coach = _filteredCoaches[index];
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (context) => CoachDetailScreen(coach: coach),
    // ));
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CoachesSearchBar(
          controller: _searchController,
          onSearch: (query) {
            setState(() {
              _searchQuery = query;
            });
            _filterCoaches();
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
              _filterCoaches();
            },
            initialIndex: _selectedSpecialtyIndex,
          ),
        ),

        const SizedBox(height: 16),

        if (_filteredCoaches.isEmpty)
          _buildEmptyState()
        else
      GridView.builder(
  padding: const EdgeInsets.symmetric(horizontal: 4),
  itemCount: _filteredCoaches.length,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: _getResponsiveCrossAxisCount(context),
    crossAxisSpacing: 2,
    mainAxisSpacing: 2,
    childAspectRatio: _getResponsiveAspectRatio(context),
  ),
  itemBuilder: (context, index) {
    final coach = _filteredCoaches[index];
    return CoachCard(
      name: coach.name,
      specialties: coach.specialties,
      followers: coach.followers,
      rating: coach.rating,
      posts: coach.posts,
      plans: coach.plans,
      imageUrl: coach.imageUrl,
      isFollowing: coach.isFollowing,
      onFollowTap: () => _toggleFollow(index),
      onCoachTap: () => _navigateToCoachDetail(index),
    );
  },
) ]);
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
