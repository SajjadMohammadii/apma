import 'package:apma_app/core/errors/failures.dart';
import 'package:apma_app/features/auth/domain/entities/user.dart';
import 'package:apma_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:apma_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase? loginUseCase;
  final AuthRepository? repository;

  AuthBloc({this.loginUseCase, this.repository}) : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      // prefer usecase if provided, otherwise call repository directly
      Either<Failure, User> result;
      if (loginUseCase != null) {
        result = await loginUseCase!(
          LoginParams(username: event.username, password: event.password),
        );
      } else if (repository != null) {
        result = await repository!.login(
          username: event.username,
          password: event.password,
        );
      } else {
        emit(const AuthError('No authentication implementation provided.'));
        return;
      }

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      if (repository != null) {
        await repository!.logout();
      }
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      if (repository != null) {
        final res = await repository!.isLoggedIn();
        res.fold((failure) => emit(const AuthUnauthenticated()), (
          isLogged,
        ) async {
          if (isLogged) {
            final userRes = await repository!.getCurrentUser();
            userRes.fold(
              (f) => emit(const AuthUnauthenticated()),
              (user) => emit(AuthAuthenticated(user)),
            );
          } else {
            emit(const AuthUnauthenticated());
          }
        });
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
