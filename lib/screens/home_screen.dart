import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';
import '../themes/app_theme.dart';
import '../services/notification_service.dart';
import '../utils/todo_notifier.dart';
import 'profile_setup_screen.dart';
import 'calm_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSwitchToCalendar;
  const HomeScreen({super.key, this.onSwitchToCalendar});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String _name = 'Friend';
  String _profilePic = '';
  List<Map<String, dynamic>> _todayEvents = [];
  int _completedTodos = 0;
  int _totalTodos = 0;
  String _currentQuote = '';
  Timer? _refreshTimer;

  late AnimationController _breathController;
  late Animation<double> _breathAnim;
  bool _breathing = false;
  int _breathPhase = 0;

  final _breathLabels = ['Breathe IN', 'Hold...', 'Breathe OUT'];
  final _breathColors = [AppColors.primary, AppColors.blue, AppColors.lavender];

  final List<String> _quotes = [
    "The cave you fear to enter holds the treasure you seek. 🌟",
    "You are not your thoughts. You are the one who observes them. 🧠",
    "Healing is not linear — and that's perfectly okay. 🌱",
    "The bravest thing you can do is feel your feelings fully. 💙",
    "Your setbacks are secretly setups for something greater. ⚡",
    "You don't have to be perfect to be worthy of love. 🌸",
    "Pain is inevitable. Suffering is optional. 🍃",
    "You survived 100% of your worst days. 💪",
    "Vulnerability is not weakness — it is the birthplace of courage. 🦁",
    "You are not broken. You are becoming. 🔨",
    "Rest is resistance in a world that demands constant hustle. 🌙",
    "What you resist persists. What you accept transforms. ☯️",
    "Courage is not the absence of fear — it's acting despite it. 🦅",
    "The mind that is still can solve what the busy mind cannot. 🏔️",
    "Forgiveness is not for them — it's for your own liberation. 🔓",
    "Self-compassion is the foundation of every other healing. ❤️‍🩹",
    "Growth requires discomfort. Embrace the stretch. 💥",
    "You are not falling apart — you are falling into yourself. 🌀",
    "Authenticity is the highest form of self-respect. 👑",
    "The present moment always will have been. Cherish it. ⏳",
    "You have permission to be a work in progress. 🎨",
    "Not all storms come to disrupt your life. Some clear your path. 🌩️",
    "You are the sky. Everything else is just the weather. 🌤️",
    "What would you do if you were not afraid? Do that. 🔥",
    "Be here. Be now. 🌿",
    "Your heart is brave. Keep going. ❤️‍🔥",
    "Stop shrinking yourself to fit spaces not designed for you. 🌳",
    "Your triggers are your teachers. Study them. 📚",
    "Done is better than perfect. Start. 🚀",
    "You came here to live fully — not just to survive. Live. 🎆",
  ];

  @override
  void initState() {
    super.initState();
    _setupBreathing();
    _loadData();
    _pickQuoteForSession();
    NotificationService.markAppUsed();
    _startAutoRefresh();
    // Fix 3: listen to todo changes for instant dashboard update
    TodoNotifier.instance.addListener(_onTodoChanged);
    EventNotifier.instance.addListener(_onEventChanged);
  }

  void _onTodoChanged() {
    if (mounted) _loadData();
  }

  void _onEventChanged() {
    if (mounted) _loadData();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadData();
    });
  }

  void _pickQuoteForSession() {
    final rand = Random();
    setState(() => _currentQuote = _quotes[rand.nextInt(_quotes.length)]);
  }

  void _setupBreathing() {
    _breathController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _breathAnim = Tween<double>(begin: 0.55, end: 1.0).animate(
        CurvedAnimation(parent: _breathController, curve: Curves.easeInOut));
  }

  void _startBreathing() async {
    setState(() => _breathing = true);
    for (int c = 0; c < 3 && _breathing; c++) {
      for (int phase = 0; phase < 3 && _breathing; phase++) {
        setState(() => _breathPhase = phase);
        if (phase == 0) {
          _breathController.forward();
        } else if (phase == 2) {
          _breathController.reverse();
        }
        await Future.delayed(const Duration(seconds: 4));
      }
    }
    if (mounted) {
      setState(() {
        _breathing = false;
        _breathPhase = 0;
      });
    }
    _breathController.reset();
  }

  void _stopBreathing() {
    setState(() => _breathing = false);
    _breathController.stop();
    _breathController.reset();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    final events = await DBHelper.instance.getEventsByDate(dateStr);
    final todos = await DBHelper.instance.getTodosByDate(dateStr);
    if (!mounted) return;
    setState(() {
      _name = prefs.getString('user_name') ?? 'Friend';
      _profilePic = prefs.getString('profile_pic') ?? '';
      _todayEvents = events;
      _totalTodos = todos.length;
      _completedTodos = todos.where((t) => t['is_completed'] == 1).length;
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    _refreshTimer?.cancel();
    TodoNotifier.instance.removeListener(_onTodoChanged);
    EventNotifier.instance.removeListener(_onEventChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';
    final allDone = _totalTodos > 0 && _completedTodos == _totalTodos;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
        Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
              Color(0xFF1A2535),
              Color(0xFF1E2E3D),
              Color(0xFF1A2830),
            ],
                    stops: [
              0.0,
              0.5,
              1.0
            ]))),
        Positioned(
            top: -80,
            right: -80,
            child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.06)))),
        Positioned(
            bottom: 150,
            left: -100,
            child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.blue.withValues(alpha: 0.05)))),
        SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$greeting,',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        letterSpacing: 0.3)),
                                Text(_name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                        fontStyle: FontStyle.italic)),
                              ]),
                        ),
                        Row(children: [
                          // ✅ App Info icon
                          GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AboutScreen())),
                              child: Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                      color: AppColors.bgCard
                                          .withValues(alpha: 0.6),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.1))),
                                  child: const Icon(Icons.info_outline_rounded,
                                      color: AppColors.textSecondary,
                                      size: 20))),

                          // Profile icon
                          GestureDetector(
                              onTap: () => Navigator.push(
                                      context, MaterialPageRoute(builder: (_) => const ProfileSetupScreen()))
                                  .then((_) => _loadData()),
                              child: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.primary, width: 2.5),
                                      boxShadow: [
                                        BoxShadow(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.3),
                                            blurRadius: 12,
                                            spreadRadius: 1)
                                      ]),
                                  child: CircleAvatar(
                                      radius: 24,
                                      backgroundColor: AppColors.primary
                                          .withValues(alpha: 0.2),
                                      backgroundImage: _profilePic.isNotEmpty &&
                                              File(_profilePic).existsSync()
                                          ? FileImage(File(_profilePic))
                                          : null,
                                      child: _profilePic.isEmpty ||
                                              !File(_profilePic).existsSync()
                                          ? const Icon(Icons.person,
                                              color: AppColors.primary,
                                              size: 24)
                                          : null))),
                        ]),
                      ]),
                  const SizedBox(height: 26),

                  // ── Quote ──
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('❝',
                        style: TextStyle(
                            color: AppColors.primary.withValues(alpha: 0.6),
                            fontSize: 30,
                            height: 0.9)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(_currentQuote,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                height: 1.7,
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.w500))),
                  ]),
                  const SizedBox(height: 28),

                  // ── Breathing ──
                  Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08))),
                      child: Column(children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Let's take a breath 🌬️",
                                        style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    Text(
                                        _breathing
                                            ? _breathLabels[_breathPhase]
                                            : '4-4-4 breathing • 36 seconds',
                                        style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12)),
                                  ]),
                              GestureDetector(
                                  onTap: _breathing
                                      ? _stopBreathing
                                      : _startBreathing,
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                          color: _breathing
                                              ? Colors.redAccent
                                                  .withValues(alpha: 0.2)
                                              : AppColors.primary
                                                  .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: _breathing
                                                  ? Colors.redAccent
                                                  : AppColors.primary,
                                              width: 1)),
                                      child: Text(_breathing ? 'Stop' : 'Begin',
                                          style: TextStyle(
                                              color: _breathing
                                                  ? Colors.redAccent
                                                  : AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13)))),
                            ]),
                        if (_breathing) ...[
                          const SizedBox(height: 24),
                          AnimatedBuilder(
                            animation: _breathAnim,
                            builder: (_, __) => Center(
                                child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                  Transform.scale(
                                      scale: _breathAnim.value * 1.4,
                                      child: Container(
                                          width: 110,
                                          height: 110,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _breathColors[_breathPhase]
                                                  .withValues(alpha: 0.08)))),
                                  Transform.scale(
                                      scale: _breathAnim.value * 1.15,
                                      child: Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _breathColors[_breathPhase]
                                                  .withValues(alpha: 0.15)))),
                                  Transform.scale(
                                      scale: _breathAnim.value,
                                      child: Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: RadialGradient(colors: [
                                                _breathColors[_breathPhase]
                                                    .withValues(alpha: 0.9),
                                                _breathColors[_breathPhase]
                                                    .withValues(alpha: 0.5),
                                              ]),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: _breathColors[
                                                            _breathPhase]
                                                        .withValues(alpha: 0.4),
                                                    blurRadius: 25,
                                                    spreadRadius: 5)
                                              ]),
                                          child: Center(
                                              child: Text(
                                                  _breathLabels[_breathPhase]
                                                      .split(' ')[0],
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13))))),
                                ])),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ])),
                  const SizedBox(height: 16),

                  // ── Todo Progress ──
                  if (_totalTodos > 0) ...[
                    Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: allDone
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: allDone
                                    ? AppColors.primary.withValues(alpha: 0.4)
                                    : Colors.white.withValues(alpha: 0.08))),
                        child: Row(children: [
                          Text(allDone ? '🎉' : '📋',
                              style: const TextStyle(fontSize: 26)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(
                                    allDone
                                        ? 'All tasks done! 🌟'
                                        : "Today's Progress",
                                    style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(height: 6),
                                allDone
                                    ? const Text('You showed up today 💙',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12))
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                            ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: LinearProgressIndicator(
                                                    value: _totalTodos > 0
                                                        ? _completedTodos /
                                                            _totalTodos
                                                        : 0,
                                                    backgroundColor:
                                                        Colors.white.withValues(
                                                            alpha: 0.08),
                                                    color: AppColors.primary,
                                                    minHeight: 6)),
                                            const SizedBox(height: 4),
                                            Text(
                                                '$_completedTodos / $_totalTodos',
                                                style: const TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 11)),
                                          ]),
                              ])),
                        ])),
                    const SizedBox(height: 16),
                  ],

                  // ── Today's Schedule ──
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Today's Schedule",
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text(
                            '${_todayEvents.length} event'
                            '${_todayEvents.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 12)),
                      ]),
                  const SizedBox(height: 10),
                  _todayEvents.isEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.05))),
                          child: const Center(
                              child: Text('No events today 🌿',
                                  style: TextStyle(color: AppColors.textMuted))))
                      : Column(
                          children: _todayEvents
                              .map((e) => GestureDetector(
                                  onTap: () =>
                                      widget.onSwitchToCalendar?.call(),
                                  child: Container(
                                      margin:
                                          const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.05),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.2))),
                                      child: Row(children: [
                                        Container(
                                            width: 3,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius:
                                                    BorderRadius.circular(2))),
                                        const SizedBox(width: 12),
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              Text(e['title'],
                                                  style: const TextStyle(
                                                      color:
                                                          AppColors.textPrimary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14)),
                                              if ((e['time'] ?? '').isNotEmpty)
                                                Text(e['time'],
                                                    style: const TextStyle(
                                                        color: AppColors.primary,
                                                        fontSize: 12)),
                                            ])),
                                        const Icon(Icons.edit_rounded,
                                            color: AppColors.textMuted,
                                            size: 14),
                                      ]))) as Widget)
                              .toList()),
                  const SizedBox(height: 16),

                  // ── Calm Invitation ──
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CalmScreen())),
                    child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.lavender.withValues(alpha: 0.25),
                                  AppColors.blue.withValues(alpha: 0.2),
                                ]),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                                color: AppColors.lavender
                                    .withValues(alpha: 0.25))),
                        child: const Row(children: [
                          Text('🌤️', style: TextStyle(fontSize: 34)),
                          SizedBox(width: 14),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('Hey, how are you really? 😊',
                                    style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                SizedBox(height: 4),
                                Text("I'm here — let's find some calm...",
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        height: 1.4)),
                              ])),
                          Icon(Icons.arrow_forward_ios_rounded,
                              color: AppColors.textMuted, size: 14),
                        ])),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
