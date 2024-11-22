import 'package:brainwave/src/features/authentication/domain/entities/app_user.dart';
import 'package:brainwave/src/features/authentication/domain/repo/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  Future<AppUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: gAuth.idToken,
        accessToken: gAuth.accessToken,
      );

      UserCredential uCredential =
          await firebaseAuth.signInWithCredential(credential);

      AppUser user = AppUser(
          uid: uCredential.user!.uid,
          email: uCredential.user!.email!,
          name: "");

      return user;
    } catch (e) {
      throw Exception("Failed to login: $e");
    }
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
