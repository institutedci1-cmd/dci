import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';

class AuthService {
  final Ref ref;

  AuthService(this.ref);

  Future<void> signInWithEmail(String email, String password) async {
    final authRepo = ref.read(authRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    await authRepo.signInWithEmail(email, password);

    await auditRepo.logAction(
      module: 'AUTH',
      action: 'LOGIN',
      metadata: {'email': email},
    );
  }

  Future<void> signOut() async {
    final authRepo = ref.read(authRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);
    final user = authRepo.currentUser;

    await authRepo.signOut();

    await auditRepo.logAction(
      module: 'AUTH',
      action: 'LOGOUT',
      metadata: {'userId': user?.uid},
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final authRepo = ref.read(authRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    await authRepo.sendPasswordResetEmail(email);

    await auditRepo.logAction(
      module: 'AUTH',
      action: 'PASSWORD_RESET',
      metadata: {'email': email},
    );
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});
