import 'package:apma_app/screens/transaction/price_management/models/price_request_model.dart';

abstract class PriceManagementState {
  const PriceManagementState();
}

class PriceManagementInitial extends PriceManagementState {
  const PriceManagementInitial();
}

class PriceManagementLoading extends PriceManagementState {
  const PriceManagementLoading();
}

class PriceManagementLoaded extends PriceManagementState {
  final List<PriceRequestModel> requests;
  final Map<String, List<PriceRequestModel>> groupedByOrder;
  final bool hasChanges;
  final List<String> changedIds;

  const PriceManagementLoaded({
    required this.requests,
    required this.groupedByOrder,
    this.hasChanges = false,
    this.changedIds = const [],
  });

  Map<String, List<PriceRequestModel>> get filteredGroupedByOrder =>
      groupedByOrder;

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

class PriceManagementError extends PriceManagementState {
  final String message;

  const PriceManagementError({required this.message});
}

class PriceManagementSaved extends PriceManagementState {
  final String message;

  const PriceManagementSaved({this.message = 'تغییرات با موفقیت ذخیره شد'});
}
