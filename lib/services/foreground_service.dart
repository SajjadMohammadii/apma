import 'dart:async'; // کتابخانه برای کار با عملیات غیرهمزمان
import 'dart:developer' as AppLogger show log; // لاگر برای دیباگ
import 'dart:io'; // کتابخانه برای کار با سیستم‌عامل
import 'package:flutter_foreground_task/flutter_foreground_task.dart'; // پکیج تسک پیش‌زمینه

// تابع startCallback - نقطه ورود برای شروع تسک در پس‌زمینه
@pragma('vm:entry-point') // دستور به کامپایلر برای حفظ این تابع
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler()); // تنظیم هندلر تسک
}

// کلاس MyTaskHandler - مدیریت‌کننده رویدادهای تسک پس‌زمینه
class MyTaskHandler extends TaskHandler {
  int _count = 0; // متغیر شمارنده برای تعداد دفعات اجرا

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    AppLogger.log(' Background Service STARTED');
    print(' [APMA Background] Service Started at: $timestamp');
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    AppLogger.log(' Background running - Count: $_count');
    print(' [APMA Background] Running... Count: $_count at $timestamp');
    _count++;

    // آپدیت نوتیفیکیشن
    FlutterForegroundTask.updateService(
      notificationTitle: 'APMA App',
      notificationText: 'فعال - $_count بار',
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isForced) async {
    AppLogger.log(' Background Service STOPPED - Count: $_count');
    print(' [APMA Background] Stopped at $timestamp');
  }

  @override
  void onNotificationButtonPressed(String id) {
    // دکمه نوتیف کلیک شد
  }

  @override
  void onNotificationPressed() {
    // وقتی روی نوتیف کلیک می‌شود → برو به صفحه اصلی
    FlutterForegroundTask.launchApp('/home');
  }

  @override
  void onNotificationDismissed() {
    // نوتیف dismiss شد
  }
}

// کلاس ForegroundService - مدیریت سرویس پیش‌زمینه
class ForegroundService {
  static bool _isRunning = false;

  static Future<void> init() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        id: 500,
        channelId: 'apma_service',
        channelName: 'APMA Background Service',
        channelDescription: 'اپلیکیشن APMA در حال اجراست',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<bool> start() async {
    if (_isRunning) return true;

    await _requestPermissions();

    await FlutterForegroundTask.startService(
      serviceId: 500,
      notificationTitle: 'APMA App',
      notificationText: 'در حال اجرا',
      callback: startCallback,
    );

    _isRunning = true;
    return true;
  }

  static Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final notificationPermission =
      await FlutterForegroundTask.checkNotificationPermission();
      if (notificationPermission != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }

      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      //  بررسی نهایی: اگر همه دسترسی‌ها داده شدند → برو به صفحه اصلی
      final notifFinal =
      await FlutterForegroundTask.checkNotificationPermission();
      final batteryFinal =
      await FlutterForegroundTask.isIgnoringBatteryOptimizations;

      if (notifFinal == NotificationPermission.granted && batteryFinal) {
        FlutterForegroundTask.launchApp('/home');
      }
    }
  }

  static Future<bool> stop() async {
    if (!_isRunning) return true;

    await FlutterForegroundTask.stopService();
    _isRunning = false;
    return true;
  }

  static bool get isRunning => _isRunning;
}
