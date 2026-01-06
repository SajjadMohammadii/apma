import 'package:equatable/equatable.dart';

class WeeklyStat extends Equatable {
  final String day;
  final String date;
  final String hours;
  final String status;

  const WeeklyStat({
    required this.day,
    required this.date,
    required this.hours,
    required this.status,
  });

  @override
  List<Object?> get props => [day, date, hours, status];
}
