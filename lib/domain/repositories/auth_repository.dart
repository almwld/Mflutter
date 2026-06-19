import 'package:dartz/dartz.dart';
import '../../core/exceptions/failure.dart';

class AppUser {
  final String id;
  final String email;
  final String name;
  
  AppUser({required this.id, required this.email, required this.name});
}

abstract class AuthRepository {
  Future<Either<Failure, AppUser>> login(String email, String password);
  Future<Either<Failure, AppUser>> register(String email, String password, String name);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
}
