import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../themes/app_theme.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});
  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<Map<String, dynamic>> _journals = [];

  final Map<String, Color> _moodBg = {
    'happy':    AppColors.moodHappy,
    'neutral':  AppColors.moodNeutral,
    'sad':      AppColors.moodSad,
    'angry':    AppColors.moodAngry,
    'grateful': AppColors.moodGrateful,
    'lovely':   const Color(0xFF7B2D5A),
    'calm':     const Color(0xFF1E3A5F),
    'normal':   const Color(0xFF2A3040),
    'joy':      const Color(0xFF5A2D0C),
    'crying':   const Color(0xFF1A2A4A),
    'blessing': const Color(0xFF1A3828),
  };

  final Map<String, Color> _moodAccent = {
    'happy':    AppColors.primary,
    'neutral':  AppColors.blue,
    'sad':      AppColors.lavender,
    'angry':    const Color(0xFFEF6B6B),
    'grateful': AppColors.amber,
    'lovely':   const Color(0xFFE07AA0),
    'calm':     const Color(0xFF64B5F6),
    'normal':   const Color(0xFF90A4AE),
    'joy':      const Color(0xFFFFB74D),
    'crying':   const Color(0xFF81D4FA),
    'blessing': const Color(0xFF81C784),
  };

  final List<String> _prompts = [
    "What's weighing on your heart right now? 💭",
    "Tell me about your day — every detail matters 🌤️",
    "How are you really feeling beneath the surface? 🌊",
    "What do you need to release today? 🍂",
    "What made your soul stir today? ✨",
    "What truth are you avoiding? Speak it here. 🔮",
    "What are you grateful for in this moment? 🙏",
    "What would you tell your younger self today? 💌",
    "What is your body trying to tell you? 🫀",
    "Describe today in three honest words... 🌿",
    "What brought you joy, even briefly, today? 🌸",
    "What are you carrying that needs to be put down? 🍃",
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DBHelper.instance.getAllJournals();
    setState(() => _journals = data);
  }

  Map<String, int> _getMonthlySummary() {
    final now = DateTime.now();
    final monthStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final summary = <String, int>{
      'happy': 0, 'neutral': 0, 'sad': 0,
      'angry': 0, 'grateful': 0, 'lovely': 0,
      'calm': 0, 'normal': 0, 'joy': 0,
      'crying': 0, 'blessing': 0,
    };
    for (final j in _journals) {
      if (j['date'].toString().startsWith(monthStr)) {
        final mood = j['mood'] ?? 'neutral';
        summary[mood] = (summary[mood] ?? 0) + 1;
      }
    }
    return summary;
  }

  String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-'
        '${n.day.toString().padLeft(2, '0')}';
  }

  String _nowTime() {
    final n = DateTime.now();
    final h = n.hour;
    final m = n.minute.toString().padLeft(2, '0');
    return '${h > 12 ? h - 12 : (h == 0 ? 12 : h)}:$m '
        '${h >= 12 ? 'PM' : 'AM'}';
  }

  String _formatDate(String date) {
    try {
      final p = date.split('-');
      const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May',
          'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[int.parse(p[1])]} ${p[2]}, ${p[0]}';
    } catch (_) {
      return date;
    }
  }

  String get _prompt =>
      _prompts[DateTime.now().minute % _prompts.length];

  void _showDialog({Map<String, dynamic>? journal}) {
    final ctrl = TextEditingController(
        text: journal?['content'] ?? '');
    String mood = journal?['mood'] ?? 'neutral';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) {
          final bg = _moodBg[mood] ?? AppColors.moodNeutral;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bg.withValues(alpha: 0.92),
                  AppColors.bgDeep,
                ]),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28))),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 24, right: 24, top: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                // Handle
                Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 14),

                Text('${_today()}  •  ${_nowTime()}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12)),
                const SizedBox(height: 14),

                // Mood selector — 2-row wrap grid
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final m in [
                      {'k': 'happy',    'e': '😊'},
                      {'k': 'grateful', 'e': '🙏'},
                      {'k': 'calm',     'e': '😌'},
                      {'k': 'joy',      'e': '🥰'},
                      {'k': 'blessing', 'e': '🙌'},
                      {'k': 'normal',   'e': '😶'},
                      {'k': 'neutral',  'e': '😐'},
                      {'k': 'sad',      'e': '😢'},
                      {'k': 'crying',   'e': '😭'},
                      {'k': 'angry',    'e': '😠'},
                      {'k': 'lovely',   'e': '💕'},
                    ])
                      GestureDetector(
                        onTap: () =>
                            setM(() => mood = m['k']!),
                        child: AnimatedContainer(
                          duration: const Duration(
                              milliseconds: 180),
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: mood == m['k']
                              ? Colors.white
                                  .withValues(alpha: 0.25)
                              : Colors.white
                                  .withValues(alpha: 0.07),
                            borderRadius:
                                BorderRadius.circular(12),
                            border: Border.all(
                              color: mood == m['k']
                                ? Colors.white
                                    .withValues(alpha: 0.5)
                                : Colors.transparent)),
                          child: Text(m['e']!,
                            style: const TextStyle(
                                fontSize: 24)))),
                  ],
                ),
                const SizedBox(height: 14),

                // Text field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white
                          .withValues(alpha: 0.12))),
                  child: TextField(
                    controller: ctrl,
                    maxLines: 8,
                    autofocus: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15, height: 1.65),
                    decoration: InputDecoration(
                      hintText: _prompt,
                      hintStyle: TextStyle(
                        color: Colors.white
                            .withValues(alpha: 0.3),
                        fontSize: 14,
                        fontStyle: FontStyle.italic),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.all(18))),
                ),
                const SizedBox(height: 14),

                // Buttons
                Row(children: [
                  if (journal != null) ...[
                    Expanded(child: OutlinedButton(
                      onPressed: () async {
                        await DBHelper.instance
                            .deleteJournal(journal['id']);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        _load();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(
                            color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14)),
                      child: const Text('Delete'))),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (ctrl.text.trim().isEmpty) return;
                        final row = {
                          'title': '',
                          'content': ctrl.text.trim(),
                          'date': _today(),
                          'time': _nowTime(),
                          'mood': mood,
                        };
                        if (journal == null) {
                          await DBHelper.instance
                              .insertJournal(row);
                        } else {
                          await DBHelper.instance
                              .updateJournal(
                                  {...row, 'id': journal['id']});
                        }
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        _load();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white
                            .withValues(alpha: 0.18),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14)),
                      child: Text(
                        journal == null
                            ? 'Save ✍️' : 'Update',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15)))),
                ]),
                const SizedBox(height: 24),
              ]),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = _getMonthlySummary();
    final now = DateTime.now();
    final monthName = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May',
        'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][now.month];
    final hasMonthEntries = summary.values.any((v) => v > 0);

    final moodEntries = [
      {'k':'happy',    'e':'😊','c':AppColors.primary,           'l':'Happy'},
      {'k':'grateful', 'e':'🙏','c':AppColors.amber,             'l':'Grateful'},
      {'k':'calm',     'e':'😌','c':const Color(0xFF64B5F6),     'l':'Calm'},
      {'k':'joy',      'e':'🥰','c':const Color(0xFFFFB74D),     'l':'Joy'},
      {'k':'blessing', 'e':'🙌','c':const Color(0xFF81C784),     'l':'Blessing'},
      {'k':'normal',   'e':'😶','c':const Color(0xFF90A4AE),     'l':'Normal'},
      {'k':'neutral',  'e':'😐','c':AppColors.blue,              'l':'Neutral'},
      {'k':'sad',      'e':'😢','c':AppColors.lavender,          'l':'Sad'},
      {'k':'crying',   'e':'😭','c':const Color(0xFF81D4FA),     'l':'Crying'},
      {'k':'angry',    'e':'😠','c':const Color(0xFFEF6B6B),     'l':'Angry'},
      {'k':'lovely',   'e':'💕','c':const Color(0xFFE07AA0),     'l':'Lovely'},
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.journalGrad1,
              AppColors.journalGrad2,
            ])),
        child: SafeArea(child: Column(children: [

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('Journal 📖',
                  style: TextStyle(
                    color: AppColors.textJournal,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
                Text('${_journals.length} entries',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12)),
              ])),

          // Monthly mood summary in shape
          if (hasMonthEntries)
            Container(
              margin: const EdgeInsets.fromLTRB(
                  16, 0, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.journalCard
                      .withValues(alpha: 0.9),
                  AppColors.journalBg
                      .withValues(alpha: 0.8),
                ]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.journalAccent
                      .withValues(alpha: 0.3)),
                boxShadow: [BoxShadow(
                  color: AppColors.journalAccent
                      .withValues(alpha: 0.08),
                  blurRadius: 12, spreadRadius: 2)]),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.insights_rounded,
                      color: AppColors.journalAccent,
                      size: 16),
                    const SizedBox(width: 8),
                    Text('$monthName Mood Summary',
                      style: const TextStyle(
                        color: AppColors.textJournal,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                  ]),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                    children: moodEntries
                        .where((e) =>
                            (summary[e['k']] ?? 0) > 0)
                        .map((entry) => Column(children: [
                          Text(entry['e'] as String,
                            style: const TextStyle(
                                fontSize: 20)),
                          const SizedBox(height: 4),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3),
                            decoration: BoxDecoration(
                              color: (entry['c'] as Color)
                                  .withValues(alpha: 0.2),
                              borderRadius:
                                  BorderRadius.circular(10),
                              border: Border.all(
                                color: (entry['c'] as Color)
                                    .withValues(alpha: 0.4))),
                            child: Text(
                              '${summary[entry['k'] as String]}d',
                              style: TextStyle(
                                color: entry['c'] as Color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12))),
                          const SizedBox(height: 2),
                          Text(entry['l'] as String,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 9)),
                        ]))
                        .toList()),
                ])),

          // Journal entries — line rule style
          Expanded(
            child: _journals.isEmpty
              ? const Center(child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text('📖',
                      style: TextStyle(fontSize: 72)),
                    SizedBox(height: 20),
                    Text('Your story begins here...',
                      style: TextStyle(
                        color: AppColors.textJournal,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      'Tap Write — your thoughts are safe 🌿',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13)),
                  ]))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      20, 4, 20, 100),
                  itemCount: _journals.length,
                  itemBuilder: (_, i) {
                    final j = _journals[i];
                    final mood = j['mood'] ?? 'neutral';
                    final emoji = {
                      'happy': '😊', 'sad': '😢',
                      'angry': '😠', 'grateful': '🙏',
                      'neutral': '😐', 'lovely': '💕',
                      'calm': '😌', 'normal': '😶',
                      'joy': '🥰', 'crying': '😭',
                      'blessing': '🙌',
                    }[mood] ?? '😐';
                    final accent = _moodAccent[mood] ??
                        AppColors.primary;

                    return GestureDetector(
                      onTap: () =>
                          _showDialog(journal: j),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white
                                  .withValues(alpha: 0.07),
                              width: 0.5))),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Column(children: [
                              Text(emoji,
                                style: const TextStyle(
                                    fontSize: 18)),
                              const SizedBox(height: 6),
                              Container(
                                width: 2, height: 36,
                                decoration: BoxDecoration(
                                  color: accent
                                      .withValues(alpha: 0.35),
                                  borderRadius:
                                      BorderRadius.circular(1))),
                            ]),
                            const SizedBox(width: 14),
                            Expanded(child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [
                                    Text(
                                      _formatDate(j['date']),
                                      style: TextStyle(
                                        color: accent,
                                        fontWeight:
                                            FontWeight.w600,
                                        fontSize: 12)),
                                    Text(j['time'],
                                      style: const TextStyle(
                                        color:
                                            AppColors.textMuted,
                                        fontSize: 11)),
                                  ]),
                                const SizedBox(height: 6),
                                Text(j['content'],
                                  style: const TextStyle(
                                    color:
                                        AppColors.textJournal,
                                    fontSize: 14,
                                    height: 1.6),
                                  maxLines: 3,
                                  overflow:
                                      TextOverflow.ellipsis),
                              ])),
                          ]),
                      ),
                    );
                  }),
          ),
        ])),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDialog(),
        backgroundColor: AppColors.journalAccent,
        icon: const Icon(Icons.edit_rounded,
            color: Colors.white),
        label: const Text('Write',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold))),
    );
  }
}