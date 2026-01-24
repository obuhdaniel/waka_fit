import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:waka_fit/features/home/data/models/gym_model.dart';
import 'package:waka_fit/shared/services/api_service.dart';

class GymApiService {
  final ApiService _apiService;

  var logger = Logger();

  GymApiService() : _apiService = ApiService();

  // ============ PUBLIC ENDPOINTS ============
  
  Future<List<GymModel>> getAllGyms({
    int page = 1,
    int limit = 20,
    String? type,
    bool? isOpen,
    double? minRating,
    double? maxPrice,
    String? amenities,
    String? city,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
        if (isOpen != null) 'isOpen': isOpen.toString(),
        if (minRating != null) 'minRating': minRating.toString(),
        if (maxPrice != null) 'maxPrice': maxPrice.toString(),
        if (amenities != null) 'amenities': amenities,
        if (city != null) 'city': city,
      };
      
      final response = await _apiService.get('/gyms', queryParams: queryParams);

      logger.i(response);
      
      // Parse the response to match your GymModel
      final responseData = response.data;
      List<dynamic> gymsData;
      
      if (responseData is Map && responseData.containsKey('data')) {
        gymsData = responseData['data']['gyms'] ?? [];
      } else {
        gymsData = responseData;
      }
      
      return gymsData.map((json) => _parseGymFromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<GymModel>> getNearbyGyms({
    required double lat,
    required double lng,
    double radius = 10,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'lat': lat.toString(),
        'lng': lng.toString(),
        'radius': radius.toString(),
        'limit': limit.toString(),
      };
      
      final response = await _apiService.get('/gyms/nearby', queryParams: queryParams);
      final responseData = response.data;
      List<dynamic> gymsData;
      
      if (responseData is Map && responseData.containsKey('data')) {
        gymsData = responseData['data'];
      } else {
        gymsData = responseData;
      }
      
      return gymsData.map((json) => _parseGymFromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<GymModel> getGymById(String id) async {
    try {
      final response = await _apiService.get('/gyms/$id');
      final responseData = response.data;
      
      Map<String, dynamic> gymData;
      if (responseData is Map && responseData.containsKey('data')) {
        gymData = responseData['data'];
      } else {
        gymData = responseData;
      }
      
      return _parseGymFromJson(gymData);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<GymPost>> getGymPosts(String gymId) async {
    try {
      final response = await _apiService.get('/gyms/$gymId/posts');
      final responseData = response.data;
      
      List<dynamic> postsData;
      if (responseData is Map && responseData.containsKey('data')) {
        postsData = responseData['data'];
      } else {
        postsData = responseData;
      }
      
      return postsData.map((json) => GymPost(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        imageUrl: json['imageUrl'],
        isPromo: json['isPromo'] ?? false,
      )).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<GymPlan>> getGymPlans(String gymId) async {
    try {
      final response = await _apiService.get('/gyms/$gymId/plans');
      final responseData = response.data;
      
      List<dynamic> plansData;
      if (responseData is Map && responseData.containsKey('data')) {
        plansData = responseData['data'];
      } else {
        plansData = responseData;
      }
      
      return plansData.map((json) => GymPlan(
        id: json['id'],
        gymId: json['gymId'],
        name: json['name'],
        price: json['price']?.toDouble() ?? 0.0,
        description: json['description'],
        features: List<String>.from(json['features'] ?? []),
        billingCycle: json['billingCycle'],
      )).toList();
    } catch (e) {
      rethrow;
    }
  }

  // ============ PROTECTED ENDPOINTS ============
  
  Future<GymModel> createGym(Map<String, dynamic> gymData) async {
    try {
      final response = await _apiService.post('/gyms', gymData);
      final responseData = response.data;
      
      Map<String, dynamic> createdGymData;
      if (responseData is Map && responseData.containsKey('data')) {
        createdGymData = responseData['data'];
      } else {
        createdGymData = responseData;
      }
      
      return _parseGymFromJson(createdGymData);
    } catch (e) {
      rethrow;
    }
  }

  Future<GymModel> updateGym(String id, Map<String, dynamic> updates) async {
    try {
      final response = await _apiService.put('/gyms/$id', updates);
      final responseData = response.data;
      
      Map<String, dynamic> updatedGymData;
      if (responseData is Map && responseData.containsKey('data')) {
        updatedGymData = responseData['data'];
      } else {
        updatedGymData = responseData;
      }
      
      return _parseGymFromJson(updatedGymData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGym(String id) async {
    try {
      await _apiService.delete('/gyms/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<GymModel>> getMyGyms() async {
    try {
      final response = await _apiService.get('/gyms/owner/my-gyms');
      final responseData = response.data;
      
      List<dynamic> gymsData;
      if (responseData is Map && responseData.containsKey('data')) {
        gymsData = responseData['data'];
      } else {
        gymsData = responseData;
      }
      
      return gymsData.map((json) => _parseGymFromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // ============ GYM POSTS ============
  
  Future<GymPost> createGymPost(String gymId, Map<String, dynamic> postData) async {
    try {
      final response = await _apiService.post('/gyms/$gymId/posts', postData);
      final responseData = response.data;
      
      Map<String, dynamic> createdPostData;
      if (responseData is Map && responseData.containsKey('data')) {
        createdPostData = responseData['data'];
      } else {
        createdPostData = responseData;
      }
      
      return GymPost(
        id: createdPostData['id'],
        title: createdPostData['title'],
        content: createdPostData['content'],
        imageUrl: createdPostData['imageUrl'],
        isPromo: createdPostData['isPromo'] ?? false,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============ GYM PLANS ============
  
  Future<GymPlan> createGymPlan(String gymId, Map<String, dynamic> planData) async {
    try {
      final response = await _apiService.post('/gyms/$gymId/plans', planData);
      final responseData = response.data;
      
      Map<String, dynamic> createdPlanData;
      if (responseData is Map && responseData.containsKey('data')) {
        createdPlanData = responseData['data'];
      } else {
        createdPlanData = responseData;
      }
      
      return GymPlan(
        id: createdPlanData['id'],
        gymId: createdPlanData['gymId'],
        name: createdPlanData['name'],
        price: createdPlanData['price']?.toDouble() ?? 0.0,
        description: createdPlanData['description'],
        features: List<String>.from(createdPlanData['features'] ?? []),
        billingCycle: createdPlanData['billingCycle'],
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============ SAVED GYMS ============
  
  Future<List<GymModel>> getMySavedGyms() async {
    try {
      final response = await _apiService.get('/gyms/user/favorites');
      final responseData = response.data;
      
      List<dynamic> gymsData;
      if (responseData is Map && responseData.containsKey('data')) {
        gymsData = responseData['data'];
      } else {
        gymsData = responseData;
      }
      
      return gymsData.map((json) => _parseGymFromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> toggleSaveGym(String gymId) async {
    try {
      final response = await _apiService.post('/gyms/$gymId/toggle-save', {});
      final responseData = response.data;
      
      if (responseData is Map) {
        return responseData['success'] ?? false;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  // ============ HELPER METHODS ============
  
  GymModel _parseGymFromJson(Map<String, dynamic> json) {
    // Parse hours - handle different formats
    String hours = '24/7';
    if (json['hours'] != null) {
      if (json['hours'] is Map) {
        final hoursMap = Map<String, String>.from(json['hours']);
        hours = '${hoursMap['monday'] ?? 'N/A'}';
      } else if (json['hours'] is String) {
        hours = json['hours'];
      }
    }
    
    return GymModel(
      id: json['id'],
      name: json['name'],
      address: json['address'] ?? '',
      distance: json['distance']?.toDouble() ?? 0.0,
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviews'] ?? json['reviewCount'] ?? 0,
      type: json['type'] ?? 'fitness',
      price: json['price']?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      amenities: List<String>.from(json['amenities'] ?? []),
      isOpen: json['isOpen'] ?? true,
      hours: hours,
      phone: json['phone'] ?? '',
      website: json['website'] ?? '',
      specialtyTags: List<String>.from(json['specialtyTags'] ?? []),
      about: json['about'] ?? '',
      isSaved: json['isSaved'] ?? false,
    );
  }

  // Create gym data helper for Nigerian gyms
  Map<String, dynamic> createGymData({
    required String name,
    required String address,
    required double lat,
    required double lng,
    String type = 'fitness',
    double price = 10000,
    List<String> amenities = const [],
    List<String> specialtyTags = const [],
    String phone = '',
    String website = '',
    String about = '',
  }) {
    return {
      'name': name,
      'address': address,
      'latitude': lat,
      'longitude': lng,
      'type': type,
      'price': price,
      'amenities': amenities,
      'specialtyTags': specialtyTags,
      'isOpen': true,
      'phone': phone,
      'website': website,
      'about': about,
      'hours': {
        'monday': '6:00 AM - 10:00 PM',
        'tuesday': '6:00 AM - 10:00 PM',
        'wednesday': '6:00 AM - 10:00 PM',
        'thursday': '6:00 AM - 10:00 PM',
        'friday': '6:00 AM - 9:00 PM',
        'saturday': '8:00 AM - 8:00 PM',
        'sunday': '9:00 AM - 6:00 PM',
      },
    };
  }
}

// Temporary models for API responses
class GymPost {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final bool isPromo;

  GymPost({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.isPromo,
  });
}

class GymPlan {
  final String id;
  final String gymId;
  final String name;
  final double price;
  final String? description;
  final List<String> features;
  final String billingCycle;

  GymPlan({
    required this.id,
    required this.gymId,
    required this.name,
    required this.price,
    this.description,
    required this.features,
    required this.billingCycle,
  });
}