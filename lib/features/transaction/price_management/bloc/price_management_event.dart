// رویدادهای بلاک مدیریت بها
// مرتبط با: price_management_bloc.dart, price_management_page.dart

// کلاس انتزاعی PriceManagementEvent - کلاس پایه رویدادها
abstract class PriceManagementEvent {
  const PriceManagementEvent();
}

// کلاس LoadPriceRequestsEvent - رویداد بارگذاری درخواست‌ها
class LoadPriceRequestsEvent extends PriceManagementEvent {
  final String? fromDate; // تاریخ شروع
  final String? toDate; // تاریخ پایان
  final int status; // وضعیت (۰=همه)
  final String criteria; // کلمات کلیدی جستجو

  // سازنده با مقادیر پیش‌فرض
  const LoadPriceRequestsEvent({
    this.fromDate,
    this.toDate,
    this.status = 0,
    this.criteria = '',
  });
}

// کلاس UpdatePriceRequestStatusEvent - رویداد به‌روزرسانی وضعیت
class UpdatePriceRequestStatusEvent extends PriceManagementEvent {
  final String requestId; // شناسه درخواست
  final int newStatus; // وضعیت جدید (۱=در حال بررسی، ۲=تایید، ۳=رد)

  // سازنده
  const UpdatePriceRequestStatusEvent({
    required this.requestId,
    required this.newStatus,
  });
}

// کلاس SaveChangesEvent - رویداد ذخیره تغییرات
class SaveChangesEvent extends PriceManagementEvent {
  const SaveChangesEvent();
}

// کلاس RefreshPriceRequestsEvent - رویداد بازخوانی
class RefreshPriceRequestsEvent extends PriceManagementEvent {
  const RefreshPriceRequestsEvent();
}
