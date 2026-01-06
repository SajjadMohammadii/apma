// صفحه امضا - دریافت امضای دیجیتال تحویل‌گیرنده
// مرتبط با: delivery_nearby_page.dart, delivery_parcels.dart

import 'dart:io'; // کتابخانه کار با فایل
import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:flutter/foundation.dart'; // ابزارهای پایه
import 'package:flutter/material.dart'; // ویجت‌های متریال
import 'package:flutter/services.dart'; // سرویس‌های سیستم

// کلاس SignaturePage - صفحه امضای دیجیتال
class SignaturePage extends StatefulWidget {
  final String customerName; // نام مشتری
  final String location; // مکان تحویل

  // سازنده
  const SignaturePage({
    super.key,
    required this.customerName,
    required this.location,
  });

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

// کلاس _SignaturePageState - state صفحه امضا
class _SignaturePageState extends State<SignaturePage> {
  final List<Offset?> _signaturePoints = []; // نقاط امضا (null = قطع خط)

  // بررسی پلتفرم موبایل
  bool get _isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  // متد initState - تنظیم جهت صفحه به افقی
  void initState() {
    super.initState();
    if (_isMobile) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  // متد build - ساخت رابط کاربری صفحه امضا
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // راست به چپ
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context), // برگشت
          ),
          actions: [
            // دکمه تایید و ذخیره
            TextButton.icon(
              onPressed: _saveSignature,
              icon: const Icon(Icons.check, size: 18, color: Colors.white),
              label: const Text(
                'تایید و ذخیره',
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // باکس امضا
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 60,
                    right: 60,
                    bottom: 10,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // هدر با آیکون و دکمه پاک کردن
                        Row(
                          children: [
                            Icon(
                              Icons.draw,
                              color: AppColors.primaryPurple,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'لطفاً در کادر زیر امضا کنید', // راهنما
                              style: TextStyle(
                                fontFamily: 'Vazir',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            // دکمه پاک کردن امضا
                            TextButton.icon(
                              onPressed:
                                  () =>
                                      setState(() => _signaturePoints.clear()),
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text(
                                'پاک کردن',
                                style: TextStyle(
                                  fontFamily: 'Vazir',
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // کادر امضا - بوم نقاشی
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 50),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  border: Border.all(
                                    color: Colors.grey[400]!,
                                    width: 2,
                                  ),
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      // شروع کشیدن - افزودن نقطه
                                      onPanStart:
                                          (d) => setState(
                                            () => _signaturePoints.add(
                                              d.localPosition,
                                            ),
                                          ),
                                      // ادامه کشیدن - افزودن نقاط
                                      onPanUpdate:
                                          (d) => setState(
                                            () => _signaturePoints.add(
                                              d.localPosition,
                                            ),
                                          ),
                                      // پایان کشیدن - قطع خط با null
                                      onPanEnd:
                                          (d) => setState(
                                            () => _signaturePoints.add(null),
                                          ),
                                      // رسم امضا با CustomPaint
                                      child: CustomPaint(
                                        size: Size(
                                          constraints.maxWidth,
                                          constraints.maxHeight,
                                        ),
                                        painter: SignaturePainter(
                                          _signaturePoints,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // متد _saveSignature - ذخیره امضا و برگشت
  void _saveSignature() {
    // بررسی خالی بودن امضا
    if (_signaturePoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'لطفاً امضا کنید', // پیام خطا
            style: TextStyle(fontFamily: 'Vazir'),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    Navigator.pop(context, true); // برگشت با نتیجه موفق
  }
}

// کلاس SignaturePainter - رسم‌کننده امضا روی بوم
class SignaturePainter extends CustomPainter {
  final List<Offset?> points; // لیست نقاط امضا
  SignaturePainter(this.points);

  @override
  // متد paint - رسم خطوط امضا
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color =
              Colors
                  .black // رنگ مشکی
          ..strokeCap =
              StrokeCap
                  .round // سر گرد
          ..strokeWidth = 2.5; // ضخامت خط

    // رسم خطوط بین نقاط متوالی
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  // همیشه دوباره رسم کن
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}
