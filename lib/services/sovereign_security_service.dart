import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';

class SovereignSecurityService {
  static encrypt.Key _deriveKey(String secret) {
    final bytes = utf8.encode(secret);
    final normalized = List<int>.generate(32, (i) => bytes.isEmpty ? 0 : bytes[i % bytes.length]);
    return encrypt.Key(Uint8List.fromList(normalized));
  }

  static Future<File> exportEncryptedBackup({required Map<String, dynamic> data, required String bioKey, required String fileName}) async {
    final key = _deriveKey(bioKey);
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(jsonEncode(data), iv: iv);
    final payload = {'version': 2, 'iv': iv.base64, 'data': encrypted.base64};
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.mudabbir');
    return file.writeAsString(jsonEncode(payload));
  }

  static Future<Map<String, dynamic>?> importEncryptedBackup({required File file, required String bioKey}) async {
    try {
      final key = _deriveKey(bioKey);
      final parsed = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final iv = encrypt.IV.fromBase64(parsed['iv'].toString());
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
      final decrypted = encrypter.decrypt64(parsed['data'].toString(), iv: iv);
      return jsonDecode(decrypted) as Map<String, dynamic>;
    } catch (_) { return null; }
  }
}
