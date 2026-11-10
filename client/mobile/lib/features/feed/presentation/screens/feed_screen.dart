import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:preload_page_view/preload_page_view.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/models/post_item_model.dart';
import '../widgets/feed_header.dart';
import '../widgets/post_card.dart';
import '../widgets/feed_filter_bar.dart';
import '../widgets/feed_grid_view.dart';
import '../../../camera/presentation/screens/camera_capture_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late PreloadPageController _pageController;

  // Trạng thái bộ lọc
  bool _isExploreActive = false;
  String? _selectedFriendId; // null = xem tất cả bạn bè, 'user-2' = chỉ xem Minh Anh
  bool _isGridView = false; // Chế độ xem Lưới (Grid) hay Vuốt đơn (Feed)
  bool _isPureViewMode = false; // Chế độ xem ảnh trọn vẹn (ẩn toàn bộ item trên ảnh)

  // Theo dõi cử chỉ chụm 2 ngón tay (Pinch to zoom)
  double _currentScale = 1.0;

  // Danh sách bạn bè để hiển thị dải avatar
  final List<FriendFilterItem> _friends = const [
    FriendFilterItem(
      userId: 'user-2',
      name: 'Minh Anh',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      hasNewPost: true,
    ),
    FriendFilterItem(
      userId: 'user-1',
      name: 'Trần Tấn',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      hasNewPost: true,
    ),
    FriendFilterItem(
      userId: 'user-3',
      name: 'Hoàng Nam',
      avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200',
      hasNewPost: false,
    ),
  ];

  // Toàn bộ dữ liệu bài đăng mẫu (gồm cả bài của bạn bè và bài khám phá cộng đồng)
  final List<PostItemModel> _allPosts = [
    // BÀI ĐĂNG CỦA MINH ANH (user-2) - BÀI ĐĂNG 3 ẢNH
    PostItemModel(
      postId: '2-1',
      userId: 'user-2',
      authorUserName: 'minhanh.cute',
      authorFullName: 'Minh Anh',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      title: 'Dắt boss cưng đi dạo công viên cuối tuần 🐶✨',
      createdAt: DateTime.now().subtract(const Duration(minutes: 42)),
      photoUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=1080',
      photoUrls: const [
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=1080',
        'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=1080',
        'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=1080',
      ],
      likeCount: 58,
      commentCount: 12,
      shareCount: 7,
      isLikedByMe: false,
      friendshipStatus: FriendshipStatus.friends,
    ),
    PostItemModel(
      postId: '2-2',
      userId: 'user-2',
      authorUserName: 'minhanh.cute',
      authorFullName: 'Minh Anh',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      title: 'Trà sữa chiều với hội bạn thân 🧋',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      photoUrl: 'https://images.unsplash.com/photo-1558857563-b37fe3160a22?w=1080',
      likeCount: 41,
      commentCount: 8,
      shareCount: 3,
      isLikedByMe: true,
      friendshipStatus: FriendshipStatus.friends,
    ),
    PostItemModel(
      postId: '2-3',
      userId: 'user-2',
      authorUserName: 'minhanh.cute',
      authorFullName: 'Minh Anh',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      title: 'Check-in bảo tàng Mỹ thuật cuối tuần 🎨',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      photoUrl: 'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?w=1080',
      likeCount: 72,
      commentCount: 15,
      shareCount: 5,
      isLikedByMe: true,
      friendshipStatus: FriendshipStatus.friends,
    ),

    // BÀI ĐĂNG CỦA TRẦN TẤN (user-1) - BÀI ĐĂNG 2 ẢNH
    PostItemModel(
      postId: '1-1',
      userId: 'user-1',
      authorUserName: 'tan_tran',
      authorFullName: 'Trần Tấn',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      title: 'Chiều hoàng hôn tuyệt đẹp trên đèo Đà Lạt 🌅',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      photoUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1080',
      photoUrls: const [
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1080',
        'https://images.unsplash.com/photo-1510312305653-8ed496efae75?w=1080',
      ],
      likeCount: 24,
      commentCount: 5,
      shareCount: 2,
      isLikedByMe: true,
      friendshipStatus: FriendshipStatus.friends,
    ),
    PostItemModel(
      postId: '1-2',
      userId: 'user-1',
      authorUserName: 'tan_tran',
      authorFullName: 'Trần Tấn',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      title: 'Camping hồ Trị An cùng anh em ⛺🔥',
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      photoUrl: 'https://images.unsplash.com/photo-1510312305653-8ed496efae75?w=1080',
      likeCount: 39,
      commentCount: 6,
      shareCount: 4,
      isLikedByMe: false,
      friendshipStatus: FriendshipStatus.friends,
    ),

    // BÀI ĐĂNG CỦA HOÀNG NAM (user-3)
    PostItemModel(
      postId: '3-1',
      userId: 'user-3',
      authorUserName: 'nam.street',
      authorFullName: 'Hoàng Nam',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200',
      title: 'Cà phê sáng cùng bạn bè ở góc phố quen ☕',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      photoUrl: 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=1080',
      likeCount: 19,
      commentCount: 3,
      shareCount: 1,
      isLikedByMe: false,
      friendshipStatus: FriendshipStatus.requested,
    ),

    // BÀI ĐĂNG CỘNG ĐỒNG KHÁM PHÁ (CHƯA KẾT BẠN)
    PostItemModel(
      postId: 'ex-1',
      userId: 'user-ex1',
      authorUserName: 'quynhanh_travel',
      authorFullName: 'Quỳnh Anh Travel',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
      title: 'Săn mây Tà Xùa đỉnh Gió sớm tinh mơ ☁️🏔️',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      photoUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=1080',
      likeCount: 145,
      commentCount: 28,
      shareCount: 22,
      isLikedByMe: false,
      friendshipStatus: FriendshipStatus.none,
    ),
    PostItemModel(
      postId: 'ex-2',
      userId: 'user-ex2',
      authorUserName: 'duy_lens',
      authorFullName: 'Duy Photo',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      title: 'Bình minh Phú Quốc nước xanh biếc trong vắt 🏝️',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      photoUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1080',
      likeCount: 89,
      commentCount: 14,
      shareCount: 10,
      isLikedByMe: false,
      friendshipStatus: FriendshipStatus.none,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PreloadPageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // LẤY DANH SÁCH BÀI ĐĂNG THEO BỘ LỌC
  List<PostItemModel> get _currentPosts {
    if (_isExploreActive) {
      // KHÁM PHÁ BAO GỒM TOÀN BỘ BÀI ĐĂNG (CẢ NHỮNG NGƯỜI ĐANG FOLLOW VÀ CỘNG ĐỒNG)
      return _allPosts;
    }

    if (_selectedFriendId != null) {
      // Chế độ Only 1 bạn: Chỉ lọc duy nhất các bài đăng của người bạn đó
      return _allPosts.where((p) => p.userId == _selectedFriendId).toList();
    }

    // Chế độ Bạn bè: Chỉ lấy các bài của bạn bè đã kết bạn / đang chờ
    return _allPosts.where((p) => p.friendshipStatus != FriendshipStatus.none).toList();
  }

  // Tên bạn bè đang chọn (nếu có)
  String? get _selectedFriendName {
    if (_selectedFriendId == null) return null;
    final friend = _friends.where((f) => f.userId == _selectedFriendId).firstOrNull;
    return friend?.name;
  }

  void _openCameraSlideUp() async {
    final newPost = await Navigator.of(context).push<PostItemModel>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) => const CameraCaptureScreen(),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );

    if (newPost != null && mounted) {
      setState(() {
        _allPosts.insert(0, newPost);
        _selectedFriendId = null;
        _isExploreActive = false;
        _isGridView = false;
      });
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      AppToast.showSuccess(
        context,
        'Đã gửi khoảnh khắc (${newPost.photoUrls.length} ảnh) thành công! ✨',
        icon: Icons.auto_awesome_rounded,
      );
    }
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cài đặt ứng dụng',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.people_outline_rounded, color: Colors.white),
                  title: const Text('Quản lý bạn bè', style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/friends');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                  title: const Text('Thông báo khoảnh khắc mới', style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  title: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/login');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayPosts = _currentPosts;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. TẦNG NỀN: VÙNG HIỂN THỊ CHÍNH (FULL-BLEED TRÀN MÀN HÌNH - KHÔNG BỊ CẮT NGANG KHI VUỐT)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onScaleStart: (details) {
                _currentScale = 1.0;
              },
              onScaleUpdate: (details) {
                if (details.pointerCount >= 2) {
                  _currentScale = details.scale;
                }
              },
              onScaleEnd: (details) {
                // CỬ CHỈ 2 NGÓN TAY TRÊN KHU VỰC FEED / GRID:
                if (_isGridView) {
                  // A. Đang ở Grid View: Banh 2 ngón tay ra (scale > 1.15) -> Trở về Feed 1 ảnh!
                  if (_currentScale > 1.15) {
                    setState(() {
                      _isGridView = false;
                      _isPureViewMode = false;
                    });
                  }
                } else {
                  // B. Đang ở Feed 1 ảnh:
                  if (_isPureViewMode) {
                    // Đang ở chế độ xem trọn vẹn: Zoom nhỏ (scale < 0.88) -> Trở về bình thường
                    if (_currentScale < 0.88) {
                      setState(() => _isPureViewMode = false);
                    }
                  } else {
                    // Đang ở bình thường:
                    // 1. Chụm 2 ngón tay (zoom nhỏ, scale < 0.85) -> BUNG RA GRID VIEW!
                    if (_currentScale < 0.85) {
                      setState(() {
                        _isGridView = true;
                        _isPureViewMode = false;
                      });
                    }
                    // 2. Banh 2 ngón tay (zoom bự, scale > 1.15) -> ẨN ITEM ĐỂ XEM ẢNH TRỌN VẸN!
                    else if (_currentScale > 1.15) {
                      setState(() => _isPureViewMode = true);
                    }
                  }
                }
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _isGridView
                    // A. CHẾ ĐỘ XEM LƯỚI (GRID VIEW)
                    ? Padding(
                        padding: EdgeInsets.only(
                          top: topPadding + 90,
                          bottom: bottomPadding + 68,
                        ),
                        child: FeedGridView(
                          key: const ValueKey('grid_view'),
                          posts: displayPosts,
                          filterName: _selectedFriendName,
                          onPostTap: (index) {
                            setState(() {
                              _isGridView = false;
                              _isPureViewMode = false;
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_pageController.hasClients) {
                                _pageController.jumpToPage(index);
                              }
                            });
                          },
                        ),
                      )
                    // B. CHẾ ĐỘ XEM VUỐT ĐƠN (FULL SWIPE FEED TRÀN VIỀN VÔ CỰC)
                    : displayPosts.isEmpty
                        ? const Center(
                            child: Text(
                              'Chưa có khoảnh khắc nào',
                              style: TextStyle(color: Colors.white54, fontSize: 16),
                            ),
                          )
                        : PreloadPageView.builder(
                            key: const ValueKey('feed_page_view'),
                            controller: _pageController,
                            scrollDirection: Axis.vertical,
                            preloadPagesCount: 2,
                            itemCount: displayPosts.length,
                            itemBuilder: (context, index) {
                              final post = displayPosts[index];
                              return PostCard(
                                key: ValueKey(post.postId),
                                post: post,
                                isPureViewMode: _isPureViewMode,
                                onTogglePureView: () {
                                  setState(() {
                                    _isPureViewMode = !_isPureViewMode;
                                  });
                                },
                                onLikeToggle: (isLiked) {
                                  setState(() {
                                    post.isLikedByMe = isLiked;
                                    post.likeCount += isLiked ? 1 : -1;
                                  });
                                },
                                onFriendshipChanged: (newStatus) {
                                  setState(() {
                                    post.friendshipStatus = newStatus;
                                  });
                                },
                              );
                            },
                          ),
              ),
            ),
          ),

          // 2. TẦNG NỔI TRÊN CÙNG: HEADER & TIÊU ĐỀ (GRADIENT SCRIM MỜ ĐỂ CHỮ RÕ NÉT)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: _isPureViewMode,
              child: AnimatedOpacity(
                opacity: _isPureViewMode ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.92),
                        Colors.black.withValues(alpha: 0.65),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Cài đặt - New Post - Profile
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
                          child: FeedHeader(
                            onSettingsTap: _showSettingsModal,
                            onNewPostTap: _openCameraSlideUp,
                            onProfileTap: () => context.push('/profile'),
                          ),
                        ),

                        // TIÊU ĐỀ FONT DANCING SCRIPT TINH TẾ (KHÁM PHÁ / BẠN BÈ / TÊN BẠN)
                        Padding(
                          padding: const EdgeInsets.only(top: 2, bottom: 12),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            child: Text(
                              _isExploreActive
                                  ? 'Khám phá'
                                  : (_selectedFriendName != null ? _selectedFriendName! : 'Bạn bè'),
                              key: ValueKey('title_${_isExploreActive}_$_selectedFriendId'),
                              style: GoogleFonts.dancingScript(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: AppColors.primaryYellow.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 1),
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
          ),

          // 3. TẦNG NỔI DƯỚI ĐÁY: NHÓM NÚT BẠN BÈ / KHÁM PHÁ / GRID (GRADIENT SCRIM MỜ ĐÁY)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: _isPureViewMode,
              child: AnimatedOpacity(
                opacity: _isPureViewMode ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.65),
                        Colors.black.withValues(alpha: 0.95),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.35, 1.0],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 14, 0, 8),
                      child: FeedFilterBar(
                        isExploreActive: _isExploreActive,
                        onExploreToggle: () {
                          setState(() {
                            _isExploreActive = !_isExploreActive;
                            _selectedFriendId = null;
                          });
                          if (!_isGridView && _pageController.hasClients) {
                            _pageController.jumpToPage(0);
                          }
                        },
                        friends: _friends,
                        selectedFriendId: _selectedFriendId,
                        onFriendSelected: (friendId) {
                          setState(() {
                            _isExploreActive = false; // Tắt khám phá khi chọn bạn cụ thể
                            _selectedFriendId = friendId;
                          });
                          if (!_isGridView && _pageController.hasClients) {
                            _pageController.jumpToPage(0);
                          }
                        },
                        isGridView: _isGridView,
                        onGridToggle: () {
                          setState(() {
                            _isGridView = !_isGridView;
                            _isPureViewMode = false;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
