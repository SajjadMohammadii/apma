import 'package:apma_app/core/constants/app_colors.dart';
import 'package:apma_app/core/constants/app_constant.dart';
import 'package:apma_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:apma_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:apma_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:apma_app/screens/auth/login_page.dart';
import 'package:apma_app/screens/transaction/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String? name;

  const HomePage({super.key, required this.username, this.name});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: const Text('پنل کاربری'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.primaryGreen,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.message_outlined, size: 24),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('صفحه پیام‌ها')));
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 24),
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('اعلان‌ها')));
              },
            ),
            Builder(
              builder:
                  (context) => IconButton(
                    icon: const Icon(Icons.menu, size: 24),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
            ),
          ],
        ),
        endDrawer: _buildDrawer(context),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildUserCard(context), const SizedBox(height: 20)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryPurple, Color(0xFF8882B2)],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: Text(
                        widget.name ?? widget.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '@${widget.username}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItemWithImage(
                context,
                imagePath: 'assets/images/home.png',
                title: 'صفحه اصلی',
                onTap: () => Navigator.pop(context),
              ),
              _buildDrawerItemWithImage(
                context,
                imagePath: 'assets/images/information.png',
                title: 'اطلاعات پایه',
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              _buildDrawerItemWithImage(
                context,
                imagePath: 'assets/images/transaction.png',
                title: 'عملیات',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionPage(),
                    ),
                  );
                },
              ),
              _buildDrawerItemWithImage(
                context,
                imagePath: 'assets/images/reports.png',
                title: 'گزارش ها',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildDrawerItemWithImage(
                context,
                imagePath: 'assets/images/setting.png',
                title: 'تنظیمات',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              _buildDrawerItemWithImage(
                context,
                imagePath: 'assets/images/logout.png',
                title: 'خروج',
                color: AppColors.error,
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItemWithImage(
    BuildContext context, {
    required String imagePath,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Image.asset(
        imagePath,
        width: 24,
        height: 24,
        color: color ?? AppColors.textPrimary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? AppColors.textPrimary,
          fontFamily: 'Vazir',
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildUserCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryPurple, Color(0xFF8882B2)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Flexible(
            flex: 0,
            child: Text(
              'خوش آمدید!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Vazir',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Color(0xFF0095F6),
                        size: 10,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        widget.name ?? widget.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Vazir',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'نقش سازمانی',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'Vazir',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.person,
                size: 28,
                color: AppColors.primaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text(
              'خروج از حساب',
              style: TextStyle(fontFamily: 'Vazir'),
            ),
            content: const Text(
              'آیا مطمئن هستید که می‌خواهید از حساب کاربری خود خارج شوید؟',
              style: TextStyle(fontFamily: 'Vazir'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('انصراف'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<AuthBloc>().add(const LogoutEvent());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('خروج'),
              ),
            ],
          ),
    );
  }
}
