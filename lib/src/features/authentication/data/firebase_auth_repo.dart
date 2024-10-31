import 'package:brainwave/src/features/authentication/domain/entities/app_user.dart';
import 'package:brainwave/src/features/authentication/domain/repo/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  @override
  Future<AppUser?> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      AppUser user = AppUser(uid: credential.user!.uid, email: email, name: '');

      return user;
    } catch (e) {
      throw Exception("Failed to login: $e");
    }
  }

  @override
  Future<AppUser?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      AppUser user = AppUser(uid: credential.user!.uid, email: email, name: '');

      return user;
    } catch (e) {
      throw Exception("Failed to login: $e");
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return null;
    }
    return AppUser(uid: firebaseUser.uid, email: firebaseUser.email!, name: '');
  }
}
