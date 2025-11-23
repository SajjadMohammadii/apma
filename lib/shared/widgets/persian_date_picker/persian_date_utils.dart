import 'package:shamsi_date/shamsi_date.dart';

class PersianDateUtils {
  /// تبدیل تاریخ رشته‌ای به Jalali
  static Jalali? parseDate(String dateStr) {
    try {
      List<String> parts = dateStr.split('/');
      return Jalali(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (e) {
      return null;
    }
  }

  /// فرمت کردن تاریخ به رشته
  static String formatDate(Jalali date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  /// بررسی اینکه آیا تاریخ در محدوده است یا نه
  static bool isDateInRange(String dateStr, String fromStr, String toStr) {
    try {
      List<String> dateParts = dateStr.split('/');
      List<String> fromParts = fromStr.split('/');
      List<String> toParts = toStr.split('/');

      int dateInt =
          int.parse(dateParts[0]) * 10000 +
          int.parse(dateParts[1]) * 100 +
          int.parse(dateParts[2]);
      int fromInt =
          int.parse(fromParts[0]) * 10000 +
          int.parse(fromParts[1]) * 100 +
          int.parse(fromParts[2]);
      int toInt =
          int.parse(toParts[0]) * 10000 +
          int.parse(toParts[1]) * 100 +
          int.parse(toParts[2]);

      return dateInt >= fromInt && dateInt <= toInt;
    } catch (e) {
      return true;
    }
  }

  /// گرفتن تاریخ امروز
  static String today() {
    final now = Jalali.now();
    return formatDate(now);
  }

  /// گرفتن اول ماه جاری
  static String startOfMonth() {
    final now = Jalali.now();
    return formatDate(Jalali(now.year, now.month, 1));
  }

  /// گرفتن آخر ماه جاری
  static String endOfMonth() {
    final now = Jalali.now();
    final daysInMonth = now.monthLength;
    return formatDate(Jalali(now.year, now.month, daysInMonth));
  }

  /// تبدیل تاریخ میلادی به شمسی
  static String gregorianToJalali(String? gregorianDate) {
    if (gregorianDate == null || gregorianDate.isEmpty) {
      return '';
    }

    try {
      final parts = gregorianDate.split('-');
      if (parts.length != 3) {
        return gregorianDate;
      }

      final gy = int.parse(parts[0]);
      final gm = int.parse(parts[1]);
      final gd = int.parse(parts[2]);

      final gregorian = Gregorian(gy, gm, gd);
      final jalali = gregorian.toJalali();

      return formatDate(jalali);
    } catch (e) {
      return gregorianDate;
    }
  }
}
