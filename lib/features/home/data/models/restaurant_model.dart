import 'package:waka_fit/features/home/presentation/widgets/restaurants/restaurant_detail_screen.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String cuisine;
  final String address;
  final double distance;
  final double rating;
  final int reviewCount;
  final double price;
  final String imageUrl;
  final List<String> dietaryTags;
  final bool isOpen;
  final String hours;
  final String phone;
  final String website;
  final String orderLink;
  final List<String> specialtyTags;
  final List<MenuCategory> menuCategories; // Added this
  final String about; // Added this
  bool isSaved;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.address,
    this.distance = 0,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.imageUrl,
    required this.dietaryTags,
    this.isOpen = true,
    required this.hours,
    required this.phone,
    required this.website,
    required this.orderLink,
    required this.specialtyTags,
    this.menuCategories = const [],
    this.about = '',
    this.isSaved = false,
  });

  

  

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      cuisine: json['cuisine'] ?? '',
      address: json['address'] ?? '',
      // Handling API using 'latitude' for distance or similar
      distance: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      dietaryTags: List<String>.from(json['dietaryTags'] ?? []),
      isOpen: json['isOpen'] ?? true,
      hours: json['hours'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'] ?? '',
      orderLink: json['orderLink'] ?? '',
      specialtyTags: List<String>.from(json['specialtyTags'] ?? []),
      about: json['about'] ?? '',
      // Map the nested menu categories
      menuCategories: (json['menuCategories'] as List? ?? [])
          .map((category) => MenuCategory.fromJson(category))
          .toList(),
      isSaved: false,
    );
  }
}