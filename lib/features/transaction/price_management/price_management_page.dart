// صفحه مدیریت بها - نمایش و مدیریت درخواست‌های قیمت
// مرتبط با: price_management_bloc.dart, price_request_service.dart, transaction.dart

import 'dart:async'; // کتابخانه async برای Timer
import 'dart:io'; // کتابخانه کار با فایل
import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:apma_app/core/network/soap_client.dart'; // کلاینت SOAP
import 'package:apma_app/core/di/injection_container.dart'; // تزریق وابستگی
import 'package:apma_app/core/services/print_service.dart'; // سرویس پرینت
import 'package:apma_app/features/transaction/price_management/bloc/price_management_bloc.dart'; // بلاک
import 'package:apma_app/features/transaction/price_management/bloc/price_management_event.dart'; // رویدادها
import 'package:apma_app/features/transaction/price_management/bloc/price_management_state.dart'; // وضعیت‌ها
import 'package:apma_app/features/transaction/price_management/services/price_request_service.dart'; // سرویس
import 'package:apma_app/features/transaction/price_management/models/price_request_model.dart'; // مدل
import 'package:apma_app/features/transaction/price_management/widgets/advanced_filter_dialog.dart'; // دیالوگ فیلتر
import 'package:apma_app/features/transaction/price_management/widgets/date_field_widget.dart'; // ویجت تاریخ
import 'package:apma_app/features/transaction/price_management/widgets/filter_button_widget.dart'; // دکمه فیلتر
import 'package:apma_app/features/transaction/price_management/widgets/status_dropdown_widget.dart'; // دراپ‌داون وضعیت
import 'package:apma_app/features/transaction/price_management/widgets/table_header_widget.dart'; // هدر جدول
import 'package:apma_app/features/transaction/price_management/widgets/table_row_widget.dart'; // ردیف جدول
import 'package:apma_app/features/transaction/price_management/widgets/sub_table_widget.dart'; // جدول فرعی
import 'package:apma_app/shared/widgets/persian_date_picker/persian_date_picker_dialog.dart'; // انتخابگر تاریخ
import 'package:flutter/foundation.dart'; // ابزارهای پایه
import 'package:flutter/material.dart'; // ویجت‌های متریال
import 'package:flutter/services.dart'; // سرویس‌های سیستم
import 'package:flutter_bloc/flutter_bloc.dart'; // کتابخانه BLoC
import 'package:shamsi_date/shamsi_date.dart'; // کتابخانه تاریخ شمسی
import 'package:pdf/pdf.dart'; // کتابخانه PDF
import 'package:pdf/widgets.dart' as pw; // ویجت‌های PDF

// کلاس PriceManagementPage - صفحه مدیریت بها
class PriceManagementPage extends StatefulWidget {
  const PriceManagementPage({super.key});

  @override
  State<PriceManagementPage> createState() => _PriceManagementPageState();
}

// کلاس _PriceManagementPageState - state صفحه مدیریت بها
class _PriceManagementPageState extends State<PriceManagementPage> {
  String selectedStatus = 'در حال بررسی'; // وضعیت انتخاب شده
  Map<String, String> subFieldStatuses = {}; // وضعیت‌های فیلدهای فرعی
  // گزینه‌های وضعیت
  final List<String> statusOptions = [
    'همه',
    'در حال بررسی',
    'تایید شده',
    'رد شده',
  ];

  Set<int> expandedRows = {}; // ردیف‌های باز شده

  int? sortColumnIndex; // ستون مرتب‌سازی
  bool isAscending = true; // صعودی یا نزولی

  Map<int, int?> subSortColumnIndex = {}; // ستون مرتب‌سازی جدول فرعی
  Map<int, bool> subIsAscending = {}; // صعودی/نزولی جدول فرعی

  String fromDate = ''; // تاریخ از
  String toDate = ''; // تاریخ تا

  // کنترلرهای فیلتر
  final TextEditingController _numberFilterController =
      TextEditingController(); // شماره
  final TextEditingController _customerFilterController =
      TextEditingController(); // مشتری
  final TextEditingController _issuerFilterController =
      TextEditingController(); // صادرکننده
  final TextEditingController _keywordsController =
      TextEditingController(); // کلمات کلیدی

  late PriceManagementBloc _bloc; // بلاک مدیریت بها
  Timer? _autoRefreshTimer; // تایمر بازخوانی خودکار
  final bool _isAutoRefreshEnabled = true; // فعال بودن بازخوانی خودکار

  List<Map<String, dynamic>> mainData = []; // داده‌های اصلی جدول
  List<Map<String, dynamic>> filteredData = []; // داده‌های فیلتر شده
  Map<int, List<Map<String, dynamic>>> subData = {}; // داده‌های جدول فرعی
  Map<int, List<Map<String, dynamic>>> originalSubData =
      {}; // نگهداری داده‌های اصلی

  @override
  // متد initState - مقداردهی اولیه
  void initState() {
    super.initState();

    // تنظیم تاریخ سال جاری شمسی
    final now = Jalali.now();
    final lastDay = Jalali(now.year, 12).monthLength;
    fromDate = '${now.year}/01/01'; // اول سال
    toDate = '${now.year}/12/$lastDay'; // آخر سال

    // تنظیم جهت صفحه به افقی
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // ساخت سرویس و بلاک
    final soapClient = sl<SoapClient>();
    final service = PriceRequestService(soapClient: soapClient);
    _bloc = PriceManagementBloc(priceRequestService: service);

    _loadData(); // بارگذاری داده‌ها
    _startAutoRefresh(); // شروع بازخوانی خودکار
  }

  // متد _startAutoRefresh - شروع بازخوانی خودکار هر ۵ ثانیه
  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isAutoRefreshEnabled) {
        _loadDataSilently(); // بارگذاری بدون نمایش لودینگ
      }
    });
  }

  // متد _loadDataSilently - بارگذاری داده‌ها بدون نمایش لودینگ
  void _loadDataSilently() {
    final fromDateGregorian = _persianToGregorian(fromDate); // تبدیل به میلادی
    final toDateGregorian = _persianToGregorian(toDate);

    _bloc.add(
      LoadPriceRequestsEvent(
        fromDate: fromDateGregorian,
        toDate: toDateGregorian,
        status: 0,
        criteria: _keywordsController.text,
      ),
    );
  }

  // متد _loadData - بارگذاری داده‌ها
  void _loadData() {
    // تبدیل تاریخ‌های شمسی به میلادی برای ارسال به سرور
    final fromDateGregorian = _persianToGregorian(fromDate);
    final toDateGregorian = _persianToGregorian(toDate);

    _bloc.add(
      LoadPriceRequestsEvent(
        fromDate: fromDateGregorian,
        toDate: toDateGregorian,
        status: 0,
        criteria: _keywordsController.text,
      ),
    );
  }

  // متد _persianToGregorian - تبدیل تاریخ شمسی به میلادی
  String _persianToGregorian(String persianDate) {
    try {
      final parts = persianDate.split('/');
      final jalali = Jalali(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final g = jalali.toGregorian();
      return '${g.year}${g.month.toString().padLeft(2, '0')}${g.day.toString().padLeft(2, '0')}';
    } catch (_) {}
    return persianDate.replaceAll('/', '');
  }

  // متد _gregorianToPersian - تبدیل تاریخ میلادی به شمسی
  String _gregorianToPersian(String gregorianDate) {
    try {
      final g = Gregorian(
        int.parse(gregorianDate.substring(0, 4)),
        int.parse(gregorianDate.substring(4, 6)),
        int.parse(gregorianDate.substring(6, 8)),
      );
      final j = g.toJalali();
      return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
    } catch (_) {}
    return gregorianDate;
  }

  // متد _persianDateToComparable - تبدیل تاریخ شمسی به عدد قابل مقایسه
  int _persianDateToComparable(String d) {
    try {
      final parts = d.split('/');
      final g =
          Jalali(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          ).toGregorian();
      return DateTime(g.year, g.month, g.day).millisecondsSinceEpoch;
    } catch (_) {
      return 0;
    }
  }

  @override
  // متد dispose - آزادسازی منابع
  void dispose() {
    _autoRefreshTimer?.cancel(); // لغو تایمر
    // برگرداندن جهت صفحه به عمودی
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _numberFilterController.dispose();
    _customerFilterController.dispose();
    _issuerFilterController.dispose();
    _keywordsController.dispose();
    _bloc.close(); // بستن بلاک
    super.dispose();
  }

  // متد _convertApiDataToUIFormat - تبدیل داده‌های API به فرمت UI
  void _convertApiDataToUIFormat(Map<String, List<PriceRequestModel>> grouped) {
    mainData.clear();
    subData.clear();
    originalSubData.clear();

    int id = 1;
    grouped.forEach((orderNumber, items) {
      if (items.isNotEmpty) {
        final first = items.first;

        // افزودن ردیف اصلی
        mainData.add({
          'id': id,
          'date': _gregorianToPersian(first.orderDate), // تاریخ شمسی
          'number': orderNumber, // شماره سفارش
          'customer': first.sherkat, // مشتری
          'issuer': first.fullPersonName, // صادرکننده
        });

        // افزودن ردیف‌های فرعی
        subData[id] =
            items.map((item) {
              // استفاده از وضعیت ذخیره شده در subFieldStatuses یا وضعیت سرور
              final status =
                  subFieldStatuses.containsKey(item.id)
                      ? subFieldStatuses[item.id]!
                      : item.statusString;

              // اگر وضعیت در subFieldStatuses نبود، اضافه کن
              if (!subFieldStatuses.containsKey(item.id)) {
                subFieldStatuses[item.id] = item.statusString;
              }

              return {
                'request_date': _gregorianToPersian(item.date),
                'product_name': item.title,
                'request_type': item.requestType,
                'current_price': item.currentPrice.toInt(),
                'requested_price': item.requestedPrice.toInt(),
                'approval_status': status,
                'original_id': item.id,
              };
            }).toList();

        originalSubData[id] = List.from(subData[id]!);
        id++;
      }
    });

    filteredData = List.from(mainData);
    _applyFiltersWithoutSetState();

    if (sortColumnIndex != null) {
      _applySortMainWithoutSetState(sortColumnIndex!, isAscending);
    }
  }

  void _applyFiltersWithoutSetState() {
    // اگر فیلتر "همه" انتخاب شده
    if (selectedStatus == 'همه') {
      filteredData = List.from(mainData);
      // بازسازی subData از originalSubData
      subData.clear();
      originalSubData.forEach((key, value) {
        subData[key] = List.from(value);
        // آپدیت کردن وضعیت‌ها بر اساس subFieldStatuses
        for (var item in subData[key]!) {
          final origId = item['original_id']?.toString() ?? '';
          if (subFieldStatuses.containsKey(origId)) {
            item['approval_status'] = subFieldStatuses[origId];
          }
        }
      });
    } else {
      // فیلتر کردن بر اساس وضعیت انتخابی
      filteredData = [];
      subData.clear();

      for (var item in mainData) {
        final id = item['id'];

        if (!originalSubData.containsKey(id)) continue;

        // فیلتر کردن آیتم‌های فرعی
        final matchingSubItems =
            originalSubData[id]!
                .where((s) {
                  final origId = s['original_id']?.toString() ?? '';
                  // همیشه از آخرین وضعیت در subFieldStatuses استفاده کن
                  final currentStatus =
                      subFieldStatuses.containsKey(origId)
                          ? subFieldStatuses[origId]
                          : s['approval_status'];

                  return currentStatus == selectedStatus;
                })
                .map((item) {
                  // کپی آیتم با وضعیت آپدیت شده
                  var newItem = Map<String, dynamic>.from(item);
                  final origId = newItem['original_id']?.toString() ?? '';
                  if (subFieldStatuses.containsKey(origId)) {
                    newItem['approval_status'] = subFieldStatuses[origId];
                  }
                  return newItem;
                })
                .toList();

        if (matchingSubItems.isNotEmpty) {
          final newId = filteredData.length + 1;

          filteredData.add({
            'id': newId,
            'date': item['date'],
            'number': item['number'],
            'customer': item['customer'],
            'issuer': item['issuer'],
          });

          subData[newId] = matchingSubItems;
        }
      }
    }

    // اعمال فیلترهای متنی
    if (_numberFilterController.text.isNotEmpty) {
      filteredData =
          filteredData
              .where(
                (item) => item['number'].toString().contains(
                  _numberFilterController.text,
                ),
              )
              .toList();
    }

    if (_customerFilterController.text.isNotEmpty) {
      filteredData =
          filteredData
              .where(
                (item) => item['customer'].toString().toLowerCase().contains(
                  _customerFilterController.text.toLowerCase(),
                ),
              )
              .toList();
    }

    if (_issuerFilterController.text.isNotEmpty) {
      filteredData =
          filteredData
              .where(
                (item) => item['issuer'].toString().toLowerCase().contains(
                  _issuerFilterController.text.toLowerCase(),
                ),
              )
              .toList();
    }

    if (_keywordsController.text.isNotEmpty) {
      final key = _keywordsController.text.trim().toLowerCase();
      filteredData =
          filteredData.where((item) {
            final combo =
                '${item['number']} ${item['customer']} ${item['issuer']}'
                    .toLowerCase();
            return combo.contains(key);
          }).toList();
    }
  }

  void _applyFilters() {
    setState(() {
      _applyFiltersWithoutSetState();
      if (sortColumnIndex != null) {
        _applySortMainWithoutSetState(sortColumnIndex!, isAscending);
      }
    });
  }

  void _applySortMainWithoutSetState(int columnIndex, bool asc) {
    filteredData.sort((a, b) {
      dynamic av, bv;

      switch (columnIndex) {
        case 0:
          av = _persianDateToComparable(a['date']);
          bv = _persianDateToComparable(b['date']);
          break;
        case 1:
          av = int.tryParse(a['number']) ?? 0;
          bv = int.tryParse(b['number']) ?? 0;
          break;
        default:
          av = a.values.elementAt(columnIndex).toString();
          bv = b.values.elementAt(columnIndex).toString();
      }

      int c =
          (av is int)
              ? av.compareTo(bv)
              : av.toString().compareTo(bv.toString());
      return asc ? c : -c;
    });
  }

  void _sortMainTable(int col) {
    setState(() {
      if (sortColumnIndex == col) {
        isAscending = !isAscending;
      } else {
        sortColumnIndex = col;
        isAscending = true;
      }
      _applySortMainWithoutSetState(col, isAscending);
    });
  }

  void _sortSubTable(int parentId, int col) {
    setState(() {
      if (subSortColumnIndex[parentId] == col) {
        subIsAscending[parentId] = !(subIsAscending[parentId] ?? true);
      } else {
        subSortColumnIndex[parentId] = col;
        subIsAscending[parentId] = true;
      }

      final asc = subIsAscending[parentId] ?? true;

      subData[parentId]!.sort((a, b) {
        dynamic av, bv;

        switch (col) {
          case 0:
            av = _persianDateToComparable(a['request_date']);
            bv = _persianDateToComparable(b['request_date']);
            break;
          case 3:
          case 4:
            av = a[col == 3 ? 'current_price' : 'requested_price'];
            bv = b[col == 3 ? 'current_price' : 'requested_price'];
            break;
          case 5:
            final aOrig = a['original_id']?.toString() ?? '';
            final bOrig = b['original_id']?.toString() ?? '';
            av = subFieldStatuses[aOrig] ?? a['approval_status'];
            bv = subFieldStatuses[bOrig] ?? b['approval_status'];
            break;
          default:
            av = a.values.elementAt(col).toString();
            bv = b.values.elementAt(col).toString();
        }

        final c =
            (av is int)
                ? av.compareTo(bv)
                : av.toString().compareTo(bv.toString());
        return asc ? c : -c;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.primaryGreen,
          appBar: _buildAppBar(),
          body: _buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryGreen,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: _isDesktopOrWeb ? [_buildExportMenuButton()] : null,
      title: Row(
        children: [
          DateFieldWidget(
            text: 'از: $fromDate',
            onTap: () => _selectDate(true),
          ),
          const SizedBox(width: 6),
          DateFieldWidget(text: 'تا: $toDate', onTap: () => _selectDate(false)),
          const SizedBox(width: 6),
          FilterButtonWidget(onTap: _showAdvancedFilterDialog),
          const SizedBox(width: 6),
          StatusDropdownWidget(
            selectedStatus: selectedStatus,
            statusOptions: statusOptions,
            onChanged: (v) {
              if (v != null) {
                setState(() {
                  selectedStatus = v;
                  _applyFilters();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  /// بررسی آیا پلتفرم دسکتاپ یا وب است
  bool get _isDesktopOrWeb {
    if (kIsWeb) return true;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  /// دکمه منوی خروجی (PDF, Excel, Print)
  Widget _buildExportMenuButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      tooltip: 'خروجی',
      onSelected: (value) {
        switch (value) {
          case 'pdf':
            _exportToPdf();
            break;
          case 'excel':
            _exportToExcel();
            break;
          case 'print':
            _printData();
            break;
        }
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'pdf',
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.red),
                  SizedBox(width: 8),
                  Text('خروجی PDF'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'excel',
              child: Row(
                children: [
                  Icon(Icons.table_chart, color: Colors.green),
                  SizedBox(width: 8),
                  Text('خروجی Excel'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'print',
              child: Row(
                children: [
                  Icon(Icons.print, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('پرینت'),
                ],
              ),
            ),
          ],
    );
  }

  /// آماده‌سازی داده‌های خروجی (مشترک برای PDF و Excel)
  List<List<String>> _prepareExportData() {
    final List<List<String>> allRows = [];

    for (var parent in filteredData) {
      final parentId = parent['id'];
      final children = subData[parentId] ?? [];

      if (children.isEmpty) {
        // اگر فرزند نداشت، فقط اطلاعات پدر را اضافه کن
        allRows.add([
          parent['date']?.toString() ?? '',
          parent['number']?.toString() ?? '',
          parent['customer']?.toString() ?? '',
          parent['issuer']?.toString() ?? '',
          '',
          '',
          '',
          '',
          '',
          '',
        ]);
      } else {
        for (var child in children) {
          allRows.add([
            parent['date']?.toString() ?? '',
            parent['number']?.toString() ?? '',
            parent['customer']?.toString() ?? '',
            parent['issuer']?.toString() ?? '',
            child['request_date']?.toString() ?? '',
            child['product_name']?.toString() ?? '',
            child['request_type']?.toString() ?? '',
            _formatNumber(child['current_price']),
            _formatNumber(child['requested_price']),
            child['approval_status']?.toString() ?? '',
          ]);
        }
      }
    }

    return allRows;
  }

  /// خروجی PDF
  Future<void> _exportToPdf() async {
    final allRows = _prepareExportData();

    if (allRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('داده‌ای برای خروجی وجود ندارد')),
      );
      return;
    }

    await PrintService.exportPdf(
      context: context,
      fileName: 'price_management_${DateTime.now().millisecondsSinceEpoch}',
      pdfBuilder: (format) async {
        final pdf = pw.Document();

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4.landscape,
            textDirection: pw.TextDirection.rtl,
            margin: const pw.EdgeInsets.all(20),
            build:
                (context) => [
                  pw.Center(
                    child: pw.Text(
                      'گزارش مدیریت بهای تمام شده',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textDirection: pw.TextDirection.rtl,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Center(
                    child: pw.Text(
                      'از تاریخ: $fromDate  تا تاریخ: $toDate',
                      style: const pw.TextStyle(fontSize: 10),
                      textDirection: pw.TextDirection.rtl,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Table.fromTextArray(
                    cellAlignment: pw.Alignment.center,
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    cellStyle: const pw.TextStyle(fontSize: 7),
                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    headers: [
                      'تاریخ سفارش',
                      'شماره سفارش',
                      'مشتری',
                      'صادرکننده',
                      'تاریخ درخواست',
                      'نام کالا',
                      'نوع درخواست',
                      'قیمت فعلی',
                      'قیمت درخواستی',
                      'وضعیت',
                    ],
                    data: allRows,
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1.2),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1.5),
                      3: const pw.FlexColumnWidth(1.3),
                      4: const pw.FlexColumnWidth(1.2),
                      5: const pw.FlexColumnWidth(2),
                      6: const pw.FlexColumnWidth(1),
                      7: const pw.FlexColumnWidth(1.2),
                      8: const pw.FlexColumnWidth(1.2),
                      9: const pw.FlexColumnWidth(1),
                    },
                  ),
                ],
          ),
        );

        return pdf.save();
      },
    );
  }

  /// خروجی Excel
  Future<void> _exportToExcel() async {
    final allRows = _prepareExportData();

    if (allRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('داده‌ای برای خروجی وجود ندارد')),
      );
      return;
    }

    final columns = [
      'تاریخ سفارش',
      'شماره سفارش',
      'مشتری',
      'صادرکننده',
      'تاریخ درخواست',
      'نام کالا',
      'نوع درخواست',
      'قیمت فعلی',
      'قیمت درخواستی',
      'وضعیت',
    ];

    await PrintService.downloadExcel(
      context: context,
      columns: columns,
      rows: allRows,
      fileName: 'price_management_${DateTime.now().millisecondsSinceEpoch}',
      sheetName: 'مدیریت بها',
    );
  }

  /// فرمت کردن اعداد با جداکننده هزارگان
  String _formatNumber(dynamic value) {
    if (value == null) return '';
    final num = int.tryParse(value.toString()) ?? 0;
    return num.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// پرینت
  Future<void> _printData() async {
    final allRows = _prepareExportData();

    if (allRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('داده‌ای برای پرینت وجود ندارد')),
      );
      return;
    }

    await PrintService.printPdf(context, (format) async {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          textDirection: pw.TextDirection.rtl,
          margin: const pw.EdgeInsets.all(20),
          build:
              (context) => [
                pw.Center(
                  child: pw.Text(
                    'گزارش مدیریت بهای تمام شده',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textDirection: pw.TextDirection.rtl,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Text(
                    'از تاریخ: $fromDate  تا تاریخ: $toDate',
                    style: const pw.TextStyle(fontSize: 10),
                    textDirection: pw.TextDirection.rtl,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Table.fromTextArray(
                  cellAlignment: pw.Alignment.center,
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 8,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 7),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  headers: [
                    'تاریخ سفارش',
                    'شماره سفارش',
                    'مشتری',
                    'صادرکننده',
                    'تاریخ درخواست',
                    'نام کالا',
                    'نوع درخواست',
                    'قیمت فعلی',
                    'قیمت درخواستی',
                    'وضعیت',
                  ],
                  data: allRows,
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1.2),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(1.3),
                    4: const pw.FlexColumnWidth(1.2),
                    5: const pw.FlexColumnWidth(2),
                    6: const pw.FlexColumnWidth(1),
                    7: const pw.FlexColumnWidth(1.2),
                    8: const pw.FlexColumnWidth(1.2),
                    9: const pw.FlexColumnWidth(1),
                  },
                ),
              ],
        ),
      );

      return pdf.save();
    }, fileName: 'price_management_print');
  }

  Widget _buildBody() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: BlocListener<PriceManagementBloc, PriceManagementState>(
        listener: (context, state) {
          if (state is PriceManagementLoaded) {
            setState(() {
              _convertApiDataToUIFormat(state.groupedByOrder);
            });
          }
        },
        child: BlocBuilder<PriceManagementBloc, PriceManagementState>(
          buildWhen: (previous, current) {
            return false;
          },
          builder: (context, state) {
            return Column(
              children: [
                TableHeaderWidget(
                  sortColumnIndex: sortColumnIndex,
                  isAscending: isAscending,
                  onSort: _sortMainTable,
                ),
                Expanded(
                  child:
                      filteredData.isEmpty
                          ? const Center(child: Text('داده‌ای یافت نشد'))
                          : ListView.builder(
                            itemCount: filteredData.length,
                            itemBuilder: (context, index) {
                              final item = filteredData[index];
                              final id = item['id'];
                              final expanded = expandedRows.contains(id);

                              return Column(
                                children: [
                                  TableRowWidget(
                                    item: item,
                                    isExpanded: expanded,
                                    onTap: () {
                                      setState(() {
                                        expanded
                                            ? expandedRows.remove(id)
                                            : expandedRows.add(id);
                                      });
                                    },
                                  ),
                                  if (expanded && subData.containsKey(id))
                                    SubTableWidget(
                                      parentId: id,
                                      subItems: subData[id]!,
                                      subFieldStatuses: subFieldStatuses,
                                      statusOptions: statusOptions,
                                      sortColumnIndex: subSortColumnIndex[id],
                                      isAscending: subIsAscending[id] ?? true,
                                      onSort: (c) => _sortSubTable(id, c),
                                      onStatusChange: (subId, status) {
                                        // آپدیت وضعیت در subFieldStatuses
                                        subFieldStatuses[subId] = status;

                                        // آپدیت وضعیت در originalSubData
                                        originalSubData.forEach((key, items) {
                                          for (var item in items) {
                                            if (item['original_id']
                                                    ?.toString() ==
                                                subId) {
                                              item['approval_status'] = status;
                                            }
                                          }
                                        });

                                        // آپدیت وضعیت در subData فعلی
                                        subData.forEach((key, items) {
                                          for (var item in items) {
                                            if (item['original_id']
                                                    ?.toString() ==
                                                subId) {
                                              item['approval_status'] = status;
                                            }
                                          }
                                        });

                                        int statusCode = 1;
                                        if (status == 'تایید شده') {
                                          statusCode = 2;
                                        }
                                        if (status == 'رد شده') statusCode = 3;

                                        _bloc.add(
                                          UpdatePriceRequestStatusEvent(
                                            requestId: subId,
                                            newStatus: statusCode,
                                          ),
                                        );

                                        setState(() {
                                          _applyFilters();
                                        });
                                      },
                                    ),
                                  const SizedBox(height: 8),
                                ],
                              );
                            },
                          ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isFrom) async {
    final selected = await PersianDatePickerDialog.show(
      context,
      isFrom ? fromDate : toDate,
    );
    if (selected != null) {
      setState(() {
        if (isFrom) {
          fromDate = selected;
        } else {
          toDate = selected;
        }
        _loadData();
      });
    }
  }

  void _showAdvancedFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AdvancedFilterDialog(
            numberController: _numberFilterController,
            customerController: _customerFilterController,
            issuerController: _issuerFilterController,
            keywordsController: _keywordsController,
            initialSearchMode: 'AND',
            onApply: (searchMode) {
              _applyFilters();
            },
            onClear: () {
              _numberFilterController.clear();
              _customerFilterController.clear();
              _issuerFilterController.clear();
              _keywordsController.clear();
              _applyFilters();
            },
          ),
    );
  }
}
