import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/film_lut_presets.dart';
import 'digital_led_date_stamp.dart';
import 'retro_film_drawer.dart';

/// Khung ngắm Kính ảnh Retro kích thước chuẩn 3:4 cổ điển
class RetroViewfinderFrame extends StatelessWidget {
  final CameraController? controller;
  final bool isCameraReady;
  final bool isFrontCamera;
  final bool isScreenFlashActive;
  final bool isTakingPhoto;
  final FilmPreset selectedFilm;
  final bool isFilmDrawerOpen;
  final VoidCallback onToggleFilmDrawer;
  final ValueChanged<FilmPreset> onSelectFilm;
  final ValueNotifier<double> zoomNotifier;
  final VoidCallback onCycleZoom;
  final void Function(ScaleStartDetails) onScaleStart;
  final void Function(ScaleUpdateDetails) onScaleUpdate;
  final void Function(ScaleEndDetails) onScaleEnd;

  // Preview Mode & Thumbnails
  final bool isPreviewMode;
  final List<XFile> capturedFiles;
  final int previewIndex;
  final ValueChanged<int> onPreviewIndexChanged;
  final TextEditingController captionController;
  final ValueChanged<int>? onRemovePhotoAt;
  final VoidCallback? onOpenPreview;

  const RetroViewfinderFrame({
    super.key,
    required this.controller,
    required this.isCameraReady,
    required this.isFrontCamera,
    required this.isScreenFlashActive,
    required this.isTakingPhoto,
    required this.selectedFilm,
    required this.isFilmDrawerOpen,
    required this.onToggleFilmDrawer,
    required this.onSelectFilm,
    required this.zoomNotifier,
    required this.onCycleZoom,
    required this.onScaleStart,
    required this.onScaleUpdate,
    required this.onScaleEnd,
    required this.isPreviewMode,
    required this.capturedFiles,
    required this.previewIndex,
    required this.onPreviewIndexChanged,
    required this.captionController,
    this.onRemovePhotoAt,
    this.onOpenPreview,
  });

  static String _formatZoomText(double zoom) {
    if ((zoom - 0.5).abs() < 0.1) return '0.5x';
    if ((zoom - zoom.round()).abs() < 0.1) {
      return '${zoom.round()}x';
    }
    return '${zoom.toStringAsFixed(1)}x';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Center(
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // A. CHẾ ĐỘ XEM TRƯỚC (CAROUSEL VUỐT QUA LẠI CÁC ẢNH ĐÃ NƯỚNG FILM)
                  if (isPreviewMode)
                    PageView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: capturedFiles.length,
                      onPageChanged: onPreviewIndexChanged,
                      itemBuilder: (context, index) {
                        return Image.file(
                          File(capturedFiles[index].path),
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  // B. KÍNH NGẮM TRỰC TIẾP TỪ CAMERA (MÀU FILM PHOTO-GRADING THẬT SỰ)
                  else if (isCameraReady && controller != null)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final double sensorRatio = controller!.value.aspectRatio;
                        final double portraitRatio =
                            sensorRatio > 1.0 ? (1.0 / sensorRatio) : sensorRatio;

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onScaleStart: onScaleStart,
                          onScaleUpdate: onScaleUpdate,
                          onScaleEnd: onScaleEnd,
                          child: ColorFiltered(
                            colorFilter: ColorFilter.matrix(selectedFilm.matrix),
                            child: FittedBox(
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: constraints.maxWidth,
                                height: constraints.maxWidth / portraitRatio,
                                child: RepaintBoundary(
                                  child: CameraPreview(controller!),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: AppColors.surfaceDark,
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryYellow),
                      ),
                    ),

                  // TRỢ SÁNG MÀN HÌNH KHI SELFIE
                  if (isScreenFlashActive && isFrontCamera && !isPreviewMode)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFFFF9E6).withValues(alpha: 0.82),
                              width: 22,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // CHỚP MÀN TRẬP TRẮNG KHI BẤM CHỤP (SHUTTER FLASH EFFECT)
                  if (isTakingPhoto)
                    Container(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),

                  // DẤU NGÀY QUARTZ DATE THẬP NIÊN 90 IN GÓC PHẢI DƯỚI
                  if (!isPreviewMode && selectedFilm.dateStamp != null)
                    Positioned(
                      right: 18,
                      bottom: 18,
                      child: DigitalLedDateStamp(
                        text: selectedFilm.dateStamp!,
                        activeColor: const Color(0xFFFF921E),
                        ghostColor: const Color(0x1A6A3200),
                        digitWidth: 7.0,
                        digitHeight: 12.0,
                      ),
                    ),

                  // BADGE CHỈ SỐ TIÊU CỰ ZOOM (GÓC TRÊN PHẢI)
                  if (!isPreviewMode && isCameraReady)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onCycleZoom,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.48),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1.0,
                                ),
                              ),
                              child: ValueListenableBuilder<double>(
                                valueListenable: zoomNotifier,
                                builder: (context, zoom, _) {
                                  return Text(
                                    _formatZoomText(zoom),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // DẢI CHỌN CUỘN FILM (XẾP DỌC BÊN TRÁI: GỐC Ở TRÊN, FILM Ở DƯỚI)
                  if (!isPreviewMode && isCameraReady)
                    RetroFilmDrawer(
                      isOpen: isFilmDrawerOpen,
                      selectedFilm: selectedFilm,
                      onSelectFilm: onSelectFilm,
                    ),

                  // DẢI ẢNH ĐÃ CHỤP THU NHỎ NẰM ĐÁY KHUNG HÌNH
                  if (!isPreviewMode && capturedFiles.isNotEmpty)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Row(
                        children: [
                          ...List.generate(capturedFiles.length, (index) {
                            final file = capturedFiles[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.45),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(file.path),
                                        width: 48,
                                        height: 64,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // Nút xóa nhỏ
                                  if (onRemovePhotoAt != null)
                                    Positioned(
                                      top: -5,
                                      right: -5,
                                      child: GestureDetector(
                                        onTap: () => onRemovePhotoAt!(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: const BoxDecoration(
                                            color: Colors.redAccent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close_rounded,
                                              color: Colors.white, size: 12),
                                        ),
                                      ),
                                    ),
                                  // Số thứ tự
                                  Positioned(
                                    bottom: 4,
                                    left: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const Spacer(),
                          // Nút tiếp tục tròn xúc giác
                          if (onOpenPreview != null)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: onOpenPreview,
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFF5F821C),
                                      Color(0xFF45610F),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFF7FA32E).withValues(alpha: 0.5),
                                    width: 1.0,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    SolarIconsBold.plain,
                                    color: Colors.black,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  // PREVIEW OVERLAY: CAPTION INPUT & CHẤM CHỈ SỐ ẢNH
                  if (isPreviewMode) ...[
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 160,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.85),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (capturedFiles.length > 1) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(capturedFiles.length, (i) {
                                final bool isCurrent = i == previewIndex;
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
                                          ]
                                        : null,
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                          ],
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: TextField(
                                  controller: captionController,
                                  maxLength: 80,
                                  maxLines: 2,
                                  minLines: 1,
                                  style: const TextStyle(color: Colors.white, fontSize: 15),
                                  decoration: InputDecoration(
                                    hintText: 'Gửi một lời nhắn...',
                                    hintStyle:
                                        const TextStyle(color: Colors.white60, fontSize: 14),
                                    border: InputBorder.none,
                                    counterText: '',
                                    suffixIcon: ValueListenableBuilder<TextEditingValue>(
                                      valueListenable: captionController,
                                      builder: (context, value, _) {
                                        final len = value.text.length;
                                        if (len == 0) return const SizedBox.shrink();
                                        final remaining = 80 - len;
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: Center(
                                            widthFactor: 1,
                                            child: Text(
                                              '$remaining',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: remaining <= 10
                                                    ? Colors.redAccent
                                                    : (remaining <= 25
                                                        ? Colors.orangeAccent
                                                        : Colors.white38),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
