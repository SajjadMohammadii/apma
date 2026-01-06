import '../../domain/entities/attendance_record.dart';

class AttendanceRecordModel extends AttendanceRecord {
  const AttendanceRecordModel({
    required super.type,
    required super.time,
    required super.date,
    required super.status,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      type: json['type'] as String,
      time: json['time'] as String,
      date: json['date'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'time': time,
      'date': date,
      'status': status,
    };
  }

  factory AttendanceRecordModel.fromEntity(AttendanceRecord entity) {
    return AttendanceRecordModel(
      type: entity.type,
      time: entity.time,
      date: entity.date,
      status: entity.status,
    );
  }
}
