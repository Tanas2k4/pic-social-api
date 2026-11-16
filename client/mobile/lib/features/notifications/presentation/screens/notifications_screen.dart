import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/viewfinder_background.dart';

enum NotificationType {
  like,
  comment,
  friendPost,
  filmRollReady,
}

class NotificationItemModel {
  final String id;
  final NotificationType type;
  final String actorName;
  final String actorAvatar;
  final String message;
  final String timeAgo;
  final String? postThumbnail;
  bool isRead;

  NotificationItemModel({
    required this.id,
    required this.type,
    required this.actorName,
    required this.actorAvatar,
    required this.message,
    required this.timeAgo,
    this.postThumbnail,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onBackTap;

  const NotificationsScreen({super.key, this.onBackTap});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // KHÔNG CHỨA THÔNG BÁO KẾT BẠN (vì đã có màn hình Bạn bè riêng)
  final List<NotificationItemModel> _notifications = [
    NotificationItemModel(
      id: 'notif-1',
      type: NotificationType.like,
      actorName: 'Minh Anh',
      actorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      message: 'đã thích cuộn ảnh "Camping hồ Trị An" của bạn',
      timeAgo: '5 phút trước',
      postThumbnail: 'https://images.unsplash.com/photo-1510312305653-8ed496efae75?w=200',
      isRead: false,
    ),
    NotificationItemModel(
      id: 'notif-2',
      type: NotificationType.comment,
      actorName: 'Hoàng Nam',
      actorAvatar: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200',
      message: 'đã bình luận: "Màu film này nhìn ấm và có chiều sâu quá bạn ơi! 🎞️"',
      timeAgo: '42 phút trước',
      postThumbnail: 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=200',
      isRead: false,
    ),
    NotificationItemModel(
      id: 'notif-3',
      type: NotificationType.comment,
      actorName: 'Quỳnh Anh',
      actorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
      message: 'đã nhắc đến bạn trong cuộn ảnh "Săn mây Tà Xùa đỉnh Gió ☁️"',
      timeAgo: '2 giờ trước',
      postThumbnail: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=200',
      isRead: false,
    ),
    NotificationItemModel(
      id: 'notif-4',
      type: NotificationType.friendPost,
      actorName: 'Duy Photo',
      actorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      message: 'vừa chụp 3 khoảnh khắc mới tại "Bình minh Phú Quốc 🏝️"',
      timeAgo: '4 giờ trước',
      postThumbnail: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=200',
      isRead: true,
    ),
    NotificationItemModel(
      id: 'notif-5',
      type: NotificationType.filmRollReady,
      actorName: 'PicSocial Lab',
      actorAvatar: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=200',
      message: 'Cuộn ảnh Film hoài niệm tuần này của bạn đã sẵn sàng để ngắm lại!',
      timeAgo: 'Hôm qua',
      isRead: true,
    ),
    NotificationItemModel(
      id: 'notif-6',
      type: NotificationType.like,
      actorName: 'Trần Tấn',
      actorAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      message: 'đã thả tim khoảnh khắc chụp phố cổ của bạn',
      timeAgo: '2 ngày trước',
      postThumbnail: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=200',
      isRead: true,
    ),
  ];

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllAsRead() {
    HapticFeedback.lightImpact();
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
    AppToast.showSuccess(context, 'Đã đánh dấu tất cả thông báo là đã đọc');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050507),
      body: ViewfinderBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
          children: [
            // 1. HEADER THÔNG BÁO (ĐÃ BỎ NÚT MŨI TÊN THOÁT)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
              child: Row(
                children: [
                  Text(
                    'Thông báo',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF28282E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_unreadCount mới',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (_unreadCount > 0)
                    GestureDetector(
                      onTap: _markAllAsRead,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Text(
                          'Đã đọc hết',
                          style: GoogleFonts.nunito(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 2. DANH SÁCH THÔNG BÁO
            Expanded(
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(top: 2, bottom: 95), // Chừa chỗ cho dock đáy
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notif = _notifications[index];
                  return _buildNotificationTile(notif);
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // --- THẺ THÔNG BÁO:
  // - Khi ĐÃ ĐỌC: Nền giống item bên Add Friends (const Color(0xFF141416))
  // - Khi CHƯA ĐỌC: Nền giống Button không có Oliu ([Color(0xFF28282E), Color(0xFF18181C)])
  // - BỎ CHẤM OLIU KHI LÀ THÔNG BÁO MỚI
  Widget _buildNotificationTile(NotificationItemModel notif) {
    final bool isUnread = !notif.isRead;

    final decoration = isUnread
        ? BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF28282E), // Gradient Graphite tối giống button không có Oliu
                Color(0xFF18181C),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          )
        : BoxDecoration(
            color: const Color(0xFF141416), // Nền phẳng giống item bên Add Friends
            borderRadius: BorderRadius.circular(14),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4.5),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => notif.isRead = true);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: decoration,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar người tương tác kèm badge icon nhỏ
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: const Color(0xFF28282E),
                    backgroundImage: NetworkImage(notif.actorAvatar),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        color: _getBadgeColor(notif.type),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Icon(
                        _getBadgeIcon(notif.type),
                        color: Colors.white,
                        size: 9.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Nội dung thông báo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: GoogleFonts.nunito(
                          fontSize: 13.5,
                          color: Colors.white,
                          height: 1.35,
                        ),
                        children: [
                          TextSpan(
                            text: notif.actorName,
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: notif.message,
                            style: GoogleFonts.nunito(
                              color: isUnread ? Colors.white : Colors.white70,
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notif.timeAgo,
                      style: GoogleFonts.nunito(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Thumbnail bài viết (nếu có)
              if (notif.postThumbnail != null) ...[
                const SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.network(
                        notif.postThumbnail!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(width: 44, height: 44),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBadgeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return SolarIconsBold.heart;
      case NotificationType.comment:
        return SolarIconsBold.chatRound;
      case NotificationType.friendPost:
        return SolarIconsBold.camera;
      case NotificationType.filmRollReady:
        return SolarIconsBold.gallery;
    }
  }

  Color _getBadgeColor(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Colors.redAccent;
      case NotificationType.comment:
        return Colors.blueAccent;
      case NotificationType.friendPost:
        return Colors.amber;
      case NotificationType.filmRollReady:
        return Colors.purpleAccent;
    }
  }
}
