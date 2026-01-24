class CoachData {
  final String id;
  final String name;
  final String specialties;
  final String followers;
  final double rating;
  final int posts;
  final int plans;
  final String imageUrl;
  bool isFollowing;
  final double distance;
  final int experience;
  final List<String> specialtyTags;
  
  // New fields for detailed view
  final String location;
  final String bio;
  final int reviews;
  final List<String> certifications;
  final List<CoachPost> coachPosts;
  final List<CoachPlan> coachPlans;

  CoachData({
    required this.id,
    required this.name,
    required this.specialties,
    required this.followers,
    required this.rating,
    required this.posts,
    required this.plans,
    required this.imageUrl,
    required this.isFollowing,
    required this.distance,
    required this.experience,
    required this.specialtyTags,
    this.location = '',
    this.bio = '',
    this.reviews = 0,
    this.certifications = const [],
    this.coachPosts = const [],
    this.coachPlans = const [],
  });
}

class CoachPost {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int likes;
  final int comments;
  final int shares;
  final DateTime date;

  CoachPost({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.date,
  });
}

class CoachPlan {
  final String id;
  final String title;
  final String description;
  final String price;
  final String duration;
  final String level;
  final List<String> features;
  final String imageUrl;

  CoachPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.level,
    required this.features,
    required this.imageUrl,
  });
}