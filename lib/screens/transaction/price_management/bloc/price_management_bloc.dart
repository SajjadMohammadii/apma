import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apma_app/screens/transaction/price_management/bloc/price_management_event.dart';
import 'package:apma_app/screens/transaction/price_management/bloc/price_management_state.dart';
import 'package:apma_app/screens/transaction/price_management/services/price_request_service.dart';

class PriceManagementBloc
    extends Bloc<PriceManagementEvent, PriceManagementState> {
  final PriceRequestService priceRequestService;

  PriceManagementBloc({required this.priceRequestService})
    : super(const PriceManagementInitial()) {
    on<LoadPriceRequestsEvent>(_onLoadPriceRequests);
    on<UpdatePriceRequestStatusEvent>(_onUpdatePriceRequestStatus);
    on<SaveChangesEvent>(_onSaveChanges);
    on<RefreshPriceRequestsEvent>(_onRefreshPriceRequests);
  }

  Future<void> _onLoadPriceRequests(
    LoadPriceRequestsEvent event,
    Emitter<PriceManagementState> emit,
  ) async {
    try {
      emit(const PriceManagementLoading());

      final requests = await priceRequestService.loadPriceChangeRequestsList(
        fromDate: event.fromDate,
        toDate: event.toDate,
        status: event.status,
        criteria: event.criteria,
      );

      final grouped = priceRequestService.groupByOrderNumber(requests);

      emit(
        PriceManagementLoaded(
          requests: requests,
          groupedByOrder: grouped,
          hasChanges: false,
          changedIds: [],
        ),
      );
    } catch (e) {
      developer.log('❌ Bloc خطا: $e');
      emit(PriceManagementError(message: e.toString()));
    }
  }

  Future<void> _onUpdatePriceRequestStatus(
    UpdatePriceRequestStatusEvent event,
    Emitter<PriceManagementState> emit,
  ) async {
    if (state is! PriceManagementLoaded) return;

    final currentState = state as PriceManagementLoaded;

    try {
      final updatedRequests =
          currentState.requests.map((request) {
            if (request.id == event.requestId) {
              request.confirmationStatus = event.newStatus;
            }
            return request;
          }).toList();

      final grouped = priceRequestService.groupByOrderNumber(updatedRequests);

      final changedIds = List<String>.from(currentState.changedIds);
      if (!changedIds.contains(event.requestId)) {
        changedIds.add(event.requestId);
      }

      emit(
        currentState.copyWith(
          requests: updatedRequests,
          groupedByOrder: grouped,
          hasChanges: true,
          changedIds: changedIds,
        ),
      );

      developer.log('✅ وضعیت ${event.requestId} به‌روز شد');
    } catch (e) {
      developer.log('❌ خطا در به‌روزرسانی: $e');
      emit(PriceManagementError(message: 'خطا در به‌روزرسانی وضعیت'));
    }
  }

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

      emit(const PriceManagementSaved());

      developer.log('✅ تغییرات ذخیره شد');

      // برگشت به حالت Loaded
      emit(currentState.copyWith(hasChanges: false, changedIds: []));
    } catch (e) {
      developer.log('❌ خطا در ذخیره: $e');
      emit(PriceManagementError(message: 'خطا در ذخیره تغییرات: $e'));
    }
  }

  Future<void> _onRefreshPriceRequests(
    RefreshPriceRequestsEvent event,
    Emitter<PriceManagementState> emit,
  ) async {
    add(const LoadPriceRequestsEvent());
  }
}
