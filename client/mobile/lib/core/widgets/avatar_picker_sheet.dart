import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_icons/solar_icons.dart';
import '../constants/app_colors.dart';
import '../constants/default_avatars.dart';
import 'app_button.dart';

/// BottomSheet chọn avatar từ bộ sưu tập DiceBear tuyển chọn (không funemoji)
class AvatarPickerSheet extends StatefulWidget {
  final String? initialAvatarUrl;
  final ValueChanged<String>? onAvatarSelected;

  const AvatarPickerSheet({
    super.key,
    this.initialAvatarUrl,
    this.onAvatarSelected,
  });

  /// Hàm tiện ích để mở modal bottom sheet
  static Future<String?> show(
    BuildContext context, {
    String? currentAvatarUrl,
    ValueChanged<String>? onAvatarSelected,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AvatarPickerSheet(
        initialAvatarUrl: currentAvatarUrl,
        onAvatarSelected: onAvatarSelected,
      ),
    );
  }

  @override
  State<AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<AvatarPickerSheet> {
  late String _selectedUrl;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _selectedUrl = widget.initialAvatarUrl ?? DefaultAvatars.items.first.url;
  }

  void _pickRandomAvatar() {
    HapticFeedback.mediumImpact();
    final remaining = DefaultAvatars.items.where((i) => i.url != _selectedUrl).toList();
    if (remaining.isNotEmpty) {
      final next = remaining[_random.nextInt(remaining.length)];
      setState(() {
        _selectedUrl = next.url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle kéo
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header: Tiêu đề + Nút Đổi ngẫu nhiên gọn gàng (không label thừa)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chọn ảnh đại diện',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Nút random biểu tượng gọn gàng, nền trong suốt không màu, không label thừa
                InkWell(
                  onTap: _pickRandomAvatar,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      SolarIconsBold.magicStick,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Vùng hiển thị avatar đang chọn xem trước (Bỏ border ngoài wrapper, viền trắng)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: _selectedUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final item = DefaultAvatars.items.firstWhere(
                        (i) => i.url == _selectedUrl,
                        orElse: () => DefaultAvatars.items.first,
                      );
                      return Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Lưới chọn 16 avatar
          Flexible(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
                childAspectRatio: 0.8,
              ),
              itemCount: DefaultAvatars.items.length,
              itemBuilder: (context, index) {
                final item = DefaultAvatars.items[index];
                final isSelected = item.url == _selectedUrl;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedUrl = item.url;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 60,
                            height: 60,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.12),
                                width: isSelected ? 2.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.25),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                            child: ClipOval(
                              child: Container(
                                color: Colors.white.withValues(alpha: 0.05),
                                child: CachedNetworkImage(
                                  imageUrl: item.url,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.white10,
                                    child: const Center(
                                      child: SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          color: Colors.white30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 13,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Nút xác nhận
          Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, mediaQuery.padding.bottom + 16),
            child: AppButton.primary(
              text: 'Sử dụng avatar này',
              isFullWidth: true,
              height: 48,
              borderRadius: BorderRadius.circular(16),
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onAvatarSelected?.call(_selectedUrl);
                Navigator.pop(context, _selectedUrl);
              },
            ),
          ),
        ],
      ),
    );
  }
}
