import 'package:flutter/material.dart';

class StatItem extends StatelessWidget {
  final String day;
  final String date;
  final String hours;
  final String status;

  const StatItem({
    super.key,
    required this.day,
    required this.date,
    required this.hours,
    required this.status,
  });

  Color get statusColor {
    switch (status) {
      case 'کامل':
        return Colors.green;
      case 'کسری':
        return Colors.red;
      case 'اضافه‌کار':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  day,
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  date,
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontFamily: 'Vazir',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: hours == '-'
                      ? 0
                      : (double.tryParse(hours.split(':')[0]) ?? 0) / 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 50,
                child: Text(
                  hours,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
