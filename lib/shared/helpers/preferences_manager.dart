// lib/shared/preferences_manager.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static final PreferencesManager _instance = PreferencesManager._internal();
  
  factory PreferencesManager() {
    return _instance;
  }
  
  PreferencesManager._internal();
  
  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  // Goals
  Future<List<String>> getGoals() async {
    final prefs = await _prefs;
    final goals = [
      if (prefs.getBool('goal_lose_weight') == true) 'lose_weight',
      if (prefs.getBool('goal_build_muscle') == true) 'build_muscle',
      if (prefs.getBool('goal_stay_active') == true) 'stay_active',
      if (prefs.getBool('goal_eat_healthier') == true) 'eat_healthier',
    ];
    return goals;
  }

  // Location
  Future<String> getLocation() async {
    final prefs = await _prefs;
    return prefs.getString('user_location') ?? 'current_location';
  }

  // Interests
  Future<List<String>> getInterests() async {
    final prefs = await _prefs;
    final interests = [
      if (prefs.getBool('interest_gyms') == true) 'gyms',
      if (prefs.getBool('interest_coaches') == true) 'coaches',
      if (prefs.getBool('interest_yoga') == true) 'yoga',
      if (prefs.getBool('interest_restaurants') == true) 'restaurants',
      if (prefs.getBool('interest_supplements') == true) 'supplements',
      if (prefs.getBool('interest_classes') == true) 'classes',
    ];
    return interests;
  }

  // Check if setup is completed
  Future<bool> isSetupCompleted() async {
    final prefs = await _prefs;
    return prefs.getBool('setup_completed') ?? false;
  }

  // Clear all preferences
  Future<void> clearPreferences() async {
    final prefs = await _prefs;
    await prefs.clear();
  }

  // Update location
  Future<void> updateLocation(String location) async {
    final prefs = await _prefs;
    await prefs.setString('user_location', location);
  }

  // Update goals
  Future<void> updateGoal(String goalId, bool selected) async {
    final prefs = await _prefs;
    await prefs.setBool('goal_$goalId', selected);
  }

  // Update interests
  Future<void> updateInterest(String interestId, bool selected) async {
    final prefs = await _prefs;
    await prefs.setBool('interest_$interestId', selected);
  }
}