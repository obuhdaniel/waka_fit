import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
import 'package:waka_fit/features/authentitcation/pages/auth_screen.dart';
import 'package:waka_fit/features/home/presentation/pages/main_navigation.dart';
import 'package:waka_fit/features/onboarding/personalization_screen.dart';
import 'package:waka_fit/shared/helpers/preferences_manager.dart';
import 'package:waka_fit/shared/providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;
  late AnimationController _bubblesController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _loadingRotation;
  late Animation<double> _bubblesAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _validateSessionAndNavigate();
  }

  void _initializeAnimations() {
    // Logo animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInCubic),
    );

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInCubic),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    // Loading animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _loadingRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.linear),
    );

    // Bubbles animation
    _bubblesController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _bubblesAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bubblesController, curve: Curves.easeInOutSine),
    );

    // Pulse animation (for app name)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 1.1),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.1, end: 1.0),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
        );
  }

  void _startAnimations() {
    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      _loadingController.repeat();
      _pulseController.repeat(reverse: true);
    });

    _bubblesController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    _bubblesController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _validateSessionAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2)); // splash delay

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // User is not logged in
      _goToAuth();
      return;
    }

    // User exists -> sync with UserProvider
    final provider = Provider.of<UserProvider>(context, listen: false);

    provider.setUser(
      name: user.displayName ?? "",
      username: user.email?.split('@').first ?? "",
      profileImageUrl: user.photoURL ?? "",
    );

    _goToHome();
  }

  void _goToAuth() {
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  Future<void> _goToHome() async {
    final prefsManager = PreferencesManager();
    final isSetupCompleted = await prefsManager.isSetupCompleted();

    if (context.mounted && isSetupCompleted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else if (context.mounted && !isSetupCompleted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PersonalizationSetupScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.wakaBackground,
              const Color.fromARGB(255, 35, 55, 2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: AnimatedBuilder(
                  animation: _bubblesAnimation,
                  builder: (context, child) =>
                      _FitnessBubbles(animation: _bubblesAnimation),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Fitness-inspired animated logo
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScale.value,
                            child: Opacity(
                              opacity: _logoOpacity.value,
                              child: const _FitnessLogo(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // App name with pulse animation
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Text(
                              "WAKA FIT",
                              style: GoogleFonts.inter(
                                fontSize: isTablet ? 42 : 32,
                                fontWeight: FontWeight.w900,
                                color: AppColors.wakaTextPrimary,
                                letterSpacing: 2.0,
                                height: 1.1,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Animated tagline
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _textSlide,
                            child: Opacity(
                              opacity: _textOpacity.value,
                              child: Column(
                                children: [
                                  Text(
                                    "Your Fitness Journey Starts Here",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: isTablet ? 20 : 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.wakaTextPrimary,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                    ),
                                    child: Text(
                                      "Connect with coaches, gyms, and healthy restaurants for a holistic wellness experience",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: isTablet ? 16 : 14,
                                        color: AppColors.wakaTextSecondary,
                                        fontWeight: FontWeight.w400,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Fitness-themed loading animation
                      AnimatedBuilder(
                        animation: _loadingController,
                        builder: (context, child) {
                          return _FitnessLoadingIndicator(
                            animation: _loadingRotation,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    Text(
                      "© 2026 Waka Fit - All rights reserved",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.wakaTextSecondary.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FitnessLogo extends StatelessWidget {
  const _FitnessLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.wakaSurface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.wakaTextPrimary.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.wakaTextSecondary.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Background gradient circle
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.wakaTextPrimary.withOpacity(0.1),
                  AppColors.wakaSurface,
                ],
              ),
            ),
          ),

          // Fitness icon with gradient
          Center(
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  AppColors.wakaTextPrimary,
                  AppColors.wakaTextSecondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Image.asset(
                'assets/images/logo.png',
                height: 128,
                width: 128,
              ),
            ),
          ),

          // Animated ring
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.wakaTextPrimary.withOpacity(0.3),
                width: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FitnessBubbles extends StatelessWidget {
  final Animation<double> animation;

  const _FitnessBubbles({required this.animation});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: Stack(
        children: [
          // Main bubble (blue)
          Positioned(
            top: 20 + (animation.value * 15),
            right: 40 + (animation.value * 8),
            child: Transform.rotate(
              angle: animation.value * 0.5,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.wakaBlue.withOpacity(0.8),
                      AppColors.wakaBlue.withOpacity(0.3),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.wakaBlue.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Green bubble
          Positioned(
            top: 50 - (animation.value * 10),
            left: 30 + (animation.value * 5),
            child: Transform.rotate(
              angle: -animation.value * 0.3,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.wakaGreen.withOpacity(0.8),
                      AppColors.wakaGreen.withOpacity(0.3),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.wakaGreen.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Purple bubble
          Positioned(
            top: 15 + (animation.value * 20),
            left: 120 - (animation.value * 10),
            child: Transform.rotate(
              angle: animation.value * 0.4,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.wakaTextSecondary.withOpacity(0.8),
                      AppColors.wakaTextSecondary.withOpacity(0.3),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.wakaTextPrimary.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Small orange bubble
          Positioned(
            bottom: 30 + (animation.value * 5),
            right: 100 - (animation.value * 15),
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.wakaBlue.withOpacity(0.7),
                    AppColors.wakaBlue.withOpacity(0.2),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.wakaBlue.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FitnessLoadingIndicator extends StatelessWidget {
  final Animation<double> animation;

  const _FitnessLoadingIndicator({required this.animation});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            children: [
              // Outer rotating ring
              Transform.rotate(
                angle: animation.value * 2 * 3.14159,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.wakaBlue.withOpacity(0.2),
                      width: 4,
                    ),
                  ),
                ),
              ),

              // Inner rotating ring
              Transform.rotate(
                angle: -animation.value * 2 * 3.14159,
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.wakaGreen.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                ),
              ),

              // Center fitness icon
              Center(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.wakaTextPrimary,
                        AppColors.wakaTextSecondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.wakaTextPrimary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.directions_run,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),

              // Animated progress arc
              Transform.rotate(
                angle: -animation.value * 2 * 3.14159,
                child: CustomPaint(
                  size: const Size(60, 60),
                  painter: _FitnessArcPainter(animation.value),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Loading text with dots animation
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final dots = ('.' * ((animation.value * 3).floor() + 1)).padRight(
              3,
            );
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Preparing your fitness experience',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.wakaTextSecondary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  dots,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.wakaTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _FitnessArcPainter extends CustomPainter {
  final double progress;

  _FitnessArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Primary arc
    final primaryPaint = Paint()
      ..shader =
          LinearGradient(
            colors: [AppColors.wakaTextPrimary, AppColors.wakaTextSecondary],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width / 2, size.height / 2),
              radius: size.width / 2 - 4,
            ),
          )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Secondary arc
    final secondaryPaint = Paint()
      ..shader =
          LinearGradient(
            colors: [AppColors.wakaBlue, AppColors.wakaGreen],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width / 2, size.height / 2),
              radius: size.width / 2 - 8,
            ),
          )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Draw primary arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      progress * 2 * 3.14159,
      false,
      primaryPaint,
    );

    // Draw secondary arc (rotated opposite direction)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -3.14159 / 2,
      -progress * 2 * 3.14159 * 0.8,
      false,
      secondaryPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
