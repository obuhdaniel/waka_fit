// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
import 'package:waka_fit/features/home/presentation/widgets/bottom_navbar.dart';
import 'package:waka_fit/features/home/presentation/widgets/category_tabs.dart';
import 'package:waka_fit/features/home/presentation/widgets/post_card.dart';
import 'package:waka_fit/features/home/presentation/widgets/top_bar.dart';
import 'package:waka_fit/features/home/presentation/widgets/trending_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentCategoryIndex = 0;
  int _currentBottomNavIndex = 0;
  String _location = 'Brooklyn, NY';

  final List<TrendingCard> _trendingItems = [
    TrendingCard(
      title: 'Transform Your Core',
      subtitle: 'Coach',
      imageUrl: 'https://picsum.photos/200/300?random=1',
      type: 'coach',
      followers: '12K followers',
      gradientStart: AppColors.primary,
      gradientEnd: AppColors.primary,
    ),
    TrendingCard(
      title: 'Elite Performance',
      subtitle: 'Gym',
      imageUrl: 'https://picsum.photos/200/300?random=2',
      type: 'gym',
      gradientStart: const Color(0xFF8338EC),
      gradientEnd: const Color(0xFF3A86FF),
    ),
    TrendingCard(
      title: 'Mindful Movement',
      subtitle: 'Yoga Studio',
      imageUrl: 'https://picsum.photos/200/300?random=3',
      type: 'coach',
      followers: '8.5K followers',
      gradientStart: const Color(0xFFFF006E),
      gradientEnd: const Color(0xFFFB5607),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Top Bar
          TopBar(
            location: _location,
            onLocationTap: _changeLocation,
            onNotificationTap: _showNotifications,
          ),
          
          // Category Tabs
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: CategoryTabs(
              onCategoryChanged: (index) {
                setState(() {
                  _currentCategoryIndex = index;
                });
              },
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Trending Section
                  TrendingSection(
                    title: 'Trending This Week',
                    items: _trendingItems,
                    onSeeAll: _seeAllTrending,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Posts Feed
                  _buildPostsFeed(),
                  
                  const SizedBox(height: 80), // Space for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom Navigation
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
          // Handle navigation to different screens
          _handleBottomNavTap(index);
        },
      ),
    );
  }

  Widget _buildPostsFeed() {
    return Column(
      children: [
        PostCard(
          userName: 'Sarah Chen',
          userTitle: 'Certified Trainer · Nutrition Expert',
          userImageUrl: 'https://picsum.photos/200/300?random=4',
          postTitle: '5 Exercises for Core Strength',
          postDescription:
              'Build a strong core with these essential exercises that target all areas of your abdominal muscles.',
          postImageUrl: 'https://picsum.photos/400/300?random=5',
          likes: 1200,
          comments: 89,
          shares: 234,
          onTap: _viewFullPost,
          onLike: _likePost,
          onSave: _savePost,
        ),
        PostCard(
          userName: 'Mike Johnson',
          userTitle: 'Strength Coach · 10+ years experience',
          userImageUrl: 'https://picsum.photos/200/300?random=6',
          postTitle: 'Nutrition Tips for Muscle Growth',
          postDescription:
              'Learn how to optimize your diet for maximum muscle growth and recovery.',
          postImageUrl: 'https://picsum.photos/400/300?random=7',
          likes: 850,
          comments: 42,
          shares: 156,
          onTap: _viewFullPost,
          onLike: _likePost,
          onSave: _savePost,
        ),
      ],
    );
  }

  // Action Methods
  void _changeLocation() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Change Location',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              ...['New York, NY', 'Los Angeles, CA', 'Chicago, IL', 'Miami, FL']
                  .map((city) => ListTile(
                        title: Text(city),
                        onTap: () {
                          setState(() {
                            _location = city;
                          });
                          Navigator.pop(context);
                        },
                      ))
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  void _showNotifications() {
    // Implement notifications screen
  }

  void _seeAllTrending() {
    // Navigate to trending screen
  }

  void _viewFullPost() {
    // Navigate to post detail screen
  }

  void _likePost() {
    // Handle like action
  }

  void _savePost() {
    // Handle save action
  }

  void _handleBottomNavTap(int index) {
    // Handle navigation to different screens
    switch (index) {
      case 1:
        // Navigate to Discover
        break;
      case 2:
        // Navigate to Saved
        break;
      case 3:
        // Navigate to Profile
        break;
    }
  }
}