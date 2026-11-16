import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_button/like_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../feed/data/models/post_item_model.dart';
import '../../../feed/presentation/widgets/comment_bottom_sheet.dart';
import '../../data/models/album_cup_model.dart';
import '../../data/models/single_photo_item.dart';

Widget _buildDetailPhotoView(String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.surfaceDark,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOlive),
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

class PhotoDetailModal extends StatefulWidget {
  final PostItemModel? post;
  final AlbumCupModel? album;
  final List<AlbumCupModel>? albums;
  final int initialAlbumIndex;
  final int initialIndex;
  final String? albumTitle;
  final Map<int, String>? photoAlbumTitles;

  const PhotoDetailModal({
    super.key,
    this.post,
    this.album,
    this.albums,
    this.initialAlbumIndex = 0,
    this.initialIndex = 0,
    this.albumTitle,
    this.photoAlbumTitles,
  }) : assert(post != null || album != null || (albums != null && albums.length > 0));

  @override
  State<PhotoDetailModal> createState() => _PhotoDetailModalState();
}

class _PhotoDetailModalState extends State<PhotoDetailModal> {
  late final List<AlbumCupModel> _albumList;
  late final PageController _verticalController;
  late final ValueNotifier<int> _activeAlbumNotifier;
  bool _isPureViewMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.albums != null && widget.albums!.isNotEmpty) {
      _albumList = widget.albums!;
    } else if (widget.album != null) {
      _albumList = [widget.album!];
    } else {
      _albumList = [];
    }

    final initialIdx = widget.initialAlbumIndex.clamp(0, (_albumList.length - 1).clamp(0, 9999));
    _activeAlbumNotifier = ValueNotifier<int>(initialIdx);
    _verticalController = PageController(initialPage: initialIdx);
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _activeAlbumNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. NỀN TỐI MỜ MƯỢT MÀ 120FPS (CHẠM VÙNG NGOÀI LÀ TỰ THOÁT)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.black.withValues(alpha: 0.92),
              ),
            ),
          ),

          // 2. KHỐI NỘI DUNG CHÍNH
          SafeArea(
            child: _albumList.isNotEmpty
                ? Stack(
                    children: [
                      // CAROUSEL CUỘN DỌC GIỮA CÁC ALBUM (TRƯỢT LÊN/XUỐNG ĐỂ XEM ALBUM KHÁC)
                      PageView.builder(
                        controller: _verticalController,
                        scrollDirection: Axis.vertical,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _albumList.length,
                        onPageChanged: (index) {
                          _activeAlbumNotifier.value = index;
                        },
                        itemBuilder: (context, albumIdx) {
                          final album = _albumList[albumIdx];
                          return RepaintBoundary(
                            child: _AlbumCardView(
                              key: ValueKey('album_${album.id}'),
                              album: album,
                              initialPhotoIndex: albumIdx == widget.initialAlbumIndex
                                  ? widget.initialIndex
                                  : 0,
                              isPureViewMode: _isPureViewMode,
                              onTogglePureView: () {
                                setState(() {
                                  _isPureViewMode = !_isPureViewMode;
                                });
                              },
                              onClose: () => Navigator.pop(context),
                            ),
                          );
                        },
                      ),

                      // CHỈ SỐ ALBUM DẠNG VIÊN THUỐC DỌC Ở MÉP PHẢI (PHẦN DÀI MÀU TRẮNG ĐỒNG BỘ)
                      if (_albumList.length > 1 && !_isPureViewMode)
                        Positioned(
                          right: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 0.8,
                                ),
                              ),
                              child: ValueListenableBuilder<int>(
                                valueListenable: _activeAlbumNotifier,
                                builder: (context, activeIdx, _) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(_albumList.length, (i) {
                                      final isCurrent = i == activeIdx;
                                      return AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.easeOutCubic,
                                        margin: const EdgeInsets.symmetric(vertical: 3),
                                        width: 6,
                                        height: isCurrent ? 18 : 6,
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
                                                    color: Colors.white.withValues(alpha: 0.35),
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
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                : RepaintBoundary(
                    child: _PostCardView(
                      post: widget.post!,
                      initialIndex: widget.initialIndex,
                      photoAlbumTitles: widget.photoAlbumTitles,
                      albumTitle: widget.albumTitle,
                      isPureViewMode: _isPureViewMode,
                      onTogglePureView: () {
                        setState(() {
                          _isPureViewMode = !_isPureViewMode;
                        });
                      },
                      onClose: () => Navigator.pop(context),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// VIEW HIỂN THỊ CỦA MỘT ALBUM CỤ THỂ (HỖ TRỢ LƯỚT NGANG CÁC ẢNH TRONG ALBUM)
class _AlbumCardView extends StatefulWidget {
  final AlbumCupModel album;
  final int initialPhotoIndex;
  final bool isPureViewMode;
  final VoidCallback onTogglePureView;
  final VoidCallback onClose;

  const _AlbumCardView({
    super.key,
    required this.album,
    this.initialPhotoIndex = 0,
    required this.isPureViewMode,
    required this.onTogglePureView,
    required this.onClose,
  });

  @override
  State<_AlbumCardView> createState() => _AlbumCardViewState();
}

class _AlbumCardViewState extends State<_AlbumCardView> {
  late PageController _photoController;
  late int _currentPhotoIndex;

  @override
  void initState() {
    super.initState();
    final photos = widget.album.photos;
    final maxIdx = (photos.length - 1).clamp(0, 9999);
    _currentPhotoIndex = widget.initialPhotoIndex.clamp(0, maxIdx);
    _photoController = PageController(initialPage: _currentPhotoIndex);
  }

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.album.photos;
    if (photos.isEmpty) return const SizedBox.shrink();

    final totalPhotos = photos.length;
    final SinglePhotoItem currentPhoto = photos[_currentPhotoIndex];
    final PostItemModel currentPost = currentPhoto.parentPost;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onClose,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // TIÊU ĐỀ ALBUM FONT DANCING SCRIPT Ở TRÊN ĐỈNH
            AnimatedOpacity(
              opacity: widget.isPureViewMode ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  widget.album.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dancingScript(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: const [
                      Shadow(
                        color: Colors.black87,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // A. KHỐI CARD CHÍNH (ASPECT RATIO 0.67 & BO GÓC 36PX Y HỆT FEED)
            Flexible(
              child: AspectRatio(
                aspectRatio: 0.67,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onTogglePureView,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 1. CAROUSEL ẢNH (CHỈ CHỨA CÁC ẢNH THỰC SỰ TRONG ALBUM)
                        totalPhotos > 1
                            ? PageView.builder(
                                controller: _photoController,
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: totalPhotos,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentPhotoIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return _buildDetailPhotoView(photos[index].photoUrl);
                                },
                              )
                            : _buildDetailPhotoView(photos.first.photoUrl),

                        // 2. LỚP GRADIENT MỜ ĐÁY ẢNH
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

                        // 3. CHẤM CHỈ SỐ ẢNH DẠNG PILL & CAPTION FONT THƯỜNG
                        if (totalPhotos > 1 || (currentPost.title != null && currentPost.title!.isNotEmpty))
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
                                    // CHẤM CHỈ SỐ ẢNH DẠNG PILL
                                    if (totalPhotos > 1) ...[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(totalPhotos, (i) {
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

                                    // CAPTION FONT THƯỜNG
                                    if (currentPost.title != null && currentPost.title!.isNotEmpty)
                                      Text(
                                        currentPost.title!,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          height: 1.3,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black87,
                                              blurRadius: 6,
                                              offset: Offset(0, 1),
                                            ),
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

            // B. HÀNG NGANG TƯƠNG TÁC (TIM, BÌNH LUẬN, CHIA SẺ, BOOKMARK Y HỆT FEED - LUÔN HIỂN THỊ)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: Row(
                  children: [
                      // 1. LikeButton
                      LikeButton(
                        key: ValueKey('like_album_${widget.album.id}_${currentPost.postId}_$_currentPhotoIndex'),
                        size: 26,
                        isLiked: currentPost.isLikedByMe,
                        likeCount: currentPost.likeCount,
                        countPostion: CountPostion.right,
                        likeCountPadding: const EdgeInsets.only(left: 6),
                        likeCountAnimationType: LikeCountAnimationType.none,
                        likeBuilder: (bool isLiked) {
                          return Icon(
                            isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
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
                          setState(() {
                            currentPost.isLikedByMe = !isLiked;
                            currentPost.likeCount += currentPost.isLikedByMe ? 1 : -1;
                          });
                          return !isLiked;
                        },
                      ),

                      const SizedBox(width: 28),

                      // 2. Bình luận (Comment)
                      GestureDetector(
                        onTap: () => CommentBottomSheet.show(context, currentPost),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 24),
                            const SizedBox(width: 6),
                            Text(
                              '${currentPost.commentCount}',
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

                      // 3. Chia sẻ
                      GestureDetector(
                        onTap: () {
                          AppToast.showSuccess(
                            context,
                            'Đã sao chép liên kết chia sẻ khoảnh khắc!',
                            icon: Icons.link_rounded,
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.arrowshape_turn_up_right,
                              color: Colors.white,
                              size: 23,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${currentPost.shareCount}',
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

                      // 4. Bookmark
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// VIEW HIỂN THỊ CỦA MỘT BÀI POST THÔNG THƯỜNG
class _PostCardView extends StatefulWidget {
  final PostItemModel post;
  final int initialIndex;
  final Map<int, String>? photoAlbumTitles;
  final String? albumTitle;
  final bool isPureViewMode;
  final VoidCallback onTogglePureView;
  final VoidCallback onClose;

  const _PostCardView({
    required this.post,
    this.initialIndex = 0,
    this.photoAlbumTitles,
    this.albumTitle,
    required this.isPureViewMode,
    required this.onTogglePureView,
    required this.onClose,
  });

  @override
  State<_PostCardView> createState() => _PostCardViewState();
}

class _PostCardViewState extends State<_PostCardView> {
  late PageController _photoController;
  late int _currentPhotoIndex;

  @override
  void initState() {
    super.initState();
    final photos = widget.post.photoUrls;
    final maxIdx = (photos.length - 1).clamp(0, 9999);
    _currentPhotoIndex = widget.initialIndex.clamp(0, maxIdx);
    _photoController = PageController(initialPage: _currentPhotoIndex);
  }

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.post.photoUrls;
    final totalPhotos = photos.length;
    final currentAlbumTitle = widget.photoAlbumTitles?[_currentPhotoIndex] ?? widget.albumTitle ?? widget.post.albumTitle;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onClose,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // TIÊU ĐỀ ALBUM (NẾU CÓ)
            if (currentAlbumTitle != null && currentAlbumTitle.isNotEmpty)
              AnimatedOpacity(
                opacity: widget.isPureViewMode ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 250),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    currentAlbumTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dancingScript(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: const [
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // A. CARD CHÍNH
            Flexible(
              child: AspectRatio(
                aspectRatio: 0.67,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onTogglePureView,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        totalPhotos > 1
                            ? PageView.builder(
                                controller: _photoController,
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: totalPhotos,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentPhotoIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return _buildDetailPhotoView(photos[index]);
                                },
                              )
                            : _buildDetailPhotoView(widget.post.photoUrl),

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

                        if (totalPhotos > 1 || (widget.post.title != null && widget.post.title!.isNotEmpty))
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
                                    if (totalPhotos > 1) ...[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(totalPhotos, (i) {
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

                                    if (widget.post.title != null && widget.post.title!.isNotEmpty)
                                      Text(
                                        widget.post.title!,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          height: 1.3,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black87,
                                              blurRadius: 6,
                                              offset: Offset(0, 1),
                                            ),
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

            // B. TƯƠNG TÁC (LUÔN HIỂN THỊ Y HỆT FEED)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: Row(
                  children: [
                      LikeButton(
                        key: ValueKey('like_post_${widget.post.postId}_$_currentPhotoIndex'),
                        size: 26,
                        isLiked: widget.post.isLikedByMe,
                        likeCount: widget.post.likeCount,
                        countPostion: CountPostion.right,
                        likeCountPadding: const EdgeInsets.only(left: 6),
                        likeCountAnimationType: LikeCountAnimationType.none,
                        likeBuilder: (bool isLiked) {
                          return Icon(
                            isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
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
                          setState(() {
                            widget.post.isLikedByMe = !isLiked;
                            widget.post.likeCount += widget.post.isLikedByMe ? 1 : -1;
                          });
                          return !isLiked;
                        },
                      ),

                      const SizedBox(width: 28),

                      GestureDetector(
                        onTap: () => CommentBottomSheet.show(context, widget.post),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 24),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.post.commentCount}',
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

                      GestureDetector(
                        onTap: () {
                          AppToast.showSuccess(
                            context,
                            'Đã sao chép liên kết chia sẻ khoảnh khắc!',
                            icon: Icons.link_rounded,
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.arrowshape_turn_up_right,
                              color: Colors.white,
                              size: 23,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.post.shareCount}',
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

                      // 4. Bookmark
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
