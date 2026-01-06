import 'package:flutter/material.dart';

class RecordItem extends StatelessWidget {
  final String type;
  final String time;
  final String status;

  const RecordItem({
    super.key,
    required this.type,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isEntry = type == 'entry';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isEntry ? Colors.green : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (isEntry ? Colors.green : Colors.orange).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isEntry ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEntry ? Icons.login : Icons.logout,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEntry ? 'ورود' : 'خروج',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Vazir',
                  ),
                ),
                Text(
                  'ساعت $time',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontFamily: 'Vazir',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'تایید شده'
                  ? Colors.green.withOpacity(0.2)
                  : Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: status == 'تایید شده'
                    ? Colors.green[700]
                    : Colors.amber[700],
                fontSize: 11,
                fontFamily: 'Vazir',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
