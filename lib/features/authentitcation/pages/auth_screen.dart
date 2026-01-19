// ignore_for_file: use_build_context_synchronously, unused_import, unused_element, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waka_fit/core/theme/text_extension.dart';
import 'package:waka_fit/features/authentitcation/pages/providers/auth_provider.dart';
import 'package:waka_fit/features/home/pages/home_screen.dart';
import 'package:waka_fit/shared/providers/theme_provider.dart';
import 'package:waka_fit/shared/providers/utils/secure_storage.dart';
import 'package:waka_fit/shared/widgets/state_widget.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialIsSignUp = false});

  final bool initialIsSignUp;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final green = const Color(0xFF17A34A);
  final _formKey = GlobalKey<FormState>();

  var logger = Logger();

  late bool isSignUp;
  bool _authListenerAttached = false;
  ViewState? _lastAuthState;
  bool agreeToTerms = false;
  bool _obscurePassword = true;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  Timer? _signInDotsTimer;
  bool _isSigningIn = false;
  int _signInDotCount = 0;
  String _signingInLabel = 'Signing in';

  @override
  void initState() {
    super.initState();
    isSignUp = widget.initialIsSignUp;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppAuthProvider>();
      _lastAuthState = provider.stateData.state;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_authListenerAttached) {
      _authListenerAttached = true;
      context.read<AppAuthProvider>().addListener(_authListener);
    }
  }

  @override
  void dispose() {
    if (_authListenerAttached) {
      context.read<AppAuthProvider>().removeListener(_authListener);
    }
    _signInDotsTimer?.cancel();
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  void _startSigningIn({String? label}) {
    if (!mounted) return;
    _signInDotsTimer?.cancel();
    setState(() {
      _isSigningIn = true;
      _signInDotCount = 0;
      if (label != null) _signingInLabel = label;
    });
    _signInDotsTimer =
        Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (!mounted || !_isSigningIn) return;
      setState(() {
        _signInDotCount = (_signInDotCount + 1) % 3;
      });
    });
  }

  void _stopSigningIn() {
    _signInDotsTimer?.cancel();
    if (!mounted) return;
    setState(() => _isSigningIn = false);
  }

  void _authListener() {
    if (!mounted) return;
    final provider = context.read<AppAuthProvider>();
    final nextState = provider.stateData.state;
    if (nextState == ViewState.error && _lastAuthState != ViewState.error) {
      final message = isSignUp
          ? 'Sign up failed. Please sign in again.'
          : 'Sign in failed. Please sign in again.';
      _notifySignInAgain(message);
    }
    _lastAuthState = nextState;
  }
Future<void> _handleGoogleLogin() async {
  if (_isSigningIn) return;
  _startSigningIn(label: 'Signing in with Google');

  try {
    final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

    // Sign in
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      logger.i('[GoogleLogin] User cancelled sign-in.');
      return;
    }

    final googleAuth = await googleUser.authentication;

    // Convert Google token to Firebase credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );



await context.read<AppAuthProvider>().signInWithCredential(credential);


  } catch (e, st) {
    logger.e("Google login failed", error: e, stackTrace: st);
    _notifySignInAgain("We couldn’t sign you in with Google. Please try again.");
  } finally {
    if (mounted) _stopSigningIn();
  }
}
  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      logger.w('Could not launch $url');
    }
  }

  bool _isStrongPassword(String value) {
    final regex =
        RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$');
    return regex.hasMatch(value);
  }

  void _notifySignInAgain(String msg) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Sign In',
          textColor: Colors.white,
          onPressed: () {
            if (!mounted) return;
            setState(() => isSignUp = false);
          },
        ),
      ),
    );
  }

  void _toastError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {

    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(context),
      body:  Consumer<AppAuthProvider>(
        builder: (context, value, child) =>
        AppStateWidget(
            stateData: value.stateData,
            child: Stack(
              children: [
                // Background with gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: themeProvider.isDarkMode
                          ? [
                              const Color(0xFF0F172A),
                              const Color(0xFF1E293B),
                              const Color(0xFF334155),
                            ]
                          : [
                              const Color(0xFFF0FDF4),
                              const Color(0xFFFFFFFF),
                              const Color(0xFFECFDF5),
                            ],
                    ),
                  ),
                ),
        
                Positioned(
                  top: -100,
                  left: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF10B981)
                              .withOpacity(themeProvider.isDarkMode ? 0.2 : 0.1),
                          const Color(0xFF10B981)
                              .withOpacity(themeProvider.isDarkMode ? 0.1 : 0.05),
                          Colors.transparent,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
        
                Positioned(
                  bottom: -80,
                  right: -80,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF059669).withOpacity(
                              themeProvider.isDarkMode ? 0.15 : 0.08),
                          const Color(0xFF059669).withOpacity(
                              themeProvider.isDarkMode ? 0.08 : 0.03),
                          Colors.transparent,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
        
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.3,
                  right: MediaQuery.of(context).size.width * 0.2,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF10B981).withOpacity(
                              themeProvider.isDarkMode ? 0.12 : 0.06),
                          const Color(0xFF10B981).withOpacity(
                              themeProvider.isDarkMode ? 0.06 : 0.02),
                          Colors.transparent,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
        
                SafeArea(
                  child: Stack(
                    children: [
                      Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 20),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                    height: 40), // Space for guest button
                               
                                const SizedBox(height: 24),
        
                                Text(
                                  'Welcome to Waka FIT',
                                  style: Theme.of(context)
                                      .textTheme
                                      .myTextStyle
                                      .copyWith(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF17A34A),
                                      ),
                                ),
        
                                const SizedBox(height: 8),
        
                                Text(
                                  'Lets help you get started',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .myTextStyle
                                      .copyWith(
                                        color: themeProvider
                                            .getSecondaryTextColor(context),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        height: 1.4,
                                      ),
                                ),
        
                                const SizedBox(height: 40),
        
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        themeProvider.getInputFillColor(context),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: themeProvider.isDarkMode
                                            ? Colors.black.withOpacity(0.3)
                                            : Colors.black.withOpacity(0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      _buildTabButton(
                                        "Sign In",
                                        !isSignUp,
                                        () => setState(() => isSignUp = false),
                                      ),
                                      _buildTabButton(
                                        "Create Account",
                                        isSignUp,
                                        () => setState(() => isSignUp = true),
                                      ),
                                    ],
                                  ),
                                ),
        
                                const SizedBox(height: 32),
        
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                     
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: _isSigningIn
                                                  ? null
                                                  : _handleGoogleLogin,
                                              icon: Image.asset(
                                                'assets/images/google.png',
                                                height: 24,
                                                width: 24,
                                              ),
                                              label: Text(
                                                "Google",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .myTextStyle
                                                    .copyWith(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                      color: themeProvider
                                                          .getTextColor(context),
                                                    ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16),
                                                backgroundColor: themeProvider
                                                    .getCardColor(context),
                                                side: BorderSide(
                                                    color: themeProvider
                                                        .getBorderColor(context)),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                          ),
                                         
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
      ),
        
      
    );
  }

  Widget _buildTabButton(String text, bool isActive, VoidCallback onTap) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF17A34A) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.myTextStyle.copyWith(
                  color: isActive
                      ? Colors.white
                      : themeProvider.getSecondaryTextColor(context),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 14,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label, {
    required TextEditingController controller,
    IconData? prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    String? emailValidator(String? value) {
      if (value == null || value.isEmpty) {
        return 'Please enter your $label';
      }
      // if (label.toLowerCase().contains('email')) {
      //   final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      //   if (!emailRegex.hasMatch(value.trim())) {
      //     return 'Please enter a valid email address';
      //   }
      // }
      return null;
    }

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.myTextStyle.copyWith(
            fontSize: 16,
            color: themeProvider.getTextColor(context),
          ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.myTextStyle.copyWith(
              color: themeProvider.getSecondaryTextColor(context),
              fontSize: 14,
            ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon,
                color: themeProvider.getSecondaryTextColor(context), size: 20)
            : null,
        filled: true,
        fillColor: themeProvider.getCardColor(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: themeProvider.getBorderColor(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: themeProvider.getBorderColor(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: emailValidator,
    );
  }

  Widget _buildSigningInIndicator(ThemeProvider themeProvider) {
    final dots = '.' * (_signInDotCount + 1);
    return AnimatedOpacity(
      opacity: _isSigningIn ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: themeProvider.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeProvider.getBorderColor(context)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation(themeProvider.getTextColor(context)),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$_signingInLabel$dots',
              style: Theme.of(context).textTheme.myTextStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.getTextColor(context),
                  ),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildPasswordField(
    String label, {
    required TextEditingController controller,
    IconData? prefixIcon,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return TextFormField(
      controller: controller,
      obscureText: _obscurePassword,
      style: Theme.of(context).textTheme.myTextStyle.copyWith(
            fontSize: 16,
            color: themeProvider.getTextColor(context),
          ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.myTextStyle.copyWith(
              color: themeProvider.getSecondaryTextColor(context),
              fontSize: 14,
            ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon,
                color: themeProvider.getSecondaryTextColor(context), size: 20)
            : null,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: themeProvider.getSecondaryTextColor(context),
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        filled: true,
        fillColor: themeProvider.getCardColor(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: themeProvider.getBorderColor(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: themeProvider.getBorderColor(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }
}
