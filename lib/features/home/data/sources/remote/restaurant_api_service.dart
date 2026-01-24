
import 'package:logger/logger.dart';
import 'package:waka_fit/features/home/data/models/coach_model.dart';
import 'package:waka_fit/features/home/data/models/restaurant_model.dart';
import 'package:waka_fit/shared/services/api_service.dart';

class RestaurantApiService {
  final ApiService _apiService;

  var logger = Logger();

  RestaurantApiService() : _apiService = ApiService();

  // ============ PUBLIC ENDPOINTS ============
    
  Future<List<RestaurantModel>> getAllRestaurants() async {
    try {
    final response = await _apiService.get('/restaurants');
    final responseData = response.data;
    
    List<dynamic> restaurantsData;
    if (responseData is List) {
      restaurantsData = responseData;
    } else if (responseData is Map && responseData.containsKey('results')) {
      restaurantsData = responseData['results'];
    } else {
      restaurantsData = [];
    }
    
    return restaurantsData
      .map((item) => RestaurantModel.fromJson(item as Map<String, dynamic>))
      .toList();
    } catch (e) {
    rethrow;
    }
  }

Future<RestaurantModel> getRestaurantDetails(String id) async {
  try {
    final response = await _apiService.get('/restaurants/$id');
    final responseData = response.data;

    // Debug print the entire response
    print('🔍 API Response for restaurant $id:');
    print(responseData);
    
    // Check which fields might be null
    final Map<String, dynamic> data = responseData as Map<String, dynamic>;
    
    // List of required string fields
    final requiredFields = [
      'id', 'name', 'cuisine', 'address', 'hours', 
      'phone', 'website', 'orderLink', 'about'
    ];
    
    for (var field in requiredFields) {
      if (data[field] == null) {
        print('⚠️ Warning: $field is null in API response');
      }
    }
    
    return RestaurantModel.fromJson(data);
  } catch (e) {
    logger.e("Error fetching restaurant details: $e");
    rethrow;
  }
} }