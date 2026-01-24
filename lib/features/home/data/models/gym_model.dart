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
  final String about;
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
    required this.about,
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
      about: about,
    );
  }
}

// Models
class GymDetail {
  final String id;
  final String name;
  final String address;
  final String distance;
  final double rating;
  final int reviewCount;
  final String hours;
  final String closingTime;
  final String phone;
  final String website;
  final String imageUrl;
  final List<String> amenities;
  final List<String> additionalFeatures;
  final List<MembershipOption> membershipOptions;
  final String about;
  final bool isOpen;
  final double? monthlyPrice;

  GymDetail({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.rating,
    required this.reviewCount,
    required this.hours,
    required this.closingTime,
    required this.phone,
    required this.website,
    required this.imageUrl,
    required this.amenities,
    this.additionalFeatures = const [],
    this.membershipOptions = const [],
    this.isOpen = true,
    this.monthlyPrice,
    this.about = '',
  });
}

class MembershipOption {
  final String name;
  final String price;
  final String description;
  final List<String> features;

  MembershipOption({
    required this.name,
    required this.price,
    required this.description,
    this.features = const [],
  });
}
