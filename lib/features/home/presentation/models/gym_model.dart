// lib/features/gyms/models/gym_model.dart
import 'package:waka_fit/features/home/presentation/widgets/gyms/gym_detail_screen.dart';

class GymModel {
  final String id;
  final String name;
  final String address;
  final double distance; // in miles
  final double rating;
  final int reviewCount;
  final String type;
  final double price; // monthly price
  final String imageUrl;
  final List<String> amenities;
  final bool isOpen;
  final String hours;
  final String phone;
  final String website;
  final List<String> specialtyTags;
  bool isSaved;

  GymModel({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.rating,
    required this.reviewCount,
    required this.type,
    required this.price,
    required this.imageUrl,
    required this.amenities,
    this.isOpen = true,
    required this.hours,
    required this.phone,
    required this.website,
    required this.specialtyTags,
    this.isSaved = false,
  });

  // Convert to GymDetail for detail screen
  GymDetail toGymDetail() {
    return GymDetail(
      id: id,
      name: name,
      address: address,
      distance: '$distance mi from you',
      rating: rating,
      reviewCount: reviewCount,
      hours: isOpen ? 'Open' : 'Closed',
      closingTime: hours.contains('-') ? hours.split('-').last.trim() : hours,
      phone: phone,
      website: website,
      imageUrl: imageUrl,
      amenities: amenities,
      additionalFeatures: [],
      membershipOptions: [
        MembershipOption(
          name: 'Basic Membership',
          price: '\$${price.toInt()}/month',
          description: 'Access to all gym facilities and equipment',
          features: amenities.take(3).toList(),
        ),
      ],
      isOpen: isOpen,
      monthlyPrice: price,
    );
  }
}