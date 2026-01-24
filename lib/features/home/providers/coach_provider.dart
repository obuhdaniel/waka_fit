import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:waka_fit/features/home/data/models/coach_model.dart';
import 'package:waka_fit/features/home/data/sources/remote/coach_api_service.dart';

class CoachProvider with ChangeNotifier {
  final CoachApiService _coachApiService;
  
  var logger = Logger();
  List<CoachData> _coaches = [];
  List<CoachData> _nearbyCoaches = [];
  CoachData? _selectedCoach;
  
  bool _isLoading = false;
  String? _error;

  List<CoachData> get coaches => _coaches;
  List<CoachData> get nearbyCoaches => _nearbyCoaches;
  CoachData? get selectedCoach => _selectedCoach;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CoachProvider()
      : _coachApiService = CoachApiService();

  // ============ FETCH METHODS ============
  
  Future<void> fetchAllCoaches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _coaches = await _coachApiService.getAllCoaches();

      logger.i("Fetched ${_coaches.length} coaches");
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      logger.e("Error fetching coaches: $_error");
    }
  }

  Future<void> fetchNearbyCoaches({
    required double lat,
    required double lng,
    double radius = 10,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _nearbyCoaches = await _coachApiService.getNearbyCoaches(
        lat: lat,
        lng: lng,
        radius: radius,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCoachById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      logger.i('Fetching coach with ID: $id');
      _selectedCoach = await _coachApiService.getCoachById(id);
      
      // Fetch additional data
      final posts = await _coachApiService.getCoachPosts(id);
      final plans = await _coachApiService.getCoachPlans(id);
      
      _selectedCoach = _selectedCoach!.copyWith(
        coachPosts: posts,
        coachPlans: plans,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============ CRUD METHODS ============
  
  Future<CoachData> createCoach(Map<String, dynamic> coachData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newCoach = await _coachApiService.createCoach(coachData);
      _coaches.insert(0, newCoach);
      
      _isLoading = false;
      notifyListeners();
      return newCoach;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<CoachData> updateCoach(String id, Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedCoach = await _coachApiService.updateCoach(id, updates);
      
      // Update in all lists
      _updateCoachInList(_coaches, updatedCoach);
      _updateCoachInList(_nearbyCoaches, updatedCoach);
      
      if (_selectedCoach?.id == id) {
        _selectedCoach = updatedCoach;
      }
      
      _isLoading = false;
      notifyListeners();
      return updatedCoach;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ============ COACH POSTS & PLANS ============
  
  Future<CoachPost> createCoachPost(String coachId, Map<String, dynamic> postData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPost = await _coachApiService.createCoachPost(coachId, postData);
      
      // Add to selected coach's posts
      if (_selectedCoach?.id == coachId) {
        final updatedPosts = [..._selectedCoach!.coachPosts, newPost];
        _selectedCoach = _selectedCoach!.copyWith(
          coachPosts: updatedPosts.cast<CoachPost>(),
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return newPost;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<CoachPlan> createCoachPlan(String coachId, Map<String, dynamic> planData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPlan = await _coachApiService.createCoachPlan(coachId, planData);
      
      // Add to selected coach's plans
      if (_selectedCoach?.id == coachId) {
        final updatedPlans = [..._selectedCoach!.coachPlans, newPlan];
        _selectedCoach = _selectedCoach!.copyWith(
          coachPlans: updatedPlans,
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return newPlan;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ============ FOLLOW FUNCTIONALITY ============
  
  Future<void> toggleFollowCoach(String coachId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final isFollowing = await _coachApiService.toggleFollowCoach(coachId);
      
      // Update coach in all lists
      _updateFollowStatus(coachId, isFollowing);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ============ HELPER METHODS ============
  
  void _updateCoachInList(List<CoachData> list, CoachData updatedCoach) {
    final index = list.indexWhere((coach) => coach.id == updatedCoach.id);
    if (index != -1) {
      list[index] = updatedCoach;
    }
  }

  void _updateFollowStatus(String coachId, bool isFollowing) {
    // Update followers count and following status
    final updateFollowers = (CoachData coach) {
      final currentFollowers = int.tryParse(coach.followers.replaceAll('K', '')) ?? 0;
      final multiplier = coach.followers.contains('K') ? 1000 : 1;
      final actualFollowers = currentFollowers * multiplier;
      
      final newFollowers = isFollowing ? actualFollowers + 1 : actualFollowers - 1;
      String followersText;
      
      if (newFollowers >= 1000) {
        followersText = '${(newFollowers / 1000).toStringAsFixed(1)}K';
      } else {
        followersText = newFollowers.toString();
      }
      
      return coach.copyWith(
        isFollowing: isFollowing,
        followers: followersText,
      );
    };
    
    // Update in main list
    final coachIndex = _coaches.indexWhere((coach) => coach.id == coachId);
    if (coachIndex != -1) {
      _coaches[coachIndex] = updateFollowers(_coaches[coachIndex]);
    }
    
    // Update in nearby list
    final nearbyIndex = _nearbyCoaches.indexWhere((coach) => coach.id == coachId);
    if (nearbyIndex != -1) {
      _nearbyCoaches[nearbyIndex] = updateFollowers(_nearbyCoaches[nearbyIndex]);
    }
    
    // Update selected coach
    if (_selectedCoach?.id == coachId) {
      _selectedCoach = updateFollowers(_selectedCoach!);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Add copyWith method to your CoachData class
extension CoachDataCopyWith on CoachData {
  CoachData copyWith({
    String? id,
    String? name,
    String? specialties,
    String? followers,
    double? rating,
    int? posts,
    int? plans,
    String? imageUrl,
    bool? isFollowing,
    double? distance,
    int? experience,
    List<String>? specialtyTags,
    String? location,
    String? bio,
    int? reviews,
    List<String>? certifications,
    List<CoachPost>? coachPosts,
    List<CoachPlan>? coachPlans,
  }) {
    return CoachData(
      id: id ?? this.id,
      name: name ?? this.name,
      specialties: specialties ?? this.specialties,
      followers: followers ?? this.followers,
      rating: rating ?? this.rating,
      posts: posts ?? this.posts,
      plans: plans ?? this.plans,
      imageUrl: imageUrl ?? this.imageUrl,
      isFollowing: isFollowing ?? this.isFollowing,
      distance: distance ?? this.distance,
      experience: experience ?? this.experience,
      specialtyTags: specialtyTags ?? this.specialtyTags,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      reviews: reviews ?? this.reviews,
      certifications: certifications ?? this.certifications,
      coachPosts: coachPosts ?? this.coachPosts,
      coachPlans: coachPlans ?? this.coachPlans,
    );
  }
}