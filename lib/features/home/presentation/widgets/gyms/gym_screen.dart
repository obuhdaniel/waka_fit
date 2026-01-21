// lib/features/gyms/screens/gym_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
import 'package:waka_fit/features/home/presentation/models/gym_model.dart';
import 'package:waka_fit/features/home/presentation/widgets/gyms/gym_card.dart';
import 'package:waka_fit/features/home/presentation/widgets/gyms/gym_detail_screen.dart';
import 'package:waka_fit/features/home/presentation/widgets/gyms/gym_filter_sheet.dart';
import 'package:waka_fit/features/home/presentation/widgets/gyms/gym_search_bar.dart';
import 'package:waka_fit/features/home/presentation/widgets/gyms/gym_specialty_chips.dart';

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
  final List<GymModel> _gyms = [];
  List<GymModel> _filteredGyms = [];
  int _selectedSpecialtyIndex = 0;
  String _searchQuery = '';
  GymSortOption _currentSort = GymSortOption.relevance;
  double _minRating = 4.0;
  double _maxDistance = 10.0;
  double _maxPrice = 200.0;

  @override
  void initState() {
    super.initState();
    _loadGyms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadGyms() {
    // Mock gym data
    _gyms.addAll([
      GymModel(
        id: '1',
        name: 'PowerHouse Fitness',
        address: '245 Atlantic Avenue, Brooklyn, NY 11201',
        distance: 0.8,
        rating: 4.7,
        reviewCount: 189,
        type: 'Premium Gym • 24/7 Access',
        price: 89,
        imageUrl: 'https://picsum.photos/200/300?random=1',
        amenities: [
          'Strength Equipment',
          'Cardio Machines',
          'Group Classes',
          'Pool',
          'Sauna',
          'Parking',
          'Locker Rooms',
          'Personal Training',
        ],
        isOpen: true,
        hours: '5:00 AM - 10:00 PM',
        phone: '(347) 555-1234',
        website: 'powerhousefitness.com',
        specialtyTags: ['Strength', 'Cardio', '24/7', 'Premium'],
      ),
      GymModel(
        id: '2',
        name: 'CrossFit Central',
        address: '123 Main Street, Brooklyn, NY 11201',
        distance: 1.2,
        rating: 4.9,
        reviewCount: 245,
        type: 'CrossFit Box • Community',
        price: 120,
        imageUrl: 'https://picsum.photos/200/300?random=2',
        amenities: [
          'CrossFit Equipment',
          'Coaching',
          'Community Events',
          'Weightlifting',
        ],
        isOpen: true,
        hours: '6:00 AM - 9:00 PM',
        phone: '(347) 555-5678',
        website: 'crossfitcentral.com',
        specialtyTags: ['CrossFit', 'Strength', 'Community', 'Coaching'],
      ),
      GymModel(
        id: '3',
        name: 'Yoga Harmony Studio',
        address: '789 Park Avenue, Brooklyn, NY 11201',
        distance: 2.5,
        rating: 4.8,
        reviewCount: 156,
        type: 'Yoga & Meditation • Holistic',
        price: 75,
        imageUrl: 'https://picsum.photos/200/300?random=3',
        amenities: [
          'Yoga Mats',
          'Meditation Room',
          'Hot Yoga',
          'Sound Healing',
          'Workshops',
        ],
        isOpen: true,
        hours: '7:00 AM - 8:00 PM',
        phone: '(347) 555-9012',
        website: 'yogaharmony.com',
        specialtyTags: ['Yoga', 'Meditation', 'Holistic', 'Wellness'],
      ),
      GymModel(
        id: '4',
        name: 'Elite Performance',
        address: '456 Fitness Way, Brooklyn, NY 11201',
        distance: 0.5,
        rating: 4.6,
        reviewCount: 98,
        type: 'Performance Training • Sports',
        price: 150,
        imageUrl: 'https://picsum.photos/200/300?random=4',
        amenities: [
          'Sports Training',
          'Recovery Equipment',
          'Physical Therapy',
          'Nutrition Counseling',
          'Biomechanics',
        ],
        isOpen: true,
        hours: '24/7',
        phone: '(347) 555-3456',
        website: 'eliteperformance.com',
        specialtyTags: ['Performance', 'Sports', 'Recovery', 'Training'],
      ),
      GymModel(
        id: '5',
        name: 'Urban Fit Club',
        address: '321 City Center, Brooklyn, NY 11201',
        distance: 1.8,
        rating: 4.4,
        reviewCount: 187,
        type: 'All-in-One • Modern',
        price: 65,
        imageUrl: 'https://picsum.photos/200/300?random=5',
        amenities: [
          'Full Equipment',
          'Group Classes',
          'Cardio Cinema',
          'Cafe',
          'Kids Zone',
        ],
        isOpen: true,
        hours: '5:00 AM - 11:00 PM',
        phone: '(347) 555-7890',
        website: 'urbanfitclub.com',
        specialtyTags: ['Modern', 'All-in-One', 'Family', 'Classes'],
      ),
      GymModel(
        id: '6',
        name: 'Iron Temple',
        address: '987 Strong Street, Brooklyn, NY 11201',
        distance: 3.2,
        rating: 4.9,
        reviewCount: 312,
        type: 'Bodybuilding • Powerlifting',
        price: 95,
        imageUrl: 'https://picsum.photos/200/300?random=6',
        amenities: [
          'Power Racks',
          'Free Weights',
          'Strongman Equipment',
          'Bodybuilding',
          'Competition Prep',
        ],
        isOpen: true,
        hours: '24/7',
        phone: '(347) 555-2345',
        website: 'irontemple.com',
        specialtyTags: ['Strength', 'Bodybuilding', 'Powerlifting', '24/7'],
      ),
    ]);

    _filterGyms();
  }

  void _filterGyms() {
    List<GymModel> filtered = List.from(_gyms);

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

    setState(() {
      _filteredGyms = filtered;
    });
  }

  List<String> _getSpecialtyList() {
    return [
      'All',
      '24/7',
      'Strength',
      'Cardio',
      'Yoga',
      'CrossFit',
      'Premium',
      'Budget',
      'Family',
      'Community',
    ];
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
            _filterGyms();
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

  void _toggleSave(int index) {
    setState(() {
      _filteredGyms[index].isSaved = !_filteredGyms[index].isSaved;
      // Update original list too
      final originalIndex =
          _gyms.indexWhere((gym) => gym.id == _filteredGyms[index].id);
      if (originalIndex != -1) {
        _gyms[originalIndex].isSaved = _filteredGyms[index].isSaved;
      }
    });
  }

  int _getResponsiveCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1200) return 4; // Large desktop
    if (width >= 900) return 3; // Desktop/tablet landscape
    if (width >= 600) return 1; // Tablet portrait
    return 1; // Mobile
  }

  double _getResponsiveAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = _getResponsiveCrossAxisCount(context);

    // Calculate card width accounting for padding and spacing
    final totalHorizontalPadding = 32.0; // 16 * 2
    final totalSpacing = 12.0 * (crossAxisCount - 1);
    final cardWidth = (width - totalHorizontalPadding - totalSpacing) / crossAxisCount;

    // Desired card height for GymCard
    final desiredCardHeight = cardWidth * 1.8;

    return cardWidth / desiredCardHeight;
  }

 @override
Widget build(BuildContext context) {
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
          _filterGyms();
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
            _filterGyms();
          },
          initialIndex: _selectedSpecialtyIndex,
        ),
      ),

      const SizedBox(height: 8),

      // Results count
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          '${_filteredGyms.length} gyms found',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ),

      const SizedBox(height: 8),

      // Gyms Grid
      if (_filteredGyms.isEmpty)
        _buildEmptyState()
      else
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: _filteredGyms.length,
          shrinkWrap: true, // ✅ KEY
          physics: const NeverScrollableScrollPhysics(), // ✅ KEY
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getResponsiveCrossAxisCount(context),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.6,
          ),
          itemBuilder: (context, index) {
            final gym = _filteredGyms[index];
            return GymCard(
              name: gym.name,
              type: gym.type,
              rating: gym.rating.toStringAsFixed(1),
              distance: '${gym.distance} mi',
              price: '\$${gym.price.toInt()}/mo',
              amenities: gym.amenities.take(3).toList(),
              imageUrl: gym.imageUrl,
              onTap: () => _navigateToGymDetail(gym),
              onSave: () => _toggleSave(index),
            );
          },
        ),
    ],
  );
}
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 80,
            color: AppColors.wakaBlue.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'No gyms found',
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
              _filterGyms();
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
      ),
    );
  }
}