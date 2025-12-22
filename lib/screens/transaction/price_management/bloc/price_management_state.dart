// وضعیت‌های بلاک مدیریت بها
// مرتبط با: price_management_bloc.dart, price_management_page.dart

import 'package:apma_app/screens/transaction/price_management/models/price_request_model.dart'; // مدل درخواست

// کلاس انتزاعی PriceManagementState - کلاس پایه وضعیت‌ها
abstract class PriceManagementState {
  const PriceManagementState();
}

// کلاس PriceManagementInitial - وضعیت اولیه
class PriceManagementInitial extends PriceManagementState {
  const PriceManagementInitial();
}

// کلاس PriceManagementLoading - وضعیت در حال بارگذاری
class PriceManagementLoading extends PriceManagementState {
  const PriceManagementLoading();
}

// کلاس PriceManagementLoaded - وضعیت بارگذاری شده
class PriceManagementLoaded extends PriceManagementState {
  final List<PriceRequestModel> requests; // لیست درخواست‌ها
  final Map<String, List<PriceRequestModel>> groupedByOrder; // گروه‌بندی شده
  final bool hasChanges; // آیا تغییرات ذخیره نشده دارد
  final List<String> changedIds; // لیست شناسه‌های تغییر یافته

  // سازنده
  const PriceManagementLoaded({
    required this.requests,
    required this.groupedByOrder,
    this.hasChanges = false,
    this.changedIds = const [],
  });

  // getter برای داده‌های فیلتر شده
  Map<String, List<PriceRequestModel>> get filteredGroupedByOrder =>
      groupedByOrder;

  // متد copyWith - ایجاد کپی با مقادیر جدید
  PriceManagementLoaded copyWith({
    List<PriceRequestModel>? requests,
    Map<String, List<PriceRequestModel>>? groupedByOrder,
    bool? hasChanges,
    List<String>? changedIds,
  }) {
    return PriceManagementLoaded(
      requests: requests ?? this.requests,
      groupedByOrder: groupedByOrder ?? this.groupedByOrder,
      hasChanges: hasChanges ?? this.hasChanges,
      changedIds: changedIds ?? this.changedIds,
    );
  }
}

// کلاس PriceManagementError - وضعیت خطا
class PriceManagementError extends PriceManagementState {
  final String message; // پیام خطا

  const PriceManagementError({required this.message});
}

// کلاس PriceManagementSaved - وضعیت ذخیره موفق
class PriceManagementSaved extends PriceManagementState {
  final String message; // پیام موفقیت

  const PriceManagementSaved({this.message = 'تغییرات با موفقیت ذخیره شد'});
}
