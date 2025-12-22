// utils/date_converter.dart
import 'package:intl/intl.dart';

class DateConverter {
  /// تبدیل تاریخ از فرمت "20220614" به DateTime
  static DateTime? parseApiDate(String apiDate) {
    try {
      if (apiDate.isEmpty || apiDate == 'NULL') return null;

      // فرمت: YYYYMMDD
      final year = int.parse(apiDate.substring(0, 4));
      final month = int.parse(apiDate.substring(4, 6));
      final day = int.parse(apiDate.substring(6, 8));

      return DateTime(year, month, day);
    } catch (e) {
      print('خطا در تبدیل تاریخ: $e');
      return null;
    }
  }

  /// تبدیل تاریخ به رشته فارسی
  static String toPersianDate(DateTime date) {
    final persianDate = DateFormat.yMMMMEEEEd('fa_IR').format(date);
    return persianDate;
  }

  /// استخراج ساعت از تاریخ
  static String extractTime(DateTime date) {
    return DateFormat.Hm('fa_IR').format(date);
  }

  /// تبدیل تاریخ API به متن فارسی کامل
  static String convertApiDateToPersian(String apiDate) {
    final date = parseApiDate(apiDate);
    if (date == null) return 'تاریخ نامعتبر';

    final persianDate = toPersianDate(date);
    final time = extractTime(date);

    return '$persianDate - ساعت $time';
  }

  /// فقط تاریخ فارسی بدون ساعت
  static String convertApiDateToPersianDateOnly(String apiDate) {
    final date = parseApiDate(apiDate);
    if (date == null) return 'تاریخ نامعتبر';

    return DateFormat.yMMMMd('fa_IR').format(date);
  }

  /// فقط ساعت از تاریخ API
  static String extractTimeFromApiDate(String apiDate) {
    final date = parseApiDate(apiDate);
    if (date == null) return '--:--';

    return extractTime(date);
  }
}