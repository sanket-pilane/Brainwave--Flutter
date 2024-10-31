import 'package:brainwave/src/features/authentication/domain/entities/app_user.dart';
import 'package:brainwave/src/features/authentication/domain/repo/auth_repo.dart';
import 'package:brainwave/src/features/authentication/presentation/cubits/auth_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubits extends Cubit<AuthStates> {
  final AuthRepo authRepo;

  AppUser? _currentUser;

  AuthCubits({required this.authRepo}) : super(AuthInitial());

  void checkAuth() async {
    final AppUser? user = await authRepo.getCurrentUser();

    if (user != null) {
      _currentUser = user;

      emit(Authenticated(user));
    } else {
      emit(UnAuthenticated());
    }
  }

  AppUser? get currentUser => _currentUser;

  Future<void> login(String email, String pass) async {
    try {
      emit(AuthLoading());

      final user = await authRepo.loginWithEmailAndPassword(email, pass);
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(UnAuthenticated());
    }
  }

  Future<void> register(String email, String pass) async {
    try {
      emit(AuthLoading());

      final user = await authRepo.registerWithEmailAndPassword(email, pass);

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(UnAuthenticated());
    }
  }

  Future<void> logout() async {
    authRepo.logout();
    emit(UnAuthenticated());
  }
}
