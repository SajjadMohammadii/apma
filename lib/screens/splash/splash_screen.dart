// صفحه اسپلش اولیه با مقداردهی برنامه
// مرتبط با: main.dart, login_page.dart, home_page.dart

import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:apma_app/core/constants/app_constant.dart'; // ثابت‌های برنامه
import 'package:apma_app/core/di/injection_container.dart'; // تزریق وابستگی
import 'package:apma_app/core/services/local_storage_service.dart'; // سرویس ذخیره‌سازی محلی
import 'package:apma_app/core/widgets/apmaco_logo.dart'; // ویجت لوگو
import 'package:apma_app/features/auth/presentation/bloc/auth_bloc.dart'; // بلاک احراز هویت
import 'package:apma_app/features/auth/presentation/bloc/auth_event.dart'; // رویدادهای احراز هویت
import 'package:apma_app/screens/auth/login_page.dart'; // صفحه ورود
import 'package:apma_app/screens/home/home_page.dart'; // صفحه خانه
import 'package:flutter/material.dart'; // ویجت‌های متریال

// کلاس SplashScreen - صفحه اسپلش (صفحه شروع برنامه)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// کلاس _SplashScreenState - state صفحه اسپلش با انیمیشن
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController; // کنترلر انیمیشن
  late Animation<double> _fadeAnimation; // انیمیشن محو شدن
  late Animation<double> _scaleAnimation; // انیمیشن مقیاس
  bool _isNavigating = false; // جلوگیری از ناوبری تکراری

  @override
  // متد initState - مقداردهی اولیه انیمیشن‌ها
  void initState() {
    super.initState();

    // مقداردهی اولیه انیمیشن‌ها
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDuration, // مدت انیمیشن
    );

    // انیمیشن محو شدن از ۰ تا ۱
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // انیمیشن مقیاس از ۰.۵ تا ۱
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // شروع انیمیشن
    _animationController.forward();

    // رفتن به صفحه بعدی پس از تاخیر
    _navigateToNextScreen();
  }

  // متد _navigateToNextScreen - ناوبری به صفحه بعدی بر اساس وضعیت ورود
  void _navigateToNextScreen() async {
    await Future.delayed(AppConstants.splashDuration); // تاخیر اسپلش

    if (mounted && !_isNavigating) {
      _isNavigating = true; // جلوگیری از ناوبری مجدد

      if (mounted) {
        // بررسی اطلاعات کاربر ذخیره‌شده
        final localStorageService = sl<LocalStorageService>();
        final isLoggedIn = localStorageService.isLoggedIn; // آیا قبلا وارد شده
        final savedUsername =
            localStorageService.savedUsername; // نام کاربری ذخیره شده
        final savedPassword =
            localStorageService.savedPassword; // رمز عبور ذخیره شده

        Widget nextScreen; // صفحه بعدی

        if (isLoggedIn && savedUsername != null) {
          // اگر کاربر قبلا وارد شده، برو به صفحه خانه
          nextScreen = HomePage(
            username: savedUsername,
            name: localStorageService.savedName ?? savedUsername,
            role: localStorageService.savedRole,
          );
        } else if (savedUsername != null && savedPassword != null) {
          // اگر رمز عبور ذخیره‌شده است، ورود خودکار انجام بده
          Future.delayed(const Duration(milliseconds: 500), () {
            final authBloc = sl<AuthBloc>();
            authBloc.add(
              AutoLoginEvent(username: savedUsername, password: savedPassword),
            );
          });
          nextScreen =
              const LoginPage(); // برو به صفحه ورود (ورود خودکار انجام می‌شود)
        } else {
          // برو به صفحه ورود
          nextScreen = const LoginPage();
        }

        // شروع انیمیشن برگشت و ناوبری همزمان
        _animationController.reverse();

        // ناوبری با انیمیشن سفارشی
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              // انیمیشن ظاهر شدن صفحه بعدی
              var fadeInAnimation = Tween(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
                ),
              );

              // انیمیشن مقیاس برای ورود نرم
              var scaleAnimation = Tween(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

              return FadeTransition(
                opacity: fadeInAnimation,
                child: ScaleTransition(scale: scaleAnimation, child: child),
              );
            },
            transitionDuration: const Duration(milliseconds: 800), // مدت انتقال
          ),
        );
      }
    }
  }

  @override
  // متد dispose - آزادسازی منابع
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  // متد build - ساخت رابط کاربری صفحه اسپلش
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // رنگ پس‌زمینه
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation, // اعمال انیمیشن محو
              child: ScaleTransition(
                scale: _scaleAnimation, // اعمال انیمیشن مقیاس
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ApmacoLogo(width: 250, height: 100), // لوگوی شرکت
                    const SizedBox(height: 50),
                    // نشانگر بارگذاری
                    SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                        backgroundColor: AppColors.primaryGreen.withOpacity(
                          0.2,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
