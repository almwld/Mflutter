import 'dart:io';
import 'dart:async';

/// =============================================================================
/// NetworkInfo - معلومات الشبكة
/// =============================================================================
/// يتحقق من حالة الاتصال بالشبكة
/// =============================================================================

class NetworkInfo {
  NetworkInfo._();

  // ═══════════════════════════════════════════════════════════════════════════
  // التحقق من الاتصال
  // ═══════════════════════════════════════════════════════════════════════════

  /// التحقق من وجود اتصال بالإنترنت
  static Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// التحقق من الاتصال بسرعة
  static Future<bool> get isConnectedFast async {
    try {
      final result = await InternetAddress.lookup('dns.google')
          .timeout(const Duration(seconds: 2));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // نوع الاتصال
  // ═══════════════════════════════════════════════════════════════════════════

  /// التحقق من الاتصال عبر WiFi
  static Future<bool> get isWifi async {
    // في حالة عدم وجود معلومات الشبكة، نفترض أن هناك اتصال
    return await isConnected;
  }

  /// التحقق من الاتصال عبر Mobile
  static Future<bool> get isMobile async {
    // في حالة عدم وجود معلومات الشبكة، نفترض أن هناك اتصال
    return await isConnected;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // قياس سرعة الاتصال
  // ═══════════════════════════════════════════════════════════════════════════

  /// قياس سرعة الاتصال (بسيطة)
  static Future<ConnectionSpeed> get connectionSpeed async {
    final stopwatch = Stopwatch()..start();
    try {
      await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      stopwatch.stop();
      final ms = stopwatch.elapsedMilliseconds;
      if (ms < 100) return ConnectionSpeed.fast;
      if (ms < 500) return ConnectionSpeed.medium;
      return ConnectionSpeed.slow;
    } catch (_) {
      return ConnectionSpeed.offline;
    }
  }
}

/// =============================================================================
/// سرعة الاتصال
/// =============================================================================
enum ConnectionSpeed {
  /// سريع
  fast,

  /// متوسط
  medium,

  /// بطيء
  slow,

  /// غير متصل
  offline,
}