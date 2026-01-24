// lib/features/coaches/providers/coaches_screen_provider.dart
import 'package:flutter/material.dart';
import 'package:waka_fit/features/home/data/models/coach_model.dart';
import 'package:waka_fit/features/home/presentation/widgets/coaches/sort_filter_sheet.dart';

class CoachesScreenProvider extends ChangeNotifier {
  // Filter & Search state
  final TextEditingController searchController = TextEditingController();
  int selectedSpecialtyIndex = 0;
  String searchQuery = '';
  SortOption currentSort = SortOption.relevance;
  double minRating = 4.0;
  double maxDistance = 10.0;
  
  List<CoachData> _allCoaches = [];
  List<CoachData> filteredCoaches = [];
  
  // Get specialty list
  List<String> get specialtyList => ['All', 'Strength', 'Cardio', 'Yoga', 'Nutrition', 'Meditation'];
  
  // Initialize with static data (you can replace this with API call)
  void initialize(List<CoachData> coaches) {
    _allCoaches = coaches;
    filteredCoaches = List.from(_allCoaches);
    notifyListeners();
  }
  
  void updateSearch(String query) {
    searchQuery = query;
    _applyFilters();
  }
  
  void updateSpecialty(int index) {
    selectedSpecialtyIndex = index;
    _applyFilters();
  }
  
  void updateFilters({
    SortOption? sort,
    double? minRating,
    double? maxDistance,
  }) {
    if (sort != null) currentSort = sort;
    if (minRating != null) this.minRating = minRating;
    if (maxDistance != null) this.maxDistance = maxDistance;
    _applyFilters();
  }
  
  void _applyFilters() {
    List<CoachData> filtered = List.from(_allCoaches);
    
    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((coach) {
        return coach.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            coach.specialties.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            coach.specialtyTags.any(
              (tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()),
            );
      }).toList();
    }
    
    // Apply specialty filter (skip "All")
    if (selectedSpecialtyIndex > 0) {
      final specialty = specialtyList[selectedSpecialtyIndex];
      filtered = filtered.where((coach) {
        return coach.specialtyTags.any(
          (tag) => tag.toLowerCase().contains(specialty.toLowerCase()),
        );
      }).toList();
    }
    
    // Apply rating filter
    filtered = filtered.where((coach) => coach.rating >= minRating).toList();
    
    // Apply distance filter
    filtered = filtered
        .where((coach) => coach.distance <= maxDistance)
        .toList();
    
    // Apply sorting
    filtered.sort((a, b) {
      switch (currentSort) {
        case SortOption.rating:
          return b.rating.compareTo(a.rating);
        case SortOption.followers:
          final aFollowers = _parseFollowers(a.followers);
          final bFollowers = _parseFollowers(b.followers);
          return bFollowers.compareTo(aFollowers);
        case SortOption.experience:
          return b.experience.compareTo(a.experience);
        case SortOption.relevance:
        default:
          return 0; // Keep original order for relevance
      }
    });
    
    filteredCoaches = filtered;
    notifyListeners();
  }
  
  double _parseFollowers(String followers) {
    final clean = followers.replaceAll('K', '').replaceAll('M', '');
    final value = double.tryParse(clean) ?? 0;
    if (followers.contains('K')) return value * 1000;
    if (followers.contains('M')) return value * 1000000;
    return value;
  }
  
  void toggleFollow(int index) {
    filteredCoaches[index].isFollowing = !filteredCoaches[index].isFollowing;
    
    // Update in original list
    final coachId = filteredCoaches[index].id;
    final originalIndex = _allCoaches.indexWhere((coach) => coach.id == coachId);
    if (originalIndex != -1) {
      _allCoaches[originalIndex].isFollowing = filteredCoaches[index].isFollowing;
    }
    
    notifyListeners();
  }
  
  void clearFilters() {
    searchController.clear();
    selectedSpecialtyIndex = 0;
    searchQuery = '';
    currentSort = SortOption.relevance;
    minRating = 4.0;
    maxDistance = 10.0;
    filteredCoaches = List.from(_allCoaches);
    notifyListeners();
  }
  
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}