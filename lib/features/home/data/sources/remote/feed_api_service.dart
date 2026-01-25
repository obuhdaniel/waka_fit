// lib/features/home/data/sources/remote/feed_api_service.dart
import 'package:dio/dio.dart';
import 'package:waka_fit/features/home/data/models/feed_model.dart';
import 'package:logger/logger.dart';
import 'package:waka_fit/shared/services/api_service.dart';

class FeedApiService {
  final ApiService _apiService;
  final Logger logger = Logger();

  FeedApiService() : _apiService = ApiService();

  // Fetch feeds with pagination
  Future<List<FeedItem>> getFeeds({
    int page = 1,
    int limit = 20,
    FeedType? filterType,
    double? lat,
    double? lng,
    double radius = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (filterType != null) {
        queryParams['type'] = filterType.name;
      }

      if (lat != null && lng != null) {
        queryParams['lat'] = lat;
        queryParams['lng'] = lng;
        queryParams['radius'] = radius;
      }

      final response = await _apiService.get(
        '/feeds',
        queryParams: queryParams,
      );

      final List<dynamic> data = response.data as List<dynamic>;
      
      logger.i('Fetched ${data.length} feeds');
      
      return data
          .where((item) => item != null)
          .map((item) => FeedItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logger.e('Error fetching feeds: $e');
      rethrow;
    }
  }

  // Fetch single feed by ID
  Future<FeedItem> getFeedById(String id) async {
    try {
      final response = await _apiService.get('/feeds/$id');
      return FeedItem.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      logger.e('Error fetching feed $id: $e');
      rethrow;
    }
  }

  // Like/Unlike a feed
  Future<void> toggleLike(String feedId, bool isLiked) async {
    try {
      final endpoint = isLiked ? '/feeds/$feedId/unlike' : '/feeds/$feedId/like';
      // await _apiService.post(endpoint);
      logger.i('${isLiked ? 'Unliked' : 'Liked'} feed $feedId');
    } catch (e) {
      logger.e('Error toggling like for feed $feedId: $e');
      rethrow;
    }
  }

  // Save/Unsave a feed
  Future<void> toggleSave(String feedId, bool isSaved) async {
    try {
      final endpoint = isSaved ? '/feeds/$feedId/unsave' : '/feeds/$feedId/save';
      // await _apiService.post(endpoint);
      logger.i('${isSaved ? 'Unsaved' : 'Saved'} feed $feedId');
    } catch (e) {
      logger.e('Error toggling save for feed $feedId: $e');
      rethrow;
    }
  }

  // Get trending feeds
  Future<List<FeedItem>> getTrendingFeeds({
    int limit = 10,
    String period = 'week', // day, week, month
  }) async {
    try {
      final response = await _apiService.get(
        '/feeds/trending',
        queryParams: {
          'limit': limit,
          'period': period,
        },
      );

      final List<dynamic> data = response.data as List<dynamic>;
      
      logger.i('Fetched ${data.length} trending feeds');
      
      return data
          .where((item) => item != null)
          .map((item) => FeedItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logger.e('Error fetching trending feeds: $e');
      rethrow;
    }
  }

  // Get feeds by type (coaches, gyms, restaurants)
  Future<List<FeedItem>> getFeedsByType(FeedType type, {int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '/feeds',
        queryParams: {
          'type': type.name,
          'limit': limit,
        },
      );

      final List<dynamic> data = response.data as List<dynamic>;
      
      logger.i('Fetched ${data.length} feeds of type ${type.name}');
      
      return data
          .where((item) => item != null)
          .map((item) => FeedItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logger.e('Error fetching feeds by type ${type.name}: $e');
      rethrow;
    }
  }
}