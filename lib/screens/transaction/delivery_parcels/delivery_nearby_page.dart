// صفحه مشتریان نزدیک - نمایش لیست مشتریان در انتظار تحویل
// مرتبط با: delivery_parcels.dart, signature_page.dart

import 'dart:io'; // کتابخانه کار با فایل
import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:flutter/foundation.dart'; // ابزارهای پایه
import 'package:flutter/material.dart'; // ویجت‌های متریال
import 'package:flutter/services.dart'; // سرویس‌های سیستم
import 'package:image_picker/image_picker.dart'; // انتخاب تصویر
import 'signature_page.dart'; // صفحه امضا

// کلاس DeliveryNearbyPage - صفحه مشتریان نزدیک
class DeliveryNearbyPage extends StatefulWidget {
  final String location; // مکان اصلی
  final String subLocation; // زیرمجموعه

  // سازنده
  const DeliveryNearbyPage({
    super.key,
    required this.location,
    required this.subLocation,
  });

  @override
  State<DeliveryNearbyPage> createState() => _DeliveryNearbyPageState();
}

// کلاس _DeliveryNearbyPageState - state صفحه مشتریان نزدیک
class _DeliveryNearbyPageState extends State<DeliveryNearbyPage> {
  final ImagePicker _picker = ImagePicker(); // انتخابگر تصویر

  // داده‌های نمونه مشتریان در انتظار
  final List<Map<String, dynamic>> _pendingDeliveries = [
    {
      'id': 1,
      'customerName': 'شرکت آلفا',
      'customerLocation': 'تهران، ولیعصر',
      'items': 3,
      'amount': '',
      'attachment': null,
      'signed': false,
    },
    {
      'id': 2,
      'customerName': 'فروشگاه بتا',
      'customerLocation': 'تهران، ونک',
      'items': 5,
      'amount': '',
      'attachment': null,
      'signed': false,
    },
    {
      'id': 3,
      'customerName': 'صنایع گاما',
      'customerLocation': 'کرج، صنعتی',
      'items': 2,
      'amount': '',
      'attachment': null,
      'signed': false,
    },
  ];

  // کنترلرهای مبلغ برای هر مشتری
  final Map<int, TextEditingController> _amountControllers = {};

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
  // متد initState - مقداردهی اولیه و تنظیم جهت صفحه
  void initState() {
    super.initState();
    if (_isMobile) {
      // تنظیم جهت صفحه به افقی
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    // ساخت کنترلرهای مبلغ
    for (var item in _pendingDeliveries) {
      _amountControllers[item['id']] = TextEditingController(
        text: item['amount'],
      );
    }
  }

  @override
  // متد build - ساخت رابط کاربری صفحه
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // راست به چپ
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: const Text(
            'مشتریان در انتظار', // عنوان
            style: TextStyle(
              fontFamily: 'Vazir',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          backgroundColor: AppColors.primaryGreen,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context), // برگشت
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // هدر نمایش مکان
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${widget.location} - ${widget.subLocation}', // نمایش مکان
                        style: const TextStyle(
                          fontFamily: 'Vazir',
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // تعداد مشتریان
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_pendingDeliveries.length} مشتری',
                        style: TextStyle(
                          fontFamily: 'Vazir',
                          color: AppColors.primaryPurple,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // جدول مشتریان
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // هدر جدول
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Expanded(
                              flex: 1,
                              child: Text(
                                'ردیف',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Vazir',
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'مشتری',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Vazir',
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'لوکیشن',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Vazir',
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'اقلام',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Vazir',
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'مبلغ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Vazir',
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'پیوست',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Vazir',
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'وضعیت',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Vazir',
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ردیف‌ها
                      Expanded(
                        child: ListView.builder(
                          itemCount: _pendingDeliveries.length,
                          itemBuilder: (context, index) {
                            final item = _pendingDeliveries[index];
                            final hasAmount =
                                _amountControllers[item['id']]
                                    ?.text
                                    .isNotEmpty ??
                                false;
                            final isSigned = item['signed'] ?? false;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    index % 2 == 0
                                        ? Colors.grey[50]
                                        : Colors.white,
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey[200]!),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${index + 1}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Vazir',
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      item['customerName'] ?? '',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Vazir',
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      item['customerLocation'] ?? '',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Vazir',
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${item['items']}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Vazir',
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      height: 28,
                                      child: TextField(
                                        controller:
                                            _amountControllers[item['id']],
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(
                                          fontFamily: 'Vazir',
                                          fontSize: 9,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: '0',
                                          hintStyle: const TextStyle(
                                            fontSize: 9,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 2,
                                                vertical: 2,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                        ),
                                        onChanged: (v) => setState(() {}),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        item['attachment'] != null
                                            ? Icons.check_circle
                                            : Icons.attach_file,
                                        size: 16,
                                        color:
                                            item['attachment'] != null
                                                ? AppColors.primaryGreen
                                                : Colors.grey,
                                      ),
                                      onPressed: () => _pickAttachment(item),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            hasAmount
                                                ? Colors.green[50]
                                                : Colors.orange[50],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        hasAmount ? 'آماده' : 'در انتظار',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Vazir',
                                          fontSize: 8,
                                          color:
                                              hasAmount
                                                  ? Colors.green
                                                  : Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // دکمه امضا
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _goToSignature,
                  icon: const Icon(Icons.draw, size: 18),
                  label: const Text(
                    'امضا',
                    style: TextStyle(fontFamily: 'Vazir', fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToSignature() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SignaturePage(
              customerName: 'امضای تحویل',
              location: '${widget.location} - ${widget.subLocation}',
            ),
      ),
    );

    if (result == true) {
      setState(() {
        for (var item in _pendingDeliveries) {
          item['signed'] = true;
        }
      });
      _showSnackBar('امضا برای همه مشتریان ثبت شد');
    }

    if (_isMobile) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  Future<void> _pickAttachment(Map<String, dynamic> item) async {
    if (_isDesktopOrWeb) {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() => item['attachment'] = file.path);
        _showSnackBar('فایل پیوست شد');
      }
    } else {
      showModalBottomSheet(
        context: context,
        builder:
            (ctx) => Directionality(
              textDirection: TextDirection.rtl,
              child: Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text(
                      'دوربین',
                      style: TextStyle(fontFamily: 'Vazir'),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final XFile? file = await _picker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (file != null) {
                        setState(() => item['attachment'] = file.path);
                        _showSnackBar('تصویر پیوست شد');
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text(
                      'گالری',
                      style: TextStyle(fontFamily: 'Vazir'),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final XFile? file = await _picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (file != null) {
                        setState(() => item['attachment'] = file.path);
                        _showSnackBar('فایل پیوست شد');
                      }
                    },
                  ),
                ],
              ),
            ),
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Vazir')),
        backgroundColor: isError ? Colors.red : AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
