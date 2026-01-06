// صفحه ورود با فرم اعتبارسنجی و احراز هویت
// مرتبط با: auth_bloc.dart, input_validator.dart, home_page.dart

import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:apma_app/core/constants/app_constant.dart'; // ثابت‌های برنامه
import 'package:apma_app/core/constants/app_string.dart'; // رشته‌های برنامه
import 'package:apma_app/core/di/injection_container.dart'; // تزریق وابستگی
import 'package:apma_app/core/mixins/permission_mixin.dart'; // میکسین دسترسی‌ها
import 'package:apma_app/core/services/local_storage_service.dart'; // سرویس ذخیره‌سازی
import 'package:apma_app/core/widgets/apmaco_logo.dart'; // ویجت لوگو
import 'package:apma_app/features/authentication/presentation/bloc/auth_bloc.dart'; // بلاک احراز هویت
import 'package:apma_app/features/authentication/presentation/bloc/auth_event.dart'; // رویدادهای بلاک
import 'package:apma_app/features/authentication/presentation/bloc/auth_state.dart'; // وضعیت‌های بلاک
import 'package:apma_app/features/home/home_page.dart'; // صفحه خانه
import 'package:flutter/material.dart'; // ویجت‌های متریال
import 'package:flutter_bloc/flutter_bloc.dart'; // کتابخانه BLoC
import 'dart:developer' as developer; // ابزار لاگ‌گیری

// کلاس LoginPage - صفحه ورود (wrapper)
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  // متد build - ساخت ویجت صفحه ورود
  Widget build(BuildContext context) {
    developer.log('🔵 LoginPage build شروع شد');
    return const LoginView(); // برگرداندن ویجت اصلی صفحه ورود
  }
}

// کلاس LoginView - ویجت اصلی صفحه ورود
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

// کلاس _LoginViewState - state صفحه ورود با میکسین دسترسی‌ها
class _LoginViewState extends State<LoginView> with PermissionMixin {
  final _formKey = GlobalKey<FormState>(); // کلید فرم برای اعتبارسنجی
  final _usernameController = TextEditingController(); // کنترلر نام کاربری
  final _passwordController = TextEditingController(); // کنترلر رمز عبور
  bool _isPasswordVisible = false; // وضعیت نمایش/مخفی رمز عبور

  @override
  // متد initState - مقداردهی اولیه و بارگذاری رمز ذخیره شده
  void initState() {
    super.initState();
    _loadSavedPassword(); // بارگذاری رمز عبور ذخیره شده
  }

  // متد _loadSavedPassword - بارگذاری نام کاربری و رمز عبور ذخیره شده
  void _loadSavedPassword() {
    final localStorageService = sl<LocalStorageService>();
    final savedUsername =
        localStorageService.savedUsername; // نام کاربری ذخیره شده
    final savedPassword =
        localStorageService.savedPassword; // رمز عبور ذخیره شده

    // پر کردن فیلدها اگر مقدار ذخیره شده موجود باشد
    if (savedUsername != null) {
      _usernameController.text = savedUsername.trim();
    }
    if (savedPassword != null) {
      _passwordController.text = savedPassword.trim();
    }
  }

  @override
  // متد dispose - آزادسازی کنترلرها
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // متد _handleLogin - مدیریت فشردن دکمه ورود
  void _handleLogin() {
    developer.log('👆 Login دکمه زده شد');

    // اعتبارسنجی فرم
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      developer.log(
        '📝 ورود: username=$username, password length=${password.length}',
      );

      // ارسال رویداد ورود به بلاک
      context.read<AuthBloc>().add(
        LoginEvent(username: username, password: password),
      );
    } else {
      developer.log('⚠️ Form validation ناموفق');
    }
  }

  // متد _navigateToHome - ناوبری به صفحه خانه
  void _navigateToHome(String username, String name, String? role) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (context) => HomePage(username: username, name: name, role: role),
      ),
    );
  }

  @override
  // متد build - ساخت رابط کاربری صفحه ورود
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // رنگ پس‌زمینه
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80), // فاصله بالا

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                // BlocConsumer برای گوش دادن و ساخت UI بر اساس وضعیت
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    // گوش دادن به تغییرات وضعیت
                    developer.log(
                      '🔔 AuthState تغییر کرد: ${state.runtimeType}',
                    );

                    if (state is AuthAuthenticated) {
                      // ورود موفق
                      developer.log(
                        ' احراز هویت موفق: ${state.user.username}',
                      );

                      // ذخیره رمز عبور اگر نیاز باشد
                      if (state.showSavePasswordDialog) {
                        final localStorageService = sl<LocalStorageService>();
                        localStorageService.savePassword(
                          _passwordController.text,
                          _usernameController.text,
                        );
                        developer.log('💾 رمز عبور خودکار ذخیره شد');
                      }

                      // رفتن به صفحه خانه
                      _navigateToHome(
                        state.user.username,
                        state.user.name ?? "",
                        state.user.role,
                      );
                    } else if (state is AuthError) {
                      // نمایش خطا
                      developer.log(' خطا: ${state.message}');

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.error,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading =
                        state is AuthLoading; // وضعیت در حال بارگذاری

                    return Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const ApmacoLogo(width: 200, height: 80), // لوگو

                          const SizedBox(height: 60),

                          // فیلد نام کاربری
                          TextFormField(
                            controller: _usernameController,
                            textAlign: TextAlign.right, // راست‌چین برای فارسی
                            enabled: !isLoading, // غیرفعال در حین بارگذاری
                            decoration: const InputDecoration(
                              hintText: AppStrings.username, // متن راهنما
                            ),
                            validator: (value) {
                              // اعتبارسنجی نام کاربری
                              if (value == null || value.trim().isEmpty) {
                                return AppStrings.emptyUsername;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // فیلد رمز عبور
                          TextFormField(
                            controller: _passwordController,
                            textAlign: TextAlign.right,
                            enabled: !isLoading,
                            obscureText: !_isPasswordVisible, // مخفی کردن رمز
                            decoration: InputDecoration(
                              hintText: AppStrings.password,
                              // آیکون نمایش/مخفی رمز
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.textHint,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              // اعتبارسنجی رمز عبور
                              if (value == null || value.isEmpty) {
                                return AppStrings.emptyPassword;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 30),

                          // دکمه ورود
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  isLoading
                                      ? null
                                      : _handleLogin, // غیرفعال در حین بارگذاری
                              child:
                                  isLoading
                                      ? const SizedBox(
                                        // نمایش لودینگ
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text(
                                        AppStrings.login,
                                      ), // متن دکمه
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // فوتر با نسخه و کپی‌رایت
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'نسخه 1.0.0', // شماره نسخه
                    style: TextStyle(
                      color: AppColors.primaryOrange,
                      fontSize: 12,
                      fontFamily: 'Vazir',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2024 APMA', // کپی‌رایت
                    style: TextStyle(
                      color: AppColors.primaryOrange,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
