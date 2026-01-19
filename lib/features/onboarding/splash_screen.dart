import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:waka_fit/features/authentitcation/pages/auth_screen.dart';
import 'package:waka_fit/features/home/pages/home_screen.dart';
import 'package:waka_fit/features/profile/profile_page.dart';
import 'package:waka_fit/shared/providers/user_provider.dart';
import 'package:waka_fit/shared/providers/utils/secure_storage.dart';

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

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _loadingRotation;
  late Animation<double> _bubblesAnimation;

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
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Loading animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _loadingRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.linear),
    );

    // Bubbles animation
    _bubblesController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _bubblesAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bubblesController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 600), () {
      _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      _loadingController.repeat();
    });

    _bubblesController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    _bubblesController.dispose();
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

  void _goToHome() {
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFEFFCF1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(
                height: 100,
                child: AnimatedBuilder(
                  animation: _bubblesAnimation,
                  builder: (context, child) =>
                      _TopBubbles(animation: _bubblesAnimation),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated Logo
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScale.value,
                            child: Opacity(
                              opacity: _logoOpacity.value,
                              child: const _LogoBox(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Animated Text
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
                                    "Realtime Safety and Awareness Platform",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      fontSize: isTablet ? 34 : 20,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2D2D2D),
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Connecting People, Communities and Services when it matters most",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      fontSize: isTablet ? 18 : 16,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w400,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      // Enhanced Loading Animation
                      AnimatedBuilder(
                        animation: _loadingController,
                        builder: (context, child) {
                          return _CustomLoadingIndicator(
                            animation: _loadingRotation,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "Built by Nigerians for 🇳🇬",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                    Text(
                      "© 2026 Hospify - All rights reserved",
                      style: TextStyle(fontSize: 11, color: Colors.black38),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoBox extends StatelessWidget {
  const _LogoBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          const BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset('assets/images/hospify_logo.png', fit: BoxFit.cover),
      ),
    );
  }
}

class _TopBubbles extends StatelessWidget {
  final Animation<double> animation;

  const _TopBubbles({required this.animation});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: Stack(
        children: [
          // Main bubble
          Positioned(
            top: 20 + (animation.value * 10),
            right: 30 + (animation.value * 5),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.green.shade50,
                    Colors.green.shade100,
                    Colors.green.shade200,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),

          // Secondary bubble
          Positioned(
            top: 40 - (animation.value * 8),
            left: 20 + (animation.value * 3),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.green.shade50,
                    Colors.green.shade100,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),

          // Small accent bubble
          Positioned(
            top: 10 + (animation.value * 15),
            right: 120 - (animation.value * 7),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade50,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.05),
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

class _CustomLoadingIndicator extends StatelessWidget {
  final Animation<double> animation;

  const _CustomLoadingIndicator({required this.animation});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            children: [
              // Outer ring
              Transform.rotate(
                angle: animation.value * 2 * 3.14159,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green.shade100,
                      width: 3,
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              // Inner dot
              Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),

              // Animated arc
              Transform.rotate(
                angle: -animation.value * 2 * 3.14159,
                child: CustomPaint(
                  size: const Size(50, 50),
                  painter: _LoadingArcPainter(animation.value),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Loading text with animation
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final dots =
                ('.' * ((animation.value * 3).floor() + 1)).padRight(3);
            return Text(
              'Loading$dots',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LoadingArcPainter extends CustomPainter {
  final double progress;

  _LoadingArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      progress * 2 * 3.14159,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
