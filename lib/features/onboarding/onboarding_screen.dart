// lib/features/onboarding/screens/onboarding_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:waka_fit/features/authentitcation/pages/auth_screen.dart';
import 'package:waka_fit/shared/providers/onboarding_provider.dart'; // Add lottie: ^latest_version to pubspec.yaml

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Color?> _gradientAnimation;

  int _currentPage = 0;
  bool _isLastPage = false;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Waka Fit',
      subtitle: 'Your personal fitness companion for tracking workouts, setting goals, and achieving results.',
      lottieAsset: 'assets/lottie/fitness_welcome.json',
      backgroundColor: Color(0xFF667EEA),
      nextColor: Color(0xFF764BA2),
    ),
    OnboardingPage(
      title: 'Track Your Progress',
      subtitle: 'Monitor your fitness journey with detailed analytics and progress tracking.',
      lottieAsset: 'assets/lottie/workout_tracking.json',
      backgroundColor: Color(0xFFF093FB),
      nextColor: Color(0xFFF5576C),
    ),
    OnboardingPage(
      title: 'Set Smart Goals',
      subtitle: 'Create personalized fitness goals and get AI-powered recommendations.',
      lottieAsset: 'assets/lottie/goal_setting.json',
      backgroundColor: Color(0xFF4FACFE),
      nextColor: Color(0xFF00F2FE),
    ),
    OnboardingPage(
      title: 'Join Community',
      subtitle: 'Connect with fitness enthusiasts and share your journey.',
      lottieAsset: 'assets/lottie/community.json',
      backgroundColor: Color(0xFF43E97B),
      nextColor: Color(0xFF38F9D7),
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _pageController = PageController(initialPage: 0);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _gradientAnimation = ColorTween(
      begin: _pages[0].backgroundColor,
      end: _pages[0].nextColor,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _animationController.forward();
    });
    
    // Listen to page changes
    _pageController.addListener(() {
      final page = _pageController.page ?? 0;
      setState(() {
        _currentPage = page.round();
        _isLastPage = _currentPage == _pages.length - 1;
      });
      
      // Update gradient animation
      _gradientAnimation = ColorTween(
        begin: _pages[_currentPage].backgroundColor,
        end: _pages[_currentPage].nextColor,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ),
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
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
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const AuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _gradientAnimation.value!,
                  _pages[_currentPage].backgroundColor.withOpacity(0.9),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Background particles
                if (_currentPage == 0)
                  Positioned.fill(
                    child: _buildParticles(),
                  ),
                
                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      // Skip button
                      if (!_isLastPage)
                        Padding(
                          padding: const EdgeInsets.only(top: 20, right: 20),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Material(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  onTap: _completeOnboarding,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      'Skip',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _pages.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                              _isLastPage = index == _pages.length - 1;
                            });
                            _animationController.reset();
                            _animationController.forward();
                          },
                          itemBuilder: (context, index) {
                            return _buildPage(_pages[index]);
                          },
                        ),
                      ),
                      
                      // Bottom navigation
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            // Page indicators
                            _buildPageIndicators(),
                            
                            const SizedBox(height: 40),
                            
                            // Next/Get Started button
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: _buildActionButton(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie animation
          SlideTransition(
            position: _slideAnimation,
            child: SizedBox(
              height: 300,
              child: Lottie.asset(
                page.lottieAsset,
                animate: true,
                repeat: true,
                reverse: true,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Title
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              page.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Subtitle
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              page.subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentPage ? 30 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentPage
                ? Colors.white
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
            boxShadow: index == _currentPage
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: _nextPage,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLastPage ? 'Get Started' : 'Continue',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _pages[_currentPage].backgroundColor,
                ),
              ),
              if (!_isLastPage)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: _pages[_currentPage].backgroundColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticles() {
    return CustomPaint(
      painter: ParticlePainter(
        particleCount: 50,
        animationValue: _animationController.value,
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String lottieAsset;
  final Color backgroundColor;
  final Color nextColor;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.lottieAsset,
    required this.backgroundColor,
    required this.nextColor,
  });
}

class ParticlePainter extends CustomPainter {
  final int particleCount;
  final double animationValue;

  ParticlePainter({
    required this.particleCount,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < particleCount; i++) {
      final x = (size.width * 0.8 * animationValue * i / particleCount) +
          size.width * 0.1;
      final y = size.height * 0.5 +
          sin(animationValue * 2 * 3.14 + i * 0.5) * size.height * 0.2;

      final radius = 2 + sin(animationValue * 2 * 3.14 + i * 0.3) * 1.5;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}