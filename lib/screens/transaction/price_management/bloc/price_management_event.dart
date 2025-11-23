abstract class PriceManagementEvent {
  const PriceManagementEvent();
}

class LoadPriceRequestsEvent extends PriceManagementEvent {
  final String? fromDate;
  final String? toDate;
  final int status;
  final String criteria;

  const LoadPriceRequestsEvent({
    this.fromDate,
    this.toDate,
    this.status = 0,
    this.criteria = '',
  });
}

class UpdatePriceRequestStatusEvent extends PriceManagementEvent {
  final String requestId;
  final int newStatus;

  const UpdatePriceRequestStatusEvent({
    required this.requestId,
    required this.newStatus,
  });
}

class SaveChangesEvent extends PriceManagementEvent {
  const SaveChangesEvent();
}

class RefreshPriceRequestsEvent extends PriceManagementEvent {
  const RefreshPriceRequestsEvent();
}
