import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/film_lut_presets.dart';

/// Dải chọn cuộn Film cổ điển kiểu thẻ Card xếp dọc (Dazz Cam Style)
class RetroFilmDrawer extends StatelessWidget {
  final bool isOpen;
  final FilmPreset selectedFilm;
  final ValueChanged<FilmPreset> onSelectFilm;

  const RetroFilmDrawer({
    super.key,
    required this.isOpen,
    required this.selectedFilm,
    required this.onSelectFilm,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      left: isOpen ? 12 : -80,
      top: 36,
      bottom: 36,
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: FilmPresets.all.map((preset) {
              final bool isSelected = selectedFilm.id == preset.id;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelectFilm(preset);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Card xem trước cuộn film
                      AnimatedScale(
                        scale: isSelected ? 1.08 : 1.0,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutQuad,
                        child: AnimatedOpacity(
                          opacity: isSelected ? 1.0 : 0.72,
                          duration: const Duration(milliseconds: 180),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11),
                              border: isSelected
                                  ? Border.all(
                                      color: preset.accentColor,
                                      width: 2.0,
                                    )
                                  : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: SizedBox(
                                width: 48,
                                height: 64,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Ảnh mẫu áp LUT trực tiếp
                                    ColorFiltered(
                                      colorFilter: ColorFilter.matrix(preset.matrix),
                                      child: Image.asset(
                                        'assets/presets/lut_sample.jpg',
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) {
                                          return Container(
                                            color: preset.accentColor.withValues(alpha: 0.4),
                                          );
                                        },
                                      ),
                                    ),
                                    // Scrim tối ở chân thẻ
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      height: 22,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withValues(alpha: 0.8),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Tên viết tắt của cuộn film
                                    Positioned(
                                      left: 3,
                                      right: 3,
                                      bottom: 3,
                                      child: Text(
                                        preset.shortName.toUpperCase(),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isSelected ? preset.accentColor : Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: preset.accentColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
