import 'package:shared_preferences/shared_preferences.dart';

class AuthSecurity {
  static const int maxAttempts = 5;
  static const int lockMinutes = 15;

  static Future<bool> canAttemptLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = prefs.getInt('login_attempts') ?? 0;
    final lockTime = prefs.getInt('lock_until') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (lockTime > 0 && now < lockTime) return false;
    if (lockTime > 0 && now >= lockTime) {
      await prefs.setInt('login_attempts', 0);
      await prefs.setInt('lock_until', 0);
    }
    return attempts < maxAttempts;
  }

  static Future<int> getRemainingLockMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    final lockTime = prefs.getInt('lock_until') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (lockTime <= now) return 0;
    return ((lockTime - now) / 60000).ceil();
  }

  static Future<void> recordFailedAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts =
        (prefs.getInt('login_attempts') ?? 0) + 1;
    await prefs.setInt('login_attempts', attempts);
    if (attempts >= maxAttempts) {
      final lockUntil = DateTime.now()
          .add(const Duration(minutes: lockMinutes))
          .millisecondsSinceEpoch;
      await prefs.setInt('lock_until', lockUntil);
    }
  }

  static Future<void> resetAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('login_attempts', 0);
    await prefs.setInt('lock_until', 0);
  }

  static Future<int> getAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('login_attempts') ?? 0;
  }
}