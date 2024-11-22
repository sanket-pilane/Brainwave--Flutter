import 'package:brainwave/src/features/authentication/domain/entities/app_user.dart';

abstract class AuthRepo {
  Future<AppUser?> loginWithEmailAndPassword(String email, String password);
  Future<AppUser?> registerWithEmailAndPassword(String email, String password);
  Future<AppUser?> getCurrentUser();
  Future<AppUser?> signInWithGoogle();
  Future<void> logout();
}
