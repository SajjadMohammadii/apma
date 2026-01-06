// صفحه چک بانک - ثبت و مدیریت چک‌های بانکی
// مرتبط با: bank_check.dart, camera_preview_screen.dart

import 'dart:io'; // کتابخانه کار با فایل
import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:apma_app/features/transaction/bankcheck/camera_preview_screen.dart'; // صفحه دوربین
import 'package:apma_app/shared/widgets/persian_date_picker/persian_date_picker_dialog.dart'; // انتخابگر تاریخ
import 'package:flutter/foundation.dart'; // ابزارهای پایه
import 'package:flutter/material.dart'; // ویجت‌های متریال
import 'package:camera/camera.dart'; // کتابخانه دوربین
import 'package:image_picker/image_picker.dart'; // انتخاب تصویر
import 'package:permission_handler/permission_handler.dart'; // مدیریت دسترسی‌ها
import 'package:shamsi_date/shamsi_date.dart'; // تاریخ شمسی
import 'package:flutter/services.dart'; // سرویس‌های سیستم

// کلاس BankPage - صفحه چک بانک
class BankPage extends StatefulWidget {
  const BankPage({super.key});

  @override
  State<BankPage> createState() => _BankPageState();
}

// کلاس _BankPageState - state صفحه چک بانک
class _BankPageState extends State<BankPage> {
  String bankStatus = "واریز"; // وضعیت بانکی انتخاب شده
  // لیست وضعیت‌های بانکی
  final List<String> bankStatuses = [
    'واریز',
    'خواباندن',
    'برگشت',
    'ابطال',
    'مرجوع',
  ];

  String? imagePath; // مسیر تصویر چک
  List<CameraDescription>? _cameras; // لیست دوربین‌ها
  final ImagePicker _picker = ImagePicker(); // انتخابگر تصویر

  // کنترلرهای فیلدها
  final TextEditingController searchController =
      TextEditingController(); // جستجو
  final TextEditingController accountController =
      TextEditingController(); // حساب
  final TextEditingController bankDateController =
      TextEditingController(); // تاریخ

  // بررسی پلتفرم موبایل
  bool get _isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  // بررسی پلتفرم دسکتاپ یا وب
  bool get _isDesktopOrWeb {
    if (kIsWeb) return true;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  @override
  // متد initState - مقداردهی اولیه
  void initState() {
    super.initState();
    _setTodayDate(); // تنظیم تاریخ امروز
  }

  // متد _setTodayDate - تنظیم تاریخ امروز شمسی
  void _setTodayDate() {
    final now = Jalali.now();
    bankDateController.text =
        '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
  }

  // متد _openDatePicker - باز کردن انتخابگر تاریخ
  Future<void> _openDatePicker() async {
    final selectedDate = await PersianDatePickerDialog.show(
      context,
      bankDateController.text,
    );
    if (selectedDate != null) {
      bankDateController.text = selectedDate;
    }
  }

  // متد _openAttachment - باز کردن پیوست
  Future<void> _openAttachment() async {
    if (_isDesktopOrWeb) {
      // فقط گزینه فایل در دسکتاپ و وب
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() => imagePath = file.path);
      }
    } else {
      // در موبایل هم فایل هم دوربین
      _showAttachmentPicker();
    }
  }

  // متد _showAttachmentPicker - نمایش انتخابگر پیوست
  void _showAttachmentPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'انتخاب فایل پیوست',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPickerOption(
                        icon: Icons.camera_alt,
                        label: 'دوربین',
                        onTap: () async {
                          Navigator.pop(context);
                          await _openCamera();
                        },
                      ),
                      _buildPickerOption(
                        icon: Icons.photo_library,
                        label: 'گالری',
                        onTap: () async {
                          Navigator.pop(context);
                          final XFile? file = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (file != null) {
                            setState(() => imagePath = file.path);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryPurple, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Vazir',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;

    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CameraPreviewScreen(
              camera: _cameras!.first,
              onCapture: (path) => setState(() => imagePath = path),
            ),
      ),
    );
  }

  void _saveData() {
    print("اطلاعات بانک ذخیره شد");
  }

  @override
  Widget build(BuildContext context) {
    bool showAccountField = bankStatus == "واریز" || bankStatus == "خواباندن";

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildSearchBox(),
                _buildDropdownField("وضعیت", bankStatus, bankStatuses),
                if (showAccountField) _buildField("به حساب", accountController),
                _buildField("تاریخ", bankDateController, isDate: true),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _openAttachment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text("پیوست", style: TextStyle(fontFamily: 'Vazir')),
                      SizedBox(width: 12),
                      Icon(Icons.attach_file),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (imagePath != null) _uploadedFileBox(),
              ],
            ),
          ),
        ),
        _saveButton(),
      ],
    );
  }

  Widget _buildSearchBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "جستجوی چک",
          style: TextStyle(
            fontFamily: "Vazir",
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: searchController,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontFamily: "Vazir",
              fontSize: 15,
              color: Colors.black87,
            ),
            decoration: const InputDecoration(
              hintText: "شماره سریال / شماره چک",
              hintStyle: TextStyle(fontFamily: "Vazir", color: Colors.grey),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: InputBorder.none,
              suffixIcon: Icon(Icons.search, color: AppColors.primaryPurple),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: "Vazir",
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              style: const TextStyle(
                fontFamily: "Vazir",
                fontSize: 14,
                color: Colors.black87,
              ),
              dropdownColor: Colors.white,
              items:
                  items.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      alignment: Alignment.centerRight,
                      child: Text(item, textAlign: TextAlign.right),
                    );
                  }).toList(),
              onChanged: (val) => setState(() => bankStatus = val!),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool isDate = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: "Vazir",
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child:
              isDate
                  ? InkWell(
                    onTap: _openDatePicker,
                    child: IgnorePointer(
                      child: TextField(
                        controller: controller,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFamily: "Vazir",
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                  : TextField(
                    controller: controller,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontFamily: "Vazir", fontSize: 15),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _uploadedFileBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "فایل چک",
          style: TextStyle(
            fontFamily: "Vazir",
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: const [
              Icon(Icons.insert_drive_file, color: Colors.blue, size: 35),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "فایل چک آپلود شد",
                  style: TextStyle(fontFamily: "Vazir", fontSize: 15),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _saveButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _saveData,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "ذخیره",
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
