import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../feed/data/models/post_item_model.dart';
import '../../data/models/album_cup_model.dart';
import '../../data/models/single_photo_item.dart';
import 'glass_cup_widget.dart';
import 'album_cup_dialog.dart';

class FloatingPhotoItem {
  final SinglePhotoItem photo;
  Offset position;
  Offset velocity;
  double angle;
  double floatPhase;
  bool isDragging;

  FloatingPhotoItem({
    required this.photo,
    required this.position,
    this.velocity = Offset.zero,
    required this.angle,
    required this.floatPhase,
    this.isDragging = false,
  });
}

class FloatingCanvasTab extends StatefulWidget {
  final List<PostItemModel> initialPosts;
  final Function(PostItemModel post, int initialIndex, [Map<int, String>? photoAlbumTitles])? onPhotoTap;
  final Function(AlbumCupModel album, int initialIndex, List<AlbumCupModel> allAlbums)? onAlbumPhotoTap;

  const FloatingCanvasTab({
    super.key,
    required this.initialPosts,
    this.onPhotoTap,
    this.onAlbumPhotoTap,
  });

  @override
  State<FloatingCanvasTab> createState() => _FloatingCanvasTabState();
}

class _FloatingCanvasTabState extends State<FloatingCanvasTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final Random _random = Random();

  List<FloatingPhotoItem> _floatingItems = [];
  bool _isInitialized = false;

  final List<AlbumCupModel> _albumCups = [];
  String? _hoveredAlbumId;
  DateTime? _lastFullToastTime;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(_tickPhysics);

    _animController.repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _initializeItems(Size size) {
    if (_isInitialized || size.width == 0 || size.height == 0) return;

    // TÁCH RỜI TỪNG BỨC ẢNH ĐƠN LẺ TỪ CÁC POST (TỐI ĐA 3 ẢNH/POST)
    final List<SinglePhotoItem> allSinglePhotos = [];
    for (var post in widget.initialPosts) {
      for (int i = 0; i < post.photoUrls.length; i++) {
        allSinglePhotos.add(
          SinglePhotoItem(
            id: '${post.postId}_$i',
            photoUrl: post.photoUrls[i],
            photoIndex: i,
            parentPost: post,
          ),
        );
      }
    }

    _floatingItems = [];

    // Tạo sẵn 2 chiếc ly mẫu có ảnh cắm xòe sẵn để test đa album
    if (_albumCups.isEmpty) {
      final initialPhotos1 = allSinglePhotos.length >= 2
          ? [allSinglePhotos.removeAt(0), allSinglePhotos.removeAt(0)]
          : <SinglePhotoItem>[];

      _albumCups.add(
        AlbumCupModel(
          id: 'cup-1',
          name: 'Film 35mm',
          position: Offset(size.width * 0.16, 220),
          photos: initialPhotos1,
          floatPhase: _random.nextDouble() * 2 * pi,
        ),
      );

      if (allSinglePhotos.length >= 2) {
        final initialPhotos2 = [allSinglePhotos.removeAt(0), allSinglePhotos.removeAt(0)];
        _albumCups.add(
          AlbumCupModel(
            id: 'cup-2',
            name: 'Đà Lạt Mộng Mơ',
            position: Offset(size.width * 0.62, 260),
            photos: initialPhotos2,
            floatPhase: _random.nextDouble() * 2 * pi,
          ),
        );
      }
    }

    final double padding = 45;
    final double usableW = size.width - padding * 2;
    final double usableH = size.height - 320;

    for (int i = 0; i < allSinglePhotos.length; i++) {
      final photo = allSinglePhotos[i];
      final double x = padding + _random.nextDouble() * (usableW > 0 ? usableW : 200);
      final double y = 180 + _random.nextDouble() * (usableH > 0 ? usableH : 260);
      final double angle = (_random.nextDouble() * 0.35) - 0.175;
      final double phase = _random.nextDouble() * 2 * pi;

      _floatingItems.add(
        FloatingPhotoItem(
          photo: photo,
          position: Offset(x, y),
          angle: angle,
          floatPhase: phase,
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 0.4,
            (_random.nextDouble() - 0.5) * 0.4,
          ),
        ),
      );
    }

    _isInitialized = true;
  }

  void _tickPhysics() {
    if (!mounted || !_isInitialized) return;

    bool hasActiveVelocity = false;
    for (var item in _floatingItems) {
      if (item.velocity.distanceSquared > 0.005) {
        hasActiveVelocity = true;
        break;
      }
    }

    if (!hasActiveVelocity) return;

    setState(() {
      final renderBox = context.findRenderObject() as RenderBox?;
      final size = renderBox?.size ?? Size.zero;
      final double maxX = max(100.0, size.width - 105);
      final double maxY = max(100.0, size.height - 125);
      const double minY = 165;
      const double minX = 16;

      for (var item in _floatingItems) {
        if (item.isDragging) continue;

        item.position += item.velocity;
        item.velocity *= 0.98; // Trượt mượt mà với quán tính không trọng lực dài hơn

        // Nghiêng nhẹ thẻ ảnh theo hướng đang trượt
        final targetAngle = (item.velocity.dx * 0.035).clamp(-0.25, 0.25);
        item.angle = item.angle * 0.92 + targetAngle * 0.08;

        // Va chạm đàn hồi mềm mại vào các biên
        if (item.position.dx < minX) {
          item.position = Offset(minX, item.position.dy);
          item.velocity = Offset(-item.velocity.dx * 0.75, item.velocity.dy * 0.9);
        } else if (item.position.dx > maxX) {
          item.position = Offset(maxX, item.position.dy);
          item.velocity = Offset(-item.velocity.dx * 0.75, item.velocity.dy * 0.9);
        }

        if (item.position.dy < minY) {
          item.position = Offset(item.position.dx, minY);
          item.velocity = Offset(item.velocity.dx * 0.9, -item.velocity.dy * 0.75);
        } else if (item.position.dy > maxY) {
          item.position = Offset(item.position.dx, maxY);
          item.velocity = Offset(item.velocity.dx * 0.9, -item.velocity.dy * 0.75);
        }
      }
    });
  }

  void _resetPositions() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      _isInitialized = false;
      _initializeItems(renderBox.size);
      setState(() {});
    }
  }

  void _showCreateAlbumDialog() {
    final nameCtrl = TextEditingController(text: 'Album ${_albumCups.length + 1}');
    final focusNode = FocusNode();

    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted && focusNode.canRequestFocus) {
        focusNode.requestFocus();
      }
    });

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tạo Album',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = Curves.easeOutCubic.transform(anim1.value);
        return Transform.scale(
          scale: 0.92 + (0.08 * curve),
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: min(MediaQuery.of(ctx).size.width * 0.85, 340.0),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tạo Album',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    focusNode: focusNode,
                    maxLength: 12,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Nhập tên album...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      counterStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                      filled: true,
                      fillColor: const Color(0xFF28282B),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                      AppButton.primary(
                        size: AppButtonSize.small,
                        borderRadius: BorderRadius.circular(10),
                        text: 'Tạo',
                        onPressed: () {
                          final text = nameCtrl.text.trim();
                          if (text.isNotEmpty) {
                            final renderBox = context.findRenderObject() as RenderBox?;
                            final size = renderBox?.size ?? const Size(360, 640);

                            setState(() {
                              _albumCups.add(
                                AlbumCupModel(
                                  id: 'cup-${DateTime.now().millisecondsSinceEpoch}',
                                  name: text,
                                  position: Offset(
                                    40.0 + _random.nextDouble() * (size.width - 170),
                                    180.0 + _random.nextDouble() * (size.height - 350),
                                  ),
                                  photos: [],
                                  floatPhase: _random.nextDouble() * 2 * pi,
                                ),
                              );
                            });
                            Navigator.pop(ctx);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      nameCtrl.dispose();
      focusNode.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _initializeItems(Size(constraints.maxWidth, constraints.maxHeight));

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // CÁC CHIẾC LY TRONG SUỐT (ALBUM CUPS)
            ..._albumCups.map((album) {
              final isHovered = _hoveredAlbumId == album.id;

              return AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  final cupFloatOffset = sin(_animController.value * 2 * pi + album.floatPhase) * 5.0;
                  return Positioned(
                    left: album.position.dx,
                    top: album.position.dy + cupFloatOffset,
                    child: child!,
                  );
                },
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      final newX = (album.position.dx + details.delta.dx)
                          .clamp(10.0, constraints.maxWidth - 140);
                      final newY = (album.position.dy + details.delta.dy)
                          .clamp(150.0, constraints.maxHeight - 200);
                      album.position = Offset(newX, newY);
                    });
                  },
                  child: DragTarget<SinglePhotoItem>(
                    onWillAcceptWithDetails: (details) {
                      if (album.isFull) {
                        final now = DateTime.now();
                        if (_lastFullToastTime == null ||
                            now.difference(_lastFullToastTime!) > const Duration(seconds: 2)) {
                          _lastFullToastTime = now;
                          AppToast.showInfo(
                            context,
                            'Album "${album.name}" đã chứa tối đa ${AlbumCupModel.maxPhotos} ảnh!',
                            icon: Icons.inventory_2_rounded,
                          );
                        }
                        return false;
                      }
                      setState(() => _hoveredAlbumId = album.id);
                      return true;
                    },
                    onLeave: (_) {
                      setState(() {
                        if (_hoveredAlbumId == album.id) {
                          _hoveredAlbumId = null;
                        }
                      });
                    },
                    onAcceptWithDetails: (details) {
                      if (album.isFull) return;
                      final photo = details.data;
                      setState(() {
                        _hoveredAlbumId = null;
                        _floatingItems.removeWhere((it) => it.photo.id == photo.id);
                        album.photos.add(photo);
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return GlassCupWidget(
                        album: album,
                        isHovered: isHovered,
                        onTap: () => _openAlbumDialog(album),
                      );
                    },
                  ),
                ),
              );
            }),

            // CÁC BỨC ẢNH ĐƠN LẺ LƠ LỬNG
            ..._floatingItems.map((item) {
              return AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  final floatOffset = sin(_animController.value * 2 * pi + item.floatPhase) * 4.0;
                  return Positioned(
                    left: item.position.dx,
                    top: item.position.dy + floatOffset,
                    child: child!,
                  );
                },
                child: Draggable<SinglePhotoItem>(
                  data: item.photo,
                  onDragStarted: () {
                    setState(() {
                      item.isDragging = true;
                      item.velocity = Offset.zero;
                    });
                  },
                  feedback: Material(
                    color: Colors.transparent,
                    child: Transform.rotate(
                      angle: item.angle + 0.08,
                      child: Transform.scale(
                        scale: 1.1,
                        child: _buildPhotoCard(item.photo, isDragging: true),
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.15,
                    child: _buildPhotoCard(item.photo),
                  ),
                  onDragEnd: (details) {
                    final renderBox = context.findRenderObject() as RenderBox?;
                    if (renderBox != null) {
                      final localOffset = renderBox.globalToLocal(details.offset);
                      const double minX = 16;
                      final double maxX = max(100.0, renderBox.size.width - 105);
                      const double minY = 165;
                      final double maxY = max(100.0, renderBox.size.height - 125);

                      final vx = (details.velocity.pixelsPerSecond.dx / 50.0).clamp(-22.0, 22.0);
                      final vy = (details.velocity.pixelsPerSecond.dy / 50.0).clamp(-22.0, 22.0);

                      setState(() {
                        item.isDragging = false;
                        item.position = Offset(
                          localOffset.dx.clamp(minX, maxX),
                          localOffset.dy.clamp(minY, maxY),
                        );
                        item.velocity = Offset(vx, vy);
                      });
                    } else {
                      setState(() => item.isDragging = false);
                    }
                  },
                  child: GestureDetector(
                    onTap: () => widget.onPhotoTap?.call(
                      item.photo.parentPost,
                      item.photo.photoIndex,
                      _findAlbumMapForPost(item.photo.parentPost),
                    ),
                    child: Transform.rotate(
                      angle: item.angle,
                      child: _buildPhotoCard(item.photo),
                    ),
                  ),
                ),
              );
            }),

            // NÚT "+ Tạo Album" & Reset vị trí góc dưới màn hình
            Positioned(
              left: 18,
              bottom: 24,
              child: SafeArea(
                child: Row(
                  children: [
                    // NÚT "+ TẠO ALBUM" - Tactile Button Retro Olive
                    AppButton.primary(
                      onPressed: _showCreateAlbumDialog,
                      text: 'Tạo Album',
                      icon: const Icon(SolarIconsBold.addCircle, size: 20, color: Colors.black),
                      height: 46,
                      borderRadius: BorderRadius.circular(23),
                    ),
                    const SizedBox(width: 10),
                    // NÚT KẾ BÊN TẠO ALBUM (TÁN XẠ ẢNH) - Tactile Icon Button
                    AppIconButton(
                      size: 46,
                      tooltip: 'Tán xạ ảnh',
                      onPressed: _resetPositions,
                      icon: const Icon(SolarIconsOutline.refresh, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Map<int, String> _findAlbumMapForPost(PostItemModel post) {
    final Map<int, String> map = {};
    for (int i = 0; i < post.photoUrls.length; i++) {
      final url = post.photoUrls[i];
      for (final cup in _albumCups) {
        if (cup.photos.any((p) => p.photoUrl == url)) {
          map[i] = cup.name;
          break;
        }
      }
    }
    return map;
  }

  Widget _buildPhotoCard(SinglePhotoItem photo, {bool isDragging = false}) {
    return Container(
      width: 88,
      height: 98,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDragging
              ? const Color(0xFFE6E6EC) // Viền xám trắng sáng khi kéo thả
              : Colors.white.withValues(alpha: 0.35),
          width: isDragging ? 2 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: isDragging
                ? Colors.white.withValues(alpha: 0.45) // Hiệu ứng ánh sáng xám trắng
                : Colors.black.withValues(alpha: 0.55),
            blurRadius: isDragging ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CachedNetworkImage(
          imageUrl: photo.photoUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[900],
          ),
        ),
      ),
    );
  }

  void _openAlbumDialog(AlbumCupModel album) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return AlbumCupDialog(
          album: album,
          onRemovePhoto: (removedPhoto) {
            setState(() {
              album.photos.removeWhere((p) => p.id == removedPhoto.id);
              _floatingItems.add(
                FloatingPhotoItem(
                  photo: removedPhoto,
                  position: Offset(100 + _random.nextDouble() * 120, 240 + _random.nextDouble() * 100),
                  angle: (_random.nextDouble() * 0.3) - 0.15,
                  floatPhase: _random.nextDouble() * 2 * pi,
                  velocity: Offset(
                    (_random.nextDouble() - 0.5) * 1.5,
                    (_random.nextDouble() - 0.5) * 1.5,
                  ),
                ),
              );
            });
            Navigator.of(ctx).pop();
            AppToast.showSuccess(
              context,
              'Đã đưa ảnh ra vũ trụ lơ lửng!',
              icon: Icons.auto_awesome_rounded,
            );
          },
          onPhotoTap: (album, photoIndex) {
            Navigator.of(ctx).pop();
            final availableAlbums = _albumCups.where((a) => a.photos.isNotEmpty).toList();
            widget.onAlbumPhotoTap?.call(album, photoIndex, availableAlbums);
          },
          onPhotosReordered: () {
            setState(() {});
          },
          onDeleteAlbum: () {
            setState(() {
              for (var photo in album.photos) {
                _floatingItems.add(
                  FloatingPhotoItem(
                    photo: photo,
                    position: Offset(100 + _random.nextDouble() * 120, 240 + _random.nextDouble() * 100),
                    angle: (_random.nextDouble() * 0.3) - 0.15,
                    floatPhase: _random.nextDouble() * 2 * pi,
                  ),
                );
              }
              _albumCups.removeWhere((c) => c.id == album.id);
            });
            Navigator.of(ctx).pop();
            AppToast.showSuccess(
              context,
              'Đã đưa ảnh ra vũ trụ lơ lửng!',
              icon: Icons.auto_awesome_rounded,
            );
          },
        );
      },
    );
  }
}
