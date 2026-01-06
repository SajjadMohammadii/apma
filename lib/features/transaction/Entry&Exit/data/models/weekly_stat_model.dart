import '../../domain/entities/weekly_stat.dart';

class WeeklyStatModel extends WeeklyStat {
  const WeeklyStatModel({
    required super.day,
    required super.date,
    required super.hours,
    required super.status,
  });

  factory WeeklyStatModel.fromJson(Map<String, dynamic> json) {
    return WeeklyStatModel(
      day: json['day'] as String,
      date: json['date'] as String,
      hours: json['hours'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'date': date,
      'hours': hours,
      'status': status,
    };
  }

  factory WeeklyStatModel.fromEntity(WeeklyStat entity) {
    return WeeklyStatModel(
      day: entity.day,
      date: entity.date,
      hours: entity.hours,
      status: entity.status,
    );
  }
}
