import 'package:local_auth/local_auth.dart';

class BiometricSecurityService {
  BiometricSecurityService._();
  static final instance = BiometricSecurityService._();
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isSupported() async {
    try { return await _auth.isDeviceSupported(); } catch (_) { return false; }
  }

  Future<List<BiometricType>> availableTypes() async {
    try { return await _auth.getAvailableBiometrics(); } catch (_) { return const []; }
  }

  Future<bool> authenticate({
    String reason = 'تحقق من هويتك للوصول إلى البيانات المحمية',
    bool biometricOnly = true,
  }) async {
    try {
      if (!await isSupported()) return false;
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException { return false; }
  }
}
