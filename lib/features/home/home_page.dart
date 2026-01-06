// صفحه اصلی برنامه با منوی کشویی و دسته‌بندی‌ها
// مرتبط با: login_page.dart, auth_bloc.dart, transaction.dart

import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:apma_app/core/constants/app_constant.dart'; // ثابت‌های برنامه
import 'package:apma_app/features/authentication/presentation/bloc/auth_bloc.dart'; // بلاک احراز هویت
import 'package:apma_app/features/authentication/presentation/bloc/auth_event.dart'; // رویدادهای بلاک
import 'package:apma_app/features/authentication/presentation/bloc/auth_state.dart'; // وضعیت‌های بلاک
import 'package:apma_app/features/%20notifications/notification_page.dart'; // صفحه اعلان‌ها
import 'package:apma_app/features/auth/login_page.dart'; // صفحه ورود
import 'package:apma_app/features/transaction/Entry&Exit/Entry%D9%80Exit%D9%80page.dart'; // صفحه ورود و خروج
import 'package:apma_app/features/transaction/delivery_parcels/delivery_parcels.dart'; // صفحه تحویل مرسولات

import 'package:apma_app/features/transaction/transaction.dart'; // صفحه عملیات
import 'package:apma_app/features/messages/messages_page.dart'; // صفحه پیام‌ها
import 'package:apma_app/features/transaction/bankcheck/bank%D9%80check.dart'; // صفحه چک بانکی
import 'package:apma_app/features/transaction/price_management/price_management_page.dart'; // صفحه مدیریت بها

import 'package:flutter/material.dart'; // ویجت‌های متریال
import 'package:flutter_bloc/flutter_bloc.dart';

import '../production/presentation/production_control.dart';

// کلاس HomePage - صفحه اصلی پس از ورود
class HomePage extends StatefulWidget {
  final String username; // نام کاربری
  final String? name; // نام کاربر
  final String? role; // نقش کاربر

  // سازنده با پارامترهای کاربر
  const HomePage({super.key, required this.username, this.name, this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

// کلاس _HomePageState - state صفحه اصلی
class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // ایندکس تب انتخاب شده
  String _selectedCategory = 'مالی'; // دسته‌بندی انتخاب شده
  List<Map<String, dynamic>> favoriteItems = []; // لیست آیتم‌های مورد علاقه

  // لیست تمام صفحات قابل دسترس
  final List<Map<String, dynamic>> availablePages = [
    {
      'title': 'مدیریت بها', // عنوان
      'icon': Icons.analytics, // آیکون
      'route': '/price_management', // مسیر
      'widget': null, // ویجت (تنظیم پویا)
    },
    {
      'title': 'کنترل تولید', // عنوان
      'icon': Icons.inventory, // آیکون
      'route': '/production_control', // مسیر
      'widget': null, // ویجت (تنظیم پویا)
    },
    {
      'title': 'چک',
      'icon': Icons.receipt_long,
      'route': '/bank_check',
      'widget': null,
    },
    {
      'title': 'ورود و خروج',
      'icon': Icons.departure_board,
      'route': 'EntryـExitـpage/',
      'widget': null,
    },
    {
      'title': 'تحویل مرسولات',
      'icon': Icons.departure_board,
      'route': '/delivery_parcels',
      'widget': null,
    },
  ];

  // لیست دسته‌بندی‌ها
  final List<String> _categories = [
    'مالی', // مالی
    'تولید', // تولید
    'ارتباط با مشتری', // CRM
    'پرسنلی', // HR
    'تسهیل دار', // تسهیلات
  ];

  @override
  // متد build - ساخت رابط کاربری صفحه اصلی
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      // گوش دادن به تغییرات وضعیت احراز هویت
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // اگر خارج شد، برگرد به صفحه ورود
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor, // رنگ پس‌زمینه
        appBar: AppBar(
          // نوار بالای صفحه
          title: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              height: 32,
              padding: const EdgeInsets.only(left: 4, right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              // دراپ‌داون انتخاب دسته‌بندی
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  dropdownColor: Colors.white,
                  isDense: true,
                  icon: const SizedBox.shrink(),
                  alignment: AlignmentDirectional.centerEnd,
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 11,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedItemBuilder: (BuildContext context) {
                    return _categories.map((String value) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            value,
                            style: const TextStyle(
                              fontFamily: 'Vazir',
                              fontSize: 11,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.primaryPurple,
                            size: 18,
                          ),
                        ],
                      );
                    }).toList();
                  },
                  items:
                      _categories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          alignment: Alignment.centerRight,
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontFamily: 'Vazir',
                              fontSize: 11,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue; // تغییر دسته‌بندی
                      });
                    }
                  },
                ),
              ),
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.primaryGreen,
          automaticallyImplyLeading: false,
          // آیکون‌های سمت چپ (پیام و اعلان)
          leading: Row(
            children: [
              Expanded(
                child: IconButton(
                  icon: const Icon(Icons.message_outlined, size: 24),
                  padding: EdgeInsets.only(left: 6),
                  onPressed: () {
                    // رفتن به صفحه پیام‌ها
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MessagesPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 24),
                  padding: EdgeInsets.only(left: 4),
                  onPressed: () {
                    // رفتن به صفحه اعلان‌ها
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // عنوان و دکمه منو سمت راست
          actions: [
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Center(
                child: Text(
                  'پنل کاربری', // عنوان صفحه
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Builder(
              builder:
                  (context) => IconButton(
                    icon: const Icon(Icons.menu, size: 24),
                    onPressed: () {
                      Scaffold.of(
                        context,
                      ).openEndDrawer(); // باز کردن منوی کشویی
                    },
                  ),
            ),
          ],
        ),
        endDrawer: _buildDrawer(context), // منوی کشویی
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserCard(context), // کارت اطلاعات کاربر
                const SizedBox(height: 20),
                _buildTabBar(), // نوار تب‌ها
                const SizedBox(height: 16),
                _buildTabContent(), // محتوای تب
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
            _buildTabItem(title: 'پرکاربرد ها', index: 1),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'پرکاربردها',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'Vazir',
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primaryGreen,
                  ),
                  onPressed: () => _showAddFavoriteDialog(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (favoriteItems.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'هیچ موردی اضافه نشده است\nبرای افزودن روی + کلیک کنید',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              ...favoriteItems.map((item) => _buildFavoriteItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteItem(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(item['icon'], color: AppColors.primaryPurple),
        title: Text(item['title'], style: const TextStyle(fontFamily: 'Vazir')),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            setState(() {
              favoriteItems.remove(item);
            });
          },
        ),
        onTap: () => _navigateToPage(item),
      ),
    );
  }

  void _showAddFavoriteDialog() {
    // فیلتر کردن صفحاتی که قبلاً اضافه نشدن
    final notAddedPages =
        availablePages.where((page) {
          return !favoriteItems.any((fav) => fav['route'] == page['route']);
        }).toList();

    showDialog(
      context: context,
      builder:
          (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text(
                'افزودن به پرکاربردها',
                style: TextStyle(fontFamily: 'Vazir'),
              ),
              content:
                  notAddedPages.isEmpty
                      ? const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'همه صفحات اضافه شده‌اند',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Vazir'),
                        ),
                      )
                      : Column(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            notAddedPages.map((page) {
                              return ListTile(
                                leading: Icon(
                                  page['icon'],
                                  color: AppColors.primaryPurple,
                                ),
                                title: Text(
                                  page['title'],
                                  style: const TextStyle(fontFamily: 'Vazir'),
                                ),
                                onTap: () {
                                  _addToFavorites(page);
                                  Navigator.pop(context);
                                },
                              );
                            }).toList(),
                      ),
            ),
          ),
    );
  }

  void _addToFavorites(Map<String, dynamic> page) {
    setState(() {
      favoriteItems.add({
        'title': page['title'],
        'icon': page['icon'],
        'route': page['route'],
      });
    });
  }

  void _navigateToPage(Map<String, dynamic> item) {
    switch (item['route']) {
      case '/price_management':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PriceManagementPage()),
        );
        break;
      case '/bank_check':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BankCheckPage()),
        );
        break;
      case 'EntryـExitـpage/':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EntryExitPage()),
        );
        break;
      case 'Production_Control':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductionControl()),
        );

      case '/delivery_parcels':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DeliveryParcelsPage()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'صفحه در دسترس نیست',
              style: TextStyle(fontFamily: 'Vazir'),
            ),
          ),
        );
    }
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
                  if (_selectedCategory == 'مالی' ||
                      _selectedCategory == 'تسهیل دار' ||
                      _selectedCategory == 'تولید' ||
                      _selectedCategory == 'پرسنلی') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                TransactionPage(category: _selectedCategory),
                      ),
                    );
                  } else {
                    _showEmptyCategoryDialog(context);
                  }
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

  void _showEmptyCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text(
                'محتوایی موجود نیست',
                style: TextStyle(fontFamily: 'Vazir'),
              ),
              content: Text(
                'در حال حاضر محتوایی برای دسته‌بندی "$_selectedCategory" در بخش عملیات موجود نیست.',
                style: const TextStyle(fontFamily: 'Vazir'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('متوجه شدم'),
                ),
              ],
            ),
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
