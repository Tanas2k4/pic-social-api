import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../feed/data/models/post_item_model.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/models/album_cup_model.dart';
import '../../data/repositories/profile_repository.dart';
import '../widgets/compact_profile_header.dart';
import '../widgets/floating_canvas_tab.dart';
import '../widgets/wavy_timeline_tab.dart';
import '../widgets/starry_cosmos_background.dart';
import '../widgets/photo_detail_modal.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _repository = ProfileRepository();

  UserProfileModel? _profile;
  List<PostItemModel> _posts = [];
  bool _isLoading = true;

  ProfileActiveTab _activeTab = ProfileActiveTab.floatingCanvas;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _repository.getMyProfile();
      final posts = await _repository.getUserPosts(profile.userName);
      if (mounted) {
        setState(() {
          _profile = profile;
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handlePhotoTap(
    PostItemModel post, [
    int initialIndex = 0,
    Map<int, String>? photoAlbumTitles,
  ]) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PhotoDetail',
      barrierColor: Colors.black.withValues(alpha: 0.9),
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: child,
        );
      },
      pageBuilder: (ctx, anim1, anim2) {
        return PhotoDetailModal(
          post: post,
          initialIndex: initialIndex,
          photoAlbumTitles: photoAlbumTitles,
        );
      },
    );
  }

  void _handleAlbumPhotoTap(
    AlbumCupModel album,
    int initialIndex, [
    List<AlbumCupModel>? allAlbums,
  ]) {
    final albums = allAlbums ?? [album];
    final albumIdx = albums.indexWhere((a) => a.id == album.id);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PhotoDetail',
      barrierColor: Colors.black.withValues(alpha: 0.9),
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: child,
        );
      },
      pageBuilder: (ctx, anim1, anim2) {
        return PhotoDetailModal(
          album: album,
          albums: albums,
          initialAlbumIndex: albumIdx >= 0 ? albumIdx : 0,
          initialIndex: initialIndex,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryOlive,
          ),
        ),
      );
    }

    final profile = _profile ??
        const UserProfileModel(
          userName: 'quynhanh_film',
          firstName: 'Quỳnh Anh',
          bio: 'Chụp phim & lưu giữ khoảnh khắc 🌿',
        );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 0. BẦU TRỜI ĐẦY SAO VÀ TINH VÂN LUNG LINH XUYÊN SUỐT TOÀN MÀN HÌNH
          const Positioned.fill(
            child: StarryCosmosBackground(),
          ),

          // 1. Vùng hiển thị chính (Tab 1 hoặc Tab 2) chiếm trọn màn hình
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _activeTab == ProfileActiveTab.floatingCanvas
                  ? FloatingCanvasTab(
                      key: const ValueKey('floating_tab'),
                      initialPosts: _posts,
                      onPhotoTap: (post, initialIndex, [albumMap]) =>
                          _handlePhotoTap(post, initialIndex, albumMap),
                      onAlbumPhotoTap: (album, initialIndex, allAlbums) =>
                          _handleAlbumPhotoTap(album, initialIndex, allAlbums),
                    )
                  : WavyTimelineTab(
                      key: const ValueKey('timeline_tab'),
                      posts: _posts,
                      onPhotoTap: (post, [albumTitle]) =>
                          _handlePhotoTap(post, 0),
                    ),
            ),
          ),

          // 2. Header góc nhỏ đặt phía trên (Overlay Glassmorphic)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CompactProfileHeader(
              profile: profile,
              postCount: _posts.length,
              currentTab: _activeTab,
              onTabChanged: (tab) => setState(() => _activeTab = tab),
              onBackTap: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }
}
