import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:waka_fit/features/home/data/models/gym_model.dart';
import 'package:waka_fit/features/home/data/sources/remote/gym_service.dart';

class GymProvider with ChangeNotifier {
  final GymApiService _gymApiService;


  var logger = Logger();
  
  List<GymModel> _gyms = [];
  List<GymModel> _myGyms = [];
  List<GymModel> _savedGyms = [];
  GymModel? _selectedGym;
  
  bool _isLoading = false;
  String? _error;

  List<GymModel> get gyms => _gyms;
  List<GymModel> get myGyms => _myGyms;
  List<GymModel> get savedGyms => _savedGyms;
  GymModel? get selectedGym => _selectedGym;
  bool get isLoading => _isLoading;
  String? get error => _error;

  GymProvider()
      : _gymApiService = GymApiService();

  void updateToken(String newToken) {
    // Token is updated in ApiService via AuthProvider
  }

  // ============ FETCH METHODS ============
  
  Future<void> fetchAllGyms({
    int page = 1,
    int limit = 20,
    String? type,
    bool? isOpen,
    double? minRating,
    double? maxPrice,
    String? amenities,
    String? city,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedGyms = await _gymApiService.getAllGyms(
        page: page,
        limit: limit,
        type: type,
        isOpen: isOpen,
        minRating: minRating,
        maxPrice: maxPrice,
        amenities: amenities,
        city: city,
      );
      
      if (page == 1) {
        _gyms = fetchedGyms;
      } else {
        _gyms.addAll(fetchedGyms);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNearbyGyms({
    required double lat,
    required double lng,
    double radius = 10,
    int limit = 20,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _gyms = await _gymApiService.getNearbyGyms(
        lat: lat,
        lng: lng,
        radius: radius,
        limit: limit,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchGymById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedGym = await _gymApiService.getGymById(id);
      
      // Also fetch saved status
      await fetchMySavedGyms();
      if (_selectedGym != null) {
        _selectedGym = _selectedGym!.copyWith(
          isSaved: _savedGyms.any((g) => g.id == id),
        );
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyGyms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myGyms = await _gymApiService.getMyGyms();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMySavedGyms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _savedGyms = await _gymApiService.getMySavedGyms();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============ CRUD METHODS ============
  
  Future<GymModel> createGym(Map<String, dynamic> gymData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newGym = await _gymApiService.createGym(gymData);
      _gyms.insert(0, newGym);
      _myGyms.insert(0, newGym);
      
      _isLoading = false;
      notifyListeners();
      return newGym;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<GymModel> updateGym(String id, Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedGym = await _gymApiService.updateGym(id, updates);
      
      // Update in all lists
      _updateGymInList(_gyms, updatedGym);
      _updateGymInList(_myGyms, updatedGym);
      _updateGymInList(_savedGyms, updatedGym);
      
      if (_selectedGym?.id == id) {
        _selectedGym = updatedGym;
      }
      
      _isLoading = false;
      notifyListeners();
      return updatedGym;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteGym(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _gymApiService.deleteGym(id);
      _gyms.removeWhere((gym) => gym.id == id);
      _myGyms.removeWhere((gym) => gym.id == id);
      _savedGyms.removeWhere((gym) => gym.id == id);
      
      if (_selectedGym?.id == id) {
        _selectedGym = null;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ============ SAVED GYMS ============
  
  Future<void> toggleSaveGym(String gymId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _gymApiService.toggleSaveGym(gymId);
      
      if (success) {
        // Update gym in all lists
        _toggleSavedStatus(gymId);
        
        // Update saved gyms list
        await fetchMySavedGyms();
      }
      
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
  
  void _updateGymInList(List<GymModel> list, GymModel updatedGym) {
    final index = list.indexWhere((gym) => gym.id == updatedGym.id);
    if (index != -1) {
      list[index] = updatedGym;
    }
  }

  void _toggleSavedStatus(String gymId) {
    // Update in main list
    final gymIndex = _gyms.indexWhere((gym) => gym.id == gymId);
    if (gymIndex != -1) {
      _gyms[gymIndex] = _gyms[gymIndex].copyWith(
        isSaved: !_gyms[gymIndex].isSaved,
      );
    }
    
    // Update in selected gym
    if (_selectedGym?.id == gymId) {
      _selectedGym = _selectedGym!.copyWith(
        isSaved: !_selectedGym!.isSaved,
      );
    }
  }

  // Copy method for GymModel
  GymModel _copyGymWithChanges(GymModel gym, {bool? isSaved}) {
    return GymModel(
      id: gym.id,
      name: gym.name,
      address: gym.address,
      distance: gym.distance,
      rating: gym.rating,
      reviewCount: gym.reviewCount,
      type: gym.type,
      price: gym.price,
      imageUrl: gym.imageUrl,
      amenities: gym.amenities,
      isOpen: gym.isOpen,
      hours: gym.hours,
      phone: gym.phone,
      website: gym.website,
      specialtyTags: gym.specialtyTags,
      about: gym.about,
      isSaved: isSaved ?? gym.isSaved,
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Add copyWith method to your GymModel class
extension GymModelCopyWith on GymModel {
  GymModel copyWith({
    String? id,
    String? name,
    String? address,
    double? distance,
    double? rating,
    int? reviewCount,
    String? type,
    double? price,
    String? imageUrl,
    List<String>? amenities,
    bool? isOpen,
    String? hours,
    String? phone,
    String? website,
    List<String>? specialtyTags,
    String? about,
    bool? isSaved,
  }) {
    return GymModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      distance: distance ?? this.distance,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      type: type ?? this.type,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      amenities: amenities ?? this.amenities,
      isOpen: isOpen ?? this.isOpen,
      hours: hours ?? this.hours,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      specialtyTags: specialtyTags ?? this.specialtyTags,
      about: about ?? this.about,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}