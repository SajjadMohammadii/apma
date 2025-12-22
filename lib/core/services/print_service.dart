// سرویس پرینت و خروجی PDF/Excel
// مرتبط با: price_management_page.dart, delivery_parcels.dart

import 'dart:io'; // کتابخانه کار با فایل‌ها
// کتابخانه داده‌های باینری
import 'dart:ui'; // کتابخانه UI
import 'package:excel/excel.dart'; // کتابخانه ساخت فایل Excel
import 'package:flutter/foundation.dart'; // ابزارهای پایه فلاتر
import 'package:flutter/material.dart'; // ویجت‌های متریال
import 'package:flutter/rendering.dart'; // رندرینگ ویجت‌ها
import 'package:pdf/pdf.dart'; // کتابخانه PDF
import 'package:pdf/widgets.dart' as pw; // ویجت‌های PDF
import 'package:printing/printing.dart'; // کتابخانه پرینت
import 'package:share_plus/share_plus.dart'; // کتابخانه اشتراک‌گذاری
import 'package:path_provider/path_provider.dart'; // دسترسی به مسیر فایل‌ها
import 'dart:developer' as developer; // ابزار لاگ‌گیری

// کلاس PrintService - سرویس پرینت و خروجی فایل
class PrintService {
  /// متغیر استاتیک _captureKey - کلید عمومی برای کپچر ویجت (فقط موبایل)
  static final GlobalKey _captureKey = GlobalKey();
  // getter برای دسترسی به captureKey
  static GlobalKey get captureKey => _captureKey;

  /// getter _isDesktop - بررسی اینکه پلتفرم دسکتاپ است یا نه
  static bool get _isDesktop {
    if (kIsWeb) return false; // اگر وب است، دسکتاپ نیست
    return Platform.isLinux ||
        Platform.isWindows ||
        Platform.isMacOS; // بررسی سیستم‌عامل‌های دسکتاپ
  }

  // -----------------------------
  //  متد printWidget - پرینت از ویجت (فقط موبایل)
  // -----------------------------
  static Future<void> printWidget({required String fileName}) async {
    try {
      developer.log(' شروع پرینت ویجت');

      // در دسکتاپ از capture استفاده نکن
      if (_isDesktop) {
        developer.log(
          ' printWidget در دسکتاپ پشتیبانی نمی‌شود. از printPdf استفاده کنید.',
        );
        return;
      }

      final imageBytes = await _captureRenderedWidget(); // کپچر ویجت به تصویر

      // ساخت سند PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4, // فرمت صفحه A4
          build:
              (_) => pw.Center(
                child: pw.Image(pw.MemoryImage(imageBytes)),
              ), // قرار دادن تصویر در مرکز
        ),
      );

      await Printing.layoutPdf(
        name: fileName,
        onLayout: (_) => pdf.save(),
      ); // اجرای پرینت

      developer.log(' پرینت ویجت موفق');
    } catch (e) {
      developer.log(' خطا در پرینت ویجت: $e');
    }
  }

  // -----------------------------
  // متد printPdf - ساخت PDF سفارشی و پرینت/ذخیره
  // -----------------------------
  static Future<void> printPdf(
    BuildContext context, // کانتکست برای نمایش پیام‌ها
    Future<Uint8List> Function(PdfPageFormat format)
    pdfBuilder, { // تابع ساخت PDF
    String? fileName, // نام فایل (اختیاری)
  }) async {
    try {
      developer.log("📄 شروع ساخت PDF");

      await Printing.layoutPdf(
        name:
            fileName ??
            "custom_pdf_${DateTime.now().millisecondsSinceEpoch}", // نام فایل با timestamp
        onLayout: pdfBuilder, // تابع ساخت محتوای PDF
      );

      developer.log(" PDF موفق");
    } catch (e) {
      developer.log(" خطا در ساخت PDF: $e");
    }
  }

  // -----------------------------
  // 📄 متد exportPdf - خروجی PDF (share/save)
  // -----------------------------
  static Future<void> exportPdf({
    required BuildContext context, // کانتکست
    required Future<Uint8List> Function(PdfPageFormat format)
    pdfBuilder, // تابع ساخت PDF
    required String fileName, // نام فایل
  }) async {
    try {
      developer.log("📄 شروع خروجی PDF");

      final pdfBytes = await pdfBuilder(
        PdfPageFormat.a4.landscape,
      ); // ساخت PDF با فرمت افقی

      // --- Desktop: ذخیره مستقیم ---
      if (_isDesktop) {
        final directory =
            await getApplicationDocumentsDirectory(); // دریافت مسیر Documents
        final path = "${directory.path}/$fileName.pdf"; // مسیر کامل فایل

        final file = File(path);
        await file.writeAsBytes(pdfBytes); // نوشتن فایل

        developer.log("✔ فایل PDF ذخیره شد در: $path");

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فایل ذخیره شد: $path')),
          ); // نمایش پیام موفقیت
        }
        return;
      }

      // --- Mobile/Web: share ---
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '$fileName.pdf',
      ); // اشتراک‌گذاری PDF

      developer.log(" خروجی PDF موفق");
    } catch (e) {
      developer.log(" خطا در خروجی PDF: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در ایجاد PDF: $e')),
        ); // نمایش پیام خطا
      }
    }
  }

  // متد exportExcel - ساخت فایل Excel از داده‌ها
  static Future<Uint8List> exportExcel({
    required List<String> columns, // لیست نام ستون‌ها
    required List<List<dynamic>> rows, // لیست ردیف‌های داده
    String? sheetName, // نام شیت (اختیاری)
  }) async {
    try {
      developer.log("📊 ساخت Excel...");
      developer.log("📊 تعداد ستون‌ها: ${columns.length}");
      developer.log("📊 تعداد ردیف‌ها: ${rows.length}");

      final excel = Excel.createExcel(); // ساخت فایل Excel جدید
      final String sheet = sheetName ?? "Sheet1"; // نام شیت پیش‌فرض

      // استفاده از شیت موجود
      final sheetObj = excel[sheet];

      // اگر شیت پیش‌فرض متفاوت است، حذفش کن
      if (sheet != "Sheet1" && excel.tables.containsKey("Sheet1")) {
        excel.delete('Sheet1');
      }

      // افزودن ستون‌ها (هدر جدول)
      sheetObj.appendRow(
        columns.map((col) => TextCellValue(col.toString())).toList(),
      );

      // افزودن ردیف‌های داده
      for (var row in rows) {
        sheetObj.appendRow(
          row.map((cell) => TextCellValue(cell.toString())).toList(),
        );
      }

      final bytes = excel.encode(); // تبدیل به بایت‌ها
      if (bytes == null) {
        throw Exception('خطا در encode کردن Excel');
      }

      developer.log(" خروجی Excel موفق - سایز: ${bytes.length} bytes");

      return Uint8List.fromList(bytes);
    } catch (e) {
      developer.log(" خطا در ساخت Excel: $e");
      rethrow;
    }
  }

  // -----------------------------
  // 📊 متد downloadExcel - خروجی Excel (share/save)
  // -----------------------------
  static Future<void> downloadExcel({
    required BuildContext context, // کانتکست
    required List<String> columns, // ستون‌ها
    required List<List<dynamic>> rows, // ردیف‌ها
    required String fileName, // نام فایل
    String? sheetName, // نام شیت (اختیاری)
  }) async {
    try {
      developer.log("📊 شروع دانلود Excel");
      developer.log("📊 تعداد ردیف‌ها: ${rows.length}");

      // بررسی وجود داده
      if (rows.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('داده‌ای برای خروجی وجود ندارد')),
          );
        }
        return;
      }

      final excelBytes = await exportExcel(
        columns: columns,
        rows: rows,
        sheetName: sheetName,
      );

      // --- Desktop: ذخیره مستقیم ---
      if (_isDesktop) {
        final directory = await getApplicationDocumentsDirectory();
        final path = "${directory.path}/$fileName.xlsx";

        final file = File(path);
        await file.writeAsBytes(excelBytes);

        developer.log("✔ فایل Excel ذخیره شد در: $path");

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('فایل ذخیره شد: $path')));
        }
        return;
      }

      // --- Mobile/Web: share ---
      await Share.shareXFiles([
        XFile.fromData(
          excelBytes,
          name: '$fileName.xlsx',
          mimeType:
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', // نوع MIME فایل Excel
        ),
      ], subject: fileName);

      developer.log(" دانلود Excel موفق");
    } catch (e) {
      developer.log(" خطا در دانلود Excel: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا در ایجاد Excel: $e')));
      }
    }
  }

  // متد خصوصی _captureRenderedWidget - کپچر ویجت رندر شده به تصویر
  static Future<Uint8List> _captureRenderedWidget() async {
    try {
      // یافتن RenderRepaintBoundary از context
      final boundary =
          _captureKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      await Future.delayed(
        const Duration(milliseconds: 50),
      ); // تاخیر برای رندر کامل

      final image = await boundary.toImage(
        pixelRatio: 3.0,
      ); // تبدیل به تصویر با کیفیت بالا
      final byteData = await image.toByteData(
        format: ImageByteFormat.png,
      ); // تبدیل به بایت‌های PNG

      return byteData!.buffer.asUint8List();
    } catch (e) {
      developer.log(" خطا در کپچر ویجت: $e");
      rethrow;
    }
  }
}
