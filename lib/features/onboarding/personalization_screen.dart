import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waka_fit/features/home/presentation/pages/home_screen.dart';

class PersonalizationSetupScreen extends StatefulWidget {
  const PersonalizationSetupScreen({Key? key}) : super(key: key);

  @override
  State<PersonalizationSetupScreen> createState() =>
      _PersonalizationSetupScreenState();
}

class _PersonalizationSetupScreenState
    extends State<PersonalizationSetupScreen> with TickerProviderStateMixin {
  // Color scheme
  static const Color accentColor = Color(0xFFB4FF39);
  static const Color backgroundColor = Colors.black;
  static const Color surfaceColor = Color(0xFF1A1A1A);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9E9E9E);

  late AnimationController _fadeController;
  late AnimationController _slideController;

  // User goals
  final List<Map<String, dynamic>> _goals = [
    {'id': 'lose_weight', 'text': 'Lose Weight', 'icon': '🔥', 'selected': false},
    {'id': 'build_muscle', 'text': 'Build Muscle', 'icon': '💪', 'selected': false},
    {'id': 'stay_active', 'text': 'Stay Active', 'icon': '⚡', 'selected': false},
    {'id': 'eat_healthier', 'text': 'Eat Healthier', 'icon': '🥗', 'selected': false},
  ];

  // Location options
  String _selectedLocation = 'Use Current Location';
  final TextEditingController _locationController = TextEditingController();
  final List<String> _suggestedLocations = [
    'Asaba',
    'Benin',
    'Lagos',
    'Abuja',
    'Port Harcourt',
    'Ibadan',
  ];

  // Interests
  final List<Map<String, dynamic>> _interests = [
    {'id': 'gyms', 'text': 'Gyms', 'icon': '🏋️', 'selected': false},
    {'id': 'coaches', 'text': 'Personal Coaches', 'icon': '👤', 'selected': false},
    {'id': 'yoga', 'text': 'Yoga Studios', 'icon': '🧘', 'selected': false},
    {'id': 'restaurants', 'text': 'Healthy Restaurants', 'icon': '🥙', 'selected': false},
    {'id': 'supplements', 'text': 'Supplement Stores', 'icon': '💊', 'selected': false},
    {'id': 'classes', 'text': 'Fitness Classes', 'icon': '🎯', 'selected': false},
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeController.forward();
    _slideController.forward();
    _loadSavedPreferences();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    for (var goal in _goals) {
      final saved = prefs.getBool('goal_${goal['id']}');
      if (saved != null) {
        goal['selected'] = saved;
      }
    }

    final savedLocation = prefs.getString('user_location');
    if (savedLocation != null && savedLocation.isNotEmpty) {
      _selectedLocation = savedLocation;
      _locationController.text = savedLocation;
    }

    for (var interest in _interests) {
      final saved = prefs.getBool('interest_${interest['id']}');
      if (saved != null) {
        interest['selected'] = saved;
      }
    }

    setState(() {});
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    for (var goal in _goals) {
      await prefs.setBool('goal_${goal['id']}', goal['selected'] as bool);
    }

    if (_selectedLocation.isNotEmpty && _selectedLocation != 'Use Current Location') {
      await prefs.setString('user_location', _selectedLocation);
    } else {
      await prefs.setString('user_location', 'current_location');
    }

    for (var interest in _interests) {
      await prefs.setBool('interest_${interest['id']}', interest['selected'] as bool);
    }

    await prefs.setBool('setup_completed', true);
    _navigateToMainApp();
  }

  void _navigateToMainApp() {
    Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _selectedLocation = 'Using Current Location...';
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _selectedLocation = 'Current Location (Approximate)';
      _locationController.clear();
    });
  }

  bool _isCompleteSetupEnabled() {
    final hasGoal = _goals.any((goal) => goal['selected'] as bool);
    final hasInterest = _interests.any((interest) => interest['selected'] as bool);
    return hasGoal && hasInterest;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title:  Text(
          'Personalize Your Experience',
          style: GoogleFonts.inter(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Goals Section
              _buildSectionTitle('What\'s your main goal?'),
              const SizedBox(height: 8),
              _buildSectionSubtitle('Select all that apply to help us tailor your experience'),
              const SizedBox(height: 24),
              _buildGoalsGrid(),

              const SizedBox(height: 16),

              // Location Section
              _buildSectionTitle('Find nearby options'),
              const SizedBox(height: 8),
              _buildSectionSubtitle('Discover local fitness spots'),
              const SizedBox(height: 24),
              _buildLocationInput(),
              const SizedBox(height: 16),
              _buildCurrentLocationButton(),
              const SizedBox(height: 24),
              _buildSuggestedLocations(),

              const SizedBox(height: 56),

              // Interests Section
              _buildSectionTitle('I\'m interested in...'),
              const SizedBox(height: 24),
              _buildInterestsGrid(),

              const SizedBox(height: 80),

              // Complete Setup Button
              _buildCompleteButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Step 1 of 1',
              style: TextStyle(
                fontSize: 13,
                color: textSecondary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: surfaceColor,
                valueColor: const AlwaysStoppedAnimation<Color>(accentColor),
                minHeight: 4,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style:  GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildSectionSubtitle(String subtitle) {
    return Text(
      subtitle,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: textSecondary,
        fontWeight: FontWeight.w400,
      ),
    );
  }

 Widget _buildGoalsGrid() {
  return GridView.count(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    crossAxisCount: 2,          // 2x2 grid
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    children: _goals.asMap().entries.map((entry) {
      final index = entry.key;
      final goal = entry.value;

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 300 + (index * 100)),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: _buildGoalChip(goal),
          );
        },
      );
    }).toList(),
  );
}
  Widget _buildGoalChip(Map<String, dynamic> goal) {
    final isSelected = goal['selected'] as bool;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: InkWell(
        onTap: () {
          setState(() {
            goal['selected'] = !isSelected;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? accentColor : surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? accentColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                goal['icon'],
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 8),
              Text(
                goal['text'],
                style: TextStyle(
                  color: isSelected ? backgroundColor : textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInput() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _locationController,
        style: const TextStyle(color: textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Enter city',
          hintStyle: TextStyle(color: textSecondary, fontSize: 15),
          prefixIcon: Icon(Icons.search, color: textSecondary, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          suffixIcon: _locationController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: textSecondary, size: 20),
                  onPressed: () {
                    setState(() {
                      _locationController.clear();
                      _selectedLocation = 'Use Current Location';
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            if (value.isNotEmpty) {
              _selectedLocation = value;
            } else {
              _selectedLocation = 'Use Current Location';
            }
          });
        },
      ),
    );
  }

  Widget _buildCurrentLocationButton() {
    return InkWell(
      onTap: _useCurrentLocation,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.my_location, color: accentColor, size: 20),
            const SizedBox(width: 10),
            const Text(
              'Use Current Location',
              style: TextStyle(
                color: accentColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedLocations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular locations',
          style: TextStyle(
            fontSize: 13,
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _suggestedLocations.map((location) {
            final isSelected = _selectedLocation == location;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedLocation = location;
                  _locationController.text = location;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor.withOpacity(0.15) : surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? accentColor : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  location,
                  style: TextStyle(
                    color: isSelected ? accentColor : textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInterestsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: _interests.length,
      itemBuilder: (context, index) {
        final interest = _interests[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 80)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildInterestChip(interest),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInterestChip(Map<String, dynamic> interest) {
    final isSelected = interest['selected'] as bool;
    return InkWell(
      onTap: () {
        setState(() {
          interest['selected'] = !isSelected;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.15) : surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              interest['icon'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                interest['text'],
                style: TextStyle(
                  color: isSelected ? accentColor : textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    final isEnabled = _isCompleteSetupEnabled();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? _savePreferences : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: isEnabled
                  ? const LinearGradient(
                      colors: [accentColor, Color(0xFF9FE82E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isEnabled ? null : surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Complete Setup',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isEnabled ? Colors.black : textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}