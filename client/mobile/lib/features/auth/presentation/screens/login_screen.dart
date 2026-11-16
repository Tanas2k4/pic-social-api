import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/country_codes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/country_picker_bottom_sheet.dart';
import '../../data/auth_repository.dart';

enum AuthInputType { phone, email }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthRepository _authRepo = AuthRepository();
  AuthInputType _inputType = AuthInputType.phone;
  bool _isLoading = false;
  bool _obscurePassword = true;

  CountryCodeItem _selectedCountry = CountryCodes.defaultCountry;
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _openCountryPicker() async {
    final result = await CountryPickerBottomSheet.show(
      context,
      currentCountry: _selectedCountry,
    );
    if (result != null) {
      setState(() => _selectedCountry = result);
    }
  }

  void _fillDemoUser(String phone, String email) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_inputType == AuthInputType.phone) {
        _phoneCtrl.text = phone.replaceFirst('+84', '');
        _selectedCountry = CountryCodes.defaultCountry;
      } else {
        _emailCtrl.text = email;
      }
      _passwordCtrl.text = 'User@123';
    });
  }

  String get _fullIdentifier {
    if (_inputType == AuthInputType.phone) {
      var num = _phoneCtrl.text.trim();
      if (num.startsWith('0')) num = num.substring(1);
      return '${_selectedCountry.dialCode}$num';
    }
    return _emailCtrl.text.trim();
  }

  Future<void> _handleLogin() async {
    final identifier = _fullIdentifier;
    if (identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_inputType == AuthInputType.phone
              ? 'Vui lòng nhập số điện thoại'
              : 'Vui lòng nhập địa chỉ email'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final password = _passwordCtrl.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập mật khẩu'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await _authRepo.login(identifier, password);
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: AppColors.surfaceDark),
      );
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF050507),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(SolarIconsOutline.arrowLeft, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background Phương án 2: Ống Ngắm Máy Cơ & Vignette
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.25), // Tâm sáng than chì khói tại khu vực nội dung
                  radius: 1.15,
                  colors: [
                    Color(0xFF22222B), // Tâm sáng màu than chì khói
                    Color(0xFF141419), // Vùng chuyển sắc êm dịu
                    Color(0xFF08080A), // Rìa tối đậm
                    Color(0xFF030304), // 4 góc tối thẳm mô phỏng Vignette thấu kính
                  ],
                  stops: [0.0, 0.42, 0.8, 1.0],
                ),
              ),
            ),
          ),

          // Khung viền ngắm máy cơ cổ điển (Viewfinder Frame Marks)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ViewfinderVignettePainter(),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 8, 24, mediaQuery.padding.bottom + 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề & phụ đề
              const Text(
                'Chào mừng bạn đến với ChupChup',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Đăng nhập tài khoản bằng số điện thoại hoặc email',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // BỘ CHUYỂN ĐỔI SĐT / EMAIL:
              // - CĂN GIỮA (Center)
              // - Làm ngắn lại vừa khít 2 nút tròn
              // - Dùng màu trong suốt / gradient graphite như nút Cài đặt & Thông báo
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nút tròn Số điện thoại
                      _buildSwitchIconButton(
                        icon: _inputType == AuthInputType.phone
                            ? SolarIconsBold.phone
                            : SolarIconsOutline.phone,
                        isSelected: _inputType == AuthInputType.phone,
                        tooltip: 'Đăng nhập bằng số điện thoại',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _inputType = AuthInputType.phone);
                        },
                      ),
                      const SizedBox(width: 4),
                      // Nút tròn Email
                      _buildSwitchIconButton(
                        icon: _inputType == AuthInputType.email
                            ? SolarIconsBold.letter
                            : SolarIconsOutline.letter,
                        isSelected: _inputType == AuthInputType.email,
                        tooltip: 'Đăng nhập bằng email',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _inputType = AuthInputType.email);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // KHỐI NHẬP LIỆU: BỎ TOÀN BỘ BORDER Ở INPUT VÀ LABEL
              if (_inputType == AuthInputType.phone) ...[
                // Input SĐT + Chọn Quốc Gia (xài hình cờ emoji bình thường)
                Row(
                  children: [
                    // Nút chọn mã vùng quốc gia (Dùng cờ emoji chuẩn, không border)
                    GestureDetector(
                      onTap: _openCountryPicker,
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedCountry.flag,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedCountry.dialCode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              SolarIconsOutline.altArrowDown,
                              color: Colors.white.withValues(alpha: 0.4),
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Ô nhập số điện thoại (Bỏ border, căn giữa hoàn hảo)
                    Expanded(
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: TextField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            textAlignVertical: TextAlignVertical.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Số điện thoại (ví dụ: 912345678)',
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.32),
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Input Email (Bỏ border, căn giữa hoàn hảo)
                Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(SolarIconsOutline.letter, color: Colors.white38, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Nhập địa chỉ email của bạn',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.32),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Ô nhập mật khẩu (Bỏ border, căn giữa trên dưới chuẩn 100%)
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(SolarIconsOutline.lock, color: Colors.white38, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Mật khẩu',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.32),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          _obscurePassword ? SolarIconsOutline.eyeClosed : SolarIconsOutline.eye,
                          color: Colors.white38,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Quên mật khẩu
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Nút Đăng nhập
              AppButton.primary(
                text: _isLoading ? 'Đang đăng nhập...' : 'Đăng nhập',
                isFullWidth: true,
                height: 50,
                borderRadius: BorderRadius.circular(16),
                onPressed: _isLoading ? () {} : _handleLogin,
              ),

              const SizedBox(height: 20),

              // Chuyển sang màn Đăng ký
              Center(
                child: GestureDetector(
                  onTap: () {
                    context.push('/register');
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                      children: const [
                        TextSpan(text: 'Chưa có tài khoản? '),
                        TextSpan(
                          text: 'Đăng ký ngay',
                          style: TextStyle(
                            color: AppColors.primaryYellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // KHỐI TÀI KHOẢN MẪU SEED SẴN (Bỏ border, tối giản)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(SolarIconsBold.userCheck, size: 15, color: AppColors.primaryYellow),
                        SizedBox(width: 6),
                        Text(
                          'Tài khoản Seed mẫu (Chạm để điền nhanh):',
                          style: TextStyle(
                            color: AppColors.primaryYellow,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDemoAccountTile(
                      name: 'Quỳnh Anh (quynhanh_film)',
                      detail: '+84 912 345 678 • quynhanh@gmail.com',
                      onTap: () => _fillDemoUser('0912345678', 'quynhanh@gmail.com'),
                    ),
                    const SizedBox(height: 8),
                    _buildDemoAccountTile(
                      name: 'Hoàng Duy (duy_vintage)',
                      detail: '+84 987 654 321 • duy@gmail.com',
                      onTap: () => _fillDemoUser('0987654321', 'duy@gmail.com'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);
}

  /// Nút tròn chuyển đổi SĐT/Email giống hệt phong cách nút Cài đặt & Thông báo
  Widget _buildSwitchIconButton({
    required IconData icon,
    required bool isSelected,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2E2E36),
                      Color(0xFF1C1C20),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoAccountTile({
    required String name,
    required String detail,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(SolarIconsBold.play, color: AppColors.primaryYellow, size: 14),
          ],
        ),
      ),
    );
  }
}

/// Khung ngắm máy ảnh phim (Viewfinder Frame Markers)
class _ViewfinderVignettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const double inset = 18.0;
    const double len = 14.0;

    // Góc trên - trái ┌
    canvas.drawLine(const Offset(inset, inset), const Offset(inset + len, inset), paint);
    canvas.drawLine(const Offset(inset, inset), const Offset(inset, inset + len), paint);

    // Góc trên - phải ┐
    canvas.drawLine(Offset(size.width - inset, inset), Offset(size.width - inset - len, inset), paint);
    canvas.drawLine(Offset(size.width - inset, inset), Offset(size.width - inset, inset + len), paint);

    // Góc dưới - trái └
    canvas.drawLine(Offset(inset, size.height - inset), Offset(inset + len, size.height - inset), paint);
    canvas.drawLine(Offset(inset, size.height - inset), Offset(inset, size.height - inset - len), paint);

    // Góc dưới - phải ┘
    canvas.drawLine(Offset(size.width - inset, size.height - inset), Offset(size.width - inset - len, size.height - inset), paint);
    canvas.drawLine(Offset(size.width - inset, size.height - inset), Offset(size.width - inset, size.height - inset - len), paint);

    // Điểm ngắm chữ thập trung tâm (Crosshair) mờ nhẹ
    final crossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;
    final center = Offset(size.width / 2, size.height * 0.22);
    canvas.drawLine(Offset(center.dx - 6, center.dy), Offset(center.dx + 6, center.dy), crossPaint);
    canvas.drawLine(Offset(center.dx, center.dy - 6), Offset(center.dx, center.dy + 6), crossPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
