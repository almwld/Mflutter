import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';

class SovereignSecurityService {
  static encrypt.Key _deriveKey(String bioSignature) {
    final padded = bioSignature.padRight(32, 'م').substring(0, 32);
    return encrypt.Key.fromUtf8(padded);
  }

  static Future<File> exportEncryptedBackup({
    required Map<String, dynamic> data,
    required String bioKey,
    required String fileName,
  }) async {
    final key = _deriveKey(bioKey);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final json = jsonEncode(data);
    final encrypted = encrypter.encrypt(json, iv: iv);
    final payload = {"iv": iv.base64, "data": encrypted.base64};
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.mudabbir');
    return await file.writeAsString(jsonEncode(payload));
  }

  static Future<Map<String, dynamic>?> importEncryptedBackup({
    required File file,
    required String bioKey,
  }) async {
    try {
      final key = _deriveKey(bioKey);
      final content = await file.readAsString();
      final parsed = jsonDecode(content);
      final iv = encrypt.IV.fromBase64(parsed['iv']);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final decrypted = encrypter.decrypt64(parsed['data'], iv: iv);
      return jsonDecode(decrypted);
    } catch (_) {
      return null;
    }
  }
}
