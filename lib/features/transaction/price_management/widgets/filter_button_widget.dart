// ویجت دکمه فیلتر - دکمه باز کردن دیالوگ فیلتر پیشرفته
// مرتبط با: price_management_page.dart, advanced_filter_dialog.dart

import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:flutter/material.dart'; // ویجت‌های متریال

// کلاس FilterButtonWidget - ویجت دکمه فیلتر
class FilterButtonWidget extends StatelessWidget {
  final VoidCallback onTap; // callback کلیک

  // سازنده
  const FilterButtonWidget({super.key, required this.onTap});

  @override
  // متد build - ساخت رابط کاربری دکمه فیلتر
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // کلیک برای باز کردن دیالوگ فیلتر
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 16,
              color: AppColors.primaryGreen,
            ), // آیکون جستجو
            SizedBox(width: 4),
            Text(
              'فیلتر', // متن دکمه
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 10,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
