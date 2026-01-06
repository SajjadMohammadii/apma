import 'dart:async';
import 'dart:ffi';
import 'dart:convert';
import 'package:apma_app/features/commuting/presentation/bloc/commuting_bloc.dart';
import 'package:apma_app/features/commuting/presentation/bloc/commuting_event.dart';
import 'package:apma_app/features/commuting/presentation/bloc/commuting_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apma_app/core/constants/app_colors.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';


class EntryExitPage extends StatefulWidget {
  const EntryExitPage({super.key});

  @override
  State<EntryExitPage> createState() => _EntryExitPageState();
}

// کلاس _EntryExitPageState - state صفحه ورود و خروج
class _EntryExitPageState extends State<EntryExitPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController; // کنترلر انیمیشن
  late Animation<double> _pulseAnimation; // انیمیشن پالس

  bool _isCheckedIn = false; // وضعیت حضور (ورود شده یا خیر)
  String _currentTime = ''; // زمان فعلی
  String _currentDate = ''; // تاریخ فعلی
  String _workDuration = '00:00:00'; // مدت زمان کاری

  // اضافه: شناسه کارمند برای ارسال به سرور
  String? _personId;
  Double? Lat;
  Double? Lng;

  // داده‌های امروز - بارگذاری از SharedPreferences
  List<Map<String, dynamic>> _todayRecords = [];

  // داده‌های آمار هفتگی - محاسبه از رکوردهای ذخیره شده
  List<Map<String, dynamic>> _weeklyStats = [];
  
  // تعداد کل هفته‌ها
  int _totalWeeks = 0;
  
  // اولین تاریخ ورود
  String? _firstEntryDate;
  
  // زمان ورود
  DateTime? _entryTime;

  Timer? _timer; // تایمر به‌روزرسانی زمان

  @override
  // متد initState - مقداردهی اولیه انیمیشن و تایمر
  void initState() {
    super.initState();
    _updateTime(); // شروع به‌روزرسانی زمان
    // تنظیم انیمیشن پالس
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // اضافه: گرفتن personId از SharedPreferences و ارسال درخواست ابتدای صفحه
    _loadPersonIdAndRequest();
    _loadTodayRecords();
    _loadWeeklyStats();
    _loadCheckInStatus(); // بارگذاری وضعیت ورود
  }

  // بارگذاری وضعیت ورود
  Future<void> _loadCheckInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isCheckedIn = prefs.getBool('is_checked_in') ?? false;
    final entryTimeStr = prefs.getString('entry_time');
    
    if (mounted) {
      setState(() {
        _isCheckedIn = isCheckedIn;
        if (entryTimeStr != null && isCheckedIn) {
          _entryTime = DateTime.parse(entryTimeStr);
        }
      });
    }
  }

  // اضافه: خواندن personId و ارسال رویداد Bloc برای گرفتن آخرین وضعیت
  Future<void> _loadPersonIdAndRequest() async {
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

  // بارگذاری رکوردهای امروز از SharedPreferences
  Future<void> _loadTodayRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jalaliToday = Jalali.now();
    final todayKey = '${jalaliToday.year}${jalaliToday.month.toString().padLeft(2, '0')}${jalaliToday.day.toString().padLeft(2, '0')}';
    
    final recordsJson = prefs.getString('records_$todayKey');
    if (recordsJson != null) {
      final List<dynamic> decoded = jsonDecode(recordsJson);
      setState(() {
        _todayRecords = decoded.map((e) => e as Map<String, dynamic>).toList();
      });
    }
  }

  // ذخیره رکورد جدید
  Future<void> _saveRecordToPrefs(String type, String time, String date) async {
    final prefs = await SharedPreferences.getInstance();
    final jalaliNow = Jalali.now();
    final todayKey = '${jalaliNow.year}${jalaliNow.month.toString().padLeft(2, '0')}${jalaliNow.day.toString().padLeft(2, '0')}';
    
    // ذخیره اولین تاریخ ورود
    if (type == 'entry') {
      final firstEntry = prefs.getString('first_entry_date');
      if (firstEntry == null) {
        await prefs.setString('first_entry_date', todayKey);
      }
    }
    
    // گرفتن رکوردهای قبلی
    final recordsJson = prefs.getString('records_$todayKey');
    List<Map<String, dynamic>> records = [];
    if (recordsJson != null) {
      final List<dynamic> decoded = jsonDecode(recordsJson);
      records = decoded.map((e) => e as Map<String, dynamic>).toList();
    }
    
    // افزودن رکورد جدید
    records.add({
      'type': type,
      'time': time,
      'date': date,
      'status': 'تایید شده',
    });
    
    // ذخیره
    await prefs.setString('records_$todayKey', jsonEncode(records));
    
    // به‌روزرسانی آمار هفتگی
    await _loadWeeklyStats();
  }

  // محاسبه آمار هفتگی
  Future<void> _loadWeeklyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final firstEntry = prefs.getString('first_entry_date');
    
    if (firstEntry == null) {
      // اگر هیچ وروی ثبت نشده، آمار نمایش داده نشود
      setState(() {
        _weeklyStats = [];
        _totalWeeks = 0;
        _firstEntryDate = null;
      });
      return;
    }
    
    // تبدیل اولین تاریخ ورود
    final firstYear = int.parse(firstEntry.substring(0, 4));
    final firstMonth = int.parse(firstEntry.substring(4, 6));
    final firstDay = int.parse(firstEntry.substring(6, 8));
    final firstJalali = Jalali(firstYear, firstMonth, firstDay);
    
    final jalaliToday = Jalali.now();
    final daysDiff = jalaliToday.toDateTime().difference(firstJalali.toDateTime()).inDays;
    
    // محاسبه تعداد هفته‌ها
    _totalWeeks = (daysDiff / 7).ceil();
    _firstEntryDate = '${firstJalali.year}/${firstJalali.month.toString().padLeft(2, '0')}/${firstJalali.day.toString().padLeft(2, '0')}';
    
    List<Map<String, dynamic>> stats = [];
    
    final dayNames = ['شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنج‌شنبه', 'جمعه'];
    
    // فقط 6 روز قبل را نمایش بده
    for (int i = 5; i >= 0; i--) {
      final day = jalaliToday.addDays(-i);
      
      // اگر این روز قبل از اولین ورود است، نمایش نده
      if (day.toDateTime().isBefore(firstJalali.toDateTime())) {
        continue;
      }
      
      final dayKey = '${day.year}${day.month.toString().padLeft(2, '0')}${day.day.toString().padLeft(2, '0')}';
      final recordsJson = prefs.getString('records_$dayKey');
      
      String hours = '-';
      String status = 'تعطیل';
      
      if (recordsJson != null) {
        final List<dynamic> decoded = jsonDecode(recordsJson);
        final records = decoded.map((e) => e as Map<String, dynamic>).toList();
        
        // محاسبه ساعات کار
        final entries = records.where((r) => r['type'] == 'entry').toList();
        final exits = records.where((r) => r['type'] == 'exit').toList();
        
        if (entries.isNotEmpty && exits.isNotEmpty) {
          // محاسبه مجموع ساعات
          int totalMinutes = 0;
          for (int j = 0; j < entries.length && j < exits.length; j++) {
            final entryTime = _parseTimeToDateTime(entries[j]['time']);
            final exitTime = _parseTimeToDateTime(exits[j]['time']);
            totalMinutes += exitTime.difference(entryTime).inMinutes;
          }
          
          final workHours = totalMinutes ~/ 60;
          final workMinutes = totalMinutes % 60;
          hours = '$workHours:${workMinutes.toString().padLeft(2, '0')}';
          
          // تعیین وضعیت
          if (totalMinutes >= 480) { // 8 ساعت
            status = 'کامل';
          } else if (totalMinutes >= 420) { // 7 ساعت
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
      
      final dayOfWeek = day.weekDay; // 1=شنبه، 7=جمعه
      final dayDate = '${day.year}/${day.month.toString().padLeft(2, '0')}/${day.day.toString().padLeft(2, '0')}';
      
      stats.add({
        'day': dayNames[(dayOfWeek - 1) % 7],
        'date': dayDate,
        'hours': hours,
        'status': status,
      });
    }
    
    // روز امروز
    final todayDayOfWeek = jalaliToday.weekDay;
    final todayDate = '${jalaliToday.year}/${jalaliToday.month.toString().padLeft(2, '0')}/${jalaliToday.day.toString().padLeft(2, '0')}';
    
    stats.add({
      'day': dayNames[(todayDayOfWeek - 1) % 7],
      'date': todayDate,
      'hours': '-',
      'status': 'امروز',
    });
    
    setState(() {
      _weeklyStats = stats;
    });
  }

  // متد _updateTime - به‌روزرسانی زمان و تاریخ هر ثانیه
  void _updateTime() {
    if (!mounted) return;

    final now = DateTime.now();
    final jalaliNow = Jalali.fromDateTime(now);
    
    setState(() {
      _currentTime =
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      _currentDate =
      '${jalaliNow.year}/${jalaliNow.month.toString().padLeft(2, '0')}/${jalaliNow.day.toString().padLeft(2, '0')}';
      
      // محاسبه مجموع زمان کاری امروز
      _workDuration = _calculateTotalWorkDuration();
    });

    _timer = Timer(const Duration(seconds: 1), _updateTime); // تایمر بازگشتی

  }

  // محاسبه مجموع زمان کاری روز
  String _calculateTotalWorkDuration() {
    int totalSeconds = 0;
    
    // پیدا کردن همه ورودها و خروج‌ها
    final entries = _todayRecords.where((r) => r['type'] == 'entry').toList();
    final exits = _todayRecords.where((r) => r['type'] == 'exit').toList();
    
    // محاسبه زمان بین هر جفت ورود-خروج
    for (int i = 0; i < entries.length && i < exits.length; i++) {
      final entryTime = _parseTimeToDateTime(entries[i]['time']);
      final exitTime = _parseTimeToDateTime(exits[i]['time']);
      totalSeconds += exitTime.difference(entryTime).inSeconds;
    }
    
    // اگر الان در حالت ورود هستیم، زمان از آخرین ورود تا الان رو اضافه کن
    if (_isCheckedIn && _entryTime != null) {
      final now = DateTime.now();
      totalSeconds += now.difference(_entryTime!).inSeconds;
    }
    
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // تبدیل رشته زمان به DateTime
  DateTime _parseTimeToDateTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  @override
  // متد dispose - آزادسازی منابع
  void dispose() {
    _timer?.cancel(); // لغو تایمر
    _animationController.dispose(); // آزادسازی کنترلر انیمیشن
    super.dispose();
  }

  // متد _toggleCheckIn - تغییر وضعیت ورود/خروج
  void _toggleCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _isCheckedIn = !_isCheckedIn;
      
      if (_isCheckedIn) {
        // ورود
        _entryTime = DateTime.now();
        prefs.setBool('is_checked_in', true);
        prefs.setString('entry_time', _entryTime!.toIso8601String());
      } else {
        // خروج
        _entryTime = null;
        _workDuration = '00:00:00';
        prefs.setBool('is_checked_in', false);
        prefs.remove('entry_time');
      }
      
      // افزودن رکورد جدید با status تایید شده
      _todayRecords.add({
        'type': _isCheckedIn ? 'entry' : 'exit',
        'time': _currentTime,
        'date': _currentDate,
        'status': 'تایید شده',
      });
    });

    // ذخیره رکورد در SharedPreferences برای آمار هفتگی
    await _saveRecordToPrefs(_isCheckedIn ? 'entry' : 'exit', _currentTime, _currentDate);

    // اضافه: در صورت وجود personId، ارسال رویداد ثبت ورود/خروج به بلاک
    if (_personId != null) {
      context.read<CommutingBloc>().add(
        SubmitCommutingEvent(
          personId: _personId!,
          selectedStatus: _isCheckedIn ? 1 : 0, // 1: ورود، 0: خروج
        ),
      );
    }

    _getServerDateTimeRequest();

    _getGeneralSettingsRequest();

    // نمایش پیام موفقیت
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isCheckedIn ? 'ورود ثبت شد' : 'خروج ثبت شد',
          style: const TextStyle(fontFamily: 'Vazir'),
        ),
        backgroundColor: _isCheckedIn ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _getServerDateTimeRequest() async {
      context.read<CommutingBloc>().add(GetServerDateTimeEvent());
  }

  Future<void> _getGeneralSettingsRequest() async {
    context.read<CommutingBloc>().add(GetGeneralSettingsEvent());
  }

  @override
  // متد build - ساخت رابط کاربری صفحه
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // راست به چپ
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
        body: BlocConsumer<CommutingBloc, CommutingState>(
          listener: (context, state) {
            if (state is CommutingLoading) {
              print(" CommutingLoading...");
            } else if (state is CommutingReady) {
              print(" CommutingReady:");
              print("آخرین وضعیت: ${state.lastStatus}");
            } else if (state is CommutingSubmitted) {
              print(" CommutingSubmitted: ثبت موفق انجام شد");
            } else if (state is CommutingError) {
              print(" CommutingError: ${state.message}");
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTimeCard(),
                  const SizedBox(height: 20),
                  _buildCheckInButton(),
                  const SizedBox(height: 20),
                  _buildTodayRecords(),
                  if (_weeklyStats.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildWeeklyStats(),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }


//...............................................................................
  Widget _buildTimeCard() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final prefs = snapshot.data!;
        int? status = prefs.getInt("lastStatus");
        print("Exit_Entry_page_status = $status");


        return BlocBuilder<CommutingBloc, CommutingState>(
          builder: (context, state) {
            String? lastDate;
            String? lastTime;
            int? lastStatus;

            if (state is CommutingReady) {
              lastDate = state.lastDate;
              lastTime = state.lastTime;
              lastStatus = state.lastStatus;
            }
            
            if(lastTime == null || lastDate == null){
              final now = DateTime.now();
              final jalaliNow = Jalali.fromDateTime(now);
              _currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
              _currentDate = '${jalaliNow.year}/${jalaliNow.month.toString().padLeft(2, '0')}/${jalaliNow.day.toString().padLeft(2, '0')}';
            }else{
              _currentDate = lastDate;
              _currentTime = lastTime;
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.primaryGreen.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _currentDate,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Vazir',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Vazir',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'زمان کاری امروز: $_workDuration',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Vazir',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isCheckedIn ? Icons.login : Icons.logout,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isCheckedIn ? 'حضور دارید' : 'در حال غیبت',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Vazir',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCheckInButton() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: GestureDetector(
        onTap: _toggleCheckIn,
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors:
              _isCheckedIn
                  ? [Colors.orange, Colors.deepOrange]
                  : [AppColors.primaryGreen, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (_isCheckedIn ? Colors.orange : AppColors.primaryGreen)
                    .withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isCheckedIn ? Icons.logout : Icons.fingerprint,
                color: Colors.white,
                size: 50,
              ),
              const SizedBox(height: 8),
              Text(
                _isCheckedIn ? 'ثبت خروج' : 'ثبت ورود',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Vazir',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayRecords() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.today,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'رکوردهای امروز',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Vazir',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_todayRecords.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'هنوز رکوردی ثبت نشده است',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Vazir',
                  ),
                ),
              ),
            )
          else
            ..._todayRecords.map((record) => _buildRecordItem(record)),
        ],
      ),
    );
  }

  Widget _buildRecordItem(Map<String, dynamic> record) {
    final isEntry = record['type'] == 'entry';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isEntry ? Colors.green : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (isEntry ? Colors.green : Colors.orange).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isEntry ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEntry ? Icons.login : Icons.logout,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEntry ? 'ورود' : 'خروج',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Vazir',
                  ),
                ),
                Text(
                  'ساعت ${record['time']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontFamily: 'Vazir',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:
              record['status'] == 'تایید شده'
                  ? Colors.green.withOpacity(0.2)
                  : Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              record['status'],
              style: TextStyle(
                color:
                record['status'] == 'تایید شده'
                    ? Colors.green[700]
                    : Colors.amber[700],
                fontSize: 11,
                fontFamily: 'Vazir',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: AppColors.primaryPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'آمار هفتگی',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Vazir',
                      ),
                    ),
                    if (_totalWeeks > 0)
                      Text(
                        'تعداد هفته‌ها: $_totalWeeks هفته',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Vazir',
                        ),
                      ),
                    if (_firstEntryDate != null)
                      Text(
                        'از تاریخ: $_firstEntryDate',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontFamily: 'Vazir',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._weeklyStats.map((stat) => _buildStatItem(stat)),
        ],
      ),
    );
  }

  Widget _buildStatItem(Map<String, dynamic> stat) {
    Color statusColor;
    switch (stat['status']) {
      case 'کامل':
        statusColor = Colors.green;
        break;
      case 'کسری':
        statusColor = Colors.red;
        break;
      case 'اضافه‌کار':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  stat['day'],
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  stat['date'] ?? '',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stat['status'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontFamily: 'Vazir',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value:
                  stat['hours'] == '-'
                      ? 0
                      : (double.tryParse(stat['hours'].split(':')[0]) ?? 0) / 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 50,
                child: Text(
                  stat['hours'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}