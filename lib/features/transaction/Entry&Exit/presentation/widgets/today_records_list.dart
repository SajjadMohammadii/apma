import 'package:flutter/material.dart';
import 'package:apma_app/core/constants/app_colors.dart';
import 'record_item.dart';

class TodayRecordsList extends StatelessWidget {
  final List<Map<String, dynamic>> records;

  const TodayRecordsList({
    super.key,
    required this.records,
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
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.today,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'رکوردهای امروز',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Vazir',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (records.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'هنوز رکوردی ثبت نشده است',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Vazir',
                  ),
                ),
              ),
            )
          else
            ...records.map(
              (record) => RecordItem(
                type: record['type'] as String,
                time: record['time'] as String,
                status: record['status'] as String,
              ),
            ),
        ],
      ),
    );
  }
}
