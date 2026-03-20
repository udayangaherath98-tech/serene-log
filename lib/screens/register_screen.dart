import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_theme.dart';
import 'login_screen.dart';
import 'profile_setup_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String _errorMsg = '';

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMsg = 'Please fill all fields');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMsg = 'Passwords do not match');
      return;
    }
    if (password.length < 6) {
      setState(() =>
          _errorMsg = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'name': name,
        'email': email,
        'uid': cred.user!.uid,
        'created_at': FieldValue.serverTimestamp(),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_registered', true);
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);

      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(
              builder: (_) => const ProfileSetupScreen()));
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMsg = e.message ?? 'Registration failed';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2535),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2535),
              Color(0xFF162A1E),
              Color(0xFF0F2D1A),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                // ✅ DayBloom logo — same style as login page
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
                const SizedBox(height: 20),

                const Text('Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1)),
                const SizedBox(height: 6),
                Text('Your journey begins here 🌿',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white
                        .withValues(alpha: 0.5))),
                const SizedBox(height: 36),

                _buildField(_nameController, 'Full Name',
                    Icons.person_outline_rounded, false),
                const SizedBox(height: 16),
                _buildField(_emailController, 'Email Address',
                    Icons.email_outlined, false),
                const SizedBox(height: 16),
                _buildPasswordField(
                    _passwordController, 'Password',
                    _obscurePass,
                    () => setState(
                        () => _obscurePass = !_obscurePass)),
                const SizedBox(height: 16),
                _buildPasswordField(
                    _confirmController, 'Confirm Password',
                    _obscureConfirm,
                    () => setState(() =>
                        _obscureConfirm = !_obscureConfirm)),
                const SizedBox(height: 12),

                if (_errorMsg.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red
                          .withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(10)),
                    child: Text(_errorMsg,
                      style: const TextStyle(
                          color: Colors.redAccent))),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: AppColors.primary
                          .withValues(alpha: 0.4)),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : const Text('Create Account',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const LoginScreen())),
                  child: const Text(
                    'Already have an account? Sign In',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14))),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String hint,
      IconData icon, bool obscure) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.1))),
      child: TextField(
        controller: c, obscureText: obscure,
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

  Widget _buildPasswordField(TextEditingController c,
      String hint, bool obscure, VoidCallback toggle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.1))),
      child: TextField(
        controller: c, obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.4)),
          prefixIcon: const Icon(Icons.lock_outline_rounded,
              color: AppColors.primary),
          suffixIcon: IconButton(
            icon: Icon(
                obscure
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.white38),
            onPressed: toggle),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 18)),
      ),
    );
  }
}