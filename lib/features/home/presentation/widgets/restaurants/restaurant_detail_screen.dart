// lib/features/restaurants/screens/restaurant_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
import 'package:waka_fit/features/home/data/models/restaurant_model.dart';
import 'package:waka_fit/features/home/providers/restaurants_provider.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;  // Only accept ID

  const RestaurantDetailScreen({
    Key? key,
    required this.restaurantId,
  }) : super(key: key);

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  bool _isFavorited = false;
  int _selectedMenuCategory = 0;

  @override
  void initState() {
    super.initState();
    _loadRestaurantDetails();
  }

  Future<void> _loadRestaurantDetails() async {
    final provider = context.read<RestaurantProvider>();
    
    // Check if we already have this restaurant loaded
    if (provider.selectedRestaurant?.id == widget.restaurantId) {
      _isFavorited = provider.selectedRestaurant!.isSaved;
      return;
    }
    
    try {
      debugPrint('🔄 Loading restaurant details for ID: ${widget.restaurantId}');
      await provider.fetchRestaurantByID(widget.restaurantId);
      
      // After loading, set favorite status
      if (mounted && provider.selectedRestaurant != null) {
        setState(() {
          _isFavorited = provider.selectedRestaurant!.isSaved;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading restaurant: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load restaurant details'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _launchDirections(String address) async {
    final String encodedAddress = Uri.encodeComponent(address);
    final Uri uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open maps'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not make call'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _launchOrderOnline(String orderLink) async {
    final Uri uri = Uri.parse(orderLink);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open ordering page'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _toggleFavorite(RestaurantModel restaurant) {
    final provider = context.read<RestaurantProvider>();
    
    setState(() {
      _isFavorited = !_isFavorited;
    });
    
    // You might want to update the restaurant in provider here
    // provider.toggleFavorite(restaurant.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorited ? 'Added to favorites' : 'Removed from favorites'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, child) {
        final restaurant = provider.selectedRestaurant;
        
        // Show loading if no restaurant or wrong restaurant
        if (restaurant == null || restaurant.id != widget.restaurantId) {
          if (provider.isLoading) {
            return _buildLoadingScreen();
          } else {
            return _buildErrorScreen(provider.error);
          }
        }
        
        return _buildContent(restaurant, provider);
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.wakaBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.wakaBlue),
            SizedBox(height: 20),
            Text(
              'Loading restaurant details...',
              style: GoogleFonts.inter(
                color: AppColors.wakaTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String? error) {
    return Scaffold(
      backgroundColor: AppColors.wakaBackground,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              SizedBox(height: 20),
              Text(
                'Failed to load restaurant',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
              SizedBox(height: 10),
              Text(
                error ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppColors.wakaTextSecondary,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadRestaurantDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.wakaBlue,
                ),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(RestaurantModel restaurant, RestaurantProvider provider) {
    return Scaffold(
      backgroundColor: AppColors.wakaBackground,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(restaurant),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickActions(restaurant),
                _buildInfoCards(restaurant),
                _buildCuisineTags(restaurant),
                _buildMenuHighlights(restaurant),
                _buildMenuItems(restaurant),
                _buildAboutSection(restaurant),
                SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(restaurant),
    );
  }

  Widget _buildSliverAppBar(RestaurantModel restaurant) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.wakaBackground,
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.wakaSurface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.wakaTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              restaurant.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey.shade400),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    restaurant.cuisine,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.wakaSurface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.share_outlined, color: AppColors.wakaTextPrimary),
            onPressed: () {
              // Share functionality
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.wakaSurface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              _isFavorited ? Icons.bookmark : Icons.bookmark_border,
              color: _isFavorited ? AppColors.wakaGreen : AppColors.wakaTextPrimary,
            ),
            onPressed: () => _toggleFavorite(restaurant),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(RestaurantModel restaurant) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Address and directions
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.wakaBlue, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            restaurant.address,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.wakaTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _launchDirections(restaurant.address),
                      child: Row(
                        children: [
                          Icon(Icons.directions, color: AppColors.wakaBlue, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Get Directions',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.wakaBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Distance and hours
          Row(
            children: [
              _StatusChip(
                icon: Icons.location_on,
                label: restaurant.distance.toString(),
                value: 'from you',
                color: AppColors.wakaBlue,
              ),
              SizedBox(width: 16),
              _StatusChip(
                icon: Icons.access_time,
                label: restaurant.isOpen ? 'Open' : 'Closed',
                value: restaurant.hours,
                color: restaurant.isOpen ? AppColors.wakaGreen : AppColors.error,
              ),
            ],
          ),
          SizedBox(height: 16),

          // Rating
          GestureDetector(
            onTap: () {
              // Navigate to reviews
            },
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text(
                  '${restaurant.rating}',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  '(${restaurant.reviewCount} reviews)',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.wakaTextSecondary,
                  ),
                ),
                Spacer(),
                Text(
                  'See Reviews',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.wakaBlue,
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: AppColors.wakaBlue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards(RestaurantModel restaurant) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.wakaField,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.wakaTextSecondary.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          _InfoCard(
            icon: Icons.phone,
            title: 'Call',
            value: restaurant.phone,
            onTap: () => _launchPhone(restaurant.phone),
          ),
          _InfoCard(
            icon: Icons.language,
            title: 'Website',
            value: restaurant.website,
            onTap: () => _launchUrl(restaurant.website),
          ),
          _InfoCard(
            icon: Icons.shopping_cart,
            title: 'Order Online',
            value: 'Ordering redirects to ${restaurant.name} website',
            onTap: () => _launchOrderOnline(restaurant.orderLink),
          ),
        ],
      ),
    );
  }

  Widget _buildCuisineTags(RestaurantModel restaurant) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: restaurant.dietaryTags.map((tag) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.wakaSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.wakaTextSecondary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getDietaryIcon(tag),
                  size: 14,
                  color: AppColors.wakaGreen,
                ),
                SizedBox(width: 6),
                Text(
                  tag,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.wakaTextPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuHighlights(RestaurantModel restaurant) {
    if (restaurant.menuCategories.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu Highlights',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.wakaTextPrimary,
            ),
          ),
          SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: restaurant.menuCategories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                return Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(
                      category.name,
                      style: GoogleFonts.inter(
                        color: _selectedMenuCategory == index 
                            ? Colors.white 
                            : AppColors.wakaTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: _selectedMenuCategory == index,
                    selectedColor: AppColors.wakaBlue,
                    backgroundColor: AppColors.wakaSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: _selectedMenuCategory == index
                            ? AppColors.wakaBlue
                            : AppColors.wakaTextSecondary.withOpacity(0.3),
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedMenuCategory = index;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(RestaurantModel restaurant) {
    if (restaurant.menuCategories.isEmpty) {
      return _buildEmptyState('No menu categories found');
    }

    int safeIndex = _selectedMenuCategory;
    if (safeIndex >= restaurant.menuCategories.length || safeIndex < 0) {
      safeIndex = 0; 
    }

    final category = restaurant.menuCategories[safeIndex];
    
    if (category.items.isEmpty) {
      return _buildEmptyState('No items available in ${category.name}');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: category.items.map((item) {
          final hasImage = item.menuImageUrl.isNotEmpty;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.wakaSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.wakaTextSecondary.withOpacity(0.2), 
                width: 1.5
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: hasImage
                  ? _buildCardWithImage(item)
                  : _buildCardWithoutImage(item),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.wakaTextSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCardWithImage(MenuItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Section
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            item.menuImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.wakaTextSecondary.withOpacity(0.1),
                child: Icon(
                  Icons.restaurant_menu,
                  size: 48,
                  color: AppColors.wakaTextSecondary.withOpacity(0.3),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: AppColors.wakaTextSecondary.withOpacity(0.1),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: AppColors.wakaBlue,
                    strokeWidth: 2,
                  ),
                ),
              );
            },
          ),
        ),
        // Content Section
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.wakaTextPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.wakaBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '\$${item.price}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.wakaBlue,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                item.description,
                style: GoogleFonts.inter(
                  color: AppColors.wakaTextSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              if (item.calories != null && item.calories! > 0) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department, 
                      size: 14, 
                      color: AppColors.wakaTextSecondary
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${item.calories} cal',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.wakaTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 12),
              Text(
                item.orderNote,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.wakaTextSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardWithoutImage(MenuItem item) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.wakaTextPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.wakaBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '\$${item.price}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.wakaBlue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            item.description,
            style: GoogleFonts.inter(
              color: AppColors.wakaTextSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (item.calories != null && item.calories! > 0) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.local_fire_department, 
                  size: 14, 
                  color: AppColors.wakaTextSecondary
                ),
                SizedBox(width: 4),
                Text(
                  '${item.calories} cal',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.wakaTextSecondary,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 12),
          Text(
            item.orderNote,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.wakaTextSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  } 

  Widget _buildAboutSection(RestaurantModel restaurant) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About ${restaurant.name}',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.wakaTextPrimary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            restaurant.about,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.5,
              color: AppColors.wakaTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(RestaurantModel restaurant) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.wakaSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _ActionIcon(
              icon: Icons.phone,
              label: 'Call',
              onTap: () => _launchPhone(restaurant.phone),
            ),
            const SizedBox(width: 12),
            _ActionIcon(
              icon: Icons.language,
              label: 'Website',
              onTap: () => _launchUrl(restaurant.website),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _launchOrderOnline(restaurant.orderLink),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.wakaBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Order Online',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDietaryIcon(String tag) {
    switch (tag.toLowerCase()) {
      case 'vegan':
        return Icons.eco;
      case 'vegetarian':
        return Icons.eco;
      case 'gluten-free':
        return Icons.circle;
      case 'dairy-free':
        return Icons.water_drop;
      case 'organic':
        return Icons.grass;
      case 'low-carb':
        return Icons.line_weight;
      default:
        return Icons.check;
    }
  }
}

// Component Widgets
class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.wakaSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.wakaTextSecondary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.wakaTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.wakaBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.wakaBlue, size: 20),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.wakaTextSecondary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.wakaTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.wakaTextSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.wakaBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.wakaBlue, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.wakaBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class MenuCategory {
  final String name;
  final List<MenuItem> items;

  MenuCategory({
    required this.name,
    required this.items,
  });

 factory MenuCategory.fromJson(Map<String, dynamic> json) {
  print('📂 Parsing MenuCategory: ${json['name']}');
  
  return MenuCategory(
    name: json['name']?.toString() ?? 'Uncategorized',
    items: (json['items'] as List? ?? [])
        .where((item) => item != null)
        .map((item) {
          try {
            return MenuItem.fromJson(item as Map<String, dynamic>);
          } catch (e) {
            print('❌ Error parsing menu item: $e');
            print('   Item data: $item');
            // Return a default item to avoid breaking the whole list
            return MenuItem(
              name: 'Error loading item',
              description: 'Could not load item details',
              price: 0.0,
              menuImageUrl: '',
            );
          }
        })
        .toList(),
  );
}
}

class MenuItem {
  final String name;
  final String description;
  final String menuImageUrl;
  final double price;
  final int? calories;
  final String orderNote;

  MenuItem({
    required this.name,
    required this.description,
    required this.price,
    required this.menuImageUrl,
    this.calories,
    this.orderNote = 'Ordering redirects to restaurant website',
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      calories: json['calories'] ?? 0,
      orderNote: json['orderNote'],
      menuImageUrl: json['menuImageUrl'] ?? '',
    );
  }
}