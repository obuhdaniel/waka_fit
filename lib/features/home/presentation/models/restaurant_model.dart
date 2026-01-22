// lib/features/restaurants/models/restaurant_model.dart
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
  bool isSaved;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.address,
    required this.distance,
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
    this.isSaved = false,
  });

  RestaurantDetail toRestaurantDetail() {
    return RestaurantDetail(
      id: id,
      name: name,
      cuisine: cuisine,
      address: address,
      distance: '$distance mi from you',
      rating: rating,
      reviewCount: reviewCount,
      isOpen: isOpen,
      hours: hours,
      phone: phone,
      website: website,
      orderLink: orderLink,
      imageUrl: imageUrl,
      dietaryTags: dietaryTags,
      menuCategories: [
        MenuCategory(
          name: 'Bowls',
          items: [
            MenuItem(
              name: 'Quinoa Power Bowl',
              description: 'Organic quinoa, grilled chicken, roasted vegetables, avocado, tahini dressing',
              price: 14.99,
              calories: 520,
              orderNote: 'Ordering redirects to FreshBowl website',
            ),
            MenuItem(
              name: 'Acai Superfood Bowl',
              description: 'Acai blend, granola, mixed berries, banana, honey, coconut flakes',
              price: 12.99,
              calories: 380,
            ),
          ],
        ),
        MenuCategory(
          name: 'Salads',
          items: [
            MenuItem(
              name: 'Mediterranean Salad',
              description: 'Mixed greens, feta, olives, cucumber, tomato, red onion, lemon vinaigrette',
              price: 11.99,
              calories: 320,
            ),
          ],
        ),
        MenuCategory(
          name: 'Smoothies',
          items: [
            MenuItem(
              name: 'Green Detox Smoothie',
              description: 'Spinach, kale, pineapple, banana, ginger, coconut water',
              price: 8.99,
              calories: 210,
            ),
          ],
        ),
      ],
      about: 'FreshBowl is dedicated to serving fresh, healthy, and delicious meals made with locally sourced ingredients. Our menu focuses on nutrient-dense bowls, salads, and smoothies that support your fitness goals.',
    );
  }
}