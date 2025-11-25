// Initial splash screen with app initialization.
// Relates to: main.dart, login_page.dart, home_page.dart

import 'package:apma_app/core/constants/app_colors.dart';
import 'package:apma_app/core/constants/app_constant.dart';
import 'package:apma_app/core/di/injection_container.dart';
import 'package:apma_app/core/services/local_storage_service.dart';
import 'package:apma_app/core/widgets/apmaco_logo.dart';
import 'package:apma_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:apma_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:apma_app/screens/auth/login_page.dart';
import 'package:apma_app/screens/home/home_page.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Start animation
    _animationController.forward();

    // Navigate to login after delay
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(AppConstants.splashDuration);

    if (mounted && !_isNavigating) {
      _isNavigating = true;

      if (mounted) {
        // بررسی اطلاعات کاربر ذخیره‌شده
        final localStorageService = sl<LocalStorageService>();
        final isLoggedIn = localStorageService.isLoggedIn;
        final savedUsername = localStorageService.savedUsername;
        final savedPassword = localStorageService.savedPassword;

        Widget nextScreen;

        if (isLoggedIn && savedUsername != null) {
          // اگر کاربر قبلا وارد شده، برو به home
          nextScreen = HomePage(
            username: savedUsername,
            name: localStorageService.savedName ?? savedUsername,
            role: localStorageService.savedRole,
          );
        } else if (savedUsername != null && savedPassword != null) {
          // اگر رمز عبور ذخیره‌شده است، خودکار ورود
          Future.delayed(const Duration(milliseconds: 500), () {
            final authBloc = sl<AuthBloc>();
            authBloc.add(
              AutoLoginEvent(username: savedUsername, password: savedPassword),
            );
          });
          nextScreen = const LoginPage();
        } else {
          // برو به صفحه login
          nextScreen = const LoginPage();
        }

        // Start fade out animation and navigate simultaneously
        _animationController.reverse();

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              // Fade in animation for next page
              var fadeInAnimation = Tween(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
                ),
              );

              // Scale transition for smooth entry
              var scaleAnimation = Tween(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

              return FadeTransition(
                opacity: fadeInAnimation,
                child: ScaleTransition(scale: scaleAnimation, child: child),
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ApmacoLogo(width: 250, height: 100),
                    const SizedBox(height: 50),
                    // Loading indicator
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
