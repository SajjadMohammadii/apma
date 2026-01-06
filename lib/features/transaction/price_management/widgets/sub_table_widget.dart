// ویجت جدول فرعی - نمایش جزئیات درخواست‌های هر سفارش
// مرتبط با: price_management_page.dart, table_row_widget.dart

import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:apma_app/shared/widgets/persian_date_picker/persian_date_utils.dart'; // ابزار تاریخ
import 'package:flutter/material.dart'; // ویجت‌های متریال

// کلاس SubTableWidget - ویجت جدول فرعی (جزئیات)
class SubTableWidget extends StatefulWidget {
  final int parentId; // شناسه ردیف والد
  final List<Map<String, dynamic>> subItems; // آیتم‌های فرعی
  final Map<String, String> subFieldStatuses; // وضعیت‌های فیلدها
  final List<String> statusOptions; // گزینه‌های وضعیت
  final int? sortColumnIndex; // ستون مرتب‌سازی
  final bool isAscending; // صعودی/نزولی
  final Function(int) onSort; // callback مرتب‌سازی
  final Function(String, String) onStatusChange; // callback تغییر وضعیت

  // سازنده
  const SubTableWidget({
    super.key,
    required this.parentId,
    required this.subItems,
    required this.subFieldStatuses,
    required this.statusOptions,
    required this.sortColumnIndex,
    required this.isAscending,
    required this.onSort,
    required this.onStatusChange,
  });

  @override
  State<SubTableWidget> createState() => _SubTableWidgetState();
}

// کلاس _SubTableWidgetState - state جدول فرعی
class _SubTableWidgetState extends State<SubTableWidget> {
  @override
  // متد build - ساخت رابط کاربری جدول فرعی
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildHeader(), // هدر جدول فرعی
          ...widget.subItems
              .map((subItem) => _buildRow(subItem))
              , // ردیف‌ها
        ],
      ),
    );
  }

  // متد _buildHeader - ساخت هدر جدول فرعی
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          color: AppColors.primaryGreen, // رنگ پس‌زمینه سبز
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // ستون‌های هدر فرعی
                _buildSortableHeader('تاریخ درخواست', flex: 2, index: 0),
                _buildDivider(),
                _buildSortableHeader('عنوان کالا', flex: 3, index: 1),
                _buildDivider(),
                _buildSortableHeader('نوع درخواست', flex: 2, index: 2),
                _buildDivider(),
                _buildSortableHeader('مبلغ فعلی', flex: 2, index: 3),
                _buildDivider(),
                _buildSortableHeader('مبلغ درخواستی', flex: 2, index: 4),
                _buildDivider(),
                _buildSortableHeader('وضعیت', flex: 2, index: 5),
              ],
            ),
          ),
        ),
        Container(height: 1, color: Colors.white.withOpacity(0.3)),
      ],
    );
  }

  // متد _buildRow - ساخت یک ردیف جدول فرعی
  Widget _buildRow(Map<String, dynamic> subItem) {
    final originalId = subItem['original_id']?.toString() ?? ''; // شناسه اصلی
    // وضعیت فعلی
    final currentStatus =
        widget.subFieldStatuses[originalId] ??
        subItem['approval_status'] ??
        'در حال بررسی';
    final isEditable =
        currentStatus == 'در حال بررسی'; // فقط "در حال بررسی" قابل ویرایش

    // تبدیل تاریخ به شمسی
    final requestDate = PersianDateUtils.gregorianToJalali(
      subItem['request_date'],
    );

    return Column(
      children: [
        Container(
          color: const Color(0xFFE8E8E8), // رنگ خاکستری روشن
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: IntrinsicHeight(
            child: Row(
              children: [
                _buildCell(requestDate, flex: 2), // تاریخ درخواست
                _buildDivider(),
                _buildCell(subItem['product_name'] ?? '', flex: 3), // نام کالا
                _buildDivider(),
                _buildCell(
                  subItem['request_type'] ?? '',
                  flex: 2,
                ), // نوع درخواست
                _buildDivider(),
                _buildCell(
                  subItem['current_price']?.toString() ?? '0', // قیمت فعلی
                  flex: 2,
                ),
                _buildDivider(),
                _buildCell(
                  subItem['requested_price']?.toString() ??
                      '0', // قیمت درخواستی
                  flex: 2,
                ),
                _buildDivider(),
                _buildDropdownCell(
                  originalId,
                  currentStatus,
                  isEditable,
                ), // دراپ‌داون وضعیت
              ],
            ),
          ),
        ),
        Container(height: 1, color: Colors.white.withOpacity(0.3)),
      ],
    );
  }

  // متد _buildSortableHeader - ساخت هدر با قابلیت مرتب‌سازی
  Widget _buildSortableHeader(
    String text, {
    required int flex,
    required int index,
  }) {
    final isActive = widget.sortColumnIndex == index; // آیا فعال است
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => widget.onSort(index), // کلیک برای مرتب‌سازی
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            // آیکون مرتب‌سازی
            Icon(
              isActive
                  ? (widget.isAscending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward)
                  : Icons.unfold_more,
              size: 14,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  // متد _buildCell - ساخت سلول متنی
  Widget _buildCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Vazir',
            fontSize: 9,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // متد _buildDropdownCell - ساخت سلول دراپ‌داون وضعیت
  Widget _buildDropdownCell(
    String itemId, // شناسه آیتم
    String currentStatus, // وضعیت فعلی
    bool isEditable, // آیا قابل ویرایش است
  ) {
    return Expanded(
      flex: 2,
      child: Center(
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isEditable ? Colors.white : Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isEditable ? AppColors.primaryGreen : Colors.grey,
              width: 1,
            ),
          ),
          child:
              isEditable
                  ? DropdownButtonHideUnderline(
                    // دراپ‌داون قابل ویرایش
                    child: DropdownButton<String>(
                      value: currentStatus,
                      dropdownColor: Colors.white,
                      isDense: true,
                      alignment: Alignment.centerRight,
                      style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 9,
                        color: Colors.black87,
                      ),
                      selectedItemBuilder: (BuildContext context) {
                        return widget.statusOptions.skip(1).map((String value) {
                          return Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontFamily: 'Vazir',
                                fontSize: 9,
                                color: Colors.black87,
                              ),
                              textDirection: TextDirection.rtl,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList();
                      },
                      items:
                          widget.statusOptions.skip(1).map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              alignment: Alignment.centerRight,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  fontFamily: 'Vazir',
                                  fontSize: 9,
                                ),
                                textDirection: TextDirection.rtl,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          widget.onStatusChange(
                            itemId,
                            newValue,
                          ); // اعمال تغییر
                        }
                      },
                    ),
                  )
                  : Center(
                    // متن غیرقابل ویرایش
                    child: Text(
                      currentStatus,
                      style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 9,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
        ),
      ),
    );
  }

  // متد _buildDivider - ساخت خط جداکننده
  Widget _buildDivider() {
    return Container(width: 1, color: Colors.white.withOpacity(0.3));
  }
}
