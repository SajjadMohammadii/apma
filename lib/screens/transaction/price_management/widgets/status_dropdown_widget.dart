// ویجت دراپ‌داون وضعیت - انتخاب وضعیت فیلتر
// مرتبط با: price_management_page.dart

import 'package:flutter/material.dart'; // ویجت‌های متریال

// کلاس StatusDropdownWidget - ویجت دراپ‌داون وضعیت
class StatusDropdownWidget extends StatelessWidget {
  final String selectedStatus; // وضعیت انتخاب شده
  final List<String> statusOptions; // گزینه‌های وضعیت
  final Function(String?) onChanged; // callback تغییر

  // سازنده
  const StatusDropdownWidget({
    super.key,
    required this.selectedStatus,
    required this.statusOptions,
    required this.onChanged,
  });

  @override
  // متد build - ساخت رابط کاربری دراپ‌داون
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStatus, // مقدار انتخاب شده
          dropdownColor: Colors.white,
          isDense: true,
          alignment: Alignment.centerRight,
          style: const TextStyle(
            fontFamily: 'Vazir',
            fontSize: 10,
            color: Colors.black87,
          ),
          // ساخت آیتم انتخاب شده
          selectedItemBuilder: (BuildContext context) {
            return statusOptions.map((String value) {
              return Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 10,
                    color: Colors.black87,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              );
            }).toList();
          },
          // آیتم‌های لیست
          items:
              statusOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    style: const TextStyle(fontFamily: 'Vazir', fontSize: 10),
                    textDirection: TextDirection.rtl,
                  ),
                );
              }).toList(),
          onChanged: onChanged, // اعمال تغییر
        ),
      ),
    );
  }
}
