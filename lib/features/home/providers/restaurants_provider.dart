import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:waka_fit/features/home/data/models/coach_model.dart';
import 'package:waka_fit/features/home/data/models/restaurant_model.dart';
import 'package:waka_fit/features/home/data/sources/remote/coach_api_service.dart';
import 'package:waka_fit/features/home/data/sources/remote/restaurant_api_service.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantApiService _restaurantApiService;
  
  var logger = Logger();
  List<CoachData> _coaches = [];
  List<CoachData> _nearbyCoaches = [];

  List<RestaurantModel> _restaurants = [];
   List<RestaurantModel> _nearbyrestaurants = [];
  RestaurantModel? _selectedRestaurant;
  
  bool _isLoading = false;
  String? _error;


List<RestaurantModel> get restaurants => _restaurants;
  List<RestaurantModel> get nearbyRestaurants => _nearbyrestaurants;
  RestaurantModel? get selectedRestaurant => _selectedRestaurant;
  bool get isLoading => _isLoading;

  String? get error => _error;

  RestaurantProvider()
      : _restaurantApiService = RestaurantApiService();

  // ============ FETCH METHODS ============
  
  Future<void> fetchAllRestaurants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _restaurants = await _restaurantApiService.getAllRestaurants();

      logger.i("Fetched ${_restaurants.length} restaurants");
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      logger.e("Error fetching restaurants: $_error");
    }
  }

  Future<void> fetchNearbyRestaurants({
    required double lat,
    required double lng,
    double radius = 10,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _nearbyrestaurants = await _restaurantApiService.getAllRestaurants();


            _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRestaurantByID(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      logger.i('Fetching restaurant with ID: $id');
      _selectedRestaurant = await _restaurantApiService.getRestaurantDetails(id);

      logger.i("Fetched restaurant: ${_selectedRestaurant?.menuCategories}");
   
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

}
