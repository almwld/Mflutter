import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    _initialized = true;
  }

  FirebaseAuth get auth {
    if (!_initialized && Firebase.apps.isEmpty) {
      throw StateError('FirebaseService.initialize() must be awaited before auth access.');
    }
    return FirebaseAuth.instance;
  }
}
