// دیالوگ ذخیره اعتبارنامه‌های کاربر به صورت محلی
// مرتبط با: login_page.dart, local_storage_service.dart

import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:apma_app/core/constants/app_constant.dart'; // ثابت‌های برنامه
import 'package:flutter/material.dart'; // ویجت‌های متریال

// کلاس SavePasswordDialog - دیالوگ پرسش ذخیره رمز عبور
class SavePasswordDialog extends StatefulWidget {
  final VoidCallback onSave; // callback هنگام تایید ذخیره
  final VoidCallback onDismiss; // callback هنگام رد کردن

  // سازنده با callbackهای اجباری
  const SavePasswordDialog({
    super.key,
    required this.onSave,
    required this.onDismiss,
  });

  @override
  State<SavePasswordDialog> createState() => _SavePasswordDialogState();
}

// کلاس _SavePasswordDialogState - state دیالوگ
class _SavePasswordDialogState extends State<SavePasswordDialog> {
  @override
  // متد build - ساخت رابط کاربری دیالوگ
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ), // گوشه‌های گرد
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge), // پدینگ بزرگ
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // آیکون قفل
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(
                  0.1,
                ), // پس‌زمینه نارنجی کم‌رنگ
                borderRadius: BorderRadius.circular(30), // دایره‌ای
              ),
              child: Icon(
                Icons.lock,
                color: AppColors.primaryOrange,
                size: 32,
              ), // آیکون قفل
            ),

            const SizedBox(height: 16),

            // عنوان دیالوگ
            const Text(
              'ذخیره رمز عبور',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Vazir',
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // متن توضیحی
            Text(
              'آیا می‌خواهید رمز عبور را ذخیره کنید؟\nدفعات بعدی می‌توانید بدون وارد کردن رمز وارد شوید.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary, // رنگ متن ثانویه
                fontFamily: 'Vazir',
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // ردیف دکمه‌ها
            Row(
              children: [
                // دکمه "بعدا" (رد کردن)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onDismiss(); // فراخوانی callback رد
                      Navigator.pop(context); // بستن دیالوگ
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: AppColors.primaryOrange, // حاشیه نارنجی
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'بعدا',
                      style: TextStyle(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Vazir',
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // دکمه "بله، ذخیره کن" (تایید)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave(); // فراخوانی callback ذخیره
                      Navigator.pop(context); // بستن دیالوگ
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor:
                          AppColors.primaryOrange, // پس‌زمینه نارنجی
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'بله، ذخیره کن',
                      style: TextStyle(
                        color: Colors.white, // متن سفید
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Vazir',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
