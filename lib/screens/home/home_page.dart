import 'package:apma_app/core/constants/app_colors.dart';
import 'package:apma_app/core/constants/app_constant.dart';
import 'package:apma_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:apma_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:apma_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:apma_app/screens/%20notifications/notification_page.dart';
import 'package:apma_app/screens/auth/login_page.dart';

import 'package:apma_app/screens/transaction/transaction.dart';
import 'package:apma_app/screens/messages/messages_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String? name;
  final String? role;

  const HomePage({super.key, required this.username, this.name, this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MessagesPage()),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 24),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsPage(),
                  ),
                );
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
              children: [
                _buildUserCard(context),
                const SizedBox(height: 20),
                _buildTabBar(),
                const SizedBox(height: 16),
                _buildTabContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryPurple, Color(0xFF8882B2)],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildTabItem(title: 'اطلاعیه ها', index: 0),
            _buildTabItem(title: 'زمان های کاری', index: 1),
            _buildTabItem(title: 'فعالیت ها', index: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({required String title, required int index}) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border:
                isSelected
                    ? Border(
                      bottom: BorderSide(
                        color: AppColors.inputBackground,
                        width: 3,
                      ),
                    )
                    : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color:
                  isSelected
                      ? AppColors.primaryOrange
                      : AppColors.inputBackground,
              fontFamily: 'Vazir',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildNotificationsContent();
      case 1:
        return _buildWorkHoursContent();
      case 2:
        return _buildActivitiesContent();
      default:
        return _buildNotificationsContent();
    }
  }

  Widget _buildNotificationsContent() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'اطلاعیه های جدید',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: 'Vazir',
              ),
            ),
            const SizedBox(height: 12),
            _buildNotificationItem(
              title: 'بروزرسانی سیستم',
              subtitle: 'سیستم در تاریخ ۱۴۰۳/۰۹/۰۵ بروزرسانی خواهد شد',
              time: '۲ ساعت پیش',
              isNew: true,
            ),
            _buildNotificationItem(
              title: 'جلسه هفتگی',
              subtitle: 'جلسه بررسی عملکرد هفتگی فردا برگزار می‌شود',
              time: '۱ روز پیش',
              isNew: true,
            ),
            _buildNotificationItem(
              title: 'تعطیلی پیش رو',
              subtitle: 'به مناسبت میلاد پیامبر اکرم، شرکت تعطیل است',
              time: '۳ روز پیش',
              isNew: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkHoursContent() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'زمان‌های کاری',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: 'Vazir',
              ),
            ),
            const SizedBox(height: 16),
            _buildWorkHourItem(day: 'شنبه تا چهارشنبه', hours: '۸:۰۰ - ۱۷:۰۰'),
            _buildWorkHourItem(day: 'پنجشنبه', hours: '۸:۰۰ - 13:۰۰'),
            _buildWorkHourItem(day: 'جمعه', hours: 'تعطیل'),
            const SizedBox(height: 16),
            const Text(
              'زمان کاری امروز: ۸:۰۰ - ۱۷:۰۰',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
                fontFamily: 'Vazir',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesContent() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'فعالیت‌های امروز',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: 'Vazir',
              ),
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              title: 'ثبت درخواست قیمت',
              count: 5,
              color: AppColors.primaryGreen,
            ),
            _buildActivityItem(
              title: 'تایید درخواست',
              count: 3,
              color: Colors.blue,
            ),
            _buildActivityItem(
              title: 'رد درخواست',
              count: 1,
              color: Colors.orange,
            ),
            _buildActivityItem(
              title: 'در حال بررسی',
              count: 2,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String subtitle,
    required String time,
    required bool isNew,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                fontFamily: 'Vazir',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (isNew) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontFamily: 'Vazir',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'Vazir',
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

  Widget _buildWorkHourItem({required String day, required String hours}) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              day,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontFamily: 'Vazir',
              ),
            ),
            Text(
              hours,
              style: TextStyle(
                fontSize: 14,
                color: hours == 'تعطیل' ? Colors.red : AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
                fontFamily: 'Vazir',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required int count,
    required Color color,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontFamily: 'Vazir',
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
                  gradient: LinearGradient(
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListTile(
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
      ),
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
              'خوش آمدید',
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
                Text(
                  widget.role ?? 'نقش سازمانی',
                  style: const TextStyle(
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
          (dialogContext) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
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
          ),
    );
  }
}
