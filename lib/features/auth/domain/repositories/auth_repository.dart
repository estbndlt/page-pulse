import '../entities/app_user.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> watchCurrentUser();
  Future<AppUser?> currentUser();
  Future<void> signInWithGoogle();
  Future<void> signOut();
}
