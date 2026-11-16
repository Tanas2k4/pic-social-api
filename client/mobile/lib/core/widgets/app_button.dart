import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  danger,
  ghost,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

/// Nút bấm xúc giác đa năng (Tactile Bounce Button) dùng chung toàn bộ ứng dụng PicSocial:
/// - Độ sâu ánh sáng vi mô (Subtle ambient gradient + viền bắt sáng Rim Light)
/// - Hiệu ứng đàn hồi cơ học: co nảy lò xo (Scale down & spring bounce) khi nhấn
/// - Rung phản hồi xúc giác (Haptic light impact)
class AppButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final Widget? icon;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.fontSize,
    this.padding,
    this.borderRadius,
  });

  const AppButton.primary({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.fontSize,
    this.padding,
    this.borderRadius,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.fontSize,
    this.padding,
    this.borderRadius,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outline({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.fontSize,
    this.padding,
    this.borderRadius,
  }) : variant = AppButtonVariant.outline;

  const AppButton.danger({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.fontSize,
    this.padding,
    this.borderRadius,
  }) : variant = AppButtonVariant.danger;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  double get _defaultHeight {
    switch (widget.size) {
      case AppButtonSize.small:
        return 36.0;
      case AppButtonSize.medium:
        return 44.0;
      case AppButtonSize.large:
        return 52.0;
    }
  }

  double get _fontSize {
    if (widget.fontSize != null) return widget.fontSize!;
    switch (widget.size) {
      case AppButtonSize.small:
        return 13.0;
      case AppButtonSize.medium:
        return 14.0;
      case AppButtonSize.large:
        return 14.5;
    }
  }

  EdgeInsetsGeometry get _padding {
    if (widget.padding != null) return widget.padding!;
    switch (widget.size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 10);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 14);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 14);
    }
  }

  BorderRadius get _borderRadius {
    if (widget.borderRadius != null) return widget.borderRadius!;
    switch (widget.size) {
      case AppButtonSize.small:
        return BorderRadius.circular(18);
      case AppButtonSize.medium:
        return BorderRadius.circular(22);
      case AppButtonSize.large:
        return BorderRadius.circular(26);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double h = widget.height ?? _defaultHeight;
    final borderRadius = _borderRadius;

    Color textColor;
    Gradient? gradient;
    Color? solidColor;
    Border? border;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        // Retro Olive #6B8E23 đậm đà, tăng độ bão hòa sâu chống bạc màu khi đón sáng
        gradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF5F821C), // Olive đậm đón sáng (không bị nhạt hay vàng)
            Color(0xFF45610F), // Rêu trầm sâu, đậm đặc đầm tay
          ],
        );
        textColor = Colors.black;
        border = Border.all(
          color: const Color(0xFF7FA32E).withValues(alpha: 0.5),
          width: 0.9,
        );
        break;

      case AppButtonVariant.secondary:
        // Graphite tối - Không border theo yêu cầu
        gradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF28282E),
            Color(0xFF18181C),
          ],
        );
        textColor = Colors.white;
        border = null; // Bỏ hoàn toàn border
        break;

      case AppButtonVariant.outline:
        solidColor = Colors.transparent;
        textColor = Colors.white;
        border = Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 1.1,
        );
        break;

      case AppButtonVariant.danger:
        gradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF5252),
            Color(0xFFD32F2F),
          ],
        );
        textColor = Colors.white;
        border = Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 0.9,
        );
        break;

      case AppButtonVariant.ghost:
        solidColor = Colors.transparent;
        textColor = AppColors.textPrimary;
        border = null;
        break;
    }

    final content = AnimatedOpacity(
      duration: const Duration(milliseconds: 140),
      opacity: _isEnabled ? 1.0 : 0.45,
      child: Center(
        child: widget.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: textColor,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    IconTheme(
                      data: IconThemeData(color: textColor, size: 18),
                      child: widget.icon!,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      widget.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: _fontSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );

    return AnimatedScale(
      scale: _isPressed && _isEnabled ? 0.955 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          if (!_isEnabled) return;
          HapticFeedback.lightImpact();
          setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (!_isEnabled) return;
          setState(() => _isPressed = false);
        },
        onTapCancel: () {
          if (!_isEnabled) return;
          setState(() => _isPressed = false);
        },
        onTap: () {
          if (!_isEnabled) return;
          widget.onPressed?.call();
        },
        child: Container(
          width: widget.isFullWidth ? double.infinity : widget.width,
          height: h,
          padding: _padding,
          decoration: BoxDecoration(
            gradient: gradient,
            color: solidColor,
            borderRadius: borderRadius,
            border: border,
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Nút bấm Icon xúc giác tròn / bo góc (Tactile Icon Button):
/// Thừa hưởng cơ học co nảy lò xo, gradient graphite/glass và viền bắt sáng Rim Light
class AppIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final double size;
  final String? tooltip;
  final bool isSelected;
  final Color? activeColor;
  final BorderRadius? borderRadius;

  const AppIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 40.0,
    this.tooltip,
    this.isSelected = false,
    this.activeColor,
    this.borderRadius,
  });

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double s = widget.size;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(s / 2);

    final effectiveGradient = widget.isSelected
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF5F821C).withValues(alpha: 0.92),
              const Color(0xFF45610F).withValues(alpha: 0.95),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF28282E),
              Color(0xFF18181C),
            ],
          );

    // Không có màu oliu thì BỎ BORDER theo yêu cầu
    final effectiveBorder = widget.isSelected
        ? Border.all(
            color: const Color(0xFF7FA32E).withValues(alpha: 0.6),
            width: 1.0,
          )
        : null;

    Widget result = AnimatedScale(
      scale: _isPressed && widget.onPressed != null ? 0.90 : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          if (widget.onPressed == null) return;
          HapticFeedback.lightImpact();
          setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (widget.onPressed == null) return;
          setState(() => _isPressed = false);
        },
        onTapCancel: () {
          if (widget.onPressed == null) return;
          setState(() => _isPressed = false);
        },
        onTap: widget.onPressed,
        child: Container(
          width: s,
          height: s,
          decoration: BoxDecoration(
            gradient: effectiveGradient,
            borderRadius: borderRadius,
            border: effectiveBorder,
          ),
          child: Center(child: widget.icon),
        ),
      ),
    );

    if (widget.tooltip != null) {
      result = Tooltip(message: widget.tooltip!, child: result);
    }

    return result;
  }
}
