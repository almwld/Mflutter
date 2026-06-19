import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // استخدام alias لتجنب التعارض
import '../../domain/repositories/auth_repository.dart';
import '../../core/exceptions/failure.dart';
import '../../core/services/firebase/firebase_service.dart';
import '../../core/di/injection.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseService _firebaseService = sl<FirebaseService>();

  @override
  Future<Either<Failure, AppUser>> login(String email, String password) async {
    try {
      final userCredential = await _firebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        return Either.right(AppUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'مستخدم',
        ));
      } else {
        return Either.left(const Failure('فشل تسجيل الدخول'));
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Either.left(Failure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Either.left(const Failure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, AppUser>> register(String email, String password, String name) async {
    try {
      final userCredential = await _firebaseService.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        await firebaseUser.updateDisplayName(name);
        return Either.right(AppUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: name,
        ));
      } else {
        return Either.left(const Failure('فشل إنشاء الحساب'));
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Either.left(Failure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Either.left(const Failure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseService.auth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _firebaseService.auth.currentUser;
    if (firebaseUser != null) {
      return AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? 'مستخدم',
      );
    }
    return null;
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'المستخدم غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم مسبقاً';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      default:
        return 'حدث خطأ في المصادقة';
    }
  }
}
