import 'package:flutter/material.dart';
import 'package:apma_app/core/constants/app_colors.dart';

class CheckInButton extends StatelessWidget {
  final bool isCheckedIn;
  final Animation<double> pulseAnimation;
  final VoidCallback onTap;

  const CheckInButton({
    super.key,
    required this.isCheckedIn,
    required this.pulseAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: pulseAnimation,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isCheckedIn
                  ? [Colors.orange, Colors.deepOrange]
                  : [AppColors.primaryGreen, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (isCheckedIn ? Colors.orange : AppColors.primaryGreen)
                    .withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCheckedIn ? Icons.logout : Icons.fingerprint,
                color: Colors.white,
                size: 50,
              ),
              const SizedBox(height: 8),
              Text(
                isCheckedIn ? 'ثبت خروج' : 'ثبت ورود',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Vazir',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
