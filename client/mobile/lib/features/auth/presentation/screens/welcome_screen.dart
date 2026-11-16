import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/viewfinder_background.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': SolarIconsBold.camera,
      'color': AppColors.primaryYellow,
      'title': 'Lăng kính Film 90s',
      'subtitle': 'Tái hiện nước màu hoài niệm, hạt grain chân thật và con dấu ngày tháng retro trên từng cú bấm máy.',
    },
    {
      'icon': SolarIconsBold.heartAngle,
      'color': AppColors.primaryOlive,
      'title': 'Gói ghém cùng Bạn Thân',
      'subtitle': 'Không gian chia sẻ mộc mạc, gửi gắm khoảnh khắc chân thực đến những người bạn thương yêu.',
    },
    {
      'icon': SolarIconsBold.userCircle,
      'color': const Color(0xFF6C5CE7),
      'title': 'Avatar DiceBear Độc Bản',
      'subtitle': 'Thỏa sức chọn lựa giữa 16 phong cách anime, pixel art, robot retro... định hình cá tính riêng.',
    },
  ];

  void _quickDemoLogin() async {
    HapticFeedback.lightImpact();
    // Đăng nhập nhanh với token demo
    await StorageService.setToken('mock_demo_token_quynhanh');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Đăng nhập nhanh với tài khoản mẫu (Quỳnh Anh)!'),
          backgroundColor: AppColors.surfaceDark,
        ),
      );
      context.go('/');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF050507),
      body: ViewfinderBackground(
        child: SafeArea(
          child: Column(
          children: [
            // Thanh trên: Logo & Nút Đăng nhập mẫu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Icon(SolarIconsBold.camera, size: 16, color: AppColors.primaryYellow),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ChupChup',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: _quickDemoLogin,
                    icon: const Icon(SolarIconsBold.play, size: 13, color: AppColors.primaryYellow),
                    label: const Text(
                      'Tài khoản mẫu',
                      style: TextStyle(
                        color: AppColors.primaryYellow,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow.withValues(alpha: 0.12),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
            ),

            // Carousel 3 slide
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  final iconColor = slide['color'] as Color;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hộp biểu tượng nghệ thuật
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            shape: BoxShape.circle,
                            border: Border.all(color: iconColor.withValues(alpha: 0.4), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: iconColor.withValues(alpha: 0.25),
                                blurRadius: 36,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              slide['icon'] as IconData,
                              size: 58,
                              color: iconColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          slide['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dấu chấm chỉ số slide (Indicators)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (idx) {
                final isActive = idx == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primaryYellow : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // Các nút hành động chính bên dưới
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, mediaQuery.padding.bottom + 16),
              child: Column(
                children: [
                  AppButton.primary(
                    text: 'Bắt đầu ngay',
                    isFullWidth: true,
                    height: 52,
                    borderRadius: BorderRadius.circular(16),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.push('/register');
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      context.push('/login');
                    },
                    child: Text(
                      'Tôi đã có tài khoản • Đăng nhập',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
