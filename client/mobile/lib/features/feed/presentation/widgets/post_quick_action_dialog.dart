import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/post_item_model.dart';

/// Hộp thoại menu thao tác nhanh dạng kính mờ (Quick Action Pop-up)
/// Chuẩn phong cách iOS / Instagram Peek & Pop
class PostQuickActionDialog extends StatelessWidget {
  final PostItemModel post;
  final String activePhotoUrl;
  final VoidCallback? onDelete;
  final VoidCallback? onHide;

  const PostQuickActionDialog({
    super.key,
    required this.post,
    required this.activePhotoUrl,
    this.onDelete,
    this.onHide,
  });

  static Future<void> show(
    BuildContext context, {
    required PostItemModel post,
    required String activePhotoUrl,
    VoidCallback? onDelete,
    VoidCallback? onHide,
  }) {
    HapticFeedback.mediumImpact();
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'QuickActionPopUp',
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 320),
      transitionBuilder: (context, anim1, anim2, child) {
        final scaleCurve = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final fadeCurve = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(scaleCurve),
          child: FadeTransition(
            opacity: fadeCurve,
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, anim1, anim2) {
        return PostQuickActionDialog(
          post: post,
          activePhotoUrl: activePhotoUrl,
          onDelete: onDelete,
          onHide: onHide,
        );
      },
    );
  }

  bool get _isMyPost {
    return post.userId == 'current-user' ||
        post.authorUserName == 'you' ||
        post.authorUserName == 'quynhanh_film';
  }

  void _handleSavePhoto(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
    AppToast.showSuccess(
      context,
      'Đã lưu khoảnh khắc vào thư viện máy! 📥',
      icon: SolarIconsBold.downloadMinimalistic,
    );
  }

  void _handleCopyLink(BuildContext context) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: 'https://chupchup.social/p/${post.postId}'));
    Navigator.of(context).pop();
    AppToast.showSuccess(
      context,
      'Đã sao chép liên kết bài viết!',
      icon: SolarIconsBold.linkRound,
    );
  }

  void _handleDeletePost(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();

    // Hộp thoại xác nhận xóa bài viết
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Xóa khoảnh khắc này?',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Khoảnh khắc và tất cả các ảnh liên quan sẽ bị xóa vĩnh viễn khỏi trang cá nhân và bảng tin.',
          style: TextStyle(color: Colors.white70, fontSize: 13.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => Navigator.pop(ctx),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF2E2E36),
                        Color(0xFF1E1E24),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AppButton.danger(
                size: AppButtonSize.small,
                borderRadius: BorderRadius.circular(12),
                onPressed: () {
                  Navigator.pop(ctx);
                  onDelete?.call();
                },
                text: 'Xóa vĩnh viễn',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleHidePost(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
    onHide?.call();
    AppToast.showInfo(context, 'Đã ẩn khoảnh khắc này khỏi bảng tin');
  }

  void _handleReportPost(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
    AppToast.showInfo(context, 'Đã gửi báo cáo nội dung tới quản trị viên');
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final cardWidth = media.size.width * 0.72;
    final cardHeight = cardWidth * 1.30;

    return Material(
      type: MaterialType.transparency,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. THẺ ẢNH XEM TRƯỚC (CHỈ HIỆN ẢNH THUẦN TÚY, KHÔNG AVATAR HAY CAPTION)
                  Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.55),
                          blurRadius: 28,
                          spreadRadius: 4,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: activePhotoUrl.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: activePhotoUrl,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(activePhotoUrl),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. MENU THAO TÁC NHANH DẠNG KÍNH MỜ (POP-UP MENU)
                  Container(
                    width: cardWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E22).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // A. Lưu ảnh về máy
                        _buildMenuItem(
                          icon: SolarIconsOutline.downloadMinimalistic,
                          label: 'Lưu ảnh về máy',
                          onTap: () => _handleSavePhoto(context),
                        ),

                        _buildDivider(),

                        // B. Sao chép liên kết
                        _buildMenuItem(
                          icon: SolarIconsOutline.linkRound,
                          label: 'Sao chép liên kết',
                          onTap: () => _handleCopyLink(context),
                        ),

                        // C. Phân nhánh hành động tùy thuộc vào bài viết của ai:
                        if (_isMyPost) ...[
                          _buildDivider(),
                          // Xóa khoảnh khắc của tôi
                          _buildMenuItem(
                            icon: SolarIconsOutline.trashBinTrash,
                            label: 'Xóa khoảnh khắc này',
                            isDestructive: true,
                            onTap: () => _handleDeletePost(context),
                          ),
                        ] else ...[
                          _buildDivider(),
                          // Ẩn bài viết của người khác
                          _buildMenuItem(
                            icon: SolarIconsOutline.eyeClosed,
                            label: 'Ẩn khoảnh khắc này',
                            onTap: () => _handleHidePost(context),
                          ),
                          _buildDivider(),
                          // Báo cáo
                          _buildMenuItem(
                            icon: SolarIconsOutline.dangerTriangle,
                            label: 'Báo cáo vi phạm',
                            isDestructive: true,
                            onTap: () => _handleReportPost(context),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? const Color(0xFFFF453A) : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: color.withValues(alpha: 0.1),
        highlightColor: color.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: isDestructive ? FontWeight.w700 : FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withValues(alpha: 0.06),
    );
  }
}
