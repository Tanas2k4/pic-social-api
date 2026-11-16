import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/viewfinder_background.dart';
import '../../data/auth_repository.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String identifier;
  final bool isPhone;
  final String demoOtp;

  const OtpVerificationScreen({
    super.key,
    required this.identifier,
    this.isPhone = true,
    this.demoOtp = '123456',
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final AuthRepository _authRepo = AuthRepository();
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _countdown = 60;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _fillDemoOtp() {
    HapticFeedback.lightImpact();
    final demo = widget.demoOtp;
    for (int i = 0; i < 6; i++) {
      if (i < demo.length) {
        _controllers[i].text = demo[i];
      }
    }
    _focusNodes.last.requestFocus();
  }

  Future<void> _resendOtp() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    final res = await _authRepo.sendOtp(widget.identifier);
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (res.isSuccess) {
      _startCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: AppColors.surfaceDark,
        ),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpCode;
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đủ 6 chữ số mã OTP'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await _authRepo.verifyOtp(widget.identifier, code);
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (res.isSuccess) {
      HapticFeedback.lightImpact();
      if (res.isNewUser) {
        // Tài khoản mới -> Mở màn hình tạo Profile & chọn avatar DiceBear
        context.push(
          '/profile-setup',
          extra: {
            'identifier': widget.identifier,
          },
        );
      } else {
        // Tài khoản cũ -> Vào thẳng Feed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xác thực thành công! Chào mừng bạn quay trở lại.'),
            backgroundColor: AppColors.surfaceDark,
          ),
        );
        context.go('/');
      }
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
      body: ViewfinderBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 12, 24, mediaQuery.padding.bottom + 20),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề
              const Text(
                'Nhập mã xác thực',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13, height: 1.45),
                  children: [
                    const TextSpan(text: 'Mã OTP gồm 6 chữ số đã được gửi tới '),
                    TextSpan(
                      text: widget.identifier,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Banner Demo OTP (Rất thuận tiện khi test - Không viền)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(SolarIconsBold.infoCircle, size: 16, color: AppColors.primaryYellow),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Thử nghiệm: Mã OTP mẫu là ${widget.demoOtp}',
                        style: const TextStyle(
                          color: AppColors.primaryYellow,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _fillDemoOtp,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Điền ngay',
                          style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 6 Ô NHẬP MÃ OTP TỰ ĐỘNG FOCUS (BỎ BORDER MẶC ĐỊNH)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (event) {
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.backspace &&
                            _controllers[index].text.isEmpty &&
                            index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.surfaceDark,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.primaryYellow, width: 1.5),
                          ),
                        ),
                        onChanged: (val) {
                          if (val.isNotEmpty) {
                            if (index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else {
                              _focusNodes[index].unfocus();
                              // Tự động kích hoạt khi nhập đủ 6 số
                              _verifyOtp();
                            }
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 28),

              // Countdown đếm ngược 60s & Gửi lại mã
              Center(
                child: _countdown > 0
                    ? Text(
                        'Gửi lại mã OTP sau ${_countdown.toString().padLeft(2, '0')}s',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      )
                    : TextButton.icon(
                        onPressed: _isLoading ? null : _resendOtp,
                        icon: const Icon(SolarIconsOutline.restart, size: 14, color: AppColors.primaryOlive),
                        label: const Text(
                          'Gửi lại mã OTP mới',
                          style: TextStyle(
                            color: AppColors.primaryOlive,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 36),

              // Nút xác thực
              AppButton.primary(
                text: _isLoading ? 'Đang xác thực...' : 'Xác nhận & Tiếp tục',
                isFullWidth: true,
                height: 50,
                borderRadius: BorderRadius.circular(16),
                onPressed: _isLoading ? () {} : _verifyOtp,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
