// صفحه عملیات - نمایش آیتم‌های منو برای هر دسته‌بندی
// مرتبط با: home_page.dart, price_management_page.dart, bank_check.dart

import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:apma_app/features/production/presentation/production_control.dart';
import 'package:apma_app/features/transaction/Entry&Exit/presentation/pages/entry_exit_page.dart'; // صفحه ورود و خروج
import 'package:apma_app/features/transaction/delivery_parcels/delivery_parcels.dart'; // صفحه تحویل مرسولات
import 'package:apma_app/features/transaction/price_management/price_management_page.dart'; // صفحه مدیریت بها
import 'package:apma_app/features/transaction/bankcheck/bank%D9%80check.dart'; // صفحه چک بانکی

import 'package:flutter/material.dart'; // ویجت‌های متریال

// کلاس TransactionPage - صفحه عملیات
class TransactionPage extends StatelessWidget {
  final String category; // دسته‌بندی انتخاب شده

  // سازنده با دسته‌بندی پیش‌فرض مالی
  const TransactionPage({super.key, this.category = 'مالی'});

  @override
  // متد build - ساخت رابط کاربری صفحه عملیات
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // راست به چپ
      child: Scaffold(
        backgroundColor: AppColors.primaryGreen, // رنگ پس‌زمینه
        appBar: AppBar(
          title: const Text(
            'عملیات', // عنوان صفحه
            style: TextStyle(fontFamily: 'Vazir', color: Colors.white),
          ),
          backgroundColor: AppColors.primaryGreen,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // برگشت
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildCategoryContent(), // ساخت محتوای دسته‌بندی
        ),
      ),
    );
  }

  // متد _buildCategoryContent - ساخت محتوا بر اساس دسته‌بندی
  Widget _buildCategoryContent() {
    if (category == 'مالی') {
      // دسته مالی
      return Column(
        children: [
          _buildMenuItem(
            title: 'مدیریت بها',
            imagePath: 'assets/images/PriceManagement.png',
          ),
        ],
      );
    } else if (category == 'تسهیل دار') {
      // دسته تسهیل دار
      return Column(
        children: [
          _buildMenuItem(title: 'چک', imagePath: 'assets/images/bankcheck.png'),
          const SizedBox(height: 16),
          _buildMenuItem(
            title: 'تحویل مرسولات',
            imagePath: 'assets/images/delivery.png',
          ),
        ],
      );
    }
    else if (category == 'پرسنلی') {
      // دسته پرسنلی
      return Column(
        children: [
          _buildMenuItem(
            title: 'ورود و خروج',
            imagePath: 'assets/images/EntryExit.png',
          ),
        ],
      );
    }  else if (category == 'تولید') {
      // دسته پرسنلی
      return Column(
        children: [
          _buildMenuItem(
            title: 'کنترل تولید',
            imagePath: 'assets/images/production_control.png',
          ),
        ],
      );
    }
    else {
      // دسته بدون محتوا
      return const Center(
        child: Text(
          'محتوایی موجود نیست',
          style: TextStyle(
            fontFamily: 'Vazir',
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      );
    }
  }

  // متد _buildMenuItem - ساخت آیتم منو
  // پارامتر title: عنوان آیتم
  // پارامتر imagePath: مسیر تصویر آیکون
  Widget _buildMenuItem({required String title, required String imagePath}) {
    return Builder(
      builder: (context) {
        return InkWell(
          onTap: () {
            // ناوبری بر اساس عنوان آیتم
            if (title == 'مدیریت بها') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PriceManagementPage(),
                ),
              );
            } else if (title == 'چک') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BankCheckPage()),
              );
            } else if (title == 'ورود و خروج') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EntryExitPage()),
              );
            }
            else if (title == 'کنترل تولید') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  ProductionControl()),
              );
            }  else if (title == 'تحویل مرسولات') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeliveryParcelsPage(),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // گرادیانت بنفش
              gradient: const LinearGradient(
                colors: [AppColors.primaryPurple, Color(0xFF8882B2)],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // عنوان آیتم
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Vazir',
                  ),
                ),
                const Spacer(),
                // آیکون آیتم
                Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    imagePath,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // آیکون جایگزین در صورت خطا
                      return const Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                        size: 40,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
