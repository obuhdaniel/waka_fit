class CoachData {
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

  CoachData({
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
  });
}