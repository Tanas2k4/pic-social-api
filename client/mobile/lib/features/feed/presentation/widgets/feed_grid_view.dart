import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/post_item_model.dart';

class FeedGridView extends StatelessWidget {
  final List<PostItemModel> posts;
  final Function(int index) onPostTap;
  final String? filterName;

  const FeedGridView({
    super.key,
    required this.posts,
    required this.onPostTap,
    this.filterName,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có khoảnh khắc nào',
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    // Lưới ảnh 3 cột bo tròn góc
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: posts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.72, // Khớp tỉ lệ khung ảnh
        ),
              itemBuilder: (context, index) {
                final post = posts[index];
                return GestureDetector(
                  onTap: () => onPostTap(index),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Ảnh thumbnail
                        post.photoUrl.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: post.photoUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.surfaceDark,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryYellow,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey, size: 24),
                                ),
                              )
                            : Image.file(
                                File(post.photoUrl),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey, size: 24),
                                ),
                              ),

                        // Gradient nhẹ ở đáy
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),

                        // Tim & Avatar nhỏ ở góc nếu đang xem tất cả
                        Positioned(
                          left: 6,
                          bottom: 6,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 12),
                              const SizedBox(width: 3),
                              Text(
                                '${post.likeCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Avatar tác giả ở góc trên (nếu xem chung)
                        if (post.authorAvatarUrl != null)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundImage: CachedNetworkImageProvider(post.authorAvatarUrl!),
                            ),
                          ),

                        // Icon badge nhiều ảnh ở góc trên bên trái
                        if (post.photoUrls.length > 1)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.all(3.5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.collections_rounded,
                                color: Colors.white,
                                size: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }
}
