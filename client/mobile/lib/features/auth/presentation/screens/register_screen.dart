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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthRepository _authRepo = AuthRepository();
  AuthInputType _inputType = AuthInputType.phone;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  CountryCodeItem _selectedCountry = CountryCodes.defaultCountry;
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
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

  String get _fullIdentifier {
    if (_inputType == AuthInputType.phone) {
      var num = _phoneCtrl.text.trim();
      if (num.startsWith('0')) num = num.substring(1);
      return '${_selectedCountry.dialCode}$num';
    }
    return _emailCtrl.text.trim();
  }

  Future<void> _handleRegister() async {
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
    final confirmPassword = _confirmPasswordCtrl.text.trim();

    if (password.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu phải có ít nhất 6 ký tự'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu và xác nhận mật khẩu không khớp'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await _authRepo.register(
      identifier: identifier,
      password: password,
      confirmPassword: confirmPassword,
      isPhone: _inputType == AuthInputType.phone,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (res.isSuccess) {
      // Chuyển sang màn hình OTP để kích hoạt tài khoản
      context.push(
        '/otp',
        extra: {
          'identifier': identifier,
          'isPhone': _inputType == AuthInputType.phone,
          'demoOtp': res.demoOtp ?? '123456',
        },
      );
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
                  center: Alignment(0, -0.25),
                  radius: 1.15,
                  colors: [
                    Color(0xFF22222B),
                    Color(0xFF141419),
                    Color(0xFF08080A),
                    Color(0xFF030304),
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
                'Tạo tài khoản mới',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Đăng ký tài khoản để khám phá và chia sẻ khoảnh khắc chất film',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // BỘ CHUYỂN ĐỔI SĐT / EMAIL:
              // - CĂN GIỮA (Center)
              // - Vừa khít 2 nút tròn
              // - Không xài màu oliu mà xài gradient graphite
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
                        tooltip: 'Đăng ký bằng số điện thoại',
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
                        tooltip: 'Đăng ký bằng email',
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

              // KHỐI NHẬP LIỆU: BỎ BORDER HOÀN TOÀN
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
                              hintText: 'Số điện thoại của bạn',
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
                            hintText: 'Địa chỉ email của bạn',
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
                          hintText: 'Tạo mật khẩu (tối thiểu 6 ký tự)',
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

              // Ô xác nhận mật khẩu (Bỏ border, căn giữa trên dưới chuẩn 100%)
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(SolarIconsOutline.lockPassword, color: Colors.white38, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _confirmPasswordCtrl,
                        obscureText: _obscureConfirmPassword,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Xác nhận lại mật khẩu',
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
                      onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          _obscureConfirmPassword ? SolarIconsOutline.eyeClosed : SolarIconsOutline.eye,
                          color: Colors.white38,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Nút Đăng ký & Nhận mã kích hoạt
              AppButton.primary(
                text: _isLoading ? 'Đang khởi tạo...' : 'Đăng ký & Kích hoạt OTP',
                isFullWidth: true,
                height: 50,
                borderRadius: BorderRadius.circular(16),
                onPressed: _isLoading ? () {} : _handleRegister,
              ),

              const SizedBox(height: 20),

              // Chuyển sang màn Đăng nhập
              Center(
                child: GestureDetector(
                  onTap: () {
                    context.pop();
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                      children: const [
                        TextSpan(text: 'Đã có tài khoản? '),
                        TextSpan(
                          text: 'Đăng nhập ngay',
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
            ],
          ),
        ),
      ),
    ],
  ),
);
}

/// Nút tròn chuyển đổi SĐT/Email
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
