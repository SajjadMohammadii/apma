import 'package:apma_app/core/constants/app_colors.dart';
import 'package:apma_app/core/constants/app_constant.dart';
import 'package:flutter/material.dart';

class SavePasswordDialog extends StatefulWidget {
  final VoidCallback onSave;
  final VoidCallback onDismiss;

  const SavePasswordDialog({
    super.key,
    required this.onSave,
    required this.onDismiss,
  });

  @override
  State<SavePasswordDialog> createState() => _SavePasswordDialogState();
}

class _SavePasswordDialogState extends State<SavePasswordDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // آیکون
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(Icons.lock, color: AppColors.primaryOrange, size: 32),
            ),

            const SizedBox(height: 16),

            // عنوان
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
                color: AppColors.textSecondary,
                fontFamily: 'Vazir',
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // دکمه‌ها
            Row(
              children: [
                // دکمه نه
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onDismiss();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: AppColors.primaryOrange,
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

                // دکمه بله
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppColors.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'بله، ذخیره کن',
                      style: TextStyle(
                        color: Colors.white,
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
