
import 'dart:io';

import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:apma_app/core/services/permission_service.dart'; // سرویس دسترسی‌ها
import 'package:apma_app/core/widgets/apmaco_logo.dart'; // ویجت لوگو
import 'package:flutter/material.dart'; // ویجت‌های متریال
import 'package:permission_handler/permission_handler.dart'; // کتابخانه مدیریت دسترسی
import 'dart:developer' as developer; // ابزار لاگ‌گیری

// کلاس PermissionDialog - دیالوگ درخواست دسترسی‌ها
class PermissionDialog extends StatefulWidget {
  final VoidCallback onPermissionsGranted; // callback هنگام اعطای دسترسی‌ها

  // سازنده با callback اجباری
  const PermissionDialog({required this.onPermissionsGranted, super.key});

  @override
  State<PermissionDialog> createState() => _PermissionDialogState();
}

// کلاس _PermissionDialogState - state دیالوگ با انیمیشن
class _PermissionDialogState extends State<PermissionDialog>
    with SingleTickerProviderStateMixin {
  bool _isRequesting = false; // متغیر وضعیت در حال درخواست
  late AnimationController _animationController; // کنترلر انیمیشن
  late Animation<double> _scaleAnimation; // انیمیشن مقیاس

  @override
  // متد initState - مقداردهی اولیه انیمیشن
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // مدت انیمیشن ۳۰۰ میلی‌ثانیه
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack, // منحنی انیمیشن
    );
    _animationController.forward(); // شروع انیمیشن
  }

  @override
  // متد dispose - آزادسازی کنترلر انیمیشن
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // متد _requestPermissions - درخواست دسترسی‌ها
  Future<void> _requestPermissions() async {
    late final deniedList;
    late final allGranted;
    final int sdkInt = int.tryParse(Platform.version.split(' ').first) ?? 0;
    if (sdkInt >= 33) {
      allGranted =
      await PermissionService.requestAllPermissionsUp33(); // درخواست دسترسی‌ها
      // گرفتن لیست دسترسی‌های رد شده
      deniedList = await PermissionService.getDeniedPermissionsUp33();
    }else{
      allGranted =
      await PermissionService.requestAllPermissionsUnder33(); // درخواست دسترسی‌ها
      // گرفتن لیست دسترسی‌های رد شده
      deniedList = await PermissionService.getDeniedPermissionsUnder33();
    }
    setState(() => _isRequesting = true); // شروع درخواست

    setState(() => _isRequesting = false); // پایان درخواست

    if (allGranted) {
      // اگر همه دسترسی‌ها داده شد
      developer.log(' تمام دسترسی‌ها موافقت کردند');
      widget.onPermissionsGranted(); // فراخوانی callback
      if (mounted) Navigator.pop(context); // بستن دیالوگ
    } else {
      // اگر برخی دسترسی‌ها رد شدند - نره جلو!
      developer.log(' برخی دسترسی‌ها رد شدند - باید همه داده بشه');

      final deniedText = deniedList.join('، ');

      if (mounted) {
        // نمایش پیام خطا با لیست دسترسی‌های رد شده
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لطفاً همه دسترسی‌ها را اعطا کنید.\nدسترسی‌های داده نشده: $deniedText',
              style: const TextStyle(fontFamily: 'Vazir', fontSize: 12),
            ),
            backgroundColor: AppColors.error, // رنگ قرمز
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'تنظیمات',
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    }
  }

  @override
  // متد build - ساخت رابط کاربری دیالوگ
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // جلوگیری از بستن با دکمه برگشت
      child: ScaleTransition(
        scale: _scaleAnimation, // اعمال انیمیشن مقیاس
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // گوشه‌های گرد
          ),
          elevation: 16, // سایه
          backgroundColor: Colors.white,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380), // حداکثر عرض
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // هدر با گرادیانت
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryOrange, // رنگ نارنجی اصلی
                          AppColors.primaryOrange.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // لوگو
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const ApmacoLogo(
                            width: 120,
                            height: 40,
                          ), // ویجت لوگو
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'دسترسی‌های مورد نیاز', // عنوان
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Vazir',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // محتوا - لیست دسترسی‌ها
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'برای استفاده بهتر از برنامه، لطفاً دسترسی‌های زیر را اعطا کنید:', // توضیحات
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontFamily: 'Vazir',
                          ),
                        ),

                        const SizedBox(height: 20),

                        // لیست دسترسی‌ها
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              _permissionTile(
                                Icons.camera_alt_rounded,
                                'دوربین',
                                'برای اسکن بارکد و تصویربرداری',
                                Colors.blue,
                              ),
                              _divider(), // خط جداکننده
                              _permissionTile(
                                Icons.mic_rounded,
                                'میکروفن',
                                'برای ضبط صدا و تماس',
                                Colors.red,
                              ),
                              _divider(),
                              _permissionTile(
                                Icons.location_on_rounded,
                                'موقعیت مکانی',
                                'برای ردیابی و نقشه',
                                Colors.green,
                              ),
                              _divider(),
                              _permissionTile(
                                Icons.contacts_rounded,
                                'مخاطبین',
                                'برای دسترسی به لیست مخاطبین',
                                Colors.purple,
                              ),
                              _divider(),
                              _permissionTile(
                                Icons.photo_library_rounded,
                                'گالری',
                                'برای انتخاب و ذخیره تصاویر',
                                Colors.orange,
                              ),
                              _divider(),
                              _permissionTile(
                                Icons.folder_rounded,
                                'فایل‌ها',
                                'برای ذخیره و خواندن فایل‌ها',
                                Colors.teal,
                              ),
                              _divider(),
                              _permissionTile(
                                Icons.phone_rounded,
                                'تماس',
                                'برای برقراری تماس تلفنی',
                                Colors.indigo,
                              ),
                              _divider(),
                              _permissionTile(
                                Icons.sms_rounded,
                                'پیامک',
                                'برای ارسال و دریافت پیامک',
                                Colors.cyan,
                              ),
                              _divider(),
                              _permissionTile(
                                Icons.calendar_month_rounded,
                                'تقویم',
                                'برای مدیریت رویدادها',
                                Colors.pink,
                              ),
                              _divider(),
                              _permissionTile(
                                Icons.notifications_rounded,
                                'اعلان‌ها',
                                'برای دریافت اطلاع‌رسانی‌ها',
                                Colors.amber,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // دکمه اعطای دسترسی
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                            _isRequesting
                                ? null
                                : _requestPermissions, // غیرفعال در حین درخواست
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: AppColors.primaryOrange.withOpacity(
                                0.4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child:
                            _isRequesting
                                ? const SizedBox(
                              // نمایش لودینگ در حین درخواست
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                                : const Row(
                              // نمایش متن و آیکون دکمه
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'اعطای دسترسی‌ها',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Vazir',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // دکمه تنظیمات - برای باز کردن تنظیمات دستگاه
                        TextButton.icon(
                          onPressed:
                              () => openAppSettings(), // باز کردن تنظیمات
                          icon: Icon(
                            Icons.settings_rounded,
                            color: AppColors.primaryGray,
                            size: 20,
                          ),
                          label: Text(
                            'باز کردن تنظیمات دستگاه',
                            style: TextStyle(
                              color: AppColors.primaryGray,
                              fontSize: 13,
                              fontFamily: 'Vazir',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // متد _permissionTile - ساخت آیتم لیست دسترسی
  // پارامتر icon: آیکون دسترسی
  // پارامتر title: عنوان دسترسی
  // پارامتر subtitle: توضیحات دسترسی
  // پارامتر color: رنگ آیکون
  Widget _permissionTile(
      IconData icon,
      String title,
      String subtitle,
      Color color,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1), // پس‌زمینه با شفافیت
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, // عنوان
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'Vazir',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle, // توضیحات
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                    fontFamily: 'Vazir',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // متد _divider - ساخت خط جداکننده بین آیتم‌ها
  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 16, // فاصله از چپ
      endIndent: 16, // فاصله از راست
    );
  }
}
