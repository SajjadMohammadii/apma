// ویجت فیلد تاریخ - نمایش تاریخ با قابلیت کلیک برای انتخاب
// مرتبط با: price_management_page.dart, persian_date_picker_dialog.dart

import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:flutter/material.dart'; // ویجت‌های متریال

// کلاس DateFieldWidget - ویجت فیلد تاریخ
class DateFieldWidget extends StatelessWidget {
  final String text; // متن تاریخ
  final VoidCallback onTap; // callback کلیک

  // سازنده
  const DateFieldWidget({super.key, required this.text, required this.onTap});

  @override
  // متد build - ساخت رابط کاربری فیلد تاریخ
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // کلیک برای باز کردن انتخابگر تاریخ
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // آیکون تقویم
            const Icon(
              Icons.calendar_today,
              size: 12,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(width: 4),
            // متن تاریخ
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'Vazir',
                fontSize: 9,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
