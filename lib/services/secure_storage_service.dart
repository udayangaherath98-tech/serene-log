import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class SecureStorageService {
  static final SecureStorageService instance =
      SecureStorageService._();
  SecureStorageService._();

  static String _encrypt(String text, String key) {
    final bytes = utf8.encode(text);
    final keyBytes = utf8.encode(key);
    final encrypted = List<int>.generate(
      bytes.length,
      (i) => bytes[i] ^ keyBytes[i % keyBytes.length],
    );
    return base64.encode(encrypted);
  }

  static String _decrypt(String encrypted, String key) {
    try {
      final bytes = base64.decode(encrypted);
      final keyBytes = utf8.encode(key);
      final decrypted = List<int>.generate(
        bytes.length,
        (i) => bytes[i] ^ keyBytes[i % keyBytes.length],
      );
      return utf8.decode(decrypted);
    } catch (_) {
      return encrypted;
    }
  }

  Future<String> _getKey() async {
    final prefs = await SharedPreferences.getInstance();
    var key = prefs.getString('_dk') ?? '';
    if (key.isEmpty) {
      final rand = Random.secure();
      key = List.generate(
        32,
        (_) => rand
            .nextInt(256)
            .toRadixString(16)
            .padLeft(2, '0'),
      ).join();
      await prefs.setString('_dk', key);
    }
    return key;
  }

  Future<void> saveSecure(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    final encKey = await _getKey();
    await prefs.setString(key, _encrypt(value, encKey));
  }

  Future<String> getSecure(String key,
      {String defaultValue = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    final encKey = await _getKey();
    final value = prefs.getString(key) ?? '';
    if (value.isEmpty) return defaultValue;
    return _decrypt(value, encKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}