import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/repositories/auth_repository.dart';
import '../../core/exceptions/failure.dart';
import '../../core/services/firebase/firebase_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseService _firebaseService = FirebaseService.instance;

  @override
  Future<Either<Failure, AppUser>> login(String email, String password) async {
    try {
      await _firebaseService.initialize();
      final credential = await _firebaseService.auth.signInWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if (user == null) return left(const Failure('فشل تسجيل الدخول'));
      return right(AppUser(id: user.uid, email: user.email ?? '', name: user.displayName ?? 'مستخدم'));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return left(Failure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return left(Failure('تعذر تسجيل الدخول: $e'));
    }
  }

  @override
  Future<Either<Failure, AppUser>> register(String email, String password, String name) async {
    try {
      await _firebaseService.initialize();
      final credential = await _firebaseService.auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if (user == null) return left(const Failure('فشل إنشاء الحساب'));
      await user.updateDisplayName(name);
      return right(AppUser(id: user.uid, email: user.email ?? '', name: name));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return left(Failure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return left(Failure('تعذر إنشاء الحساب: $e'));
    }
  }

  @override Future<void> logout() async { await _firebaseService.initialize(); await _firebaseService.auth.signOut(); }

  @override
  Future<AppUser?> getCurrentUser() async {
    await _firebaseService.initialize();
    final user = _firebaseService.auth.currentUser;
    return user == null ? null : AppUser(id: user.uid, email: user.email ?? '', name: user.displayName ?? 'مستخدم');
  }

  String _getAuthErrorMessage(String code) => switch (code) {
    'user-not-found' => 'المستخدم غير موجود',
    'wrong-password' => 'كلمة المرور غير صحيحة',
    'email-already-in-use' => 'البريد الإلكتروني مستخدم مسبقاً',
    'invalid-email' => 'البريد الإلكتروني غير صحيح',
    'weak-password' => 'كلمة المرور ضعيفة جداً',
    _ => 'حدث خطأ في المصادقة',
  };
}
