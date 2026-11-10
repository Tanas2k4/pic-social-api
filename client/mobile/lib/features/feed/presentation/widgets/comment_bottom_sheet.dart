import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_colors.dart';
import '../../data/models/post_item_model.dart';

/// Dữ liệu định nghĩa 10 Custom Neon Glow Icon
class NeonGlowIconData {
  final int id;
  final String name;
  final IconData icon;
  final Color primaryColor;
  final Color glowColor;

  const NeonGlowIconData({
    required this.id,
    required this.name,
    required this.icon,
    required this.primaryColor,
    required this.glowColor,
  });
}

// BỘ 10 CUSTOM NEON GLOW ICONS ĐỘC QUYỀN CỦA CHUPCHUP
final List<NeonGlowIconData> kNeonGlowIcons = [
  // 1. Neon Trái tim nảy lửa
  const NeonGlowIconData(
    id: 1,
    name: 'Trái tim',
    icon: Icons.favorite_rounded,
    primaryColor: Color(0xFFFF2A6D),
    glowColor: Color(0xFFFF0055),
  ),
  // 2. Neon Ngọn lửa rực cháy
  const NeonGlowIconData(
    id: 2,
    name: 'Ngọn lửa',
    icon: Icons.local_fire_department_rounded,
    primaryColor: Color(0xFFFF7A00),
    glowColor: Color(0xFFFF4D00),
  ),
  // 3. Neon Ngôi sao vàng ChupChup
  const NeonGlowIconData(
    id: 3,
    name: 'Lấp lánh',
    icon: Icons.auto_awesome_rounded,
    primaryColor: Color(0xFFFFE600),
    glowColor: Color(0xFFFFB800),
  ),
  // 4. Neon Mặt cười rạng rỡ (Cyan)
  const NeonGlowIconData(
    id: 4,
    name: 'Vui vẻ',
    icon: Icons.sentiment_very_satisfied_rounded,
    primaryColor: Color(0xFF00F0FF),
    glowColor: Color(0xFF00BFFF),
  ),
  // 5. Neon Tiệc tùng / Pháo hoa (Magenta)
  const NeonGlowIconData(
    id: 5,
    name: 'Tiệc tùng',
    icon: Icons.celebration_rounded,
    primaryColor: Color(0xFFD000FF),
    glowColor: Color(0xFFAA00FF),
  ),
  // 6. Neon Like / Tuyệt vời (Lime Green)
  const NeonGlowIconData(
    id: 6,
    name: 'Tuyệt đỉnh',
    icon: Icons.thumb_up_alt_rounded,
    primaryColor: Color(0xFF39FF14),
    glowColor: Color(0xFF00FF66),
  ),
  // 7. Neon Tia sét năng lượng (Volt)
  const NeonGlowIconData(
    id: 7,
    name: 'Tia sét',
    icon: Icons.bolt_rounded,
    primaryColor: Color(0xFFFFFF00),
    glowColor: Color(0xFFFFD700),
  ),
  // 8. Neon Yêu thương / Tri kỷ (Rose)
  const NeonGlowIconData(
    id: 8,
    name: 'Yêu thương',
    icon: Icons.volunteer_activism_rounded,
    primaryColor: Color(0xFFFF3399),
    glowColor: Color(0xFFFF007F),
  ),
  // 9. Neon Chill / Cà phê góc phố (Sky Blue)
  const NeonGlowIconData(
    id: 9,
    name: 'Cà phê chill',
    icon: Icons.local_cafe_rounded,
    primaryColor: Color(0xFF00E5FF),
    glowColor: Color(0xFF0099FF),
  ),
  // 10. Neon Giai điệu phiêu lãng (Coral Pink)
  const NeonGlowIconData(
    id: 10,
    name: 'Âm nhạc',
    icon: Icons.music_note_rounded,
    primaryColor: Color(0xFFFF5252),
    glowColor: Color(0xFFFF1744),
  ),
];

class CommentItemModel {
  final String id;
  final String authorName;
  final String avatarUrl;
  final String content;
  final DateTime createdAt;
  final bool isAuthor;
  final int? neonIconId;
  int likeCount;
  bool isLiked;

  CommentItemModel({
    required this.id,
    required this.authorName,
    required this.avatarUrl,
    required this.content,
    required this.createdAt,
    this.isAuthor = false,
    this.neonIconId,
    this.likeCount = 0,
    this.isLiked = false,
  });
}

class CommentBottomSheet extends StatefulWidget {
  final PostItemModel post;

  const CommentBottomSheet({super.key, required this.post});

  static void show(BuildContext context, PostItemModel post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => CommentBottomSheet(post: post),
    );
  }

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  NeonGlowIconData? _selectedNeonIcon;

  // Dữ liệu bình luận mẫu sinh động
  late List<CommentItemModel> _comments;

  @override
  void initState() {
    super.initState();
    _comments = [
      CommentItemModel(
        id: 'c1',
        authorName: 'Trần Tấn',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
        content: 'Bức ảnh chụp góc này ánh sáng đỉnh thật sự luôn bạn ơi! 📸✨',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        neonIconId: 3, // Neon Star
        likeCount: 4,
        isLiked: true,
      ),
      CommentItemModel(
        id: 'c2',
        authorName: widget.post.authorFullName ?? widget.post.authorUserName,
        avatarUrl: widget.post.authorAvatarUrl ?? '',
        content: 'Cảm ơn ông nhé, chụp bằng cam góc rộng á haha 😄',
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
        isAuthor: true, // Tác giả bài viết
        neonIconId: 4, // Neon Laugh
        likeCount: 2,
      ),
      CommentItemModel(
        id: 'c3',
        authorName: 'Hoàng Nam',
        avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200',
        content: 'Cháy quá, cuối tuần sau set kèo đi chung tiếp nào anh em! 🔥🔥',
        createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
        neonIconId: 2, // Neon Fire
        likeCount: 1,
      ),
    ];
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty && _selectedNeonIcon == null) return;

    setState(() {
      _comments.add(
        CommentItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          authorName: 'Bạn',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
          content: text.isEmpty ? _selectedNeonIcon!.name : text,
          createdAt: DateTime.now(),
          neonIconId: _selectedNeonIcon?.id,
          likeCount: 0,
        ),
      );
      widget.post.commentCount += 1;
      _commentController.clear();
      _selectedNeonIcon = null;
    });

    _scrollToBottom();
  }

  // WIDGET HIỂN THỊ MỘT NEON GLOW ICON (ĐÃ BỎ BORDER TRÒN)
  Widget _buildNeonIconWidget(NeonGlowIconData item, {double size = 26, bool isSelected = false}) {
    return Container(
      width: size + 14,
      height: size + 14,
      decoration: BoxDecoration(
        color: isSelected
            ? item.primaryColor.withValues(alpha: 0.22)
            : Colors.transparent,
        shape: BoxShape.circle,
        // ĐÃ BỎ HOÀN TOÀN BORDER THEO YÊU CẦU
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: item.glowColor.withValues(alpha: 0.6),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          item.icon,
          size: size,
          color: item.primaryColor,
          shadows: [
            Shadow(
              color: item.glowColor,
              blurRadius: 12,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isKeyboardOpen = bottomInset > 0;

    // Chiều cao tự thích ứng mượt mà: khi bật bàn phím thì khung trượt lên trên bàn phím mà không bóp nghẹt ListView
    final double sheetHeight = isKeyboardOpen
        ? (screenHeight - bottomInset - 36).clamp(340.0, screenHeight * 0.85)
        : screenHeight * 0.72;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: sheetHeight,
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // 1. THANH KÉO (DRAG HANDLE) & TIÊU ĐỀ
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_rounded, color: AppColors.primaryYellow, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Bình luận (${_comments.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Nút Đóng
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white10, height: 1),

            // 2. DANH SÁCH BÌNH LUẬN (BONG BÓNG CHAT iMESSAGE - CÔ LẬP REPAINT LAYER)
            Expanded(
              child: RepaintBoundary(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final c = _comments[index];
                    final neonData = c.neonIconId != null
                        ? kNeonGlowIcons.firstWhere((n) => n.id == c.neonIconId)
                        : null;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar người comment
                          CircleAvatar(
                            radius: 17,
                            backgroundImage: CachedNetworkImageProvider(c.avatarUrl),
                          ),
                          const SizedBox(width: 10),

                          // Bong bóng lời nhắn (Bubble Chat)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tên + Badge tác giả + Thời gian
                                Row(
                                  children: [
                                    Text(
                                      c.authorName,
                                      style: TextStyle(
                                        color: c.isAuthor ? AppColors.primaryYellow : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (c.isAuthor) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryYellow.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'Tác giả',
                                          style: TextStyle(
                                            color: AppColors.primaryYellow,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(width: 8),
                                    Text(
                                      timeago.format(c.createdAt, locale: 'vi'),
                                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                // Khung nội dung comment bo tròn (ĐÃ BỎ BORDER HOÀN TOÀN)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF222222),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          c.content,
                                          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
                                        ),
                                      ),
                                      // Nếu có Neon Glow Icon đính kèm
                                      if (neonData != null) ...[
                                        const SizedBox(width: 8),
                                        _buildNeonIconWidget(neonData, size: 20),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // 3. DẢI 10 CUSTOM NEON GLOW ICONS PHẢN ỨNG NHANH (CÔ LẬP LAYER SHADOW BLUR)
            RepaintBoundary(
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  border: const Border(
                    top: BorderSide(color: Colors.white10),
                  ),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: kNeonGlowIcons.length,
                  itemBuilder: (context, index) {
                    final item = kNeonGlowIcons[index];
                    final isSelected = _selectedNeonIcon?.id == item.id;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            // Chạm vào để chọn hoặc bỏ chọn
                            if (_selectedNeonIcon?.id == item.id) {
                              _selectedNeonIcon = null;
                            } else {
                              _selectedNeonIcon = item;
                            }
                          });
                        },
                        child: _buildNeonIconWidget(
                          item,
                          size: 24,
                          isSelected: isSelected,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 4. THANH NHẬP COMMENT DẠNG VIÊN THUỐC (PILL INPUT - CỐ ĐỊNH PADDING ĐÁY 12PX)
            RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    // Khung nhập
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF262626),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: _selectedNeonIcon != null
                                ? _selectedNeonIcon!.primaryColor.withValues(alpha: 0.5)
                                : Colors.white12,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Icon đã chọn (nếu có)
                            if (_selectedNeonIcon != null) ...[
                              Icon(
                                _selectedNeonIcon!.icon,
                                color: _selectedNeonIcon!.primaryColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                textCapitalization: TextCapitalization.sentences,
                                onTap: _scrollToBottom,
                                decoration: InputDecoration(
                                  hintText: 'Gửi lời nhắn cho ${widget.post.authorFullName ?? widget.post.authorUserName}...',
                                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onSubmitted: (_) => _sendComment(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Nút Gửi (Màu Vàng Neon ChupChup)
                    GestureDetector(
                      onTap: _sendComment,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryYellow.withValues(alpha: 0.45),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.send_rounded, color: Colors.black, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
