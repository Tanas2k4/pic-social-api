import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

enum ToastType { info, success, warning, error }

class AppToast {
  static OverlayEntry? _currentEntry;
  static bool _isVisible = false;

  /// Hiển thị Toast thông báo dạng Viên thuốc kính mờ ở đỉnh màn hình (Top Floating Glass Pill)
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    IconData? customIcon,
    Widget? customIconWidget,
    Duration duration = const Duration(milliseconds: 2300),
  }) {
    // Rung nhẹ haptic phản hồi xúc giác
    HapticFeedback.lightImpact();

    // Hủy toast cũ nếu đang hiển thị
    _dismiss();

    final overlay = Overlay.of(context, rootOverlay: true);

    _currentEntry = OverlayEntry(
      builder: (context) => _TopPillToastWidget(
        message: message,
        type: type,
        customIcon: customIcon,
        customIconWidget: customIconWidget,
        duration: duration,
        onDismissed: () {
          _dismiss();
        },
      ),
    );

    _isVisible = true;
    overlay.insert(_currentEntry!);
  }

  static void showSuccess(BuildContext context, String message, {IconData? icon, Widget? iconWidget}) {
    show(context, message: message, type: ToastType.success, customIcon: icon, customIconWidget: iconWidget);
  }

  static void showInfo(BuildContext context, String message, {IconData? icon, Widget? iconWidget}) {
    show(context, message: message, type: ToastType.info, customIcon: icon, customIconWidget: iconWidget);
  }

  static void showWarning(BuildContext context, String message, {IconData? icon, Widget? iconWidget}) {
    show(context, message: message, type: ToastType.warning, customIcon: icon, customIconWidget: iconWidget);
  }

  static void showError(BuildContext context, String message, {IconData? icon, Widget? iconWidget}) {
    show(context, message: message, type: ToastType.error, customIcon: icon, customIconWidget: iconWidget);
  }

  static void _dismiss() {
    if (_isVisible && _currentEntry != null) {
      try {
        _currentEntry?.remove();
      } catch (_) {}
      _currentEntry = null;
      _isVisible = false;
    }
  }
}

class _TopPillToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final IconData? customIcon;
  final Widget? customIconWidget;
  final Duration duration;
  final VoidCallback onDismissed;

  const _TopPillToastWidget({
    required this.message,
    required this.type,
    this.customIcon,
    this.customIconWidget,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_TopPillToastWidget> createState() => _TopPillToastWidgetState();
}

class _TopPillToastWidgetState extends State<_TopPillToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 250),
    );

    // Hiệu ứng trượt nảy lò xo mềm mại từ trên xuống
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    ));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // Hẹn giờ tự đóng
    Future.delayed(widget.duration, () {
      if (mounted) {
        _close();
      }
    });
  }

  void _close() async {
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getDefaultIcon() {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.warning:
        return Icons.warning_amber_rounded;
      case ToastType.error:
        return Icons.error_outline_rounded;
      case ToastType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 8;
    final iconWidget = widget.customIconWidget ??
        Icon(
          widget.customIcon ?? _getDefaultIcon(),
          color: Colors.black,
          size: 16,
        );

    return Positioned(
      top: topPadding,
      left: 0,
      right: 0,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: _offsetAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  // Vuốt lên trên để tắt nhanh
                  if (details.primaryDelta != null && details.primaryDelta! < -5) {
                    _close();
                  }
                },
                child: Container(
                  width: 250,
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 32),
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOlive, // Tông màu Retro Olive #6B8E23
                    borderRadius: BorderRadius.circular(19),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      iconWidget,
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
