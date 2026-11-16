import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../feed/data/models/post_item_model.dart';

class TimelineMilestone {
  final DateTime date;
  final List<PostItemModel> posts;

  TimelineMilestone({required this.date, required this.posts});
}

class WavyTimelineTab extends StatefulWidget {
  final List<PostItemModel> posts;
  final Function(PostItemModel post, [String? albumTitle])? onPhotoTap;

  const WavyTimelineTab({
    super.key,
    required this.posts,
    this.onPhotoTap,
  });

  @override
  State<WavyTimelineTab> createState() => _WavyTimelineTabState();
}

class _WavyTimelineTabState extends State<WavyTimelineTab> {
  late ScrollController _scrollController;
  bool _showScrollToTop = false;

  // Chiều cao cố định cho mỗi hàng mốc để đường lượn sóng và node đồng bộ 100%
  static const double _rowHeight = 130.0;
  static const double _rowSpacing = 24.0;
  static const double _topPadding = 175.0; // Bắt đầu ngay dưới thanh Bio và Tabs

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        final show = _scrollController.offset > 160;
        if (show != _showScrollToTop) {
          setState(() => _showScrollToTop = show);
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  List<TimelineMilestone> _groupPostsByDate(List<PostItemModel> allPosts) {
    final Map<String, List<PostItemModel>> grouped = {};
    for (var post in allPosts) {
      final key = _formatDateKey(post.createdAt);
      grouped.putIfAbsent(key, () => []).add(post);
    }

    final List<TimelineMilestone> milestones = [];
    grouped.forEach((key, postList) {
      milestones.add(TimelineMilestone(
        date: postList.first.createdAt,
        posts: postList,
      ));
    });

    milestones.sort((a, b) => b.date.compareTo(a.date));
    return milestones;
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final milestones = _groupPostsByDate(widget.posts);

    if (milestones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_motion_outlined,
              size: 48,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 12),
            const Text(
              'Chưa có mốc ký ức nào',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final double totalHeight = _topPadding +
        (milestones.length * _rowHeight) +
        ((milestones.length - 1) * _rowSpacing) +
        100.0; // Khoảng thở đáy

    return Stack(
      children: [
        // Cuộn toàn bộ đường sóng, mũi tên và các mốc ký ức đồng thời (Xuyên thấu không bị cắt ngang)
        SingleChildScrollView(
          controller: _scrollController,
          clipBehavior: Clip.none,
          padding: const EdgeInsets.only(bottom: 60),
          child: SizedBox(
            height: totalHeight,
            child: Stack(
              children: [
                // 1. Đường WAVY NÉT ĐỨT + ĐẦU MŨI TÊN + CÁC CHẤM NODE (Cuộn đồng bộ 100%)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ContinuousWavyRoadmapPainter(
                      itemCount: milestones.length,
                      topPadding: _topPadding,
                      rowHeight: _rowHeight,
                      rowSpacing: _rowSpacing,
                    ),
                  ),
                ),

                // 2. Nội dung các mốc (Ngày tháng đối diện ảnh nhỏ xinh)
                Positioned(
                  top: _topPadding,
                  left: 14,
                  right: 14,
                  child: Column(
                    children: [
                      for (int i = 0; i < milestones.length; i++) ...[
                        SizedBox(
                          height: _rowHeight,
                          child: _buildMilestoneRow(
                            context,
                            milestones[i],
                            isPhotoOnRight: i % 2 == 0,
                          ),
                        ),
                        if (i < milestones.length - 1)
                          const SizedBox(height: _rowSpacing),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. NÚT TRÒN MŨI TÊN TRƯỢT LÊN ĐỈNH (XUẤT HIỆN KHI CUỘN XUỐNG)
        Positioned(
          right: 20,
          bottom: 24,
          child: AnimatedScale(
            scale: _showScrollToTop ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: GestureDetector(
              onTap: _scrollToTop,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryOlive,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOlive.withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.black, // Nền xanh retro thì icon màu đen
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // MỖI MỐC: NGÀY THÁNG ĐỐI DIỆN ẢNH NHỎ, KHOẢNG GIỮA DÀNH CHO NODE & LINE
  Widget _buildMilestoneRow(
    BuildContext context,
    TimelineMilestone milestone, {
    required bool isPhotoOnRight,
  }) {
    final dateFormatted = _formatDisplayDate(milestone.date);
    final firstPost = milestone.posts.first;
    final String? caption = firstPost.title;

    // Text ngày tháng năm: in nghiêng trắng mờ nhẹ, không bg, không border
    final dateWidget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        dateFormatted,
        textAlign: isPhotoOnRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.65),
          fontStyle: FontStyle.italic,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
      ),
    );

    // Card ảnh nhỏ gọn theo yêu cầu, caption ở trên đầu bằng Dancing Script
    final photoWidget = Column(
      crossAxisAlignment:
          isPhotoOnRight ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (caption != null && caption.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              caption,
              style: GoogleFonts.dancingScript(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        if (milestone.posts.length == 1)
          _buildSmallSinglePhoto(firstPost)
        else
          _buildSmallFannedPhotos(context, milestone.posts),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: isPhotoOnRight ? dateWidget : photoWidget,
        ),
        // Khoảng trống 36px ở giữa dành cho đường nét đứt và chấm node phát sáng
        const SizedBox(width: 36),
        Expanded(
          child: isPhotoOnRight ? photoWidget : dateWidget,
        ),
      ],
    );
  }

  // Card ảnh nhỏ gọn xinh xắn (kích thước ~82x95px)
  Widget _buildSmallSinglePhoto(PostItemModel post) {
    return GestureDetector(
      onTap: () => widget.onPhotoTap?.call(post),
      child: Container(
        width: 82,
        height: 95,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: CachedNetworkImage(
            imageUrl: post.photoUrl,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
      ),
    );
  }

  // Ảnh xòe tiền nhỏ gọn
  Widget _buildSmallFannedPhotos(BuildContext context, List<PostItemModel> postList) {
    final displayPosts = postList.take(3).toList();
    final count = displayPosts.length;

    final List<double> rotationAngles = count == 2
        ? [-0.14, 0.14]
        : [-0.22, 0.0, 0.22];

    final List<double> horizontalOffsets = count == 2
        ? [-10.0, 10.0]
        : [-16.0, 0.0, 16.0];

    return GestureDetector(
      onTap: () => _showFannedAlbumSheet(context, postList),
      child: SizedBox(
        width: 105,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            for (int i = 0; i < count; i++)
              Positioned(
                left: 18 + horizontalOffsets[i],
                child: Transform.rotate(
                  angle: rotationAngles[i],
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 68,
                    height: 84,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: i == count - 1
                            ? AppColors.primaryOlive
                            : Colors.white.withValues(alpha: 0.35),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.7),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: displayPosts[i].photoUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFannedAlbumSheet(BuildContext context, List<PostItemModel> postList) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bộ ảnh ${_formatDisplayDate(postList.first.createdAt)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 230,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: postList.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final post = postList[idx];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        widget.onPhotoTap?.call(post);
                      },
                      child: Container(
                        width: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFF222224),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: post.photoUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              post.title ?? 'Khoảnh khắc',
                              style: GoogleFonts.dancingScript(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// CustomPainter vẽ toàn bộ đường lượn sóng Wavy liên tục, đầu mũi tên và các node
class _ContinuousWavyRoadmapPainter extends CustomPainter {
  final int itemCount;
  final double topPadding;
  final double rowHeight;
  final double rowSpacing;

  _ContinuousWavyRoadmapPainter({
    required this.itemCount,
    required this.topPadding,
    required this.rowHeight,
    required this.rowSpacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (itemCount == 0 || size.height == 0) return;

    final xc = size.width / 2;
    final arrowTopY = topPadding - 24.0; // Đặt ngay phía trên mốc đầu tiên, bên dưới thanh Bio

    final paint = Paint()
      ..color = AppColors.primaryOlive.withValues(alpha: 0.75)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final arrowPaint = Paint()
      ..color = AppColors.primaryOlive
      ..style = PaintingStyle.fill;

    // 1. VẼ ĐẦU MŨI TÊN ▲ TẠI ĐỈNH (Cuộn theo danh sách)
    final arrowPath = Path();
    arrowPath.moveTo(xc, arrowTopY);
    arrowPath.lineTo(xc - 5.5, arrowTopY + 9);
    arrowPath.lineTo(xc + 5.5, arrowTopY + 9);
    arrowPath.close();
    canvas.drawPath(arrowPath, arrowPaint);

    // Tính tọa độ Y của từng node
    final List<double> nodeYs = [];
    for (int i = 0; i < itemCount; i++) {
      final y = topPadding + (i * (rowHeight + rowSpacing)) + (rowHeight / 2);
      nodeYs.add(y);
    }

    // 2. VẼ ĐƯỜNG CONG WAVY BÉZIER UỐN LƯỢN NỐI LIỀN TẤT CẢ CÁC MỐC
    final path = Path();
    // Bắt đầu từ dưới đầu mũi tên
    path.moveTo(xc, arrowTopY + 9);

    // Đoạn từ mũi tên tới node đầu tiên
    const double waveAmp = 20.0;
    path.quadraticBezierTo(
      xc + waveAmp * 0.5,
      (arrowTopY + 9 + nodeYs.first) / 2,
      xc,
      nodeYs.first,
    );

    // Đoạn uốn lượn hình chữ S giữa từng cặp node
    for (int i = 0; i < nodeYs.length - 1; i++) {
      final currentY = nodeYs[i];
      final nextY = nodeYs[i + 1];
      final midY = (currentY + nextY) / 2;
      final amp = (i % 2 == 0) ? -waveAmp : waveAmp;

      path.quadraticBezierTo(xc + amp, midY, xc, nextY);
    }

    // Vẽ nét đứt rõ nét
    _drawDashedPath(canvas, path, paint, dashLength: 6, dashSpace: 4);

    // 3. VẼ CÁC CHẤM NODE PHÁT SÁNG TRỰC TIẾP TRÊN TRỤC ĐƯỜNG CONG (Đảm bảo 100% không lệch)
    final nodeGlowPaint = Paint()
      ..color = AppColors.primaryOlive.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final nodeSolidPaint = Paint()
      ..color = AppColors.primaryOlive
      ..style = PaintingStyle.fill;

    final nodeCenterPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final y in nodeYs) {
      // Vòng hào quang mờ ngoài
      canvas.drawCircle(Offset(xc, y), 8.0, nodeGlowPaint);
      // Vòng tròn đặc màu xanh retro
      canvas.drawCircle(Offset(xc, y), 5.5, nodeSolidPaint);
      // Chấm trắng ở tâm
      canvas.drawCircle(Offset(xc, y), 2.2, nodeCenterPaint);
    }
  }

  void _drawDashedPath(
    Canvas canvas,
    Path source,
    Paint paint, {
    required double dashLength,
    required double dashSpace,
  }) {
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = min(dashLength, metric.length - distance);
        final extractPath = metric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += dashLength + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ContinuousWavyRoadmapPainter oldDelegate) {
    return oldDelegate.itemCount != itemCount;
  }
}
