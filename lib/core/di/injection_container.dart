// تنظیم تزریق وابستگی با استفاده از GetIt service locator
// مرتبط با: main.dart, auth_bloc.dart, تمام repositoryها و use caseها

import 'package:apma_app/core/network/soap_client.dart'; // کلاینت SOAP
import 'package:apma_app/core/services/local_storage_service.dart'; // سرویس ذخیره‌سازی محلی
import 'package:apma_app/features/auth/data/datasources/auth_remote_datasource.dart'; // منبع داده راه دور
import 'package:apma_app/features/auth/data/repositories/auth_repository_impl.dart'; // پیاده‌سازی ریپازیتوری
import 'package:apma_app/features/auth/domain/repositories/auth_repository.dart'; // رابط ریپازیتوری
import 'package:apma_app/features/auth/domain/usecases/login_usecase.dart'; // یوزکیس ورود
import 'package:apma_app/features/auth/presentation/bloc/auth_bloc.dart'; // بلاک احراز هویت
import 'package:get_it/get_it.dart'; // کتابخانه GetIt برای تزریق وابستگی
import 'package:shared_preferences/shared_preferences.dart'; // ذخیره‌سازی تنظیمات
import 'package:http/http.dart' as http;
import 'package:apma_app/core/services/location_service.dart';
import '../../features/commuting/data/datasources/commuting_remote_datasource.dart';
import '../../features/commuting/data/repositories/commuting_repository_impl.dart';
import '../../features/commuting/domain/repositories/commuting_repository.dart';
import '../../features/commuting/presentation/bloc/commuting_bloc.dart';


// متغیر sl - نمونه GetIt برای استفاده در سایر فایل‌ها (Service Locator)
final sl = GetIt.instance;

// تابع init - مقداردهی اولیه تمام وابستگی‌ها
Future<void> init() async {
  //! ویژگی‌ها - احراز هویت

  // بلاک - ثبت به صورت Factory (هر بار نمونه جدید)
  sl.registerFactory(
        () => AuthBloc(
      loginUseCase: sl(), // یوزکیس ورود
      repository: sl(), // ریپازیتوری
      localStorageService: sl(), // سرویس ذخیره‌سازی محلی
    ),
  );

  // یوزکیس‌ها - ثبت به صورت LazySingleton
  sl.registerLazySingleton(() => LoginUseCase(sl()));

  // ریپازیتوری - ثبت به صورت LazySingleton
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // منابع داده - استفاده از SOAP
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(soapClient: sl()),
  );

  //! هسته

  // سرویس ذخیره‌سازی محلی - مقداردهی و ثبت
  final localStorageService = LocalStorageService();
  await localStorageService.init(); // مقداردهی اولیه
  sl.registerLazySingleton(() => localStorageService);

  // کلاینت SOAP - ثبت با آدرس وب‌سرویس
  sl.registerLazySingleton<SoapClient>(
        () => SoapClient(
      baseUrl: AuthRemoteDataSourceImpl.webServiceUrl, // آدرس وب‌سرویس
      httpClient: sl(), // کلاینت HTTP
    ),
  );

  //! خارجی

  // کلاینت HTTP - ثبت به صورت LazySingleton
  sl.registerLazySingleton(() => http.Client());

  // SharedPreferences - دریافت نمونه و ثبت
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

// دیتا‌سورس SOAP commuting
  sl.registerLazySingleton<CommutingRemoteDataSource>(
        () => CommutingRemoteDataSourceImpl(soapClient: sl()),
  );

// ریپازیتوری commuting
  sl.registerLazySingleton<CommutingRepository>(
        () => CommutingRepositoryImpl(remote: sl()),
  );

// بلاک commuting
  sl.registerFactory(
        () => CommutingBloc(
      repository: sl(),
      locationService: sl(),
    ),
  );

  // ثبت LocationService
  sl.registerLazySingleton<LocationService>(() => LocationService());

}
