// lib/features/coaches/screens/coach_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:waka_fit/core/theme/app_colors.dart';
import 'package:waka_fit/features/home/data/models/coach_model.dart';
import 'package:waka_fit/features/home/presentation/widgets/post_card.dart';
import 'package:waka_fit/features/home/providers/coach_provider.dart';

class CoachDetailScreen extends StatefulWidget {
  final CoachData coach;

  const CoachDetailScreen({Key? key, required this.coach}) : super(key: key);

  @override
  State<CoachDetailScreen> createState() => _CoachDetailScreenState();
}

class _CoachDetailScreenState extends State<CoachDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _isFollowing = false;
  bool _showFullBio = false;
  double _headerOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController()..addListener(_onScroll);
    _isFollowing = widget.coach.isFollowing;

    _loadCoachDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

    Future<void> _loadCoachDetails() async {
    final provider = context.read<CoachProvider>();
    
    // If we already have complete coach data, use it
    if (
        widget.coach.coachPosts.isNotEmpty && 
        widget.coach.coachPlans.isNotEmpty) {
      return;
    }
    
    // Otherwise, fetch from provider
    try {
      await provider.fetchCoachById(widget.coach.id);
    
    } catch (e) {
      // Handle error - could show a snackbar or retry button
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load coach details: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }


  void _onScroll() {
    final offset = _scrollController.offset;
    setState(() {
      _headerOpacity = (offset / 100).clamp(0.0, 1.0);
    });
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
      widget.coach.isFollowing = _isFollowing;
    });
    // TODO: Update follow status via API
  }

  void _sendMessage() {
    // TODO: Implement message functionality
  }

  void _viewFullPost() {
    // TODO: Implement full post view
  }

  void _likePost() {
    // TODO: Implement like functionality
  }

  void _savePost() {
    // TODO: Implement save functionality
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.wakaBackground,
            AppColors.wakaSurface.withOpacity(0.5),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'coach_avatar_${widget.coach.name}',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.wakaGreen.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.wakaStroke,
                    backgroundImage: NetworkImage(widget.coach.imageUrl),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      widget.coach.name,
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.wakaTextPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.wakaBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            color: AppColors.wakaBlue,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.coach.specialties,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.wakaBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.coach.location.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.wakaTextSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.coach.location,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.wakaTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Enhanced Stats Row
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.wakaSurface,
                  AppColors.wakaSurface.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.wakaStroke.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  value: widget.coach.followers,
                  label: 'Followers',
                  icon: Icons.people_outline,
                ),
                _buildDivider(),
                _buildStatColumn(
                  value: '${widget.coach.rating}',
                  label: 'Rating',
                  icon: Icons.star,
                  isRating: true,
                ),
                _buildDivider(),
                _buildStatColumn(
                  value: '${widget.coach.posts}',
                  label: 'Posts',
                  icon: Icons.article_outlined,
                ),
                _buildDivider(),
                _buildStatColumn(
                  value: '${widget.coach.reviews}',
                  label: 'Reviews',
                  icon: Icons.rate_review_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Modern Action Buttons
          Row(
            children: [
              Expanded(
                flex: 3,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _toggleFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFollowing
                          ? AppColors.wakaSurface
                          : AppColors.wakaGreen,
                      foregroundColor: _isFollowing
                          ? AppColors.wakaTextPrimary
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: _isFollowing
                            ? BorderSide(color: AppColors.wakaStroke)
                            : BorderSide.none,
                      ),
                      elevation: _isFollowing ? 0 : 2,
                      shadowColor: AppColors.wakaGreen.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isFollowing ? Icons.check_circle : Icons.person_add,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isFollowing ? 'Following' : 'Follow',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.wakaGreen.withOpacity(0.1),
                      AppColors.wakaGreen.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.wakaGreen.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.wakaGreen,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          
          // Modern Bio
          if (widget.coach.bio.isNotEmpty) ...[
            const SizedBox(height: 20),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _showFullBio
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.coach.bio,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.wakaTextSecondary,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.coach.bio.length > 150) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(() => _showFullBio = true),
                      child: Text(
                        'Read more',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.wakaGreen,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              secondChild: Text(
                widget.coach.bio,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.wakaTextSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.wakaStroke.withOpacity(0.2),
            AppColors.wakaStroke.withOpacity(0.6),
            AppColors.wakaStroke.withOpacity(0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required String value,
    required String label,
    required IconData icon,
    bool isRating = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isRating ? AppColors.wakaGreen : AppColors.wakaTextPrimary,
              ),
            ),
            if (isRating) ...[
              const SizedBox(width: 2),
              Icon(
                Icons.star,
                size: 16,
                color: AppColors.wakaGreen,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: AppColors.wakaTextSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.wakaTextSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPostsTab(CoachData displayedCoach) {
    if (displayedCoach.coachPosts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.article_outlined,
        title: 'No posts yet',
        subtitle: 'Check back later for updates',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: displayedCoach.coachPosts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final post = displayedCoach.coachPosts[index];
        return PostCard(
          userName: displayedCoach.name,
          userTitle: displayedCoach.specialties,
          userImageUrl: displayedCoach.imageUrl,
          postTitle: post.title,
          postDescription: post.description,
          postImageUrl: post.imageUrl,
          likes: post.likes,
          comments: post.comments,
          shares: post.shares,
          onTap: _viewFullPost,
          onLike: _likePost,
          onSave: _savePost,
        );
      },
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.coach.bio.isNotEmpty) ...[
            _buildSectionHeader('Background', Icons.person_outline),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.wakaSurface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.wakaStroke.withOpacity(0.3),
                ),
              ),
              child: Text(
                widget.coach.bio,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.wakaTextSecondary,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],

          if (widget.coach.certifications.isNotEmpty) ...[
            _buildSectionHeader('Certifications', Icons.workspace_premium),
            const SizedBox(height: 16),
            ...widget.coach.certifications.map(
              (cert) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withOpacity(0.1),
                      AppColors.success.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified,
                        color: AppColors.success,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cert,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.wakaTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],

          _buildSectionHeader('Specialties', Icons.stars_outlined),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.coach.specialtyTags.map(
              (specialty) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.wakaGreen.withOpacity(0.15),
                      AppColors.wakaGreen.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.wakaGreen.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  specialty,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.wakaTextPrimary,
                  ),
                ),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.wakaGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.wakaGreen,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.wakaTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildPlansTab(CoachData displayedCoach) {
    if (displayedCoach.coachPlans.isEmpty) {
      return _buildEmptyState(
        icon: Icons.fitness_center_outlined,
        title: 'No plans available',
        subtitle: 'Plans will appear here when available',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: displayedCoach.coachPlans.length,
      itemBuilder: (context, index) {
        final plan = displayedCoach.coachPlans[index];
        return _buildPlanCard(plan);
      },
    );
  }

  Widget _buildPlanCard(CoachPlan plan) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.wakaSurface,
            AppColors.wakaSurface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.wakaStroke.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.wakaTextPrimary,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.wakaGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                plan.price,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.wakaGreen,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildPlanChip(
                  icon: Icons.schedule,
                  text: plan.duration,
                ),
                _buildPlanChip(
                  icon: Icons.trending_up,
                  text: plan.level,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                plan.description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.wakaTextSecondary,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.wakaGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'View Plan',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.wakaField.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.wakaStroke.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.wakaTextSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.wakaTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.wakaStroke.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.wakaTextSecondary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.wakaTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.wakaTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final detailedCoach = context.select<CoachProvider, CoachData?>(
    (p) => p.selectedCoach?.id == widget.coach.id ? p.selectedCoach : null,
  );

  // 2. Use the detailed version if available, otherwise fall back to the passed widget data
  final displayedCoach = detailedCoach ?? widget.coach;

    return Scaffold(
      backgroundColor: AppColors.wakaBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.wakaBackground.withOpacity(_headerOpacity),
        elevation: _headerOpacity > 0.5 ? 1 : 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.wakaSurface.withOpacity(0.9),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.wakaStroke.withOpacity(0.3),
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.wakaTextPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: AnimatedOpacity(
          opacity: _headerOpacity,
          duration: const Duration(milliseconds: 200),
          child: Text(
            widget.coach.name,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.wakaTextPrimary,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.wakaSurface.withOpacity(0.9),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.wakaStroke.withOpacity(0.3),
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.share_outlined,
                color: AppColors.wakaTextPrimary,
                size: 20,
              ),
              onPressed: () {},
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.wakaSurface.withOpacity(0.9),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.wakaStroke.withOpacity(0.3),
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.more_vert,
                color: AppColors.wakaTextPrimary,
                size: 20,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 56),
                  _buildHeader(),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.wakaBackground,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.wakaStroke.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Posts'),
                      Tab(text: 'Plans'),
                      Tab(text: 'About'),
                    ],
                    labelColor: AppColors.wakaGreen,
                    unselectedLabelColor: AppColors.wakaTextSecondary,
                    indicatorColor: AppColors.wakaGreen,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorWeight: 3,
                    labelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    unselectedLabelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsTab(displayedCoach),
            _buildPlansTab(displayedCoach),
            _buildAboutTab(),
          ],
        ),
      ),
    );
  }
}


class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.wakaBackground,
      child: child,
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}

