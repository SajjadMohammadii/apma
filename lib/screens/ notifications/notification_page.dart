// صفحه اعلان‌ها - نمایش لیست اعلان‌های کاربر
// مرتبط با: home_page.dart, messages_page.dart

import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:flutter/material.dart'; // ویجت‌های متریال

// کلاس NotificationsPage - صفحه اعلان‌ها
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

// کلاس _NotificationsPageState - state صفحه اعلان‌ها
class _NotificationsPageState extends State<NotificationsPage> {
  final TextEditingController _searchController =
      TextEditingController(); // کنترلر جستجو

  @override
  // متد dispose - آزادسازی کنترلر
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  // متد build - ساخت رابط کاربری صفحه اعلان‌ها
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // راست به چپ
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor, // رنگ پس‌زمینه
        appBar: AppBar(
          title: const Text(
            'اعلان‌ها', // عنوان صفحه
            style: TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          backgroundColor: AppColors.primaryGreen,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context), // برگشت
          ),
          centerTitle: true,
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // فیلد جستجو
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'جستجو', // متن راهنما
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontFamily: 'Vazir',
                      ),
                      suffixIcon: const Icon(Icons.search), // آیکون جستجو
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    textAlign: TextAlign.right, // راست‌چین
                    style: TextStyle(fontFamily: 'Vazir'),
                  ),
                ),
                SizedBox(height: 40),
                // کارت اعلان - بخش بالا (متن اعلان)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "کاربر name@ وارد اپلیکیشن شد", // متن اعلان نمونه
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // کارت اعلان - بخش پایین (تاریخ و زمان)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    // گرادیانت بنفش
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryPurple, Color(0xFF8882B2)],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "27 آبان 1404 - 11:30", // تاریخ و زمان اعلان
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
