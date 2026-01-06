import 'package:equatable/equatable.dart';

class AttendanceRecord extends Equatable {
  final String type;
  final String time;
  final String date;
  final String status;

  const AttendanceRecord({
    required this.type,
    required this.time,
    required this.date,
    required this.status,
  });

  bool get isEntry => type == 'entry';
  bool get isExit => type == 'exit';

  @override
  List<Object?> get props => [type, time, date, status];
}
