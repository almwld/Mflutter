import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

/// =============================================================================
/// PermissionUtils - أدوات التصريح
/// =============================================================================
/// إدارة صلاحيات التطبيق
/// =============================================================================

class PermissionUtils {
  PermissionUtils._();

  // ═══════════════════════════════════════════════════════════════════════════
  // صلاحيات التخزين
  // ═══════════════════════════════════════════════════════════════════════════

  /// طلب تصريح التخزين
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // للماحظة Android 11+ يستخدم MANAGE_EXTERNAL_STORAGE
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  /// طلب تصريح التخزين الخارجي
  static Future<bool> requestManageStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    }
    return true;
  }

  /// التحقق من تصريح التخزين
  static Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      return await Permission.storage.isGranted;
    }
    return true;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // صلاحيات الكاميرا
  // ═══════════════════════════════════════════════════════════════════════════

  /// طلب تصريح الكاميرا
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// التحقق من تصريح الكاميرا
  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // صلاحيات الموقع
  // ═══════════════════════════════════════════════════════════════════════════

  /// طلب تصريح الموقع
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// التحقق من تصريح الموقع
  static Future<bool> hasLocationPermission() async {
    return await Permission.location.isGranted;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // صلاحيات الإشعارات
  // ═══════════════════════════════════════════════════════════════════════════

  /// طلب تصريح الإشعارات
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// التحقق من تصريح الإشعارات
  static Future<bool> hasNotificationPermission() async {
    return await Permission.notification.isGranted;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // صلاحيات الميكروفون
  // ═══════════════════════════════════════════════════════════════════════════

  /// طلب تصريح الميكروفون
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// التحقق من تصريح الميكروفون
  static Future<bool> hasMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // فتح إعدادات التطبيق
  // ═══════════════════════════════════════════════════════════════════════════

  /// فتح إعدادات التطبيق
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // دوال مساعدة
  // ═══════════════════════════════════════════════════════════════════════════

  /// طلب جميع الصلاحيات المطلوبة
  static Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    return await [
      Permission.storage,
      Permission.camera,
      Permission.location,
      Permission.notification,
      Permission.microphone,
    ].request();
  }

  /// التحقق من جميع الصلاحيات
  static Future<bool> checkAllPermissions() async {
    final storage = await Permission.storage.isGranted;
    final camera = await Permission.camera.isGranted;
    return storage && camera;
  }

  /// الحصول على حالة التصريح
  static Future<PermissionStatus> getPermissionStatus(Permission permission) async {
    return await permission.status;
  }

  /// التحقق مما إذا كان التصريح مرفوضاً نهائياً
  static Future<bool> isPermanentlyDenied(Permission permission) async {
    return await permission.isPermanentlyDenied;
  }

  /// التحقق مما إذا كان التصريح مقيداً
  static Future<bool> isRestricted(Permission permission) async {
    return await permission.isRestricted;
  }

  /// التحقق مما إذا كان التصريح محدوداً
  static Future<bool> isLimited(Permission permission) async {
    return await permission.isLimited;
  }
}