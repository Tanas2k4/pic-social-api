import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:like_button/like_button.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/friend_badge_avatar.dart';
import '../../../../core/widgets/friendship_icons.dart';
import '../../data/models/post_item_model.dart';
import 'comment_bottom_sheet.dart';
import 'post_quick_action_dialog.dart';

class PostCard extends StatefulWidget {
  final PostItemModel post;
  final Function(bool isLiked) onLikeToggle;
  final Function(FriendshipStatus newStatus)? onFriendshipChanged;
  final bool isPureViewMode;
  final VoidCallback? onTogglePureView;
  final VoidCallback? onDeletePost;
  final VoidCallback? onHidePost;

  const PostCard({
    super.key,
    required this.post,
    required this.onLikeToggle,
    this.onFriendshipChanged,
    this.isPureViewMode = false,
    this.onTogglePureView,
    this.onDeletePost,
    this.onHidePost,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int _currentPhotoIndex = 0;

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.postId != widget.post.postId) {
      _currentPhotoIndex = 0;
    }
  }

  Widget _buildPersonWithArrowIcon({Color color = Colors.white, double size = 20}) {
    return FriendshipIcons.personWithArrow(color: color, size: size);
  }

  Widget _buildFriendshipIcon(BuildContext context) {
    // Ẩn icon bên phải khi là bài của chính mình hoặc đã là bạn bè (vì đã có dấu tích xác nhận ngay trên Avatar)
    if (widget.post.userId == 'current-user' ||
        widget.post.authorUserName == 'you' ||
        widget.post.friendshipStatus == FriendshipStatus.friends) {
      return const SizedBox.shrink();
    }

    Widget iconWidget;
    String tooltip;

    switch (widget.post.friendshipStatus) {
      case FriendshipStatus.requested:
        iconWidget = _buildPersonWithArrowIcon(color: Colors.white, size: 20);
        tooltip = 'Đã gửi lời mời kết bạn (Đang chờ duyệt)';
        break;

      case FriendshipStatus.none:
      default:
        iconWidget = const Icon(
          SolarIconsOutline.userPlusRounded,
          color: Colors.white,
          size: 20,
        );
        tooltip = 'Kết bạn';
        break;
    }

    return GestureDetector(
      onTap: () {
        if (widget.post.friendshipStatus == FriendshipStatus.none) {
          widget.onFriendshipChanged?.call(FriendshipStatus.requested);
          AppToast.showSuccess(
            context,
            'Đã gửi lời mời kết bạn tới ${widget.post.authorFullName ?? widget.post.authorUserName}',
            iconWidget: _buildPersonWithArrowIcon(color: Colors.black, size: 16),
          );
        } else if (widget.post.friendshipStatus == FriendshipStatus.requested) {
          AppToast.showInfo(
            context,
            'Lời mời kết bạn đang chờ đối phương chấp nhận',
            iconWidget: _buildPersonWithArrowIcon(color: Colors.black, size: 16),
          );
        }
      },
      child: Tooltip(
        message: tooltip,
        child: Container(
          padding: const EdgeInsets.all(6),
          color: Colors.transparent,
          child: iconWidget,
        ),
      ),
    );
  }

  Widget _buildPhotoView(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.surfaceDark,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primaryYellow),
          ),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.broken_image_rounded, size: 50, color: Colors.grey),
        ),
      );
    } else {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image_rounded, size: 50, color: Colors.grey),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Align(
      alignment: const Alignment(0, 0.22), // Dịch xích xuống dưới để khoảng cách trên - dưới cân đối hoàn hảo
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. VÙNG ẢNH CHÍNH (XEM TRỌN VẸN KHI BẬT PURE VIEW MODE, HỖ TRỢ VUỐT NGANG TỐI ĐA 3 ẢNH)
            Flexible(
              child: AspectRatio(
                aspectRatio: 0.67,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    // CHẠM NHẸ VÀO ẢNH ĐỂ BẬT/TẮT XEM TRỌN VẸN
                    onTap: widget.onTogglePureView,
                    // NHẤN GIỮ ĐỂ MỞ QUICK ACTION POP-UP (PEEK & POP / MENU THAO TÁC NHANH)
                    onLongPress: () {
                      final activeUrl = post.photoUrls.isNotEmpty && _currentPhotoIndex < post.photoUrls.length
                          ? post.photoUrls[_currentPhotoIndex]
                          : post.photoUrl;
                      PostQuickActionDialog.show(
                        context,
                        post: post,
                        activePhotoUrl: activeUrl,
                        onDelete: widget.onDeletePost,
                        onHide: widget.onHidePost,
                      );
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                      // A. ẢNH CHÍNH (HỖ TRỢ CAROUSEL VUỐT NGANG NẾU CÓ > 1 ẢNH)
                      post.photoUrls.length > 1
                          ? PageView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: post.photoUrls.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPhotoIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return _buildPhotoView(post.photoUrls[index]);
                              },
                            )
                          : _buildPhotoView(post.photoUrl),

                      // B. Lớp gradient mờ ở đáy ảnh (Ẩn khi bật chế độ xem trọn vẹn)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 140,
                        child: AnimatedOpacity(
                          opacity: widget.isPureViewMode ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 250),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // C. Thông tin tác giả ở góc trên (Ẩn khi xem trọn vẹn)
                      Positioned(
                        top: 14,
                        left: 14,
                        right: 14,
                        child: AnimatedOpacity(
                          opacity: widget.isPureViewMode ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 250),
                          child: IgnorePointer(
                            ignoring: widget.isPureViewMode,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  color: AppColors.cardOverlay,
                                  child: Row(
                                    children: [
                                      FriendBadgeAvatar(
                                        avatarUrl: post.authorAvatarUrl,
                                        isFriend: post.friendshipStatus == FriendshipStatus.friends,
                                        radius: 17,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              post.authorFullName ?? post.authorUserName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              timeago.format(post.createdAt, locale: 'vi'),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.white.withValues(alpha: 0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      _buildFriendshipIcon(context),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // D. Các chấm chỉ số ảnh & Caption ở đáy ảnh (Ẩn khi xem trọn vẹn)
                      if (post.photoUrls.length > 1 || (post.title != null && post.title!.isNotEmpty))
                        Positioned(
                          left: 18,
                          right: 18,
                          bottom: 16,
                          child: AnimatedOpacity(
                            opacity: widget.isPureViewMode ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 250),
                            child: IgnorePointer(
                              ignoring: widget.isPureViewMode,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // CÁC CHẤM CHỈ SỐ ẢNH PHÍA TRÊN CAPTION (CHẤM HIỆN TẠI DÀI RA DẠNG PILL)
                                  if (post.photoUrls.length > 1) ...[
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(post.photoUrls.length, (i) {
                                        final bool isCurrent = i == _currentPhotoIndex;
                                        return AnimatedContainer(
                                          duration: const Duration(milliseconds: 250),
                                          curve: Curves.easeOutCubic,
                                          margin: const EdgeInsets.only(right: 5),
                                          width: isCurrent ? 18 : 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: isCurrent
                                                ? Colors.white
                                                : Colors.white.withValues(alpha: 0.35),
                                            borderRadius: BorderRadius.circular(3),
                                            boxShadow: isCurrent
                                                ? [
                                                    const BoxShadow(
                                                      color: Colors.black45,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 1),
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.white.withValues(alpha: 0.3),
                                                      blurRadius: 4,
                                                    ),
                                                  ]
                                                : const [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      blurRadius: 3,
                                                      offset: Offset(0, 1),
                                                    ),
                                                  ],
                                          ),
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 8),
                                  ],

                                  // CAPTION CHỮ
                                  if (post.title != null && post.title!.isNotEmpty)
                                    Text(
                                      post.title!,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        height: 1.3,
                                        shadows: [
                                          Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 1)),
                                        ],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            ),

            const SizedBox(height: 6),

            // 2. HÀNG NGANG TƯƠNG TÁC (TIM, COMMENT, SHARE)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: Row(
                children: [
                  // 1. Thả tim (Like)
                  LikeButton(
                    size: 26,
                    isLiked: post.isLikedByMe,
                    likeCount: post.likeCount,
                    countPostion: CountPostion.right,
                    likeCountPadding: const EdgeInsets.only(left: 6),
                    likeCountAnimationType: LikeCountAnimationType.none,
                    likeBuilder: (bool isLiked) {
                      return Icon(
                        isLiked ? SolarIconsBold.heart : SolarIconsOutline.heart,
                        color: isLiked ? Colors.redAccent : Colors.white,
                        size: 26,
                      );
                    },
                    countBuilder: (int? count, bool isLiked, String text) {
                      return Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                    onTap: (isLiked) async {
                      widget.onLikeToggle(!isLiked);
                      return !isLiked;
                    },
                  ),

                  const SizedBox(width: 28),

                  // 2. Bình luận (Comment)
                  GestureDetector(
                    onTap: () => CommentBottomSheet.show(context, post),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        const Icon(SolarIconsOutline.chatRoundDots, color: Colors.white, size: 24),
                        const SizedBox(width: 6),
                        Text(
                          '${post.commentCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 28),

                  // 3. Chia sẻ (Icon Mũi tên cong Outline)
                  GestureDetector(
                    onTap: () {
                      AppToast.showSuccess(
                        context,
                        'Đã sao chép liên kết chia sẻ khoảnh khắc!',
                        icon: SolarIconsBold.linkRound,
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        const Icon(
                          SolarIconsOutline.forward_2,
                          color: Colors.white,
                          size: 23,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${post.shareCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 4. Bookmark (Lưu khoảnh khắc)
                  GestureDetector(
                    onTap: () {
                      AppToast.showSuccess(
                        context,
                        'Đã lưu khoảnh khắc vào bộ sưu tập!',
                        icon: Icons.bookmark_added_rounded,
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.bookmark_border_rounded, color: Colors.white70, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
