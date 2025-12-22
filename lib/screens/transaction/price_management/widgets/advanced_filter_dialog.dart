// دیالوگ فیلتر پیشرفته - فیلتر کردن داده‌ها بر اساس معیارهای مختلف
// مرتبط با: price_management_page.dart, filter_button_widget.dart

import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:flutter/material.dart'; // ویجت‌های متریال

// کلاس AdvancedFilterDialog - دیالوگ فیلتر پیشرفته
class AdvancedFilterDialog extends StatefulWidget {
  final TextEditingController numberController; // کنترلر شماره
  final TextEditingController customerController; // کنترلر مشتری
  final TextEditingController issuerController; // کنترلر صادرکننده
  final TextEditingController keywordsController; // کنترلر کلمات کلیدی
  final String initialSearchMode; // حالت جستجو (AND/OR)
  final Function(String) onApply; // callback اعمال فیلتر
  final VoidCallback onClear; // callback پاک کردن

  // سازنده
  const AdvancedFilterDialog({
    super.key,
    required this.numberController,
    required this.customerController,
    required this.issuerController,
    required this.keywordsController,
    required this.initialSearchMode,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<AdvancedFilterDialog> createState() => _AdvancedFilterDialogState();
}

// کلاس _AdvancedFilterDialogState - state دیالوگ فیلتر
class _AdvancedFilterDialogState extends State<AdvancedFilterDialog> {
  late String selectedSearchMode; // حالت جستجوی انتخاب شده

  @override
  // متد initState - مقداردهی اولیه
  void initState() {
    super.initState();
    selectedSearchMode = widget.initialSearchMode;
  }

  @override
  // متد build - ساخت رابط کاربری دیالوگ
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // راست به چپ
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 400,
          constraints: const BoxConstraints(maxHeight: 550),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(), // هدر دیالوگ
                const Divider(height: 20),
                const SizedBox(height: 12),
                _buildFilterTextField(
                  'شماره پیش فاکتور', // فیلد شماره
                  widget.numberController,
                  Icons.numbers,
                ),
                const SizedBox(height: 12),
                _buildFilterTextField(
                  'نام مشتری', // فیلد مشتری
                  widget.customerController,
                  Icons.person,
                ),
                const SizedBox(height: 12),
                _buildFilterTextField(
                  'صادرکننده', // فیلد صادرکننده
                  widget.issuerController,
                  Icons.person_outline,
                ),
                const SizedBox(height: 12),
                _buildKeywordFilter(), // فیلتر کلمات کلیدی
                const SizedBox(height: 20),
                _buildActionButtons(), // دکمه‌های عملیات
              ],
            ),
          ),
        ),
      ),
    );
  }

  // متد _buildHeader - ساخت هدر دیالوگ
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'فیلتر پیشرفته', // عنوان
          style: TextStyle(
            fontFamily: 'Vazir',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        // دکمه بستن
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  // متد _buildKeywordFilter - ساخت بخش فیلتر کلمات کلیدی
  Widget _buildKeywordFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'جستجو بر اساس کلمات کلیدی', // عنوان
          style: TextStyle(
            fontFamily: 'Vazir',
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        // فیلد ورودی کلمات کلیدی
        TextField(
          controller: widget.keywordsController,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.search,
              size: 20,
              color: AppColors.primaryGreen,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryGreen),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            hintText: 'مثال: کاسپین البرز (کلمات را با فاصله جدا کنید)',
            hintStyle: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 10,
              color: Colors.grey.shade400,
            ),
          ),
          style: const TextStyle(fontFamily: 'Vazir', fontSize: 12),
        ),
        const SizedBox(height: 8),
        // انتخاب حالت جستجو (AND/OR)
        Row(
          children: [
            Expanded(child: _buildSearchModeOption('AND', 'همه کلمات (و)')),
            const SizedBox(width: 8),
            Expanded(child: _buildSearchModeOption('OR', 'هر کدام (یا)')),
          ],
        ),
        const SizedBox(height: 8),
        _buildInfoBox(), // باکس اطلاعات
      ],
    );
  }

  // متد _buildSearchModeOption - ساخت گزینه حالت جستجو
  Widget _buildSearchModeOption(String mode, String label) {
    final isSelected = selectedSearchMode == mode;
    return InkWell(
      onTap: () {
        setState(() {
          selectedSearchMode = mode; // تغییر حالت
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primaryGreen.withOpacity(0.1)
                  : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // آیکون رادیو
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color: isSelected ? AppColors.primaryGreen : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryGreen : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // متد _buildInfoBox - ساخت باکس اطلاعات راهنما
  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 16,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              // توضیح حالت جستجو
              selectedSearchMode == 'AND'
                  ? 'نتایج باید شامل تمام کلمات باشند'
                  : 'نتایج باید شامل حداقل یکی از کلمات باشند',
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 10,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // متد _buildFilterTextField - ساخت فیلد متنی فیلتر
  Widget _buildFilterTextField(
    String label, // برچسب
    TextEditingController controller, // کنترلر
    IconData icon, // آیکون
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Vazir',
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppColors.primaryGreen),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryGreen),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            hintText: 'جستجو...',
            hintStyle: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 11,
              color: Colors.grey.shade400,
            ),
          ),
          style: const TextStyle(fontFamily: 'Vazir', fontSize: 12),
        ),
      ],
    );
  }

  // متد _buildActionButtons - ساخت دکمه‌های عملیات
  Widget _buildActionButtons() {
    return Row(
      children: [
        // دکمه پاک کردن
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              widget.onClear();
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade400),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'پاک کردن',
              style: TextStyle(fontFamily: 'Vazir', fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // دکمه اعمال فیلتر
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.onApply(selectedSearchMode);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'اعمال فیلتر',
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
