// lib/features/restaurants/screens/restaurant_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
import 'package:waka_fit/features/home/presentation/models/restaurant_model.dart';
import 'package:waka_fit/features/home/presentation/widgets/restaurants/restaurant_card.dart';
import 'package:waka_fit/features/home/presentation/widgets/restaurants/restaurant_detail_screen.dart';
import 'package:waka_fit/features/home/presentation/widgets/restaurants/restaurant_filter_sheet.dart';
import 'package:waka_fit/features/home/presentation/widgets/restaurants/restaurant_search_bar.dart';
import 'package:waka_fit/features/home/presentation/widgets/restaurants/restaurant_specialty_chips.dart';

enum RestaurantSortOption {
  relevance,
  rating,
  distance,
  price,
}

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<RestaurantModel> _restaurants = [];
  List<RestaurantModel> _filteredRestaurants = [];
  int _selectedCuisineIndex = 0;
  String _searchQuery = '';
  RestaurantSortOption _currentSort = RestaurantSortOption.relevance;
  double _minRating = 4.0;
  double _maxDistance = 10.0;
  double _maxPrice = 30.0;
  List<String> _selectedDietary = [];

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadRestaurants() {
    _restaurants.addAll([
      RestaurantModel(
        id: '1',
        name: 'FreshBowl',
        cuisine: 'Healthy Bowls • Smoothies',
        address: '423 Bedford Ave, Brooklyn, NY 11211',
        distance: 1.2,
        rating: 4.9,
        reviewCount: 312,
        price: 12.5,
        imageUrl: 'https://picsum.photos/200/300?random=21',
        dietaryTags: ['Vegan', 'Gluten-Free', 'Organic', 'Dairy-Free'],
        isOpen: true,
        hours: 'Open until 9 PM',
        phone: '(347) 555-1234',
        website: 'freshbowl.com',
        orderLink: 'https://freshbowl.com/order',
        specialtyTags: ['Bowls', 'Smoothies', 'Healthy', 'Vegan'],
      ),
      RestaurantModel(
        id: '2',
        name: 'Protein House',
        cuisine: 'High Protein • Fitness Meals',
        address: '789 Fitness Way, Brooklyn, NY 11201',
        distance: 0.8,
        rating: 4.8,
        reviewCount: 245,
        price: 16.0,
        imageUrl: 'https://picsum.photos/200/300?random=22',
        dietaryTags: ['High-Protein', 'Low-Carb', 'Gluten-Free'],
        isOpen: true,
        hours: 'Open until 10 PM',
        phone: '(347) 555-5678',
        website: 'proteinhouse.com',
        orderLink: 'https://proteinhouse.com/order',
        specialtyTags: ['Protein', 'Fitness', 'Low-Carb', 'Meal Prep'],
      ),
      RestaurantModel(
        id: '3',
        name: 'Green Leaf Cafe',
        cuisine: 'Salads • Wraps • Vegan',
        address: '123 Green Street, Brooklyn, NY 11211',
        distance: 1.5,
        rating: 4.7,
        reviewCount: 189,
        price: 10.5,
        imageUrl: 'https://picsum.photos/200/300?random=23',
        dietaryTags: ['Vegan', 'Vegetarian', 'Organic', 'Gluten-Free'],
        isOpen: true,
        hours: 'Open until 8 PM',
        phone: '(347) 555-9012',
        website: 'greenleafcafe.com',
        orderLink: 'https://greenleafcafe.com/order',
        specialtyTags: ['Salads', 'Vegan', 'Organic', 'Healthy'],
      ),
      RestaurantModel(
        id: '4',
        name: 'Smoothie Lab',
        cuisine: 'Smoothies • Juices • Bowls',
        address: '456 Wellness Ave, Brooklyn, NY 11201',
        distance: 2.1,
        rating: 4.9,
        reviewCount: 156,
        price: 9.0,
        imageUrl: 'https://picsum.photos/200/300?random=24',
        dietaryTags: ['Vegan', 'Gluten-Free', 'Dairy-Free', 'Organic'],
        isOpen: true,
        hours: 'Open until 7 PM',
        phone: '(347) 555-3456',
        website: 'smoothielab.com',
        orderLink: 'https://smoothielab.com/order',
        specialtyTags: ['Smoothies', 'Juices', 'Vegan', 'Detox'],
      ),
      RestaurantModel(
        id: '5',
        name: 'Fit Kitchen',
        cuisine: 'Meal Prep • Healthy Entrees',
        address: '321 Health Street, Brooklyn, NY 11201',
        distance: 1.8,
        rating: 4.6,
        reviewCount: 278,
        price: 14.0,
        imageUrl: 'https://picsum.photos/200/300?random=25',
        dietaryTags: ['High-Protein', 'Low-Carb', 'Gluten-Free'],
        isOpen: true,
        hours: 'Open until 9 PM',
        phone: '(347) 555-7890',
        website: 'fitkitchen.com',
        orderLink: 'https://fitkitchen.com/order',
        specialtyTags: ['Meal Prep', 'Healthy', 'Protein', 'Clean Eating'],
      ),
      RestaurantModel(
        id: '6',
        name: 'Superfood Bar',
        cuisine: 'Acai Bowls • Smoothies • Toasts',
        address: '654 Berry Lane, Brooklyn, NY 11211',
        distance: 2.5,
        rating: 4.8,
        reviewCount: 145,
        price: 11.0,
        imageUrl: 'https://picsum.photos/200/300?random=26',
        dietaryTags: ['Vegan', 'Gluten-Free', 'Dairy-Free', 'Superfoods'],
        isOpen: true,
        hours: 'Open until 8 PM',
        phone: '(347) 555-2345',
        website: 'superfoodbar.com',
        orderLink: 'https://superfoodbar.com/order',
        specialtyTags: ['Acai', 'Superfoods', 'Vegan', 'Healthy'],
      ),
    ]);

    _filterRestaurants();
  }

  void _filterRestaurants() {
    List<RestaurantModel> filtered = List.from(_restaurants);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((restaurant) {
        return restaurant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            restaurant.cuisine.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            restaurant.specialtyTags.any(
                (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Apply cuisine filter (skip "All")
    if (_selectedCuisineIndex > 0) {
      final cuisine = _getCuisineList()[_selectedCuisineIndex];
      filtered = filtered.where((restaurant) {
        return restaurant.specialtyTags.any(
            (tag) => tag.toLowerCase().contains(cuisine.toLowerCase()));
      }).toList();
    }

    // Apply dietary filters
    if (_selectedDietary.isNotEmpty) {
      filtered = filtered.where((restaurant) {
        return restaurant.dietaryTags.any((tag) => _selectedDietary.contains(tag));
      }).toList();
    }

    // Apply rating filter
    filtered = filtered.where((restaurant) => restaurant.rating >= _minRating).toList();

    // Apply distance filter
    filtered = filtered.where((restaurant) => restaurant.distance <= _maxDistance).toList();

    // Apply price filter
    filtered = filtered.where((restaurant) => restaurant.price <= _maxPrice).toList();

    // Apply sorting
    filtered.sort((a, b) {
      switch (_currentSort) {
        case RestaurantSortOption.rating:
          return b.rating.compareTo(a.rating);
        case RestaurantSortOption.distance:
          return a.distance.compareTo(b.distance);
        case RestaurantSortOption.price:
          return a.price.compareTo(b.price);
        case RestaurantSortOption.relevance:
        default:
          return 0;
      }
    });

    setState(() {
      _filteredRestaurants = filtered;
    });
  }

  List<String> _getCuisineList() {
    return [
      'All',
      'Healthy',
      'Vegan',
      'Protein',
      'Smoothies',
      'Bowls',
      'Salads',
      'Meal Prep',
      'Organic',
    ];
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return RestaurantFilterSheet(
          initialSort: _currentSort,
          initialMinRating: _minRating,
          initialMaxDistance: _maxDistance,
          initialMaxPrice: _maxPrice,
          initialDietary: _selectedDietary,
          onApply: (filters) {
            setState(() {
              _currentSort = filters['sort'];
              _minRating = filters['minRating'];
              _maxDistance = filters['maxDistance'];
              _maxPrice = filters['maxPrice'];
              _selectedDietary = filters['dietary'];
            });
            _filterRestaurants();
          },
        );
      },
    );
  }

  void _navigateToRestaurantDetail(RestaurantModel restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailScreen(
          restaurant: restaurant.toRestaurantDetail(),
        ),
      ),
    );
  }

  void _toggleSave(int index) {
    setState(() {
      _filteredRestaurants[index].isSaved = !_filteredRestaurants[index].isSaved;
      final originalIndex = _restaurants
          .indexWhere((r) => r.id == _filteredRestaurants[index].id);
      if (originalIndex != -1) {
        _restaurants[originalIndex].isSaved = _filteredRestaurants[index].isSaved;
      }
    });
  }

  int _getResponsiveCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 2;
  }

  double _getResponsiveAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = _getResponsiveCrossAxisCount(context);
    final totalHorizontalPadding = 32.0;
    final totalSpacing = 12.0 * (crossAxisCount - 1);
    final cardWidth = (width - totalHorizontalPadding - totalSpacing) / crossAxisCount;
    final desiredCardHeight = cardWidth * 1.8;
    return cardWidth / desiredCardHeight;
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          RestaurantSearchBar(
            controller: _searchController,
            onSearch: (query) {
              setState(() {
                _searchQuery = query;
              });
              _filterRestaurants();
            },
            onFilterTap: _showFilterSheet,
          ),

          // Cuisine Chips
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.wakaSurface,
              border: Border.symmetric(
                horizontal: BorderSide(color: AppColors.wakaStroke, width: 2),
              ),
            ),
            child: CuisineChips(
              cuisines: _getCuisineList(),
              onCuisineSelected: (index) {
                setState(() {
                  _selectedCuisineIndex = index;
                });
                _filterRestaurants();
              },
              initialIndex: _selectedCuisineIndex,
            ),
          ),

          const SizedBox(height: 8),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${_filteredRestaurants.length} restaurants found',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Restaurants Grid
          if (_filteredRestaurants.isEmpty)
            Expanded(
              child: _buildEmptyState(),
            )
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _filteredRestaurants.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getResponsiveCrossAxisCount(context),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: _getResponsiveAspectRatio(context),
                ),
                itemBuilder: (context, index) {
                  final restaurant = _filteredRestaurants[index];
                  return RestaurantCard(
                    name: restaurant.name,
                    cuisine: restaurant.cuisine,
                    rating: restaurant.rating.toStringAsFixed(1),
                    distance: '${restaurant.distance} mi',
                    price: '\$${restaurant.price.toStringAsFixed(2)}',
                    dietaryTags: restaurant.dietaryTags.take(2).toList(),
                    imageUrl: restaurant.imageUrl,
                    isOpen: restaurant.isOpen,
                    hours: restaurant.hours,
                    onTap: () => _navigateToRestaurantDetail(restaurant),
                    onSave: () => _toggleSave(index),
                  );
                },
              ),
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
            Icons.restaurant_outlined,
            size: 80,
            color: AppColors.wakaBlue.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'No restaurants found',
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
              setState(() {
                _selectedCuisineIndex = 0;
                _searchQuery = '';
                _searchController.clear();
                _minRating = 4.0;
                _maxDistance = 10.0;
                _maxPrice = 30.0;
                _selectedDietary = [];
                _currentSort = RestaurantSortOption.relevance;
              });
              _filterRestaurants();
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