// ویجت ردیف جدول - نمایش یک ردیف از جدول اصلی
// مرتبط با: price_management_page.dart, table_header_widget.dart, sub_table_widget.dart

import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:flutter/material.dart'; // ویجت‌های متریال

// کلاس TableRowWidget - ویجت ردیف جدول
class TableRowWidget extends StatelessWidget {
  final Map<String, dynamic> item; // داده‌های ردیف
  final bool isExpanded; // آیا جدول فرعی باز است
  final VoidCallback onTap; // callback کلیک

  // سازنده
  const TableRowWidget({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  // متد build - ساخت رابط کاربری ردیف
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // کلیک برای باز/بسته کردن جدول فرعی
      child: Column(
        children: [
          Container(
            color: AppColors.primaryPurple, // رنگ پس‌زمینه بنفش
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // ستون ردیف با آیکون باز/بسته
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isExpanded
                              ? Icons
                                  .keyboard_arrow_up // باز
                              : Icons.keyboard_arrow_down, // بسته
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item['id']}', // شماره ردیف
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Vazir',
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildDivider(),
                  _buildCell(item['date'], flex: 2), // تاریخ
                  _buildDivider(),
                  _buildCell(item['number'], flex: 2), // شماره
                  _buildDivider(),
                  _buildCell(item['customer'], flex: 3), // مشتری
                  _buildDivider(),
                  _buildCell(item['issuer'], flex: 2), // صادرکننده
                ],
              ),
            ),
          ),
          // خط جداکننده پایین
          Container(height: 1, color: Colors.white.withOpacity(0.3)),
        ],
      ),
    );
  }

  // متد _buildCell - ساخت سلول جدول
  Widget _buildCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Vazir',
          fontSize: 12,
          color: Colors.white,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // متد _buildDivider - ساخت خط جداکننده عمودی
  Widget _buildDivider() {
    return Container(width: 1, color: Colors.white.withOpacity(0.3));
  }
}
