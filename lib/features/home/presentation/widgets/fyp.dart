// lib/features/home/presentation/widgets/for_you_content.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
import 'package:waka_fit/features/home/presentation/widgets/post_card.dart';
import 'package:waka_fit/features/home/presentation/widgets/trending_card.dart';
import 'package:waka_fit/features/home/providers/feed_provider.dart';
import 'package:waka_fit/features/home/data/models/feed_model.dart';

class ForYouContent extends StatefulWidget {
  const ForYouContent({Key? key}) : super(key: key);

  @override
  State<ForYouContent> createState() => _ForYouContentState();
}

class _ForYouContentState extends State<ForYouContent> {
  @override
  void initState() {
    super.initState();
    // Load data when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final provider = context.read<FeedProvider>();
    provider.fetchFeeds(refresh: true);
    provider.fetchTrendingFeeds();
    provider.fetchCoachFeeds();
    provider.fetchGymFeeds();
  }

  void _seeAllTrending() {
    // Navigate to trending screen
  }

  void _viewFullPost(String feedId) {
    // Navigate to post detail screen
  }

  void _handleLike(String feedId, bool isLiked) {
    final provider = context.read<FeedProvider>();
    provider.toggleLike(feedId, isLiked);
  }

  void _handleSave(String feedId, bool isSaved) {
    final provider = context.read<FeedProvider>();
    provider.toggleSave(feedId, isSaved);
  }

  // Convert trending feeds to TrendingCard widgets
  List<TrendingCard> _buildTrendingCards(List<FeedItem> trendingFeeds) {
    return trendingFeeds.map((feed) {
      Color gradientStart;
      Color gradientEnd;
      
      // Assign colors based on feed type
      switch (feed.type) {
        case FeedType.coach:
          gradientStart = AppColors.primary;
          gradientEnd = AppColors.primary.withOpacity(0.8);
          break;
        case FeedType.gym:
          gradientStart = const Color(0xFF8338EC);
          gradientEnd = const Color(0xFF3A86FF);
          break;
        case FeedType.restaurant:
          gradientStart = const Color(0xFFFF006E);
          gradientEnd = const Color(0xFFFB5607);
          break;
        default:
          gradientStart = AppColors.primary;
          gradientEnd = AppColors.primary.withOpacity(0.8);
      }

      return TrendingCard(
        title: feed.title ?? feed.owner.name,
        subtitle: feed.type.name.toUpperCase(),
        imageUrl: feed.imageUrl ?? feed.owner.imageUrl,
        type: feed.type.name,
        followers: '${feed.likes}K',
        gradientStart: gradientStart,
        gradientEnd: gradientEnd,
        // onTap: () {
        //   // Handle trending item tap
        // },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (context, provider, child) {
        // Show loading state
        if (provider.isLoading && provider.feeds.isEmpty) {
          return _buildLoadingState();
        }

        // Show error state
        if (provider.error != null && provider.feeds.isEmpty) {
          return _buildErrorState(provider.error!);
        }

        return  RefreshIndicator(
        onRefresh: () async {
          final provider = context.read<FeedProvider>();
          await provider.fetchFeeds(refresh: true);
          await provider.fetchTrendingFeeds();
        },
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Trending Section
                // _buildTrendingSection(provider),
                
                // const SizedBox(height: 24),
                
                // Posts Feed
                _buildPostsFeed(provider),
                
                // Load more indicator
                if (provider.isLoadingMore) _buildLoadMoreIndicator(),
                
                // No more data indicator
                if (!provider.hasMore && provider.feeds.isNotEmpty)
                  _buildNoMoreData(),
                
                const SizedBox(height: 80), // Space for bottom nav
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendingSection(FeedProvider provider) {
    return TrendingSection(
      title: 'Trending This Week',
      items: _buildTrendingCards(provider.trendingFeeds),
      // isLoading: provider.isLoadingTrending,
      onSeeAll: _seeAllTrending,
    );
  }

  Widget _buildPostsFeed(FeedProvider provider) {
    if (provider.postCardFeeds.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: provider.postCardFeeds.map((feed) {
        return PostCard(
          userName: feed.userName,
          userTitle: feed.userTitle,
          userImageUrl: feed.userImageUrl,
          postTitle: feed.postTitle,
          postDescription: feed.postDescription,
          postImageUrl: feed.postImageUrl,
          likes: feed.likes ?? 0,
          comments: feed.comments ?? 0,
          shares: feed.shares ?? 0,
          // isLiked: feed.isLiked,
          // isSaved: feed.isSaved,
          onTap: () => _viewFullPost(feed.id),
          onLike: () => _handleLike(feed.id, feed.isLiked),
          onSave: () => _handleSave(feed.id, feed.isSaved),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Column(
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 20),
            Text(
              'Loading feeds...',
              style: TextStyle(
                color: AppColors.wakaTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 20),
            Text(
              'Failed to load feeds',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.wakaTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final provider = context.read<FeedProvider>();
                provider.fetchFeeds(refresh: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.feed,
            size: 64,
            color: AppColors.wakaTextSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'No feeds available',
            style: TextStyle(
              color: AppColors.wakaTextSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Check back later for updates',
            style: TextStyle(
              color: AppColors.wakaTextSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildNoMoreData() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        'No more feeds to load',
        style: TextStyle(
          color: AppColors.wakaTextSecondary.withOpacity(0.7),
        ),
      ),
    );
  }
}