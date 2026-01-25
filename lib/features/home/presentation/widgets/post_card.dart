import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waka_fit/core/theme/app_colors.dart';

class PostCard extends StatelessWidget {
  final String userName;
  final String userTitle;
  final String userImageUrl;
  final String postTitle;
  final String postDescription;
  final String postImageUrl;
  final int likes;
  final int comments;
  final int shares;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onSave;

  const PostCard({
    Key? key,
    required this.userName,
    required this.userTitle,
    required this.userImageUrl,
    required this.postTitle,
    required this.postDescription,
    required this.postImageUrl,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.onTap,
    required this.onLike,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.wakaSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.wakaStroke,
          width: 2
        )

      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(userImageUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: GoogleFonts.inter(
                          color: AppColors.wakaTextPrimary,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      SizedBox(height: 8,),
                      Text(
                        userTitle,
                        style: GoogleFonts.inter(
                          color: AppColors.wakaTextSecondary,
                          fontSize: 12
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onSave,
                  icon: Icon(
                    Icons.bookmark_border,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Post content
            Text(
              postTitle,
              style: GoogleFonts.inter(
                color: AppColors.wakaTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500
              ),
            ),
            const SizedBox(height: 8),
            Text(
              postDescription,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.wakaTextPrimary
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            
            // Post image
            Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(postImageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
            const SizedBox(height: 16),
            
            // Stats
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: [
            //     _buildStatButton(
            //       icon: Icons.favorite_border,
            //       count: likes,
            //       onPressed: onLike,
            //     ),
            //     _buildStatButton(
            //       icon: Icons.comment_outlined,
            //       count: comments,
            //       onPressed: () {},
            //     ),
            //     _buildStatButton(
            //       icon: Icons.share_outlined,
            //       count: shares,
            //       onPressed: () {},
            //     ),
            //   ],
            // ),
            
            // View full post
            // Align(
            //   alignment: Alignment.centerLeft,
            //   child: TextButton(
            //     onPressed: onTap,
            //     child: Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         Text(
            //           'View Full Post',
            //           style: TextStyle(
            //             color: AppColors.wakaBlue,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //         const SizedBox(width: 4),
            //         Icon(
            //           Icons.arrow_forward,
            //           size: 16,
            //           color: AppColors.wakaBlue,
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatButton({
    required IconData icon,
    required int count,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: AppColors.textTertiary,
        size: 18,
      ),
      label: Text(
        _formatCount(count),
        style: TextStyle(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}