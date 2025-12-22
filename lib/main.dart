// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(title: const Text("تست اپ")),
//         body: const Center(child: Text("اپ اجرا شد ")),
//       ),
//     );
//   }
// }

// نقطه ورود اصلی برنامه APMA
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'core/constants/app_string.dart';
import 'core/themes/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'services/foreground_service.dart';

// DI - تزریق وابستگی
import 'core/di/injection_container.dart' as di;

// Bloc ها
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/commuting/presentation/bloc/commuting_bloc.dart';

/// تابع main - نقطه شروع برنامه
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // فقط حالت عمودی
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // مقداردهی اولیه GetIt
  await di.init();

  // سرویس پس‌زمینه برای اندروید
  if (!kIsWeb && Platform.isAndroid) {
    await ForegroundService.init();
    await ForegroundService.start();
  }

  runApp(const ApmacoApp());
}

// کلاس ApmacoApp - ویجت ریشه برنامه
class ApmacoApp extends StatelessWidget {
  const ApmacoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // بلاک احراز هویت
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>(),
        ),
        // بلاک ورود/خروج پرسنل
        BlocProvider<CommutingBloc>(
          create: (context) => di.sl<CommutingBloc>()
            // ..add(LoadLastStatus("EMP123")), // بارگذاری اولیه وضعیت
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: WithForegroundTask(
          child: const SplashScreen(),
        ),
       // home: BlocTestPage(),

    ),
    );
  }
}
