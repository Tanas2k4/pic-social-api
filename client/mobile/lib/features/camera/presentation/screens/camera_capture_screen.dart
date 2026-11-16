import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../feed/data/models/post_item_model.dart';
import '../../data/film_lut_presets.dart';
import '../../services/camera_feedback_service.dart';
import '../../services/film_processor_service.dart';
import '../widgets/retro_viewfinder_frame.dart';
import '../widgets/retro_shutter_bar.dart';

/// Màn hình Máy ảnh Film Retro cho PicSocial
/// Áp dụng kiến trúc tách bạch: Live Preview GPU + Background Engine nướng hiệu ứng thật (Pipeline Parity)
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
  bool _isShutterPressed = false;
  FlashMode _flashMode = FlashMode.off;

  // THÔNG SỐ TIÊU CỰ & ZOOM CỦA ĐIỆN THOẠI
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;
  bool _isFrontCamera = false;
  bool _isScreenFlashActive = false;

  // MẶC ĐỊNH LÀ ẢNH GỐC KHI MỞ MÁY
  FilmPreset _selectedFilm = FilmPresets.original;
  bool _isFilmDrawerOpen = true;
  double _touchStartX = 0.0;
  double _touchStartY = 0.0;
  bool _hasSwipedHorizontally = false;

  // DANH SÁCH ẢNH ĐÃ CHỤP / CHỌN (TỐI ĐA 3 ẢNH)
  final List<XFile> _capturedFiles = [];
  bool _isPreviewMode = false;
  int _previewIndex = 0;
  final TextEditingController _captionController = TextEditingController();

  // Hiệu ứng vuốt lên trượt để về Feed
  final ValueNotifier<double> _dragOffsetY = ValueNotifier<double>(0.0);
  final ValueNotifier<double> _zoomNotifier = ValueNotifier<double>(1.0);
  late AnimationController _animController;
  Animation<double>? _slideAnimation;

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

      // Đọc các mức tiêu cự thực tế của phần cứng camera
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

      // Khởi tạo Flash phù hợp
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

  Future<void> _setZoom(double zoom) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final clamped = zoom.clamp(_minZoom, _maxZoom);
    try {
      await _controller!.setZoomLevel(clamped);
      _currentZoom = clamped;
      _zoomNotifier.value = clamped;
      CameraFeedbackService.dialTick();
    } catch (e) {
      debugPrint('Lỗi zoom: $e');
    }
  }

  void _cycleZoom() {
    final levels = _availableZoomLevels;
    if (levels.isEmpty) return;
    int currentIndex = levels.indexWhere((l) => (_currentZoom - l).abs() < 0.25);
    int nextIndex = (currentIndex + 1) % levels.length;
    _setZoom(levels[nextIndex]);
  }

  Future<void> _flipCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    CameraFeedbackService.toggleSwitch();
    setState(() {
      _isCameraReady = false;
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    });
    await _controller?.dispose();
    await _initCameraController(_cameras![_selectedCameraIndex]);
  }

  Future<void> _toggleFlash() async {
    CameraFeedbackService.toggleSwitch();
    if (_isFrontCamera) {
      setState(() {
        _isScreenFlashActive = !_isScreenFlashActive;
      });
      AppToast.showInfo(
        context,
        _isScreenFlashActive ? 'Đã bật trợ sáng màn hình selfie 💡' : 'Đã tắt trợ sáng màn hình',
        icon: _isScreenFlashActive ? SolarIconsBold.bolt : SolarIconsOutline.bolt,
      );
      return;
    }

    if (_controller == null || !_controller!.value.isInitialized) return;
    FlashMode nextMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    try {
      await _controller!.setFlashMode(nextMode);
      setState(() {
        _flashMode = nextMode;
      });
      if (!mounted) return;
      AppToast.showInfo(
        context,
        nextMode == FlashMode.torch ? 'Đã bật đèn Flash ⚡' : 'Đã tắt đèn Flash',
        icon: nextMode == FlashMode.torch ? SolarIconsBold.bolt : SolarIconsOutline.bolt,
      );
    } catch (e) {
      debugPrint('Flash error: $e');
      if (mounted) {
        AppToast.showWarning(context, 'Thiết bị không hỗ trợ Flash cho camera này');
      }
    }
  }

  // CHỤP ẢNH FILM: SHUTTER TỨC THÌ + NƯỚNG HIỆU ỨNG VÀO FILE THẬT
  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isTakingPhoto) return;
    if (_capturedFiles.length >= 3) return;

    try {
      // 1. Phản hồi xúc giác & âm thanh màn trập cơ học
      await CameraFeedbackService.shutterClick();
      setState(() => _isTakingPhoto = true);

      // 2. Chụp khung hình từ camera
      final XFile photo = await _controller!.takePicture();

      if (mounted) {
        setState(() => _isTakingPhoto = false);
      }

      // 3. Phản hồi tiếng mô tơ lên phim
      CameraFeedbackService.filmWinding();

      // 4. Nướng hiệu ứng Film Preset vào file ảnh
      final presetToBake = _selectedFilm;
      final String bakedPath = await FilmProcessorService.instance.bakeFilmPreset(
        sourcePath: photo.path,
        preset: presetToBake,
      );

      if (mounted) {
        setState(() {
          _capturedFiles.add(XFile(bakedPath));
          if (_capturedFiles.length >= 3) {
            _isPreviewMode = true;
            _previewIndex = 0;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTakingPhoto = false);
      }
      debugPrint('Chụp ảnh thất bại: $e');
    }
  }

  // CHỌN ẢNH TỪ THƯ VIỆN & NƯỚNG TONE FILM ĐÃ CHỌN
  Future<void> _pickFromGallery() async {
    final int remaining = 3 - _capturedFiles.length;
    if (remaining <= 0) {
      AppToast.showWarning(
        context,
        'Bạn đã chọn đủ tối đa 3 ảnh! 📸',
        icon: SolarIconsOutline.gallery,
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> images = await picker.pickMultiImage(imageQuality: 85);
      if (images.isNotEmpty && mounted) {
        final toAdd = images.take(remaining).toList();
        for (final img in toAdd) {
          final bakedPath = await FilmProcessorService.instance.bakeFilmPreset(
            sourcePath: img.path,
            preset: _selectedFilm,
          );
          if (mounted) {
            setState(() {
              _capturedFiles.add(XFile(bakedPath));
            });
          }
        }
        if (_capturedFiles.length >= 3 && mounted) {
          setState(() {
            _isPreviewMode = true;
            _previewIndex = 0;
          });
        }
      }
    } catch (e) {
      final XFile? single = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (single != null && mounted) {
        final bakedPath = await FilmProcessorService.instance.bakeFilmPreset(
          sourcePath: single.path,
          preset: _selectedFilm,
        );
        if (mounted) {
          setState(() {
            _capturedFiles.add(XFile(bakedPath));
            if (_capturedFiles.length >= 3) {
              _isPreviewMode = true;
              _previewIndex = 0;
            }
          });
        }
      }
    }
  }

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

  void _retakeAll() {
    setState(() {
      _capturedFiles.clear();
      _isPreviewMode = false;
      _previewIndex = 0;
      _captionController.clear();
    });
  }

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

  // CỬ CHỈ TRƯỢT LÊN ĐỂ VỀ FEED
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
                // 1. THANH TIÊU ĐỀ TRÊN CÙNG
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: _handleVerticalDragUpdate,
                  onVerticalDragEnd: _handleVerticalDragEnd,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppIconButton(
                          size: 42,
                          icon: Icon(
                            _isPreviewMode ? SolarIconsOutline.arrowLeft : SolarIconsOutline.closeCircle,
                            color: Colors.white,
                            size: 21,
                          ),
                          tooltip: _isPreviewMode ? 'Quay lại' : 'Đóng camera',
                          onPressed: () {
                            if (_isPreviewMode) {
                              setState(() => _isPreviewMode = false);
                            } else {
                              _dismissUpwards();
                            }
                          },
                        ),

                        // TIÊU ĐỀ
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isPreviewMode
                                  ? 'Xem trước (${_capturedFiles.length} ảnh film)'
                                  : (_capturedFiles.isEmpty
                                      ? 'Máy ảnh Film Retro'
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
                                  Icon(SolarIconsOutline.arrowUp,
                                      color: Colors.white.withValues(alpha: 0.6), size: 15),
                                  const SizedBox(width: 4),
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

                        // NÚT BẬT / TẮT FLASH HOẶC RETAKE
                        _isPreviewMode
                            ? AppIconButton(
                                size: 42,
                                icon: const Icon(SolarIconsOutline.restart,
                                    color: Colors.white, size: 21),
                                tooltip: 'Chụp lại từ đầu',
                                onPressed: _retakeAll,
                              )
                            : AppIconButton(
                                size: 42,
                                icon: Icon(
                                  _isFrontCamera
                                      ? (_isScreenFlashActive ? SolarIconsBold.bolt : SolarIconsOutline.bolt)
                                      : (_flashMode == FlashMode.torch ? SolarIconsBold.bolt : SolarIconsOutline.bolt),
                                  color: (_isFrontCamera ? _isScreenFlashActive : _flashMode == FlashMode.torch)
                                      ? const Color(0xFFFFCC00)
                                      : Colors.white,
                                  size: 21,
                                ),
                                tooltip: 'Đèn Flash',
                                onPressed: _toggleFlash,
                              ),
                      ],
                    ),
                  ),
                ),

                // 2. KHUNG NGẮM KÍNH ẢNH RETRO
                RetroViewfinderFrame(
                  controller: _controller,
                  isCameraReady: _isCameraReady,
                  isFrontCamera: _isFrontCamera,
                  isScreenFlashActive: _isScreenFlashActive,
                  isTakingPhoto: _isTakingPhoto,
                  selectedFilm: _selectedFilm,
                  isFilmDrawerOpen: _isFilmDrawerOpen,
                  onToggleFilmDrawer: () {
                    setState(() => _isFilmDrawerOpen = !_isFilmDrawerOpen);
                  },
                  onSelectFilm: (preset) {
                    setState(() => _selectedFilm = preset);
                  },
                  zoomNotifier: _zoomNotifier,
                  onCycleZoom: _cycleZoom,
                  onScaleStart: (details) {
                    _baseZoom = _currentZoom;
                    _touchStartX = details.focalPoint.dx;
                    _touchStartY = details.focalPoint.dy;
                    _hasSwipedHorizontally = false;
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
                      final double diffX = details.focalPoint.dx - _touchStartX;
                      final double diffY = details.focalPoint.dy - _touchStartY;

                      if (!_hasSwipedHorizontally && diffX.abs() > 32 && diffX.abs() > diffY.abs() * 1.2) {
                        if (diffX > 0 && !_isFilmDrawerOpen) {
                          _hasSwipedHorizontally = true;
                          setState(() => _isFilmDrawerOpen = true);
                          CameraFeedbackService.dialTick();
                        } else if (diffX < 0 && _isFilmDrawerOpen) {
                          _hasSwipedHorizontally = true;
                          setState(() => _isFilmDrawerOpen = false);
                          CameraFeedbackService.dialTick();
                        }
                      } else if (!_hasSwipedHorizontally) {
                        if (details.focalPointDelta.dy < 0 || _dragOffsetY.value < 0) {
                          _dragOffsetY.value += details.focalPointDelta.dy;
                        }
                      }
                    }
                  },
                  onScaleEnd: (details) {
                    _hasSwipedHorizontally = false;
                    if (_dragOffsetY.value < -70 ||
                        (_dragOffsetY.value < -20 && details.velocity.pixelsPerSecond.dy < -250)) {
                      _dismissUpwards();
                    } else if (_dragOffsetY.value != 0) {
                      _springBack();
                    }
                  },
                  isPreviewMode: _isPreviewMode,
                  capturedFiles: _capturedFiles,
                  previewIndex: _previewIndex,
                  onPreviewIndexChanged: (i) => setState(() => _previewIndex = i),
                  captionController: _captionController,
                  onRemovePhotoAt: _removePhotoAt,
                  onOpenPreview: () {
                    CameraFeedbackService.dialTick();
                    setState(() {
                      _isPreviewMode = true;
                      _previewIndex = 0;
                    });
                  },
                ),

                // 3. CỤM PHÍM BẤM CHỤP SHUTTER & THAO TÁC CƠ HỌC
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: _handleVerticalDragUpdate,
                  onVerticalDragEnd: _handleVerticalDragEnd,
                  child: RetroShutterBar(
                    isPreviewMode: _isPreviewMode,
                    capturedCount: _capturedFiles.length,
                    isShutterPressed: _isShutterPressed,
                    isTakingPhoto: _isTakingPhoto,
                    onPickGallery: _pickFromGallery,
                    onShutterTap: _takePhoto,
                    onShutterPressChanged: (pressed) {
                      setState(() => _isShutterPressed = pressed);
                    },
                    onFlipCamera: _flipCamera,
                    onBackToCamera: () {
                      setState(() => _isPreviewMode = false);
                    },
                    onSubmitPost: _submitPost,
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
