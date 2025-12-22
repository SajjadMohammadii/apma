// صفحه چک بانکی - نمایش چک‌های مشتری یا بانک
// مرتبط با: transaction.dart, customer.dart, bank.dart

import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:apma_app/screens/transaction/bankcheck/bank/bank.dart'; // صفحه چک بانک
import 'package:apma_app/screens/transaction/bankcheck/custumer/customer.dart'; // صفحه چک مشتری
import 'package:flutter/material.dart'; // ویجت‌های متریال

// کلاس BankCheckPage - صفحه چک بانکی
class BankCheckPage extends StatefulWidget {
  const BankCheckPage({super.key});

  @override
  State<BankCheckPage> createState() => _BankCheckPageState();
}

// کلاس _BankCheckPageState - state صفحه چک بانکی
class _BankCheckPageState extends State<BankCheckPage> {
  String selectedCheckType = 'مشتری'; // نوع چک انتخاب شده
  final List<String> checkTypes = ['مشتری', 'بانک']; // انواع چک

  @override
  // متد build - ساخت رابط کاربری صفحه
  Widget build(BuildContext context) {
    bool isCustomer = selectedCheckType == "مشتری"; // آیا چک مشتری
    bool isBank = selectedCheckType == "بانک"; // آیا چک بانک

    return Directionality(
      textDirection: TextDirection.rtl, // راست به چپ
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor, // رنگ پس‌زمینه
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context), // برگشت
          ),
          centerTitle: true,
          title: _buildMainDropdown(), // دراپ‌داون انتخاب نوع
        ),
        body:
            isCustomer
                ? const CustomerPage() // صفحه چک مشتری
                : isBank
                ? const BankPage() // صفحه چک بانک
                : Container(),
      ),
    );
  }

  // متد _buildMainDropdown - ساخت دراپ‌داون انتخاب نوع چک
  Widget _buildMainDropdown() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCheckType, // مقدار انتخاب شده
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          style: const TextStyle(
            fontFamily: "Vazir",
            fontSize: 14,
            color: AppColors.primaryPurple,
          ),
          dropdownColor: Colors.white,
          items:
              checkTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  alignment: Alignment.centerRight,
                  child: Text(type, textAlign: TextAlign.right),
                );
              }).toList(),
          onChanged: (value) {
            setState(() => selectedCheckType = value!); // تغییر نوع
          },
        ),
      ),
    );
  }
}
