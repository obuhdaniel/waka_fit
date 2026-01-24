
import 'package:waka_fit/features/home/data/models/coach_model.dart';
import 'package:waka_fit/shared/services/api_service.dart';

class CoachApiService {
  final ApiService _apiService;

  CoachApiService() : _apiService = ApiService();

  // ============ PUBLIC ENDPOINTS ============
  
  Future<List<CoachData>> getAllCoaches() async {
    try {
      final response = await _apiService.get('/coaches');
      final responseData = response.data;
      
      List<dynamic> coachesData;
      if (responseData is List) {
        coachesData = responseData;
      } else if (responseData is Map && responseData.containsKey('data')) {
        coachesData = responseData['data']['items'];
      } else {
        coachesData = [];
      }
      
      return coachesData.map((json) => _parseCoachFromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CoachData>> getNearbyCoaches({
    required double lat,
    required double lng,
    double radius = 10,
  }) async {
    try {
      final queryParams = {
        'lat': lat.toString(),
        'lng': lng.toString(),
        'radius': radius.toString(),
      };
      
      final response = await _apiService.get('/coaches/nearby', queryParams: queryParams);
      final responseData = response.data;
      
      List<dynamic> coachesData;
      if (responseData is List) {
        coachesData = responseData;
      } else if (responseData is Map && responseData.containsKey('data')) {
        coachesData = responseData['data'];
      } else {
        coachesData = [];
      }
      
      return coachesData.map((json) => _parseCoachFromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<CoachData> getCoachById(String id) async {
    try {
      final response = await _apiService.get('/coaches/$id');
      final responseData = response.data;
      
      Map<String, dynamic> coachData;
      if (responseData is Map && responseData.containsKey('data')) {
        coachData = responseData['data'];
      } else {
        coachData = responseData;
      }
      
      return _parseCoachFromJson(coachData);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CoachPost>> getCoachPosts(String coachId) async {
    try {
      final response = await _apiService.get('/coaches/$coachId/posts');
      final responseData = response.data;
      
      List<dynamic> postsData;
      if (responseData is List) {
        postsData = responseData;
      } else if (responseData is Map && responseData.containsKey('data')) {
        postsData = responseData['data'];
      } else {
        postsData = [];
      }
      
      return postsData.map((json) => CoachPost(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        imageUrl: json['imageUrl'],
        likes: json['likes'] ?? 0,
        comments: json['comments'] ?? 0,
        shares: json['shares'] ?? 0,
        date: DateTime.parse(json['createdAt']),
      )).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CoachPlan>> getCoachPlans(String coachId) async {
    try {
      final response = await _apiService.get('/coaches/$coachId/plans');
      final responseData = response.data;
      
      List<dynamic> plansData;
      if (responseData is List) {
        plansData = responseData;
      } else if (responseData is Map && responseData.containsKey('data')) {
        plansData = responseData['data'];
      } else {
        plansData = [];
      }
      
      return plansData.map((json) => CoachPlan(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        price: '₦${json['price']?.toInt() ?? 0}',
        duration: json['duration'] ?? '',
        level: json['level'] ?? 'beginner',
        features: List<String>.from(json['features'] ?? []),
        imageUrl: json['imageUrl'],
      )).toList();
    } catch (e) {
      rethrow;
    }
  }

  // ============ PROTECTED ENDPOINTS ============
  
  Future<CoachData> createCoach(Map<String, dynamic> coachData) async {
    try {
      final response = await _apiService.post('/coaches', coachData);
      final responseData = response.data;
      
      Map<String, dynamic> createdCoachData;
      if (responseData is Map && responseData.containsKey('data')) {
        createdCoachData = responseData['data'];
      } else {
        createdCoachData = responseData;
      }
      
      return _parseCoachFromJson(createdCoachData);
    } catch (e) {
      rethrow;
    }
  }

  Future<CoachData> updateCoach(String id, Map<String, dynamic> updates) async {
    try {
      final response = await _apiService.put('/coaches/$id', updates);
      final responseData = response.data;
      
      Map<String, dynamic> updatedCoachData;
      if (responseData is Map && responseData.containsKey('data')) {
        updatedCoachData = responseData['data'];
      } else {
        updatedCoachData = responseData;
      }
      
      return _parseCoachFromJson(updatedCoachData);
    } catch (e) {
      rethrow;
    }
  }

  Future<CoachPost> createCoachPost(String coachId, Map<String, dynamic> postData) async {
    try {
      final response = await _apiService.post('/coaches/$coachId/posts', postData);
      final responseData = response.data;
      
      Map<String, dynamic> createdPostData;
      if (responseData is Map && responseData.containsKey('data')) {
        createdPostData = responseData['data'];
      } else {
        createdPostData = responseData;
      }
      
      return CoachPost(
        id: createdPostData['id'],
        title: createdPostData['title'],
        description: createdPostData['description'] ?? '',
        imageUrl: createdPostData['imageUrl'],
        likes: createdPostData['likes'] ?? 0,
        comments: createdPostData['comments'] ?? 0,
        shares: createdPostData['shares'] ?? 0,
        date: DateTime.parse(createdPostData['createdAt']),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<CoachPlan> createCoachPlan(String coachId, Map<String, dynamic> planData) async {
    try {
      final response = await _apiService.post('/coaches/$coachId/plans', planData);
      final responseData = response.data;
      
      Map<String, dynamic> createdPlanData;
      if (responseData is Map && responseData.containsKey('data')) {
        createdPlanData = responseData['data'];
      } else {
        createdPlanData = responseData;
      }
      
      return CoachPlan(
        id: createdPlanData['id'],
        title: createdPlanData['title'],
        description: createdPlanData['description'] ?? '',
        price: '₦${createdPlanData['price']?.toInt() ?? 0}',
        duration: createdPlanData['duration'] ?? '',
        level: createdPlanData['level'] ?? 'beginner',
        features: List<String>.from(createdPlanData['features'] ?? []),
        imageUrl: createdPlanData['imageUrl'],
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============ FOLLOW FUNCTIONALITY ============
  
  Future<bool> toggleFollowCoach(String coachId) async {
    try {
      final response = await _apiService.post('/coaches/$coachId/follow', {});
      final responseData = response.data;
      
      if (responseData is Map) {
        return responseData['following'] ?? false;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  // ============ HELPER METHODS ============
  
  CoachData _parseCoachFromJson(Map<String, dynamic> json) {
    // Parse followers - handle different formats
    String followers = '0';
    if (json['followersCount'] != null) {
      final count = json['followersCount'];
      if (count >= 1000) {
        followers = '${(count / 1000).toStringAsFixed(1)}K';
      } else {
        followers = count.toString();
      }
    }
    
    // Parse posts count
    final postsCount = json['posts'] is List ? (json['posts'] as List).length : 0;
    
    // Parse plans count
    final plansCount = json['plans'] is List ? (json['plans'] as List).length : 0;
    
    return CoachData(
      id: json['id'],
      name: json['name'],
      specialties: json['specialties'] ?? 'Fitness Coach',
      followers: followers,
      rating: json['rating']?.toDouble() ?? 0.0,
      posts: postsCount,
      plans: plansCount,
      imageUrl: json['imageUrl'] ?? '',
      isFollowing: json['isFollowing'] ?? false,
      distance: json['distance']?.toDouble() ?? 0.0,
      experience: json['experience'] ?? 0,
      specialtyTags: List<String>.from(json['specialtyTags'] ?? []),
      location: json['location'] ?? '',
      bio: json['bio'] ?? '',
      reviews: json['reviews'] ?? 0,
      certifications: List<String>.from(json['certifications'] ?? []),
      coachPosts:(json['posts'] as List? ?? []).map((p) => CoachPost(
      id: p['id'],
      title: p['title'],
      description: p['description'] ?? '',
      imageUrl: p['imageUrl'],
      likes: p['likes'] ?? 0,
      comments: p['comments'] ?? 0,
      shares: p['shares'] ?? 0,
      date: DateTime.parse(p['createdAt'] ?? DateTime.now().toIso8601String()),
    )).toList(), // Will be loaded separately
      coachPlans: (json['plans'] as List? ?? []).map((p) => CoachPlan(
      id: p['id'],
      title: p['title'],
      description: p['description'] ?? '',
      price: '₦${(p['price'] ?? 0).toInt()}', // Formatting price
      duration: p['duration'] ?? '',
      level: p['level'] ?? 'beginner',
      features: List<String>.from(p['features'] ?? []),
      imageUrl: p['imageUrl'],
    )).toList(), // Will be loaded separately
    );
  }

  // Create coach data helper for Nigerian coaches
  Map<String, dynamic> createCoachData({
    required String name,
    required String location,
    required double lat,
    required double lng,
    String specialties = 'Fitness Coach',
    String bio = '',
    int experience = 0,
    List<String> specialtyTags = const [],
    List<String> certifications = const [],
  }) {
    return {
      'name': name,
      'specialties': specialties,
      'bio': bio,
      'location': location,
      'latitude': lat,
      'longitude': lng,
      'experience': experience,
      'specialtyTags': specialtyTags,
      'certifications': certifications,
    };
  }
}