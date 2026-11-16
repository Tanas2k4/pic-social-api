import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/avatar_picker_sheet.dart';
import '../../../../core/widgets/viewfinder_background.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/profile_repository.dart';

class SettingsScreen extends StatefulWidget {
  final UserProfileModel? profile;

  const SettingsScreen({super.key, this.profile});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserProfileModel _profile;
  bool _shareLocation = true;
  bool _onlyFriendsSeeLocation = true;
  bool _pushNotifications = true;
  bool _dataSaver = false;
  String _cacheSize = '86.4 MB';

  @override
  void initState() {
    super.initState();
    _profile = widget.profile ??
        const UserProfileModel(
          userName: 'quynhanh_film',
          firstName: 'Quỳnh Anh',
          bio: 'Chụp phim & lưu giữ khoảnh khắc 🌿',
          avatarUrl: 'https://api.dicebear.com/9.x/lorelei/png?seed=Willow',
        );
  }

  Future<void> _openAvatarPicker() async {
    final selectedUrl = await AvatarPickerSheet.show(
      context,
      currentAvatarUrl: _profile.avatarUrl,
    );
    if (selectedUrl != null && selectedUrl != _profile.avatarUrl) {
      setState(() {
        _profile = _profile.copyWith(avatarUrl: selectedUrl);
      });
      // Gửi cập nhật avatar preset lên server
      ProfileRepository().updateAvatarWithPreset(selectedUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Đã cập nhật ảnh đại diện thành công!'),
            backgroundColor: AppColors.surfaceDark,
          ),
        );
      }
    }
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xóa bộ nhớ đệm', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Dữ liệu ảnh tạm thời sẽ được xóa để giải phóng bộ nhớ. Ảnh trên đám mây của bạn không bị ảnh hưởng.',
          style: TextStyle(color: Colors.white70),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nút Hủy nhỏ gọn vừa khít chữ, bg giống button thông báo khi active (gradient graphite 0xFF2E2E36 -> 0xFF1E1E24)
              InkWell(
                onTap: () => Navigator.pop(ctx),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF2E2E36),
                        Color(0xFF1E1E24),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AppButton.primary(
                size: AppButtonSize.small,
                borderRadius: BorderRadius.circular(10),
                text: 'Xóa ngay',
                onPressed: () {
                  setState(() => _cacheSize = '0.0 MB');
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã giải phóng bộ nhớ đệm thành công!'),
                      backgroundColor: AppColors.surfaceDark,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản PicSocial này?',
          style: TextStyle(color: Colors.white70),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nút Hủy nhỏ gọn vừa khít chữ, bg giống button thông báo khi active (gradient graphite 0xFF2E2E36 -> 0xFF1E1E24)
              InkWell(
                onTap: () => Navigator.pop(ctx),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF2E2E36),
                        Color(0xFF1E1E24),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AppButton.danger(
                size: AppButtonSize.small,
                borderRadius: BorderRadius.circular(10),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await StorageService.clearToken();
                  if (mounted) {
                    context.go('/login');
                  }
                },
                text: 'Đăng xuất',
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050507),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(SolarIconsOutline.arrowLeft, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ViewfinderBackground(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
          // Thẻ tóm tắt tài khoản (Chạm để đổi avatar - Bỏ border)
          InkWell(
            onTap: _openAvatarPicker,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: _profile.avatarUrl != null && _profile.avatarUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: _profile.avatarUrl!,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(SolarIconsBold.user, color: Colors.white70),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3.5),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E2E36),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            SolarIconsBold.pen2,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _profile.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${_profile.userName} • Chạm để đổi avatar',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    SolarIconsOutline.altArrowRight,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // NHÓM 1: TÀI KHOẢN
          _buildSectionHeader('TÀI KHOẢN'),
          _buildSettingsGroup([
            _buildTile(
              icon: SolarIconsOutline.galleryEdit,
              title: 'Đổi ảnh đại diện (DiceBear)',
              trailingText: '16 mẫu',
              onTap: _openAvatarPicker,
            ),
            _buildTile(
              icon: SolarIconsOutline.user,
              title: 'Thông tin cá nhân (Tên, Bio, Vị trí)',
              onTap: () {
                _showEditProfileModal(context, _profile);
              },
            ),
            _buildTile(
              icon: SolarIconsOutline.lock,
              title: 'Đổi mật khẩu',
              onTap: () {},
            ),
            _buildTile(
              icon: SolarIconsOutline.shieldCheck,
              title: 'Bảo vệ bản quyền ảnh (Photo License)',
              trailingText: 'Tiêu chuẩn',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 24),

          // NHÓM 2: QUYỀN RIÊNG TƯ & VỊ TRÍ
          _buildSectionHeader('QUYỀN RIÊNG TƯ & VỊ TRÍ'),
          _buildSettingsGroup([
            _buildSwitchTile(
              icon: SolarIconsOutline.mapPoint,
              title: 'Chia sẻ vị trí khi đăng ảnh',
              value: _shareLocation,
              onChanged: (val) => setState(() => _shareLocation = val),
            ),
            _buildSwitchTile(
              icon: SolarIconsOutline.eye,
              title: 'Chỉ bạn bè xem được vị trí',
              value: _onlyFriendsSeeLocation,
              onChanged: (val) => setState(() => _onlyFriendsSeeLocation = val),
            ),
            _buildTile(
              icon: SolarIconsOutline.userBlock,
              title: 'Danh sách đã chặn',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 24),

          // NHÓM 3: ỨNG DỤNG & BỘ NHỚ
          _buildSectionHeader('ỨNG DỤNG & DỮ LIỆU'),
          _buildSettingsGroup([
            _buildSwitchTile(
              icon: SolarIconsOutline.bell,
              title: 'Thông báo đẩy',
              value: _pushNotifications,
              onChanged: (val) => setState(() => _pushNotifications = val),
            ),
            _buildSwitchTile(
              icon: SolarIconsOutline.database,
              title: 'Chế độ tiết kiệm dữ liệu',
              value: _dataSaver,
              onChanged: (val) => setState(() => _dataSaver = val),
            ),
            _buildTile(
              icon: SolarIconsOutline.trashBinTrash,
              title: 'Xóa bộ nhớ đệm (Cache)',
              trailingText: _cacheSize,
              onTap: _clearCache,
            ),
          ]),

          const SizedBox(height: 24),

          // NHÓM 4: THÔNG TIN & TRỢ GIÚP
          _buildSectionHeader('THÔNG TIN'),
          _buildSettingsGroup([
            _buildTile(
              icon: SolarIconsOutline.documentText,
              title: 'Điều khoản & Chính sách bảo mật',
              onTap: () {},
            ),
            _buildTile(
              icon: SolarIconsOutline.questionCircle,
              title: 'Báo cáo sự cố hoặc đóng góp ý kiến',
              onTap: () {},
            ),
            _buildTile(
              icon: SolarIconsOutline.infoCircle,
              title: 'Phiên bản PicSocial',
              trailingText: '1.0.0 (Beta)',
            ),
          ]),

          const SizedBox(height: 28),

          // NHÓM 5: ĐĂNG XUẤT & XÓA TÀI KHOẢN
          _buildSettingsGroup([
            _buildTile(
              icon: SolarIconsOutline.logout,
              title: 'Đăng xuất',
              textColor: Colors.white,
              iconColor: Colors.white70,
              onTap: _handleLogout,
            ),
            _buildTile(
              icon: SolarIconsOutline.userCross,
              title: 'Xóa tài khoản vĩnh viễn',
              textColor: Colors.redAccent,
              iconColor: Colors.redAccent,
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 40),
        ],
      ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: 52,
                color: Colors.white.withValues(alpha: 0.05),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? trailingText,
    Color textColor = Colors.white,
    Color iconColor = Colors.white70,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 20),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(
              trailingText,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (onTap != null)
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: Colors.white.withValues(alpha: 0.25),
            ),
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 20),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeTrackColor: AppColors.primaryOlive,
        onChanged: onChanged,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }

  void _showEditProfileModal(BuildContext context, UserProfileModel profile) {
    final nameCtrl = TextEditingController(text: profile.displayName);
    final bioCtrl = TextEditingController(text: profile.bio ?? '');
    final locationCtrl = TextEditingController(text: profile.location ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chỉnh sửa thông tin',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    _openAvatarPicker();
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryOlive, width: 2),
                        ),
                        child: ClipOval(
                          child: _profile.avatarUrl != null && _profile.avatarUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: _profile.avatarUrl!,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(SolarIconsBold.user, color: AppColors.primaryOlive, size: 36),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOlive.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryOlive.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'Đổi avatar DiceBear',
                          style: TextStyle(color: AppColors.primaryOlive, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildInputField('Họ và tên', nameCtrl),
              const SizedBox(height: 12),
              _buildInputField('Tiểu sử (Bio)', bioCtrl, maxLines: 2),
              const SizedBox(height: 12),
              _buildInputField('Vị trí', locationCtrl),
              const SizedBox(height: 24),
              AppButton.primary(
                isFullWidth: true,
                height: 48,
                borderRadius: BorderRadius.circular(14),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✨ Đã lưu thông tin hồ sơ!'),
                      backgroundColor: AppColors.surfaceDark,
                    ),
                  );
                },
                text: 'Lưu thay đổi',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF262628),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
