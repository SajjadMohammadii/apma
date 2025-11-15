import 'package:apma_app/core/network/soap_client.dart';
import 'package:apma_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:apma_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:apma_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:apma_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:apma_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Export sl so it can be used in other files
final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth

  // Bloc
  sl.registerFactory(() => AuthBloc(loginUseCase: sl(), repository: sl()));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources - استفاده از سرور SOAP واقعی
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(soapClient: sl()),
  );

  //! Core

  // SOAP Client
  sl.registerLazySingleton<SoapClient>(
    () => SoapClient(
      baseUrl: AuthRemoteDataSourceImpl.webServiceUrl,
      httpClient: sl(),
    ),
  );

  //! External

  // HTTP Client
  sl.registerLazySingleton(() => http.Client());

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
