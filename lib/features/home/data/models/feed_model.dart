enum FeedType {
  coach,
  gym,
  restaurant,
  post,
  article,
  challenge,
}

class FeedOwner {
  final String id;
  final String name;
  final String imageUrl;
  final double latitude;
  final double longitude;

  FeedOwner({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });

  factory FeedOwner.fromJson(Map<String, dynamic> json) {
    return FeedOwner(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}

class FeedItem {
  final String id;
  final FeedType type;
  final String? content;
  final String? title;
  final String? description;
  final String? imageUrl;
  final FeedOwner owner;
  final DateTime createdAt;
  final int? likes;
  final int? comments;
  final int? shares;
  final bool isLiked;
  final bool isSaved;
  final dynamic entityData; // Could be CoachData, GymModel, RestaurantModel, etc.

  FeedItem({
    required this.id,
    required this.type,
    required this.owner,
    required this.createdAt,
    this.content,
    this.title,
    this.description,
    this.imageUrl,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.entityData,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    final typeString = json['type']?.toString() ?? 'post';
    final type = FeedType.values.firstWhere(
      (t) => t.name.toLowerCase() == typeString.toLowerCase(),
      orElse: () => FeedType.post,
    );

    return FeedItem(
      id: json['id']?.toString() ?? '',
      type: type,
      content: json['content']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      owner: FeedOwner.fromJson(json['owner'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isSaved: json['isSaved'] ?? false,
    );
  }

  // Convert to PostCard-compatible format
  String get userName => owner.name;
  String get userTitle => _getUserTitle();
  String get userImageUrl => owner.imageUrl;
  String get postTitle => title ?? _getDefaultTitle();
  String get postDescription => description ?? content ?? '';
  String get postImageUrl => imageUrl ?? '';

  String _getUserTitle() {
    switch (type) {
      case FeedType.coach:
        return 'Certified Coach';
      case FeedType.gym:
        return 'Fitness Center';
      case FeedType.restaurant:
        return 'Healthy Restaurant';
      case FeedType.challenge:
        return 'Fitness Challenge';
      default:
        return 'Fitness Enthusiast';
    }
  }

  String _getDefaultTitle() {
    switch (type) {
      case FeedType.coach:
        return 'New Coaching Program Available';
      case FeedType.gym:
        return 'Gym Updates & Events';
      case FeedType.restaurant:
        return 'New Healthy Menu Items';
      case FeedType.challenge:
        return 'Join Our Fitness Challenge';
      default:
        return 'Fitness Tips & Updates';
    }
  }

  // Helper method to check if this feed has enough data for PostCard
  bool get isValidForPostCard {
    return title != null || content != null;
  }
}