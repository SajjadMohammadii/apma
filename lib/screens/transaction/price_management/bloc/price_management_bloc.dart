// بلاک مدیریت بها - مدیریت state و منطق کسب‌وکار
// مرتبط با: price_management_page.dart, price_request_service.dart

import 'dart:developer' as developer; // ابزار لاگ‌گیری
import 'package:flutter_bloc/flutter_bloc.dart'; // کتابخانه BLoC
import 'package:apma_app/screens/transaction/price_management/bloc/price_management_event.dart'; // رویدادها
import 'package:apma_app/screens/transaction/price_management/bloc/price_management_state.dart'; // وضعیت‌ها
import 'package:apma_app/screens/transaction/price_management/services/price_request_service.dart'; // سرویس

// کلاس PriceManagementBloc - بلاک مدیریت درخواست‌های قیمت
class PriceManagementBloc
    extends Bloc<PriceManagementEvent, PriceManagementState> {
  final PriceRequestService priceRequestService; // سرویس درخواست قیمت

  // سازنده - ثبت هندلرهای رویداد
  PriceManagementBloc({required this.priceRequestService})
    : super(const PriceManagementInitial()) {
    on<LoadPriceRequestsEvent>(_onLoadPriceRequests); // بارگذاری درخواست‌ها
    on<UpdatePriceRequestStatusEvent>(
      _onUpdatePriceRequestStatus,
    ); // به‌روزرسانی وضعیت
    on<SaveChangesEvent>(_onSaveChanges); // ذخیره تغییرات
    on<RefreshPriceRequestsEvent>(_onRefreshPriceRequests); // بازخوانی
  }

  // هندلر _onLoadPriceRequests - بارگذاری درخواست‌های قیمت
  Future<void> _onLoadPriceRequests(
    LoadPriceRequestsEvent event,
    Emitter<PriceManagementState> emit,
  ) async {
    try {
      emit(const PriceManagementLoading()); // نمایش لودینگ

      // دریافت لیست درخواست‌ها از سرویس
      final requests = await priceRequestService.loadPriceChangeRequestsList(
        fromDate: event.fromDate,
        toDate: event.toDate,
        status: event.status,
        criteria: event.criteria,
      );

      // گروه‌بندی بر اساس شماره سفارش
      final grouped = priceRequestService.groupByOrderNumber(requests);

      // ارسال وضعیت بارگذاری شده
      emit(
        PriceManagementLoaded(
          requests: requests,
          groupedByOrder: grouped,
          hasChanges: false,
          changedIds: [],
        ),
      );
    } catch (e) {
      developer.log(' Bloc خطا: $e');
      emit(PriceManagementError(message: e.toString())); // ارسال خطا
    }
  }

  // هندلر _onUpdatePriceRequestStatus - به‌روزرسانی وضعیت یک درخواست
  Future<void> _onUpdatePriceRequestStatus(
    UpdatePriceRequestStatusEvent event,
    Emitter<PriceManagementState> emit,
  ) async {
    if (state is! PriceManagementLoaded) return; // فقط در حالت Loaded

    final currentState = state as PriceManagementLoaded;

    try {
      // به‌روزرسانی وضعیت در لیست
      final updatedRequests =
          currentState.requests.map((request) {
            if (request.id == event.requestId) {
              request.confirmationStatus = event.newStatus;
            }
            return request;
          }).toList();

      // گروه‌بندی مجدد
      final grouped = priceRequestService.groupByOrderNumber(updatedRequests);

      // افزودن به لیست تغییر یافته‌ها
      final changedIds = List<String>.from(currentState.changedIds);
      if (!changedIds.contains(event.requestId)) {
        changedIds.add(event.requestId);
      }

      // ارسال وضعیت جدید
      emit(
        currentState.copyWith(
          requests: updatedRequests,
          groupedByOrder: grouped,
          hasChanges: true,
          changedIds: changedIds,
        ),
      );

      // ذخیره فوری در سرور
      try {
        await priceRequestService.setPriceChangeRequestConfirmationStatus(
          event.requestId,
          event.newStatus,
        );
        developer.log(' وضعیت ${event.requestId} به‌روز و ذخیره شد');
      } catch (e) {
        developer.log(' خطا در ذخیره فوری: $e');
      }
    } catch (e) {
      developer.log(' خطا در به‌روزرسانی: $e');
      emit(PriceManagementError(message: 'خطا در به‌روزرسانی وضعیت'));
    }
  }

  // هندلر _onSaveChanges - ذخیره تمام تغییرات
  Future<void> _onSaveChanges(
    SaveChangesEvent event,
    Emitter<PriceManagementState> emit,
  ) async {
    if (state is! PriceManagementLoaded) return;

    final currentState = state as PriceManagementLoaded;

    try {
      developer.log('💾 ذخیره ${currentState.changedIds.length} تغییر');

      // فیلتر موارد تغییر یافته
      final changedRequests =
          currentState.requests
              .where((r) => currentState.changedIds.contains(r.id))
              .toList();

      // ذخیره در سرور
      await priceRequestService.saveAllChanges(changedRequests);

      emit(currentState.copyWith(hasChanges: false, changedIds: []));

      emit(const PriceManagementSaved()); // نمایش پیام موفقیت

      developer.log(' تغییرات ذخیره شد');

      // برگشت به حالت Loaded
      emit(currentState.copyWith(hasChanges: false, changedIds: []));
    } catch (e) {
      developer.log(' خطا در ذخیره: $e');
      emit(PriceManagementError(message: 'خطا در ذخیره تغییرات: $e'));
    }
  }

  // هندلر _onRefreshPriceRequests - بازخوانی داده‌ها
  Future<void> _onRefreshPriceRequests(
    RefreshPriceRequestsEvent event,
    Emitter<PriceManagementState> emit,
  ) async {
    add(const LoadPriceRequestsEvent()); // ارسال رویداد بارگذاری
  }
}
