import 'package:apma_app/core/constants/app_colors.dart';
import 'package:apma_app/core/constants/app_constant.dart';
import 'package:apma_app/core/constants/app_string.dart';
import 'package:apma_app/core/widgets/apmaco_logo.dart';
import 'package:apma_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:apma_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:apma_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:apma_app/screens/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    developer.log('🔵 LoginPage build شروع شد');
    return const LoginView();
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    developer.log('👆 Login دکمه فشار خورد');

    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      developer.log(
        '📝 ورود: username=$username, password length=${password.length}',
      );

      context.read<AuthBloc>().add(
        LoginEvent(username: username, password: password),
      );
    } else {
      developer.log('⚠️ Form validation ناموفق');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // فاصله از بالا برای بالاتر آوردن فرم
            const SizedBox(height: 80),

            // فرم لاگین
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    developer.log(
                      '🔔 AuthState تغییر کرد: ${state.runtimeType}',
                    );

                    if (state is AuthAuthenticated) {
                      developer.log(
                        '✅ احراز هویت موفق: ${state.user.username}',
                      );

                      // Navigate to Home
                      Future.delayed(const Duration(milliseconds: 100), () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder:
                                (context) => HomePage(
                                  username: state.user.username,
                                  name: state.user.name,
                                ),
                          ),
                        );
                      });
                    } else if (state is AuthError) {
                      developer.log('❌ خطا: ${state.message}');

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
                    final isLoading = state is AuthLoading;

                    return Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Logo
                          const ApmacoLogo(width: 200, height: 80),

                          const SizedBox(height: 60),

                          // Username Field
                          TextFormField(
                            controller: _usernameController,
                            textAlign: TextAlign.right,
                            enabled: !isLoading,
                            decoration: const InputDecoration(
                              hintText: AppStrings.username,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppStrings.emptyUsername;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            textAlign: TextAlign.right,
                            enabled: !isLoading,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: AppStrings.password,
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
                              if (value == null || value.isEmpty) {
                                return AppStrings.emptyPassword;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 30),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleLogin,
                              child:
                                  isLoading
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text(AppStrings.login),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Version Info در پایین
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'نسخه 1.0.0',
                    style: TextStyle(
                      color: AppColors.primaryOrange,
                      fontSize: 12,
                      fontFamily: 'Vazir',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2024 APMA',
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
