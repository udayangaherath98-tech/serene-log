import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../themes/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('About DayBloom',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.bg,
        elevation: 0,
        iconTheme:
            const IconThemeData(color: AppColors.textPrimary)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 20),

          // App Icon — DayBloom flower logo
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgCard,
              boxShadow: [BoxShadow(
                color: AppColors.primary
                    .withValues(alpha: 0.4),
                blurRadius: 20, spreadRadius: 3)],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/daybloom_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.wb_sunny_rounded,
                  size: 52, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('DayBloom',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28, fontWeight: FontWeight.w800,
              letterSpacing: 1)),
          const SizedBox(height: 6),
          const Text('Your daily wellness companion',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20)),
            child: const Text('Version 1.0.0',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold))),
          const SizedBox(height: 28),

          // About
          _card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                  Icons.info_outline_rounded,
                  'About This App'),
              const SizedBox(height: 12),
              const Text(
                'DayBloom is a personal wellness companion designed to help students, professionals, and everyday people manage their time, emotions, and daily life with clarity and calm.\n\nBuilt with the science of psychology, DayBloom helps you journal your feelings, organize your day, and find peace — even on the hardest days.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13, height: 1.7)),
            ])),
          const SizedBox(height: 16),

          // Features
          _card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                  Icons.star_rounded, 'Features'),
              const SizedBox(height: 14),
              for (final f in [
                ['📅', 'Calendar & Smart Event Reminders'],
                ['📖', 'Personal Journal & Diary'],
                ['✅', 'Daily To-Do List'],
                ['🧘', 'Breathing & Calm Exercises'],
                ['💙', 'Mood-based Calm Space'],
                ['👥', 'Personal Contacts Manager'],
                ['🌿', 'Psychology-based Themes'],
                ['🔒', 'Private & Secure — Offline'],
              ])
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    Text(f[0],
                        style: const TextStyle(
                            fontSize: 18)),
                    const SizedBox(width: 12),
                    Text(f[1],
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13)),
                  ])),
            ])),
          const SizedBox(height: 16),

          // Feedback & Ratings
          _card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(Icons.favorite_rounded, 'Love DayBloom?'),
              const SizedBox(height: 12),
              const Text(
                'Your feedback helps us grow and improve. Let us know what you think or how we can make DayBloom even better for you!',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13, height: 1.6)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showFeedbackDialog(context),
                  icon: const Icon(Icons.star_rounded, color: AppColors.amber),
                  label: const Text('Rate & Send Feedback',
                      style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.3))),
                  ),
                ),
              ),
            ])),
          const SizedBox(height: 16),

          // Developer — Lumora Ventures
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.blue.withValues(alpha: 0.2),
                AppColors.lavender.withValues(alpha: 0.15),
              ]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color:
                      AppColors.blue.withValues(alpha: 0.3))),
            child: Column(children: [
              // ✅ Real Lumora logo
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [BoxShadow(
                    color: const Color(0xFFD4A843)
                        .withValues(alpha: 0.3),
                    blurRadius: 15, spreadRadius: 2)],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/lumora_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Center(
                      child: Text('LV',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight:
                              FontWeight.w900))),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Developed by',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12)),
              const SizedBox(height: 4),
              const Text('Team Lumora Ventures',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5)),
              const SizedBox(height: 6),
              const Text('Innovating for a better tomorrow',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontStyle: FontStyle.italic)),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => launchUrl(
                  Uri.parse('https://lumoraventures.com/'),
                  mode: LaunchMode.externalApplication),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      AppColors.blue,
                      AppColors.lavender
                    ]),
                    borderRadius:
                        BorderRadius.circular(14),
                    boxShadow: [BoxShadow(
                      color: AppColors.blue
                          .withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 1)]),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.language_rounded,
                          color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('lumoraventures.com',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                      SizedBox(width: 6),
                      Icon(Icons.open_in_new_rounded,
                          color: Colors.white70, size: 14),
                    ])),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Legal
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05))),
            child: const Column(children: [
              Text(
                '© 2025 Lumora Ventures. All rights reserved.',
                style: TextStyle(
                  color: AppColors.textMuted, fontSize: 11),
                textAlign: TextAlign.center),
              SizedBox(height: 6),
              Text(
                'DayBloom is designed for personal wellness use only.',
                style: TextStyle(
                  color: AppColors.textMuted, fontSize: 11),
                textAlign: TextAlign.center),
            ])),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.07))),
      child: child,
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(children: [
      Icon(icon, color: AppColors.primary, size: 18),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 15)),
    ]);
  }

  void _showFeedbackDialog(BuildContext context) {
    int rating = 5;
    final ctrl = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Rate DayBloom', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppColors.amber,
                      size: 36,
                    ),
                    onPressed: () => setState(() => rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Any suggestions or feedback?',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            isSaving 
                ? const Padding(padding: EdgeInsets.all(8.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)))
                : ElevatedButton(
                    onPressed: () async {
                      setState(() => isSaving = true);
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        await FirebaseFirestore.instance.collection('app_feedback').add({
                          'uid': user?.uid ?? 'anonymous',
                          'timestamp': FieldValue.serverTimestamp(),
                          'rating': rating,
                          'feedback': ctrl.text.trim(),
                        });
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Thank you for your feedback! 💙', style: TextStyle(color: Colors.white)),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      } catch (e) {
                        setState(() => isSaving = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to submit: $e', style: const TextStyle(color: Colors.white)),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
          ],
        );
      }),
    );
  }
}