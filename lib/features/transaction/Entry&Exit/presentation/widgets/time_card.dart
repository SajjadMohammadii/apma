import 'package:flutter/material.dart';
import 'package:apma_app/core/constants/app_colors.dart';

class TimeCard extends StatelessWidget {
  final String currentDate;
  final String currentTime;
  final String workDuration;
  final bool isCheckedIn;

  const TimeCard({
    super.key,
    required this.currentDate,
    required this.currentTime,
    required this.workDuration,
    required this.isCheckedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withOpacity(0.7)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            currentDate,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'Vazir',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentTime,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'Vazir',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'زمان کاری امروز: $workDuration',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Vazir',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCheckedIn ? Icons.login : Icons.logout,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  isCheckedIn ? 'حضور دارید' : 'در حال غیبت',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Vazir',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
