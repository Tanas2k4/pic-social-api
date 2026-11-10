import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../feed/data/models/post_item_model.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  List<CameraDescription>? _cameras;
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  bool _isCameraReady = false;
  bool _isTakingPhoto = false;
  FlashMode _flashMode = FlashMode.off;

  // CÁC THÔNG SỐ TIÊU CỰ & ZOOM CỦA ĐIỆN THOẠI
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;
  bool _isFrontCamera = false;
  bool _isScreenFlashActive = false;

  // Lấy các mức tiêu cự thực tế của phần cứng điện thoại
  List<double> get _availableZoomLevels {
    final List<double> levels = [];
    if (_minZoom < 0.9) {
      levels.add(_minZoom);
    }
    if (_minZoom <= 1.0 && _maxZoom >= 1.0) {
      levels.add(1.0);
    }
    if (_maxZoom >= 2.0) {
      levels.add(2.0);
    }
    if (_maxZoom >= 3.0 && levels.length < 4) {
      levels.add(3.0);
    }
    return levels;
  }

  // DANH SÁCH ẢNH ĐÃ CHỤP / CHỌN (TỐI ĐA 3 ẢNH)
  final List<XFile> _capturedFiles = [];
  bool _isPreviewMode = false;
  int _previewIndex = 0;
  final TextEditingController _captionController = TextEditingController();

  // Hiệu ứng vuốt lên trượt lên mượt mà (Dùng ValueNotifier để KHÔNG rebuild widget tree khi vuốt)
  final ValueNotifier<double> _dragOffsetY = ValueNotifier<double>(0.0);
  final ValueNotifier<double> _zoomNotifier = ValueNotifier<double>(1.0);
  late AnimationController _animController;
  Animation<double>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animController.addListener(() {
      if (_slideAnimation != null) {
        _dragOffsetY.value = _slideAnimation!.value;
      }
    });
    _initCameras();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animController.dispose();
    _dragOffsetY.dispose();
    _zoomNotifier.dispose();
    _controller?.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCameraController(cameraController.description);
    }
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        int initialIndex = _cameras!.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
        );
        if (initialIndex == -1) initialIndex = 0;
        _selectedCameraIndex = initialIndex;
        await _initCameraController(_cameras![_selectedCameraIndex]);
      }
    } catch (e) {
      debugPrint('Lỗi khởi tạo camera: $e');
    }
  }

  Future<void> _initCameraController(CameraDescription description) async {
    _isFrontCamera = description.lensDirection == CameraLensDirection.front;

    final CameraController cameraController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = cameraController;

    try {
      await cameraController.initialize();

      // Đọc các mức tiêu cự thực tế của phần cứng camera trên điện thoại
      try {
        _minZoom = await cameraController.getMinZoomLevel();
        _maxZoom = await cameraController.getMaxZoomLevel();
        _currentZoom = (_minZoom <= 1.0 && _maxZoom >= 1.0) ? 1.0 : _minZoom;
        _zoomNotifier.value = _currentZoom;
        await cameraController.setZoomLevel(_currentZoom);
      } catch (e) {
        debugPrint('Lỗi đọc tiêu cự zoom: $e');
        _minZoom = 1.0;
        _maxZoom = 1.0;
        _currentZoom = 1.0;
        _zoomNotifier.value = 1.0;
      }

      // Khởi tạo Flash phù hợp (Camera sau dùng LED, Camera trước dùng Screen Flash)
      if (!_isFrontCamera) {
        try {
          await cameraController.setFlashMode(_flashMode);
        } catch (_) {
          _flashMode = FlashMode.off;
        }
      } else {
        _flashMode = FlashMode.off;
      }

      if (mounted) {
        setState(() {
          _isCameraReady = true;
        });
      }
    } catch (e) {
      debugPrint('Lỗi mở camera: $e');
    }
  }

  // ĐẶT TIÊU CỰ NHANH THEO MỨC CỦA THIẾT BỊ (0.5, 1, 2, 3...)
  Future<void> _setZoom(double zoom) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final clamped = zoom.clamp(_minZoom, _maxZoom);
    try {
      await _controller!.setZoomLevel(clamped);
      _currentZoom = clamped;
      _zoomNotifier.value = clamped;
      HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Lỗi zoom: $e');
    }
  }

  // CHUYỂN TIÊU CỰ TIẾP THEO KHI CHẠM VÀO NÚT (VÍ DỤ: 1 -> 2 -> 3 -> 1)
  void _cycleZoom() {
    final levels = _availableZoomLevels;
    if (levels.isEmpty) return;
    int currentIndex = levels.indexWhere((l) => (_currentZoom - l).abs() < 0.25);
    int nextIndex = (currentIndex + 1) % levels.length;
    _setZoom(levels[nextIndex]);
  }

  // ĐỊNH DẠNG CHUỖI HIỂN THỊ TIÊU CỰ (VÍ DỤ: 1x, 2x, 0.5x)
  static String _formatZoomText(double zoom) {
    if ((zoom - 0.5).abs() < 0.1) return '0.5x';
    if ((zoom - zoom.round()).abs() < 0.1) {
      return '${zoom.round()}x';
    }
    return '${zoom.toStringAsFixed(1)}x';
  }

  Future<void> _flipCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    setState(() {
      _isCameraReady = false;
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    });
    await _controller?.dispose();
    await _initCameraController(_cameras![_selectedCameraIndex]);
  }

  Future<void> _toggleFlash() async {
    if (_isFrontCamera) {
      // Camera selfie: Bật / Tắt trợ sáng màn hình trắng
      setState(() {
        _isScreenFlashActive = !_isScreenFlashActive;
      });
      HapticFeedback.lightImpact();
      AppToast.showInfo(
        context,
        _isScreenFlashActive ? 'Đã bật trợ sáng màn hình selfie 💡' : 'Đã tắt trợ sáng màn hình',
        icon: _isScreenFlashActive ? Icons.flash_on_rounded : Icons.flash_off_rounded,
      );
      return;
    }

    // Camera sau: Bật / Tắt đèn Flash LED phần cứng
    if (_controller == null || !_controller!.value.isInitialized) return;
    FlashMode nextMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    try {
      await _controller!.setFlashMode(nextMode);
      setState(() {
        _flashMode = nextMode;
      });
      HapticFeedback.lightImpact();
      if (!mounted) return;
      AppToast.showInfo(
        context,
        nextMode == FlashMode.torch ? 'Đã bật đèn Flash ⚡' : 'Đã tắt đèn Flash',
        icon: nextMode == FlashMode.torch ? Icons.flash_on_rounded : Icons.flash_off_rounded,
      );
    } catch (e) {
      debugPrint('Flash error: $e');
      if (mounted) {
        AppToast.showWarning(context, 'Thiết bị không hỗ trợ Flash cho camera này');
      }
    }
  }

  // CHỤP ẢNH (HỖ TRỢ CHỤP NHIỀU ẢNH LÊN TỚI 3 ẢNH)
  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isTakingPhoto) return;
    if (_capturedFiles.length >= 3) return;

    try {
      setState(() => _isTakingPhoto = true);
      final XFile photo = await _controller!.takePicture();
      setState(() {
        _capturedFiles.add(photo);
        _isTakingPhoto = false;
        // Nếu đã đủ 3 ảnh thì tự động chuyển sang chế độ Xem trước & Đăng
        if (_capturedFiles.length >= 3) {
          _isPreviewMode = true;
          _previewIndex = 0;
        }
      });
    } catch (e) {
      setState(() => _isTakingPhoto = false);
      debugPrint('Chụp ảnh thất bại: $e');
    }
  }

  // CHỌN ẢNH TỪ THƯ VIỆN (CHỌN 1 HOẶC NHIỀU ẢNH CHO ĐỦ TỐI ĐA 3 ẢNH)
  Future<void> _pickFromGallery() async {
    final int remaining = 3 - _capturedFiles.length;
    if (remaining <= 0) {
      AppToast.showWarning(
        context,
        'Bạn đã chọn đủ tối đa 3 ảnh! 📸',
        icon: Icons.photo_library_rounded,
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> images = await picker.pickMultiImage(imageQuality: 85);
      if (images.isNotEmpty && mounted) {
        setState(() {
          final toAdd = images.take(remaining).toList();
          _capturedFiles.addAll(toAdd);
          if (_capturedFiles.length >= 3) {
            _isPreviewMode = true;
            _previewIndex = 0;
          }
        });
      }
    } catch (e) {
      // Fallback nếu máy không hỗ trợ pickMultiImage
      final XFile? single = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (single != null && mounted) {
        setState(() {
          _capturedFiles.add(single);
          if (_capturedFiles.length >= 3) {
            _isPreviewMode = true;
            _previewIndex = 0;
          }
        });
      }
    }
  }

  // XÓA 1 ẢNH KHỎI DANH SÁCH
  void _removePhotoAt(int index) {
    if (index >= 0 && index < _capturedFiles.length) {
      setState(() {
        _capturedFiles.removeAt(index);
        if (_capturedFiles.isEmpty) {
          _isPreviewMode = false;
        }
        if (_previewIndex >= _capturedFiles.length) {
          _previewIndex = (_capturedFiles.length - 1).clamp(0, 2);
        }
      });
    }
  }

  // LÀM MỚI TOÀN BỘ ĐỂ CHỤP LẠI TỪ ĐẦU
  void _retakeAll() {
    setState(() {
      _capturedFiles.clear();
      _isPreviewMode = false;
      _previewIndex = 0;
      _captionController.clear();
    });
  }

  // ĐĂNG BÀI MỚI VÀ TRẢ DỮ LIỆU VỀ FEED
  void _submitPost() {
    if (_capturedFiles.isEmpty) return;

    final newPost = PostItemModel(
      postId: 'post-local-${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current-user',
      authorUserName: 'you',
      authorFullName: 'Bạn',
      authorAvatarUrl: null,
      title: _captionController.text.trim().isEmpty ? null : _captionController.text.trim(),
      createdAt: DateTime.now(),
      photoUrl: _capturedFiles.first.path,
      photoUrls: _capturedFiles.map((f) => f.path).toList(),
      likeCount: 0,
      commentCount: 0,
      shareCount: 0,
      isLikedByMe: false,
      friendshipStatus: FriendshipStatus.friends,
    );

    Navigator.of(context).pop(newPost);
  }

  // TRƯỢT LÊN BIẾN MẤT LÊN TRÊN ĐỂ VỀ FEED
  void _dismissUpwards() {
    if (_animController.isAnimating) return;
    final screenHeight = MediaQuery.of(context).size.height;
    _slideAnimation = Tween<double>(
      begin: _dragOffsetY.value,
      end: -screenHeight,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInCubic));

    _animController.forward(from: 0).then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _springBack() {
    _slideAnimation = Tween<double>(
      begin: _dragOffsetY.value,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutBack));
    _animController.forward(from: 0);
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dy < 0 || _dragOffsetY.value < 0) {
      _dragOffsetY.value += details.delta.dy;
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_dragOffsetY.value < -70 ||
        (_dragOffsetY.value < -20 && details.primaryVelocity != null && details.primaryVelocity! < -250)) {
      _dismissUpwards();
    } else {
      _springBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _dismissUpwards();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: ValueListenableBuilder<double>(
          valueListenable: _dragOffsetY,
          builder: (context, offsetY, child) {
            return Transform.translate(
              offset: Offset(0, offsetY),
              child: child,
            );
          },
          child: SafeArea(
            child: Column(
              children: [
                // 1. THANH ĐIỀU HƯỚNG TRÊN CÙNG (CÓ HỖ TRỢ VUỐT LÊN ĐỂ VỀ FEED)
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: _handleVerticalDragUpdate,
                  onVerticalDragEnd: _handleVerticalDragEnd,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nút Đóng hoặc Nút Quay lại Camera
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isPreviewMode ? Icons.arrow_back_rounded : Icons.close_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: () {
                              if (_isPreviewMode) {
                                setState(() => _isPreviewMode = false);
                              } else {
                                _dismissUpwards();
                              }
                            },
                          ),
                        ),

                        // Tiêu đề
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isPreviewMode
                                  ? 'Xem trước (${_capturedFiles.length} ảnh)'
                                  : (_capturedFiles.isEmpty
                                      ? 'Khoảnh khắc mới'
                                      : 'Đã chụp ${_capturedFiles.length}/3 ảnh'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (!_isPreviewMode)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.keyboard_arrow_up_rounded,
                                      color: Colors.white.withValues(alpha: 0.6), size: 16),
                                  Text(
                                    'Vuốt lên để về Feed',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),

                        // Nút Flash (khi đang chụp) hoặc Nút Đặt lại (khi xem trước)
                        if (!_isPreviewMode)
                          Builder(builder: (context) {
                            final isFlashOn = _isFrontCamera
                                ? _isScreenFlashActive
                                : _flashMode == FlashMode.torch;
                            return Container(
                              decoration: BoxDecoration(
                                color: isFlashOn
                                    ? AppColors.primaryOlive.withValues(alpha: 0.25)
                                    : Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  isFlashOn
                                      ? Icons.flash_on_rounded
                                      : Icons.flash_off_rounded,
                                  color: isFlashOn
                                      ? AppColors.primaryOlive
                                      : Colors.white,
                                  size: 22,
                                ),
                                tooltip: _isFrontCamera ? 'Trợ sáng màn hình selfie' : 'Đèn Flash',
                                onPressed: _toggleFlash,
                              ),
                            );
                          })
                        else
                          // Nút xóa tất cả ảnh để chụp lại
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.redAccent, size: 22),
                              tooltip: 'Xóa tất cả ảnh',
                              onPressed: _retakeAll,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // 2. KHUNG CAMERA / XEM TRƯỚC (TỈ LỆ CHUẨN 0.67)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: AspectRatio(
                          aspectRatio: 0.67,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(36),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // A. CHẾ ĐỘ XEM TRƯỚC (CAROUSEL VUỐT QUA LẠI CÁC ẢNH)
                                if (_isPreviewMode)
                                  PageView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: _capturedFiles.length,
                                    onPageChanged: (i) => setState(() => _previewIndex = i),
                                    itemBuilder: (context, index) {
                                      return Image.file(
                                        File(_capturedFiles[index].path),
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                // B. CHẾ ĐỘ CAMERA ĐANG CHỤP TRỰC TIẾP (KÈM CỬ CHỈ PINCH TO ZOOM 2 NGÓN TAY)
                                else if (_isCameraReady && _controller != null)
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final double sensorRatio = _controller!.value.aspectRatio;
                                      final double portraitRatio =
                                          sensorRatio > 1.0 ? (1.0 / sensorRatio) : sensorRatio;

                                      return GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onScaleStart: (details) {
                                          _baseZoom = _currentZoom;
                                        },
                                        onScaleUpdate: (details) async {
                                          if (details.pointerCount >= 2) {
                                            if (_controller == null || !_controller!.value.isInitialized) return;
                                            final newZoom = (_baseZoom * details.scale).clamp(_minZoom, _maxZoom);
                                            if ((newZoom - _currentZoom).abs() > 0.04) {
                                              try {
                                                await _controller!.setZoomLevel(newZoom);
                                                _currentZoom = newZoom;
                                                _zoomNotifier.value = newZoom;
                                              } catch (_) {}
                                            }
                                          } else if (details.pointerCount == 1) {
                                            if (details.focalPointDelta.dy < 0 || _dragOffsetY.value < 0) {
                                              _dragOffsetY.value += details.focalPointDelta.dy;
                                            }
                                          }
                                        },
                                        onScaleEnd: (details) {
                                          if (_dragOffsetY.value < -70 ||
                                              (_dragOffsetY.value < -20 && details.velocity.pixelsPerSecond.dy < -250)) {
                                            _dismissUpwards();
                                          } else if (_dragOffsetY.value != 0) {
                                            _springBack();
                                          }
                                        },
                                        child: FittedBox(
                                          fit: BoxFit.cover,
                                          child: SizedBox(
                                            width: constraints.maxWidth,
                                            height: constraints.maxWidth / portraitRatio,
                                            child: RepaintBoundary(
                                              child: CameraPreview(_controller!),
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

                                // LỚP VIỀN TRỢ SÁNG MÀN HÌNH KHI SELFIE BAN ĐÊM
                                if (_isScreenFlashActive && _isFrontCamera && !_isPreviewMode)
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

                                // Chớp trắng khi chụp
                                if (_isTakingPhoto)
                                  Container(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),

                                // D. NÚT TIÊU CỰ ĐƠN (HIỂN THỊ DUY NHẤT 1 SỐ KÈM 'x', NỀN BLUR, KHÔNG BORDER, GÓC TRÊN BÊN PHẢI)
                                if (!_isPreviewMode && _isCameraReady && _availableZoomLevels.length > 1)
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: _cycleZoom,
                                      child: ClipOval(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                          child: Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.45),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: ValueListenableBuilder<double>(
                                                valueListenable: _zoomNotifier,
                                                builder: (context, zoom, _) {
                                                  return Text(
                                                    _formatZoomText(zoom),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
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
                                  ),

                                // C. DANH SÁCH THUMBNAIL ẢNH ĐÃ CHỤP & NÚT TIẾP TỤC TRÒN (XUẤT HIỆN KHI ĐÃ CÓ ÍT NHẤT 1 ẢNH)
                                if (!_isPreviewMode && _capturedFiles.isNotEmpty)
                                  Positioned(
                                    left: 16,
                                    right: 16,
                                    bottom: 16,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        // Danh sách Thumbnail ảnh đã chụp (bỏ hoàn toàn border phía sau)
                                        ...List.generate(_capturedFiles.length, (index) {
                                          final file = _capturedFiles[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12),
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
                                                // Nút xóa đỏ nhỏ góc trên
                                                Positioned(
                                                  top: -5,
                                                  right: -5,
                                                  child: GestureDetector(
                                                    onTap: () => _removePhotoAt(index),
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
                                                // Số thứ tự ở góc dưới
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

                                        // NÚT TIẾP TỤC TRÒN VỚI ICON MÁY BAY GỬI (GIỐNG NÚT GỬI KHOẢNH KHẮC)
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _isPreviewMode = true;
                                              _previewIndex = 0;
                                            });
                                          },
                                          child: Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryYellow,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.primaryYellow
                                                      .withValues(alpha: 0.5),
                                                  blurRadius: 10,
                                                  spreadRadius: 1,
                                                  offset: const Offset(0, 2),
                                                ),
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.35),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.send_rounded,
                                                color: Colors.black,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // D. LỚP GRADIENT MỜ ĐÁY ẢNH & Ô NHẬP CAPTION (KHI Ở PREVIEW MODE)
                                if (_isPreviewMode) ...[
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
                                        // CHẤM CHỈ SỐ ẢNH TRẮNG ĐỤC (KHI CÓ > 1 ẢNH)
                                        if (_capturedFiles.length > 1) ...[
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: List.generate(_capturedFiles.length, (i) {
                                              final bool isCurrent = i == _previewIndex;
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

                                        // Ô NHẬP CAPTION (BLUR MỜ, KHÔNG BORDER, HINT TEXT RÚT GỌN)
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
                                                controller: _captionController,
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
                                                    valueListenable: _captionController,
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
                  ),

                  // 3. THANH ĐIỀU KHIỂN DƯỚI ĐÁY (HỖ TRỢ VUỐT LÊN ĐỂ VỀ FEED)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onVerticalDragUpdate: _handleVerticalDragUpdate,
                    onVerticalDragEnd: _handleVerticalDragEnd,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 6, 24, 16),
                      child: !_isPreviewMode
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // NÚT CHỌN TỪ THƯ VIỆN
                              IconButton(
                                icon: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    const Icon(Icons.photo_library_outlined,
                                        color: Colors.white, size: 28),
                                    if (_capturedFiles.isNotEmpty)
                                      Positioned(
                                        top: -2,
                                        right: -4,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: AppColors.primaryYellow,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '+${3 - _capturedFiles.length}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                tooltip: 'Chọn ảnh từ thư viện',
                                onPressed: _pickFromGallery,
                              ),

                              // NÚT CHỤP VÀNG LỚN (HIỆN TIẾN ĐỘ NẾU ĐANG CHỤP DỞ)
                              GestureDetector(
                                onTap: _takePhoto,
                                child: Container(
                                  width: 74,
                                  height: 74,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 4),
                                    color: AppColors.primaryYellow,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryYellow.withValues(alpha: 0.45),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: _capturedFiles.isEmpty
                                        ? const Icon(Icons.camera_alt_rounded,
                                            color: Colors.black, size: 32)
                                        : Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.camera_alt_rounded,
                                                  color: Colors.black, size: 22),
                                              Text(
                                                '${_capturedFiles.length}/3',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),

                              // NÚT ĐỔI CAMERA TRƯỚC / SAU
                              IconButton(
                                icon: const Icon(Icons.flip_camera_ios_outlined,
                                    color: Colors.white, size: 28),
                                onPressed: _flipCamera,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              // Nút Quay lại Camera để chụp thêm hoặc sửa
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() => _isPreviewMode = false);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white38),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: const Text(
                                    'Chụp thêm',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Nút Gửi khoảnh khắc
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: _submitPost,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryYellow,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.send_rounded, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Gửi khoảnh khắc (${_capturedFiles.length})',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
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
                ],
              ),
            ),
          ),
        ),
      );
  }
}
