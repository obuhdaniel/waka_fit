// lib/features/restaurants/screens/restaurant_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
import 'package:waka_fit/features/home/data/models/restaurant_model.dart';
import 'package:waka_fit/features/home/presentation/widgets/restaurants/restaurant_card.dart';
import 'package:waka_fit/features/home/presentation/widgets/restaurants/restaurant_detail_screen.dart';
import 'package:waka_fit/features/home/presentation/widgets/restaurants/restaurant_filter_sheet.dart';
import 'package:waka_fit/features/home/presentation/widgets/restaurants/restaurant_search_bar.dart';
import 'package:waka_fit/features/home/presentation/widgets/restaurants/restaurant_specialty_chips.dart';
import 'package:waka_fit/features/home/providers/restaurants_provider.dart';

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
    // Initialize provider data
    _loadRestaurants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurants() async {
    // Access the provider using context (must be called after initState)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<RestaurantProvider>(context, listen: false);
      await provider.fetchAllRestaurants();
      // Initial filter after data is loaded
      _filterRestaurants(provider.restaurants);
    });
  }

  void _filterRestaurants(List<RestaurantModel> allRestaurants) {
    List<RestaurantModel> filtered = List.from(allRestaurants);

    return setState(() {
      _filteredRestaurants = filtered;
    });
    // // Apply search filter
    // if (_searchQuery.isNotEmpty) {
    //   filtered = filtered.where((restaurant) {
    //     return restaurant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
    //         restaurant.cuisine.toLowerCase().contains(_searchQuery.toLowerCase()) ||
    //         restaurant.specialtyTags.any(
    //             (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
    //   }).toList();
    // }

    // // Apply cuisine filter (skip "All")
    // if (_selectedCuisineIndex > 0) {
    //   final cuisine = _getCuisineList()[_selectedCuisineIndex];
    //   filtered = filtered.where((restaurant) {
    //     return restaurant.specialtyTags.any(
    //         (tag) => tag.toLowerCase().contains(cuisine.toLowerCase()));
    //   }).toList();
    // }

    // // Apply dietary filters
    // if (_selectedDietary.isNotEmpty) {
    //   filtered = filtered.where((restaurant) {
    //     return restaurant.dietaryTags.any((tag) => _selectedDietary.contains(tag));
    //   }).toList();
    // }

    // // Apply rating filter
    // filtered = filtered.where((restaurant) => restaurant.rating >= _minRating).toList();

    // // Apply distance filter
    // filtered = filtered.where((restaurant) => restaurant.distance <= _maxDistance).toList();

    // // Apply price filter
    // filtered = filtered.where((restaurant) => restaurant.price <= _maxPrice).toList();

    // // Apply sorting
    // filtered.sort((a, b) {
    //   switch (_currentSort) {
    //     case RestaurantSortOption.rating:
    //       return b.rating.compareTo(a.rating);
    //     case RestaurantSortOption.distance:
    //       return a.distance.compareTo(b.distance);
    //     case RestaurantSortOption.price:
    //       return a.price.compareTo(b.price);
    //     case RestaurantSortOption.relevance:
    //     default:
    //       return 0;
    //   }
    // });

    // setState(() {
    //   _filteredRestaurants = filtered;
    // });
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
            final provider = Provider.of<RestaurantProvider>(context, listen: false);
            _filterRestaurants(provider.restaurants);
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
          restaurantId: restaurant.id,
        ),
      ),
    );
  }

  void _toggleSave(int index) {
    setState(() {
      _filteredRestaurants[index].isSaved = !_filteredRestaurants[index].isSaved;
      // Update in provider as well
      final provider = Provider.of<RestaurantProvider>(context, listen: false);
      final originalIndex = provider.restaurants
          .indexWhere((r) => r.id == _filteredRestaurants[index].id);
      if (originalIndex != -1) {
        provider.restaurants[originalIndex].isSaved = _filteredRestaurants[index].isSaved;
      }
    });
  }

  int _getResponsiveCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 3;
    if (width >= 900) return 2;
    if (width >= 600) return 1;
    return 1;
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
    return Consumer<RestaurantProvider>(
      builder: (context, provider, child) {
        // Filter restaurants when provider data changes
        if (_filteredRestaurants.isEmpty && provider.restaurants.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _filterRestaurants(provider.restaurants);
          });
        }

        // Show loading state
        if (provider.isLoading && provider.restaurants.isEmpty) {
          return _buildLoadingState();
        }

        // Show error state
        if (provider.error != null && provider.restaurants.isEmpty) {
          return _buildErrorState(provider.error!, provider);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            RestaurantSearchBar(
              controller: _searchController,
              onSearch: (query) {
                setState(() {
                  _searchQuery = query;
                });
                _filterRestaurants(provider.restaurants);
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
                  _filterRestaurants(provider.restaurants);
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

            // Restaurants Grid / Empty State
            if (_filteredRestaurants.isEmpty && !provider.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: _buildEmptyState(provider),
              )
            else if (provider.isLoading && provider.restaurants.isEmpty)
              _buildLoadingState()
            else
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _filteredRestaurants.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.wakaBlue,
            ),
            const SizedBox(height: 20),
            Text(
              'Loading restaurants...',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, RestaurantProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.wakaBlue.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              'Error loading restaurants',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => provider.fetchAllRestaurants(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.wakaBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(RestaurantProvider provider) {
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
            provider.restaurants.isEmpty ? 'No restaurants available' : 'No restaurants found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.restaurants.isEmpty
                ? 'Check back later or try refreshing'
                : 'Try adjusting your filters or search terms',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (provider.restaurants.isEmpty) {
                provider.fetchAllRestaurants();
              } else {
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
                _filterRestaurants(provider.restaurants);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.wakaBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(provider.restaurants.isEmpty ? 'Refresh' : 'Clear All Filters'),
          ),
        ],
      ),
    );
  }
}