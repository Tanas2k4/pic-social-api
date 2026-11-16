import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/default_avatars.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/viewfinder_background.dart';
import '../../../profile/data/repositories/profile_repository.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String? identifier;

  const ProfileSetupScreen({super.key, this.identifier});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _bioCtrl = TextEditingController(text: 'Đam mê chụp phim & lưu giữ khoảnh khắc ✨');
  late String _selectedAvatarUrl;

  @override
  void initState() {
    super.initState();
    // Khởi tạo avatar mặc định theo identifier
    _selectedAvatarUrl = DefaultAvatars.getByUsername(widget.identifier);
    _nameCtrl.text = widget.identifier?.contains('@') == true
        ? widget.identifier!.split('@')[0]
        : 'Thành viên mới';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _onSelectAvatar(String url) {
    HapticFeedback.selectionClick();
    setState(() => _selectedAvatarUrl = url);
  }

  void _pickRandomAvatar() {
    HapticFeedback.mediumImpact();
    final remaining = DefaultAvatars.items.where((i) => i.url != _selectedAvatarUrl).toList();
    if (remaining.isNotEmpty) {
      remaining.shuffle();
      setState(() => _selectedAvatarUrl = remaining.first.url);
    }
  }

  void _finishSetup() async {
    HapticFeedback.lightImpact();
    // Cập nhật avatar preset lên server
    ProfileRepository().updateAvatarWithPreset(_selectedAvatarUrl);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chào mừng bạn đến với cộng đồng ChupChup!'),
        backgroundColor: AppColors.surfaceDark,
      ),
    );
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF050507),
      body: ViewfinderBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 16, 24, mediaQuery.padding.bottom + 20),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thiết lập hồ sơ của bạn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Chọn ảnh đại diện và đặt tên hiển thị của bạn',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 24),

              // Avatar xem trước trung tâm to tròn kèm nút ngẫu nhiên
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.25),
                                blurRadius: 18,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: _selectedAvatarUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: InkWell(
                            onTap: _pickRandomAvatar,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(SolarIconsBold.magicStick, size: 14, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _pickRandomAvatar,
                      icon: const Icon(SolarIconsBold.magicStick, size: 14, color: Colors.white70),
                      label: const Text(
                        'Chọn ngẫu nhiên',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Chọn ảnh đại diện
              const Text(
                'Chọn ảnh đại diện',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: DefaultAvatars.items.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = DefaultAvatars.items[index];
                    final isSelected = item.url == _selectedAvatarUrl;

                    return GestureDetector(
                      onTap: () => _onSelectAvatar(item.url),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 58,
                            height: 58,
                            padding: const EdgeInsets.all(2.5),
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
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: item.url,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white60,
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Form thông tin (Bỏ border)
              const Text(
                'Họ và tên hiển thị',
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _nameCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Ví dụ: Quỳnh Anh',
                    hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'Tiểu sử (Bio)',
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _bioCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Mô tả ngắn về bạn',
                    hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Nút hoàn tất
              AppButton.primary(
                text: 'Hoàn tất & Bắt đầu khám phá',
                isFullWidth: true,
                height: 52,
                borderRadius: BorderRadius.circular(16),
                onPressed: _finishSetup,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
