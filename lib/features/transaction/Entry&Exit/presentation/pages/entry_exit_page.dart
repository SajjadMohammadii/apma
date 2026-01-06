import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:apma_app/core/constants/app_colors.dart';
import 'package:apma_app/features/commuting/presentation/bloc/commuting_bloc.dart';
import 'package:apma_app/features/commuting/presentation/bloc/commuting_event.dart';
import 'package:apma_app/features/commuting/presentation/bloc/commuting_state.dart';
import '../widgets/time_card.dart';
import '../widgets/check_in_button.dart';
import '../widgets/today_records_list.dart';
import '../widgets/weekly_stats_list.dart';

class EntryExitPage extends StatefulWidget {
  const EntryExitPage({super.key});

  @override
  State<EntryExitPage> createState() => _EntryExitPageState();
}

class _EntryExitPageState extends State<EntryExitPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  Timer? _timer;
  Timer? _workDurationTimer;

  bool _isCheckedIn = false;
  String _currentTime = '';
  String _currentDate = '';
  String _workDuration = '00:00:00';
  String? _personId;
  DateTime? _entryTime;

  List<Map<String, dynamic>> _todayRecords = [];
  List<Map<String, dynamic>> _weeklyStats = [];
  int _totalWeeks = 0;
  String? _firstEntryDate;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _updateTime();
    _loadInitialData();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadInitialData() async {
    await _loadPersonId();
    await _loadCheckInStatus();
    await _loadTodayRecords();
    await _loadWeeklyStats();
    _startWorkDurationTimer();
  }

  void _updateTime() {
    if (!mounted) return;

    final now = DateTime.now();
    final jalaliNow = Jalali.fromDateTime(now);

    setState(() {
      _currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      _currentDate =
          '${jalaliNow.year}/${jalaliNow.month.toString().padLeft(2, '0')}/${jalaliNow.day.toString().padLeft(2, '0')}';
    });

    _timer = Timer(const Duration(seconds: 1), _updateTime);
  }

  void _startWorkDurationTimer() {
    _calculateWorkDuration();
    _workDurationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _calculateWorkDuration(),
    );
  }

  Future<void> _loadPersonId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString("personId");

    if (!mounted) return;

    setState(() {
      _personId = id;
    });

    if (id != null) {
      context.read<CommutingBloc>().add(LoadLastStatusEvent(id));
    }
  }

  Future<void> _loadCheckInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isCheckedIn = prefs.getBool('is_checked_in') ?? false;
    final entryTimeStr = prefs.getString('entry_time');

    if (!mounted) return;

    setState(() {
      _isCheckedIn = isCheckedIn;
      if (entryTimeStr != null && isCheckedIn) {
        _entryTime = DateTime.parse(entryTimeStr);
      }
    });
  }

  Future<void> _loadTodayRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jalaliToday = Jalali.now();
    final todayKey =
        '${jalaliToday.year}${jalaliToday.month.toString().padLeft(2, '0')}${jalaliToday.day.toString().padLeft(2, '0')}';

    final recordsJson = prefs.getString('records_$todayKey');
    if (recordsJson != null) {
      final List<dynamic> decoded = jsonDecode(recordsJson);
      if (mounted) {
        setState(() {
          _todayRecords =
              decoded.map((e) => e as Map<String, dynamic>).toList();
        });
      }
    }
  }

  Future<void> _loadWeeklyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final firstEntry = prefs.getString('first_entry_date');

    if (firstEntry == null) {
      if (mounted) {
        setState(() {
          _weeklyStats = [];
          _totalWeeks = 0;
          _firstEntryDate = null;
        });
      }
      return;
    }

    final firstYear = int.parse(firstEntry.substring(0, 4));
    final firstMonth = int.parse(firstEntry.substring(4, 6));
    final firstDay = int.parse(firstEntry.substring(6, 8));
    final firstJalali = Jalali(firstYear, firstMonth, firstDay);

    final jalaliToday = Jalali.now();
    final daysDiff =
        jalaliToday.toDateTime().difference(firstJalali.toDateTime()).inDays;

    final totalWeeks = (daysDiff / 7).ceil();
    final firstEntryDate =
        '${firstJalali.year}/${firstJalali.month.toString().padLeft(2, '0')}/${firstJalali.day.toString().padLeft(2, '0')}';

    final List<Map<String, dynamic>> stats = [];
    final dayNames = [
      'شنبه',
      'یکشنبه',
      'دوشنبه',
      'سه‌شنبه',
      'چهارشنبه',
      'پنج‌شنبه',
      'جمعه'
    ];

    for (int i = 5; i >= 0; i--) {
      final day = jalaliToday.addDays(-i);

      if (day.toDateTime().isBefore(firstJalali.toDateTime())) {
        continue;
      }

      final dayKey =
          '${day.year}${day.month.toString().padLeft(2, '0')}${day.day.toString().padLeft(2, '0')}';
      final recordsJson = prefs.getString('records_$dayKey');

      String hours = '-';
      String status = 'تعطیل';

      if (recordsJson != null) {
        final List<dynamic> decoded = jsonDecode(recordsJson);
        final records =
            decoded.map((e) => e as Map<String, dynamic>).toList();

        final entries = records.where((r) => r['type'] == 'entry').toList();
        final exits = records.where((r) => r['type'] == 'exit').toList();

        if (entries.isNotEmpty && exits.isNotEmpty) {
          int totalMinutes = 0;
          for (int j = 0; j < entries.length && j < exits.length; j++) {
            final entryTime = _parseTimeToDateTime(entries[j]['time']);
            final exitTime = _parseTimeToDateTime(exits[j]['time']);
            totalMinutes += exitTime.difference(entryTime).inMinutes;
          }

          final workHours = totalMinutes ~/ 60;
          final workMinutes = totalMinutes % 60;
          hours = '$workHours:${workMinutes.toString().padLeft(2, '0')}';

          if (totalMinutes >= 480) {
            status = 'کامل';
          } else if (totalMinutes >= 420) {
            status = 'کسری';
          } else {
            status = 'کسری';
          }

          if (totalMinutes > 480) {
            status = 'اضافه‌کار';
          }
        } else if (entries.isNotEmpty) {
          status = 'در حال کار';
        }
      }

      final dayOfWeek = day.weekDay;
      final dayDate =
          '${day.year}/${day.month.toString().padLeft(2, '0')}/${day.day.toString().padLeft(2, '0')}';

      stats.add({
        'day': dayNames[(dayOfWeek - 1) % 7],
        'date': dayDate,
        'hours': hours,
        'status': status,
      });
    }

    final todayDayOfWeek = jalaliToday.weekDay;
    final todayDate =
        '${jalaliToday.year}/${jalaliToday.month.toString().padLeft(2, '0')}/${jalaliToday.day.toString().padLeft(2, '0')}';

    stats.add({
      'day': dayNames[(todayDayOfWeek - 1) % 7],
      'date': todayDate,
      'hours': '-',
      'status': 'امروز',
    });

    if (mounted) {
      setState(() {
        _weeklyStats = stats;
        _totalWeeks = totalWeeks;
        _firstEntryDate = firstEntryDate;
      });
    }
  }

  void _calculateWorkDuration() {
    int totalSeconds = 0;

    final entries = _todayRecords.where((r) => r['type'] == 'entry').toList();
    final exits = _todayRecords.where((r) => r['type'] == 'exit').toList();

    for (int i = 0; i < entries.length && i < exits.length; i++) {
      final entryTime = _parseTimeToDateTime(entries[i]['time']);
      final exitTime = _parseTimeToDateTime(exits[i]['time']);
      totalSeconds += exitTime.difference(entryTime).inSeconds;
    }

    if (_isCheckedIn && _entryTime != null) {
      final now = DateTime.now();
      totalSeconds += now.difference(_entryTime!).inSeconds;
    }

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (mounted) {
      setState(() {
        _workDuration =
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _toggleCheckIn() async {
    setState(() {
      _isCheckedIn = !_isCheckedIn;
    });

    final prefs = await SharedPreferences.getInstance();
    final jalaliNow = Jalali.now();
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final currentDate =
        '${jalaliNow.year}/${jalaliNow.month.toString().padLeft(2, '0')}/${jalaliNow.day.toString().padLeft(2, '0')}';

    if (_isCheckedIn) {
      _entryTime = now;
      await prefs.setBool('is_checked_in', true);
      await prefs.setString('entry_time', now.toIso8601String());
    } else {
      _entryTime = null;
      await prefs.setBool('is_checked_in', false);
      await prefs.remove('entry_time');
    }

    await _saveRecord(_isCheckedIn ? 'entry' : 'exit', currentTime, currentDate);

    if (_personId != null) {
      context.read<CommutingBloc>().add(
            SubmitCommutingEvent(
              personId: _personId!,
              selectedStatus: _isCheckedIn ? 1 : 0,
            ),
          );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isCheckedIn ? 'ورود ثبت شد' : 'خروج ثبت شد',
            style: const TextStyle(fontFamily: 'Vazir'),
          ),
          backgroundColor: _isCheckedIn ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _saveRecord(String type, String time, String date) async {
    final prefs = await SharedPreferences.getInstance();
    final jalaliNow = Jalali.now();
    final todayKey =
        '${jalaliNow.year}${jalaliNow.month.toString().padLeft(2, '0')}${jalaliNow.day.toString().padLeft(2, '0')}';

    if (type == 'entry') {
      final firstEntry = prefs.getString('first_entry_date');
      if (firstEntry == null) {
        await prefs.setString('first_entry_date', todayKey);
      }
    }

    final recordsJson = prefs.getString('records_$todayKey');
    List<Map<String, dynamic>> records = [];
    if (recordsJson != null) {
      final List<dynamic> decoded = jsonDecode(recordsJson);
      records = decoded.map((e) => e as Map<String, dynamic>).toList();
    }

    records.add({
      'type': type,
      'time': time,
      'date': date,
      'status': 'تایید شده',
    });

    await prefs.setString('records_$todayKey', jsonEncode(records));

    await _loadTodayRecords();
    await _loadWeeklyStats();
  }

  DateTime _parseTimeToDateTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _workDurationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: const Text(
            'ورود و خروج',
            style: TextStyle(fontFamily: 'Vazir', color: Colors.white),
          ),
          backgroundColor: AppColors.primaryGreen,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: BlocListener<CommutingBloc, CommutingState>(
          listener: (context, state) {
            if (state is CommutingReady) {
              if (state.lastDate != null && state.lastTime != null) {
                setState(() {
                  _currentDate = state.lastDate!;
                  _currentTime = state.lastTime!;
                });
              }
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TimeCard(
                  currentDate: _currentDate,
                  currentTime: _currentTime,
                  workDuration: _workDuration,
                  isCheckedIn: _isCheckedIn,
                ),
                const SizedBox(height: 20),
                CheckInButton(
                  isCheckedIn: _isCheckedIn,
                  pulseAnimation: _pulseAnimation,
                  onTap: _toggleCheckIn,
                ),
                const SizedBox(height: 20),
                TodayRecordsList(records: _todayRecords),
                if (_weeklyStats.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  WeeklyStatsList(
                    stats: _weeklyStats,
                    totalWeeks: _totalWeeks,
                    firstEntryDate: _firstEntryDate,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
