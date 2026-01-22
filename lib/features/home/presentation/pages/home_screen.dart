// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
import 'package:waka_fit/features/home/presentation/widgets/bottom_navbar.dart';
import 'package:waka_fit/features/home/presentation/widgets/category_tabs.dart';
import 'package:waka_fit/features/home/presentation/widgets/coaches/coaches_screen.dart';
import 'package:waka_fit/features/home/presentation/widgets/fyp.dart';
import 'package:waka_fit/features/home/presentation/widgets/gyms/gym_screen.dart';
import 'package:waka_fit/features/home/presentation/widgets/post_card.dart';
import 'package:waka_fit/features/home/presentation/widgets/restaurants/restaurant_screen.dart';
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

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.wakaBackground,
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
              child: _buildContent(),
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



    Widget _buildContent() {
    switch (_currentCategoryIndex) {
      case 0: // For You
        return ForYouContent(
        );
      case 1: // Coaches
        return CoachesScreen(
        );
      case 2: // Coaches
        return GymScreen(
        );
      case 3:
        return RestaurantScreen(
        );
        

      default:
        return ForYouContent(
          
        );
    }
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