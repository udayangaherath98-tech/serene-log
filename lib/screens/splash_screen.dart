import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'profile_setup_screen.dart';
import '../themes/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();

    final isRegistered = prefs.getBool('is_registered') ?? false;
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final profileDone = prefs.getBool('profile_complete') ?? false;

    if (!mounted) return;

    if (!isRegistered) {
      // First install — Register
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const RegisterScreen()));
    } else if (!isLoggedIn) {
      // Registered but manually signed out
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else if (!profileDone) {
      // Logged in but profile incomplete
      Navigator.pushReplacement(context,
          MaterialPageRoute(
              builder: (_) => const ProfileSetupScreen()));
    } else {
      // ✅ Always go directly to Dashboard!
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const MainScreen()));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A2535),
              Color(0xFF1E2E3D),
              Color(0xFF1A2830),
            ],
          ),
        ),
        child: Stack(children: [
          Positioned(top: -80, right: -80,
            child: Container(width: 250, height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.06)))),
          Positioned(bottom: 100, left: -100,
            child: Container(width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: AppColors.blue.withValues(alpha: 0.05)))),
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo — same as login page
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bgCard,
                        boxShadow: [BoxShadow(
                          color: AppColors.primary
                              .withValues(alpha: 0.5),
                          blurRadius: 35, spreadRadius: 6)],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/daybloom_logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                            const Icon(Icons.wb_sunny_rounded,
                              size: 64, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text('DayBloom',
                      style: TextStyle(
                        fontSize: 40, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: 1.5)),
                    const SizedBox(height: 10),
                    Text('Your daily wellness companion 🌸',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.55),
                        letterSpacing: 0.5)),
                    const SizedBox(height: 70),
                    SizedBox(width: 36, height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary
                            .withValues(alpha: 0.7))),
                    const SizedBox(height: 80),
                    Text('by Team Lumora Ventures',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.3),
                        letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}