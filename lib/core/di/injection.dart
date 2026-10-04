import '../services/firebase/firebase_service.dart';

T sl<T>() {
  if (T == FirebaseService) return FirebaseService.instance as T;
  throw StateError('No service registered for $T');
}
