// ویجت دکمه ذخیره - دکمه ذخیره تغییرات با تغییر رنگ
// مرتبط با: price_management_page.dart, price_management_bloc.dart

import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:flutter/material.dart'; // ویجت‌های متریال

// کلاس SaveButtonWidget - ویجت دکمه ذخیره
class SaveButtonWidget extends StatelessWidget {
  final bool hasChanges; // آیا تغییرات ذخیره نشده وجود دارد
  final VoidCallback onTap; // callback کلیک

  // سازنده
  const SaveButtonWidget({
    super.key,
    required this.hasChanges,
    required this.onTap,
  });

  @override
  // متد build - ساخت رابط کاربری دکمه ذخیره
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        // رنگ بنفش اگر تغییرات دارد، سفید اگر ندارد
        color: hasChanges ? AppColors.primaryPurple : Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap, // کلیک برای ذخیره
          borderRadius: BorderRadius.circular(6),
          child: Center(
            child: Text(
              'ذخیره', // متن دکمه
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                // رنگ متن سفید اگر تغییرات دارد، مشکی اگر ندارد
                color: hasChanges ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
