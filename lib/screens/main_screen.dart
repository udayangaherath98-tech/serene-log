import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_theme.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'journal_screen.dart' as journal;
import 'todo_screen.dart';
import 'login_screen.dart';
import '../services/notification_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await NotificationService.instance.requestPermissionsAsync();
  }

  late final List<Widget> _screens = [
    HomeScreen(onSwitchToCalendar: () => setState(() => _index = 1)),
    const CalendarScreen(),
    const journal.JournalScreen(),
    const TodoScreen(),
  ];

  final _navItems = const [
    {'icon': Icons.home_rounded,
     'outline': Icons.home_outlined,
     'label': 'Home'},
    {'icon': Icons.calendar_month_rounded,
     'outline': Icons.calendar_month_outlined,
     'label': 'Calendar'},
    {'icon': Icons.auto_stories_rounded,
     'outline': Icons.auto_stories_outlined,
     'label': 'Journal'},
    {'icon': Icons.checklist_rounded,
     'outline': Icons.checklist_outlined,
     'label': 'To-Do'},
  ];

  void _signOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out',
          style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure?',
          style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
              style: TextStyle(color: AppColors.primary))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              final prefs =
                  await SharedPreferences.getInstance();
              await prefs.setBool('is_logged_in', false);
              if (!mounted) return;
              Navigator.pushReplacement(context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
            child: const Text('Sign Out',
              style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgDeep,
          border: Border(
            top: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.15),
              width: 0.5)),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 8, horizontal: 8),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                // Nav items
                ..._navItems.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final active = _index == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _index = i),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(
                            milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          color: active
                            ? AppColors.primary
                                .withValues(alpha: 0.12)
                            : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(14)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              active
                                ? item['icon'] as IconData
                                : item['outline'] as IconData,
                              color: active
                                ? AppColors.primary
                                : AppColors.textMuted,
                              size: 22),
                            const SizedBox(height: 3),
                            Text(item['label'] as String,
                              style: TextStyle(
                                color: active
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                                fontSize: 10,
                                fontWeight: active
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                          ]),
                      ),
                    ));
                }),

                // Sign out
                Expanded(
                  child: GestureDetector(
                    onTap: _signOut,
                    behavior: HitTestBehavior.opaque,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 8),
                        Icon(Icons.logout_rounded,
                          color: AppColors.textMuted,
                          size: 20),
                        SizedBox(height: 3),
                        Text('Out',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10)),
                        SizedBox(height: 8),
                      ]),
                  )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}