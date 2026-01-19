// lib/features/onboarding/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:waka_fit/features/authentitcation/pages/auth_screen.dart';
import 'package:waka_fit/shared/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Expert Coaches',
      'subtitle': 'Access personalized training plans and guidance from certified professionals.',
    },
    {
      'title': 'Local Gyms',
      'subtitle': 'Discover gyms near you with facilities that match your fitness needs.',
    },
    {
      'title': 'Healthy Eats',
      'subtitle': 'Find restaurants offering nutritious meals that support your fitness goals.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    final onboardingProvider =
        Provider.of<OnboardingProvider>(context, listen: false);
    onboardingProvider.completeOnboarding();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 16, 16, 16),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (_currentPage < _pages.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

            // Main content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Bottom section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentPage
                              ? Colors.blue
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 0, 212, 255),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Continue',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, String> page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
            ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Color.fromARGB(255, 53, 225, 196), Color.fromARGB(255, 125, 242, 117)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'Waka Fit',
              style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              ),
            ),
            ),

          const SizedBox(height: 7),

          // Subtitle
          const Text(
            'YOUR FITNESS JOURNEY',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 50),

          // Feature icon (you can replace with actual icons or images)
            Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[50],
            ),
            child: Image.asset(
              _getIconForPage(_currentPage),
              width: double.infinity,
              height: 60,
            ),
            ),
          const SizedBox(height: 40),

          // Feature title
          Text(
            page['title']!,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          // Feature description
          Text(
            page['subtitle']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getIconForPage(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return 'assets/images/onboarding/coach.png'; // Coaches
      case 1:
        return 'assets/images/onboarding/gym.png'; // Gyms
      case 2:
        return 'assets/images/onboarding/food.png'; // Healthy eats
      default:
        return 'assets/images/onboarding/food.png';
    }
  }
}