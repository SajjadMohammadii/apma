import 'package:flutter/material.dart';
import 'package:apma_app/core/constants/app_colors.dart';
import 'stat_item.dart';

class WeeklyStatsList extends StatelessWidget {
  final List<Map<String, dynamic>> stats;
  final int totalWeeks;
  final String? firstEntryDate;

  const WeeklyStatsList({
    super.key,
    required this.stats,
    required this.totalWeeks,
    this.firstEntryDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: AppColors.primaryPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'آمار هفتگی',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Vazir',
                      ),
                    ),
                    if (totalWeeks > 0)
                      Text(
                        'تعداد هفته‌ها: $totalWeeks هفته',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Vazir',
                        ),
                      ),
                    if (firstEntryDate != null)
                      Text(
                        'از تاریخ: $firstEntryDate',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontFamily: 'Vazir',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...stats.map(
            (stat) => StatItem(
              day: stat['day'] as String,
              date: stat['date'] as String,
              hours: stat['hours'] as String,
              status: stat['status'] as String,
            ),
          ),
        ],
      ),
    );
  }
}
