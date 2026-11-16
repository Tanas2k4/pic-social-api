import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/album_cup_model.dart';
import '../../data/models/single_photo_item.dart';

class AlbumCupDialog extends StatefulWidget {
  final AlbumCupModel album;
  final Function(SinglePhotoItem photo)? onRemovePhoto;
  final Function(AlbumCupModel album, int photoIndex)? onPhotoTap;
  final VoidCallback? onDeleteAlbum;
  final VoidCallback? onPhotosReordered;

  const AlbumCupDialog({
    super.key,
    required this.album,
    this.onRemovePhoto,
    this.onPhotoTap,
    this.onDeleteAlbum,
    this.onPhotosReordered,
  });

  @override
  State<AlbumCupDialog> createState() => _AlbumCupDialogState();
}

class _AlbumCupDialogState extends State<AlbumCupDialog> {
  String? _draggingPhotoId;

  Widget _buildPhotoThumbnail(SinglePhotoItem photo, int index) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => widget.onPhotoTap?.call(widget.album, index),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: photo.photoUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.onRemovePhoto != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => widget.onRemovePhoto!(photo),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final album = widget.album;
    final photos = album.photos;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header: Tên Album + Nút Xóa
          Row(
            children: [
              Expanded(
                child: Text(
                  album.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.onDeleteAlbum != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                  tooltip: 'Xóa album',
                  onPressed: widget.onDeleteAlbum,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Danh sách ảnh đơn trong ly (Có hỗ trợ Kéo thả sắp xếp vị trí trượt mượt mà)
          if (photos.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              alignment: Alignment.center,
              child: Text(
                'Chưa có ảnh nào trong album này',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 13,
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                const double spacing = 10.0;
                const int crossAxisCount = 3;
                final double cellWidth =
                    (constraints.maxWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;
                final double cellHeight = cellWidth / 0.8;
                final int rowCount = (photos.length + crossAxisCount - 1) ~/ crossAxisCount;
                final double totalHeight = rowCount * cellHeight +
                    (rowCount > 1 ? (rowCount - 1) * spacing : 0.0);

                return SizedBox(
                  height: totalHeight > 0 ? totalHeight : 100,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: List.generate(photos.length, (index) {
                      final photo = photos[index];
                      final col = index % crossAxisCount;
                      final row = index ~/ crossAxisCount;
                      final left = col * (cellWidth + spacing);
                      final top = row * (cellHeight + spacing);

                      // ANIMATED POSITIONED: MỖI KHI ĐỔI THỨ TỰ, CÁC ẢNH TỰ TRƯỢT SANG VỊ TRÍ MỚI SIÊU MƯỢT
                      return AnimatedPositioned(
                        key: ValueKey(photo.id),
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        left: left,
                        top: top,
                        width: cellWidth,
                        height: cellHeight,
                        child: DragTarget<String>(
                          onWillAcceptWithDetails: (details) {
                            final draggedId = details.data;
                            if (draggedId != photo.id) {
                              final fromIdx = photos.indexWhere((p) => p.id == draggedId);
                              final toIdx = photos.indexWhere((p) => p.id == photo.id);
                              if (fromIdx != -1 && toIdx != -1 && fromIdx != toIdx) {
                                setState(() {
                                  final item = photos.removeAt(fromIdx);
                                  photos.insert(toIdx, item);
                                });
                                widget.onPhotosReordered?.call();
                              }
                            }
                            return true;
                          },
                          builder: (context, candidateData, rejectedData) {
                            final isBeingDragged = _draggingPhotoId == photo.id;

                            return LongPressDraggable<String>(
                              data: photo.id,
                              delay: const Duration(milliseconds: 140),
                              onDragStarted: () {
                                setState(() {
                                  _draggingPhotoId = photo.id;
                                });
                              },
                              onDragEnd: (details) {
                                setState(() {
                                  _draggingPhotoId = null;
                                });
                                // Kéo ảnh lên phía trên (ra khỏi bottom sheet lên vũ trụ)
                                if (details.offset.dy <
                                    MediaQuery.of(context).size.height * 0.58) {
                                  widget.onRemovePhoto?.call(photo);
                                }
                              },
                              feedback: Material(
                                color: Colors.transparent,
                                child: Container(
                                  width: cellWidth * 1.06,
                                  height: cellHeight * 1.06,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E1E),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFE6E6EC), // Viền xám trắng sáng khi dnd
                                      width: 2.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.45), // Ánh sáng xám trắng
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(3),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: photo.photoUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.2,
                                child: _buildPhotoThumbnail(photo, index),
                              ),
                              child: Opacity(
                                opacity: isBeingDragged ? 0.2 : 1.0,
                                child: _buildPhotoThumbnail(photo, index),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
