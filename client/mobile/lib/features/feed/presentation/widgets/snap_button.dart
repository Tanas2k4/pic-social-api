import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SnapButton extends StatelessWidget {
  final VoidCallback onTap;

  const SnapButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Center(
          child: Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: AppColors.primaryYellow,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 30),
          ),
        ),
      ),
    );
  }
}
