import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_security.dart';
import '../themes/app_theme.dart';
import 'main_screen.dart';
import 'profile_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Color(0xFF0F2D1A),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _login() async {
    final canAttempt = await AuthSecurity.canAttemptLogin();
    if (!canAttempt) {
      final mins = await AuthSecurity.getRemainingLockMinutes();
      setState(() {
        _error = 'Too many attempts. Try again in $mins minutes 🔒';
        _loading = false;
      });
      return;
    }

    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }
    if (!_emailCtrl.text.contains('@') ||
        !_emailCtrl.text.contains('.')) {
      setState(() => _error = 'Enter a valid email address');
      return;
    }

    setState(() { _loading = true; _error = ''; });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim().toLowerCase(),
        password: _passCtrl.text,
      );

      await AuthSecurity.resetAttempts();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setBool('is_registered', true);
      
      bool profileDone = false;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('profiles')
              .doc(user.uid)
              .get();
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            await prefs.setString('user_name', data['name'] ?? '');
            await prefs.setString('user_phone', data['phone'] ?? '');
            await prefs.setString('user_address', data['address'] ?? '');
            await prefs.setString('user_bio', data['bio'] ?? '');
            await prefs.setBool('profile_complete', true);
            profileDone = true;
          } else {
            // Check users collection just for the name if profile incomplete
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
            if (userDoc.exists && userDoc.data() != null) {
              await prefs.setString('user_name', userDoc.data()!['name'] ?? '');
            }
          }
        } catch (e) {
          debugPrint('Profile fetch error: $e');
        }
      }
      
      if (!profileDone) {
        profileDone = prefs.getBool('profile_complete') ?? false;
      }

      if (!mounted) return;
      Navigator.pushReplacement(context,
        MaterialPageRoute(
          builder: (_) => profileDone
              ? const MainScreen()
              : const ProfileSetupScreen()));
    } on FirebaseAuthException catch (e) {
      await AuthSecurity.recordFailedAttempt();
      final attempts = await AuthSecurity.getAttempts();
      final remaining = AuthSecurity.maxAttempts - attempts;
      setState(() {
        _error = remaining > 0
            ? '${e.message ?? 'Login failed'}\n$remaining attempts remaining'
            : 'Account locked for 15 minutes 🔒';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xFF0F2D1A),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F2D1A),
        body: Container(
          // ✅ Full page same gradient — no color bar
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A2535),
                Color(0xFF162A1E),
                Color(0xFF0F2D1A),
              ],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: Stack(children: [
            Positioned(top: -80, right: -80,
              child: Container(width: 250, height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary
                      .withValues(alpha: 0.06)))),
            Positioned(bottom: -80, left: -80,
              child: Container(width: 280, height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // ✅ Same gradient color — no black bar
                  color: const Color(0xFF0F2D1A)
                      .withValues(alpha: 0.5)))),
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    28, 40, 28, 40),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top - 80),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      // ✅ DayBloom flower logo
                      Container(
                        width: 110, height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.bgCard,
                          boxShadow: [BoxShadow(
                            color: AppColors.primary
                                .withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 4)],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/daybloom_logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                              const Icon(
                                Icons.wb_sunny_rounded,
                                size: 56,
                                color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Welcome Back 🌿',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1)),
                      const SizedBox(height: 8),
                      Text('Sign in to DayBloom',
                        style: TextStyle(
                          color: Colors.white
                              .withValues(alpha: 0.5),
                          fontSize: 14)),
                      const SizedBox(height: 48),

                      _field(_emailCtrl, 'Email',
                          Icons.email_outlined),
                      const SizedBox(height: 16),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withValues(alpha: 0.07),
                          borderRadius:
                              BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white
                                .withValues(alpha: 0.1))),
                        child: TextField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          style: const TextStyle(
                              color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(
                              color: Colors.white
                                  .withValues(alpha: 0.4)),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: AppColors.primary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                                color: Colors.white38),
                              onPressed: () => setState(
                                () => _obscure = !_obscure)),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 18)),
                        ),
                      ),

                      if (_error.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red
                                .withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(10)),
                          child: Text(_error,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13))),
                      ],

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity, height: 56,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16)),
                            elevation: 8,
                            shadowColor: AppColors.primary
                                .withValues(alpha: 0.4)),
                          child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Sign In',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text('by Team Lumora Ventures',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white
                              .withValues(alpha: 0.3))),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint,
      IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1))),
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.4)),
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 18)),
      ),
    );
  }
}