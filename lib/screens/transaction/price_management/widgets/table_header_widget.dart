// ویجت هدر جدول - نمایش عناوین ستون‌ها با قابلیت مرتب‌سازی
// مرتبط با: price_management_page.dart, table_row_widget.dart

import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:flutter/material.dart'; // ویجت‌های متریال

// کلاس TableHeaderWidget - ویجت هدر جدول اصلی
class TableHeaderWidget extends StatelessWidget {
  final int? sortColumnIndex; // ستون مرتب‌سازی فعلی
  final bool isAscending; // صعودی یا نزولی
  final Function(int) onSort; // callback مرتب‌سازی

  // سازنده
  const TableHeaderWidget({
    super.key,
    required this.sortColumnIndex,
    required this.isAscending,
    required this.onSort,
  });

  @override
  // متد build - ساخت رابط کاربری هدر
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryGreen, // رنگ پس‌زمینه سبز
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                // ستون‌های هدر
                _buildSortableHeader(
                  'ردیف',
                  flex: 1,
                  index: -1,
                ), // ردیف سورت نمیخوره
                _buildDivider(),
                _buildSortableHeader('تاریخ پیش فاکتور', flex: 2, index: 0),
                _buildDivider(),
                _buildSortableHeader('شماره پیش فاکتور', flex: 2, index: 1),
                _buildDivider(),
                _buildSortableHeader('مشتری', flex: 3, index: 2),
                _buildDivider(),
                _buildSortableHeader('صادرکننده', flex: 2, index: 3),
              ],
            ),
          ),
          // خط جداکننده پایین
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.3),
            margin: const EdgeInsets.only(top: 8),
          ),
        ],
      ),
    );
  }

  // متد _buildSortableHeader - ساخت هدر با قابلیت مرتب‌سازی
  Widget _buildSortableHeader(
    String text, { // متن هدر
    required int flex, // نسبت عرض
    required int index, // ایندکس ستون (-1 = غیرقابل مرتب‌سازی)
  }) {
    final isActive = sortColumnIndex == index; // آیا این ستون فعال است
    final isSortable = index >= 0; // ردیف سورت نمیخوره

    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: isSortable ? () => onSort(index) : null, // کلیک برای مرتب‌سازی
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // آیکون مرتب‌سازی
            if (isSortable) ...[
              const SizedBox(width: 4),
              Icon(
                isActive
                    ? (isAscending ? Icons.arrow_upward : Icons.arrow_downward)
                    : Icons.unfold_more,
                color: Colors.white,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // متد _buildDivider - ساخت خط جداکننده عمودی
  Widget _buildDivider() {
    return Container(width: 1, color: Colors.white.withOpacity(0.3));
  }
}
