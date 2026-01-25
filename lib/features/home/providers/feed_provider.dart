// lib/features/home/providers/feed_provider.dart
import 'package:flutter/material.dart';
import 'package:waka_fit/features/home/data/models/feed_model.dart';
import 'package:waka_fit/features/home/data/sources/remote/feed_api_service.dart';
import 'package:logger/logger.dart';

class FeedProvider with ChangeNotifier {
  final FeedApiService _feedApiService;
  final Logger logger = Logger();

  // State
  List<FeedItem> _feeds = [];
  List<FeedItem> _trendingFeeds = [];
  List<FeedItem> _coachFeeds = [];
  List<FeedItem> _gymFeeds = [];
  List<FeedItem> _restaurantFeeds = [];
  
  bool _isLoading = false;
  bool _isLoadingTrending = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  final int _pageSize = 10;

  // Getters
  List<FeedItem> get feeds => _feeds;
  List<FeedItem> get trendingFeeds => _trendingFeeds;
  List<FeedItem> get coachFeeds => _coachFeeds;
  List<FeedItem> get gymFeeds => _gymFeeds;
  List<FeedItem> get restaurantFeeds => _restaurantFeeds;
  bool get isLoading => _isLoading;
  bool get isLoadingTrending => _isLoadingTrending;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;

  FeedProvider() 
      : _feedApiService = FeedApiService();

  // ============ MAIN FEEDS METHODS ============

  Future<void> fetchFeeds({
    bool refresh = false,
    double? lat,
    double? lng,
    double radius = 10,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _feeds.clear();
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newFeeds = await _feedApiService.getFeeds(
        page: _currentPage,
        limit: _pageSize,
        lat: lat,
        lng: lng,
        radius: radius,
      );

      if (refresh) {
        _feeds = newFeeds;
      } else {
        _feeds.addAll(newFeeds);
      }

      _hasMore = newFeeds.length == _pageSize;
      _currentPage++;

      logger.i('Fetched ${newFeeds.length} feeds, total: ${_feeds.length}');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      logger.e('Error fetching feeds: $_error');
    }
  }

  Future<void> fetchTrendingFeeds() async {
    try {
      _isLoadingTrending = true;
      notifyListeners();

      _trendingFeeds = await _feedApiService.getTrendingFeeds(limit: 5);
      
      logger.i('Fetched ${_trendingFeeds.length} trending feeds');
      
      _isLoadingTrending = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingTrending = false;
      notifyListeners();
      logger.e('Error fetching trending feeds: $_error');
    }
  }

  // ============ FEEDS BY TYPE ============

  Future<void> fetchCoachFeeds({int limit = 10}) async {
    try {
      _coachFeeds = await _feedApiService.getFeedsByType(FeedType.coach, limit: limit);
      notifyListeners();
      logger.i('Fetched ${_coachFeeds.length} coach feeds');
    } catch (e) {
      logger.e('Error fetching coach feeds: $e');
    }
  }

  Future<void> fetchGymFeeds({int limit = 10}) async {
    try {
      _gymFeeds = await _feedApiService.getFeedsByType(FeedType.gym, limit: limit);
      notifyListeners();
      logger.i('Fetched ${_gymFeeds.length} gym feeds');
    } catch (e) {
      logger.e('Error fetching gym feeds: $e');
    }
  }

  Future<void> fetchRestaurantFeeds({int limit = 10}) async {
    try {
      _restaurantFeeds = await _feedApiService.getFeedsByType(FeedType.restaurant, limit: limit);
      notifyListeners();
      logger.i('Fetched ${_restaurantFeeds.length} restaurant feeds');
    } catch (e) {
      logger.e('Error fetching restaurant feeds: $e');
    }
  }

  // ============ FEED ACTIONS ============

  Future<void> toggleLike(String feedId, bool isLiked) async {
    try {
      final feedIndex = _feeds.indexWhere((feed) => feed.id == feedId);
      if (feedIndex != -1) {
        final feed = _feeds[feedIndex];
        final updatedFeed = FeedItem(
          id: feed.id,
          type: feed.type,
          owner: feed.owner,
          createdAt: feed.createdAt,
          content: feed.content,
          title: feed.title,
          description: feed.description,
          imageUrl: feed.imageUrl,
          likes: feed.likes! + (isLiked ? -1 : 1),
          comments: feed.comments,
          shares: feed.shares,
          isLiked: !feed.isLiked,
          isSaved: feed.isSaved,
        );
        _feeds[feedIndex] = updatedFeed;
        
        // Also update in trending feeds if present
        final trendingIndex = _trendingFeeds.indexWhere((feed) => feed.id == feedId);
        if (trendingIndex != -1) {
          _trendingFeeds[trendingIndex] = updatedFeed;
        }
        
        notifyListeners();
        
        // Call API
        await _feedApiService.toggleLike(feedId, isLiked);
      }
    } catch (e) {
      logger.e('Error toggling like for feed $feedId: $e');
      // Revert on error
      notifyListeners();
    }
  }

  Future<void> toggleSave(String feedId, bool isSaved) async {
    try {
      final feedIndex = _feeds.indexWhere((feed) => feed.id == feedId);
      if (feedIndex != -1) {
        final feed = _feeds[feedIndex];
        final updatedFeed = FeedItem(
          id: feed.id,
          type: feed.type,
          owner: feed.owner,
          createdAt: feed.createdAt,
          content: feed.content,
          title: feed.title,
          description: feed.description,
          imageUrl: feed.imageUrl,
          likes: feed.likes,
          comments: feed.comments,
          shares: feed.shares,
          isLiked: feed.isLiked,
          isSaved: !feed.isSaved,
        );
        _feeds[feedIndex] = updatedFeed;
        notifyListeners();
        
        // Call API
        await _feedApiService.toggleSave(feedId, isSaved);
      }
    } catch (e) {
      logger.e('Error toggling save for feed $feedId: $e');
      // Revert on error
      notifyListeners();
    }
  }

  // ============ UTILITY METHODS ============

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearFeeds() {
    _feeds.clear();
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  FeedItem? getFeedById(String id) {
    return _feeds.firstWhere((feed) => feed.id == id);
  }

  // Get feeds suitable for PostCard display
  List<FeedItem> get postCardFeeds {
    return _feeds.where((feed) => feed.isValidForPostCard).toList();
  }
}