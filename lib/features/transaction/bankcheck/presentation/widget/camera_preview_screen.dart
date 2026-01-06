// صفحه پیش‌نمایش دوربین - گرفتن عکس از چک
// مرتبط با: customer.dart, bank.dart

import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:flutter/material.dart'; // ویجت‌های متریال
import 'package:camera/camera.dart'; // کتابخانه دوربین

// کلاس CameraPreviewScreen - صفحه پیش‌نمایش دوربین
class CameraPreviewScreen extends StatefulWidget {
  final CameraDescription camera; // توصیف دوربین
  final Function(String) onCapture; // callback پس از گرفتن عکس

  // سازنده
  const CameraPreviewScreen({
    super.key,
    required this.camera,
    required this.onCapture,
  });

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

// کلاس _CameraPreviewScreenState - state صفحه دوربین
class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  late CameraController _controller; // کنترلر دوربین
  late Future<void> _initializeControllerFuture; // Future مقداردهی

  @override
  // متد initState - مقداردهی اولیه دوربین
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    ); // کیفیت بالا
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  // متد dispose - آزادسازی منابع دوربین
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // متد _takePicture - گرفتن عکس
  Future<void> _takePicture() async {
    await _initializeControllerFuture; // انتظار برای آماده شدن
    final image = await _controller.takePicture(); // گرفتن عکس
    if (!mounted) return;

    Navigator.pop(context); // بستن صفحه
    widget.onCapture(image.path); // ارسال مسیر عکس
  }

  @override
  // متد build - ساخت رابط کاربری دوربین
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // پس‌زمینه مشکی
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          // نمایش لودینگ تا آماده شدن دوربین
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return Stack(
            children: [
              // پیش‌نمایش دوربین
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: CameraPreview(_controller),
              ),
              // چارچوب راهنما برای قرار دادن چک
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              // متن راهنما
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'چک را در چارچوب قرار دهید', // متن راهنما
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              // دکمه گرفتن عکس
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _takePicture, // گرفتن عکس با کلیک
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.primaryGreen,
                          width: 4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // دکمه بستن صفحه
              Positioned(
                top: 40,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context), // برگشت
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
