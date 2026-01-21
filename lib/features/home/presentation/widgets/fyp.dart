// lib/features/home/presentation/widgets/for_you_content.dart
import 'package:flutter/material.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
import 'package:waka_fit/features/home/presentation/widgets/post_card.dart';
import 'package:waka_fit/features/home/presentation/widgets/trending_card.dart';
class ForYouContent extends StatelessWidget {

   ForYouContent({
    Key? key,
   
  }) : super(key: key);


  void _showNotifications() {
    // Implement notifications screen
  }

  void _seeAllTrending() {
    // Navigate to trending screen
  }

  void _viewFullPost() {
    // Navigate to post detail screen
  }

  void _likePost() {
    // Handle like action
  }

  void _savePost() {
    // Handle save action
  }

  final List<TrendingCard> _trendingItems = [
    TrendingCard(
      title: 'Transform Your Core',
      subtitle: 'Coach',
      imageUrl: 'https://picsum.photos/200/300?random=1',
      type: 'coach',
      followers: '12K',
      gradientStart: AppColors.primary,
      gradientEnd: AppColors.primary,
    ),
    TrendingCard(
      title: 'Elite Performance',
      subtitle: 'Gym',
      imageUrl: 'https://picsum.photos/200/300?random=2',
      type: 'gym',
      gradientStart: const Color(0xFF8338EC),
      gradientEnd: const Color(0xFF3A86FF),
    ),
    TrendingCard(
      title: 'Mindful Movement',
      subtitle: 'Yoga Studio',
      imageUrl: 'https://picsum.photos/200/300?random=3',
      type: 'coach',
      followers: '8.5K',
      gradientStart: const Color(0xFFFF006E),
      gradientEnd: const Color(0xFFFB5607),
    ),
  ];



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
                children: [
                  // Trending Section
                  TrendingSection(
                    title: 'Trending This Week',
                    items: _trendingItems,
                    onSeeAll: _seeAllTrending,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Posts Feed
                  _buildPostsFeed(),
                  
                  const SizedBox(height: 80), // Space for bottom nav
                ],
              ),);
  }

  
  Widget _buildPostsFeed() {
    return Column(
      children: [
        PostCard(
          userName: 'Sarah Chen',
          userTitle: 'Certified Trainer · Nutrition Expert',
          userImageUrl: 'https://picsum.photos/200/300?random=4',
          postTitle: '5 Exercises for Core Strength',
          postDescription:
              'Build a strong core with these essential exercises that target all areas of your abdominal muscles.',
          postImageUrl: 'https://picsum.photos/400/300?random=5',
          likes: 1200,
          comments: 89,
          shares: 234,
          onTap: _viewFullPost,
          onLike: _likePost,
          onSave: _savePost,
        ),
        PostCard(
          userName: 'Mike Johnson',
          userTitle: 'Strength Coach · 10+ years experience',
          userImageUrl: 'https://picsum.photos/200/300?random=6',
          postTitle: 'Nutrition Tips for Muscle Growth',
          postDescription:
              'Learn how to optimize your diet for maximum muscle growth and recovery.',
          postImageUrl: 'https://picsum.photos/400/300?random=7',
          likes: 850,
          comments: 42,
          shares: 156,
          onTap: _viewFullPost,
          onLike: _likePost,
          onSave: _savePost,
        ),
      ],
    );
  }


}

