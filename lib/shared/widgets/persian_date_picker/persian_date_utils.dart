import 'package:shamsi_date/shamsi_date.dart';

/// یک کلاس کمکی (Utility) برای کار با تاریخ شمسی
class PersianDateUtils {
  /// متد تبدیل رشته تاریخ به آبجکت تاریخ شمسی Jalali
  ///
  /// ورودی: تاریخ به فرمت `yyyy/mm/dd`
  /// خروجی: آبجکت Jalali یا null اگر فرمت اشتباه باشد
  static Jalali? parseDate(String dateStr) {
    try {
      // جدا کردن سال/ماه/روز بر اساس "/"
      List<String> parts = dateStr.split('/');

      // تبدیل رشته‌ها به عدد و ساخت تاریخ جلالی
      return Jalali(
        int.parse(parts[0]), // سال
        int.parse(parts[1]), // ماه
        int.parse(parts[2]), // روز
      );
    } catch (e) {
      // در صورت خطا، مقدار null برمی‌گرداند
      return null;
    }
  }

  /// فرمت کردن یک تاریخ جلالی به رشته `yyyy/mm/dd`
  static String formatDate(Jalali date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  /// بررسی اینکه آیا یک تاریخ داخل بازه‌ی مشخص قرار دارد یا نه
  ///
  /// ورودی:
  /// - dateStr → تاریخی که باید بررسی شود
  /// - fromStr → شروع بازه
  /// - toStr → پایان بازه
  ///
  /// خروجی: true اگر بین بازه باشد، false اگر نباشد
  static bool isDateInRange(String dateStr, String fromStr, String toStr) {
    try {
      // تبدیل تاریخ‌ها به لیست رشته‌ای
      List<String> dateParts = dateStr.split('/');
      List<String> fromParts = fromStr.split('/');
      List<String> toParts = toStr.split('/');

      // تبدیل تاریخ به عدد برای مقایسه ساده
      // مثال: 1403/11/05 → 14031105
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

      // بررسی قرار گرفتن تاریخ بین شروع و پایان
      return dateInt >= fromInt && dateInt <= toInt;
    } catch (e) {
      // اگر خطا رخ بدهد، بهتر است true برگردانده شود تا فیلتر خللی ایجاد نکند
      return true;
    }
  }

  /// گرفتن تاریخ امروز (به صورت رشته)
  ///
  /// خروجی: تاریخ امروز به فرمت `yyyy/mm/dd`
  static String today() {
    final now = Jalali.now();
    return formatDate(now);
  }

  /// گرفتن اولین روز ماه جاری
  static String startOfMonth() {
    final now = Jalali.now();
    // روز اول همان ماه
    return formatDate(Jalali(now.year, now.month, 1));
  }

  /// گرفتن آخرین روز ماه جاری
  static String endOfMonth() {
    final now = Jalali.now();
    final daysInMonth = now.monthLength; // تعداد روزهای ماه
    return formatDate(Jalali(now.year, now.month, daysInMonth));
  }

  /// تبدیل تاریخ میلادی (gregorian) به تاریخ شمسی (jalali)
  ///
  /// ورودی: تاریخ میلادی `YYYY-MM-DD`
  /// خروجی: تاریخ شمسی `YYYY/MM/DD`
  static String gregorianToJalali(String? gregorianDate) {
    // اگر مقدار خالی یا null باشد
    if (gregorianDate == null || gregorianDate.isEmpty) {
      return '';
    }

    try {
      // جدا کردن سال، ماه، روز
      final parts = gregorianDate.split('-');

      // اگر فرمت درست نبود همان مقدار اولیه برگردد
      if (parts.length != 3) {
        return gregorianDate;
      }

      final gy = int.parse(parts[0]);
      final gm = int.parse(parts[1]);
      final gd = int.parse(parts[2]);

      // ساخت یک تاریخ میلادی
      final gregorian = Gregorian(gy, gm, gd);

      // تبدیل میلادی به شمسی
      final jalali = gregorian.toJalali();

      // خروجی استاندارد شده
      return formatDate(jalali);
    } catch (e) {
      // در صورت خطا همان تاریخ ورودی بازگردانده شود
      return gregorianDate;
    }
  }
}
