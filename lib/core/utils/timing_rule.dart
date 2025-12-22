// models/timing_rule.dart
class TimingRule {
  final String startDate;
  final String endDate;
  final String name;
  final String surname;
  final String id;
  final String personId;
  final bool extraTime;
  final int differenceTime;
  final int ruleType;
  final String title;
  final String ruleId;

  TimingRule({
    required this.startDate,
    required this.endDate,
    required this.name,
    required this.surname,
    required this.id,
    required this.personId,
    required this.extraTime,
    required this.differenceTime,
    required this.ruleType,
    required this.title,
    required this.ruleId,
  });

  factory TimingRule.fromJson(Map<String, dynamic> json) {
    return TimingRule(
      startDate: json['StartDate'] ?? '',
      endDate: json['EndDate'] ?? '',
      name: json['Name'] ?? '',
      surname: json['Surname'] ?? '',
      id: json['ID'] ?? '',
      personId: json['PersonId'] ?? '',
      extraTime: json['ExtraTime'] ?? false,
      differenceTime: json['DifferenceTime'] ?? 0,
      ruleType: json['RuleType'] ?? 0,
      title: json['Title'] ?? '',
      ruleId: json['RuleID'] ?? '',
    );
  }
}