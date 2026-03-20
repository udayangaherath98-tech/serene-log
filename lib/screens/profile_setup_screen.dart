import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../themes/app_theme.dart';
import 'main_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  State<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState
    extends State<ProfileSetupScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  File? _image;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameCtrl.text = prefs.getString('user_name') ?? '';
      _phoneCtrl.text = prefs.getString('user_phone') ?? '';
      _bioCtrl.text = prefs.getString('user_bio') ?? '';
      _addressCtrl.text =
          prefs.getString('user_address') ?? '';
      final pic = prefs.getString('profile_pic') ?? '';
      if (pic.isNotEmpty) _image = File(pic);
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, maxWidth: 400);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Name is required ⚠️'),
            backgroundColor: Colors.redAccent));
      return;
    }
    setState(() => _loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'user_name', _nameCtrl.text.trim());
      await prefs.setString(
          'user_phone', _phoneCtrl.text.trim());
      await prefs.setString(
          'user_bio', _bioCtrl.text.trim());
      await prefs.setString(
          'user_address', _addressCtrl.text.trim());
      if (_image != null) {
        await prefs.setString('profile_pic', _image!.path);
      }
      await prefs.setBool('profile_complete', true);

      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(
              builder: (_) => const MainScreen()));

      _syncToFirebase();
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _syncToFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'profile_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 15));
      await user.updateDisplayName(_nameCtrl.text.trim());
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg, elevation: 0,
        // ✅ No info icon — moved to dashboard
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context))
            : null,
        title: const Text('My Profile',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bg, AppColors.bgDeep])),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 20),
            child: Column(children: [
              const SizedBox(height: 10),

              // Profile Picture
              GestureDetector(
                onTap: _pickImage,
                child: Stack(children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                        color: AppColors.primary
                            .withValues(alpha: 0.4),
                        blurRadius: 25,
                        spreadRadius: 3)]),
                    child: CircleAvatar(
                      radius: 58,
                      backgroundColor: AppColors.primary
                          .withValues(alpha: 0.3),
                      backgroundImage: _image != null
                          ? FileImage(_image!) : null,
                      child: _image == null
                          ? const Icon(Icons.person,
                              size: 58,
                              color: AppColors.primary)
                          : null)),
                  Positioned(
                    bottom: 2, right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.bg, width: 2)),
                      child: const Icon(Icons.camera_alt,
                          size: 16,
                          color: Colors.white))),
                ])),
              const SizedBox(height: 8),
              const Text('Tap to change photo',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12)),
              const SizedBox(height: 30),

              _buildField(_nameCtrl, 'Full Name *',
                  Icons.person_outline, TextInputType.name),
              const SizedBox(height: 14),
              _buildField(_phoneCtrl, 'Phone Number',
                  Icons.phone_outlined, TextInputType.phone),
              const SizedBox(height: 14),
              _buildField(
                  _addressCtrl, 'Address (Optional)',
                  Icons.location_on_outlined,
                  TextInputType.streetAddress),
              const SizedBox(height: 14),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1))),
                child: TextField(
                  controller: _bioCtrl, maxLines: 3,
                  style: const TextStyle(
                      color: Colors.white),
                  decoration: const InputDecoration(
                    hintText:
                        'Bio — write something about yourself...',
                    hintStyle: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 42),
                      child: Icon(Icons.notes,
                          color: AppColors.primary)),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.all(16)))),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: AppColors.primary
                        .withValues(alpha: 0.4)),
                  child: _loading
                      ? const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2)),
                            SizedBox(width: 12),
                            Text('Saving...',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold)),
                          ])
                      : const Text('Save Profile 🌿',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold))),
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String hint,
      IconData icon, TextInputType type) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.1))),
      child: TextField(
        controller: c, keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted),
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 18)),
      ),
    );
  }
}