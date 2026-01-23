// lib/features/navigation/main_navigation.dart
import 'package:flutter/material.dart';
import 'package:waka_fit/features/discover/presentation/discover_screen.dart';
import 'package:waka_fit/features/home/presentation/pages/home_screen.dart';
import 'package:waka_fit/features/home/presentation/widgets/bottom_navbar.dart';
import 'package:waka_fit/features/profile/profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _pages = [
    const HomeScreen(),
    const DiscoverScreen(),
    const DiscoverScreen(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove any app bar from here since each screen might have its own
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe between pages
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}