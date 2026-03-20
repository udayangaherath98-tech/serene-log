import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database/db_helper.dart';
import '../themes/app_theme.dart';
import '../services/notification_service.dart';
import '../utils/todo_notifier.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() =>
      _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();
  List<Map<String, dynamic>> _allEvents = [];
  List<Map<String, dynamic>> _dayEvents = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _loadAll() async {
    final all = await DBHelper.instance.getAllEvents();
    setState(() {
      _allEvents = all;
      _dayEvents = all
          .where((e) => e['date'] == _fmt(_selected))
          .toList();
    });
  }

  List _eventsForDay(DateTime day) =>
      _allEvents
          .where((e) => e['date'] == _fmt(day))
          .toList();

  Future<String?> _pickTime(BuildContext ctx,
      {String initial = ''}) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (initial.contains(':')) {
      try {
        final t = initial.toUpperCase();
        final parts = t
            .replaceAll('AM', '').replaceAll('PM', '')
            .trim().split(':');
        int h = int.parse(parts[0]);
        int m = int.parse(parts[1]);
        if (t.contains('PM') && h != 12) h += 12;
        if (t.contains('AM') && h == 12) h = 0;
        initialTime = TimeOfDay(hour: h, minute: m);
      } catch (_) {}
    }

    final picked = await showTimePicker(
      context: ctx, initialTime: initialTime,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.calendarAccent,
            surface: AppColors.calendarCard,
            onSurface: AppColors.textCalendar), dialogTheme: const DialogThemeData(backgroundColor: AppColors.calendarCard),
        ),
        child: child!,
      ),
    );

    if (picked == null) return null;
    final h = picked.hour;
    final m = picked.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:$m $period';
  }

  void _showEventDialog({Map<String, dynamic>? event}) {
    final titleCtrl =
        TextEditingController(text: event?['title'] ?? '');
    final descCtrl = TextEditingController(
        text: event?['description'] ?? '');
    String selectedTime = event?['time'] ?? '';

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.calendarCard,
                AppColors.calendarBg,
              ]),
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(28))),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.calendarAccent
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(
                event == null
                    ? '📅 Add Event' : '✏️ Edit Event',
                style: const TextStyle(
                  color: AppColors.textCalendar,
                  fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(_fmt(_selected),
                style: const TextStyle(
                  color: AppColors.calendarAccent,
                  fontSize: 12)),
              const SizedBox(height: 20),

              _calField(titleCtrl, 'Event Title *',
                  Icons.title_rounded),
              const SizedBox(height: 12),
              _calField(descCtrl, 'Description (optional)',
                  Icons.notes_rounded),
              const SizedBox(height: 12),

              // Time picker
              GestureDetector(
                onTap: () async {
                  final t = await _pickTime(context,
                      initial: selectedTime);
                  if (t != null) setM(() => selectedTime = t);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selectedTime.isNotEmpty
                        ? AppColors.calendarAccent
                            .withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.1))),
                  child: Row(children: [
                    Icon(Icons.access_time_rounded,
                      color: selectedTime.isNotEmpty
                        ? AppColors.calendarAccent
                        : AppColors.textMuted, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(
                      selectedTime.isNotEmpty
                        ? '⏰  Reminder at $selectedTime'
                        : 'Set reminder time (tap to pick)',
                      style: TextStyle(
                        color: selectedTime.isNotEmpty
                          ? AppColors.textCalendar
                          : AppColors.textMuted,
                        fontSize: 14))),
                    if (selectedTime.isNotEmpty)
                      GestureDetector(
                        onTap: () =>
                            setM(() => selectedTime = ''),
                        child: const Icon(Icons.clear_rounded,
                          color: AppColors.textMuted,
                          size: 18)),
                  ]),
                ),
              ),

              if (selectedTime.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(children: [
                    const Icon(Icons.notifications_active_rounded,
                      color: AppColors.calendarAccent,
                      size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Phone notification at $selectedTime',
                      style: const TextStyle(
                        color: AppColors.calendarAccent,
                        fontSize: 11)),
                  ])),

              const SizedBox(height: 20),
              Row(children: [
                if (event != null) ...[
                  Expanded(child: OutlinedButton(
                    onPressed: () async {
                      try {
                        final int deleteId = int.tryParse(event['id'].toString()) ?? 0;
                        await DBHelper.instance.deleteEvent(deleteId);
                        try {
                          await NotificationService.instance.cancelEventReminder(deleteId);
                        } catch(e) { debugPrint('Notification cancel error: $e'); }
                      } catch (e) {
                        debugPrint('Delete error: $e');
                      }
                      EventNotifier.instance.value++;
                      await _loadAll();
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
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
                Expanded(flex: 2, child: ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    
                    final Map<String, dynamic> row = {
                      'title': titleCtrl.text.trim(),
                      'description': descCtrl.text.trim(),
                      'date': _fmt(_selected),
                      'time': selectedTime,
                    };
                    
                    try {
                      int id;
                      if (event == null) {
                        id = await DBHelper.instance.insertEvent(row);
                      } else {
                        id = int.tryParse(event['id'].toString()) ?? 0;
                        await DBHelper.instance.updateEvent({...row, 'id': id});
                        try {
                          await NotificationService.instance.cancelEventReminder(id);
                        } catch(e) { debugPrint('Notification cancel error: $e'); }
                      }
                      
                      if (selectedTime.isNotEmpty) {
                        await NotificationService.instance
                            .scheduleEventReminder(
                          id: id,
                          title: titleCtrl.text.trim(),
                          date: _fmt(_selected),
                          time: selectedTime,
                        );
                      }
                    } catch (e) {
                      debugPrint('Save error: $e');
                    }
                    
                    EventNotifier.instance.value++;
                    await _loadAll();
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.calendarAccent,
                    foregroundColor: AppColors.calendarBg,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14)),
                  child: Text(
                    event == null ? 'Add Event' : 'Update',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF14213D))))),
              ]),
              const SizedBox(height: 24),
            ]),
        ),
      ),
    );
  }

  Widget _calField(TextEditingController c, String hint,
      IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.1))),
      child: TextField(
        controller: c,
        style: const TextStyle(color: AppColors.textCalendar),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              color: AppColors.textMuted, fontSize: 13),
          prefixIcon: Icon(icon,
              color: AppColors.calendarAccent, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 14))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.calendarGrad1,
              AppColors.calendarGrad2,
            ])),
        child: SafeArea(child: Column(children: [
          // AppBar
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('Calendar 📅',
                  style: TextStyle(
                    color: AppColors.textCalendar,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => _showEventDialog(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.calendarAccent
                          .withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.calendarAccent
                            .withValues(alpha: 0.4))),
                    child: const Icon(Icons.add_rounded,
                      color: AppColors.calendarAccent,
                      size: 22))),
              ])),

          // Calendar
          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.calendarCard
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.calendarAccent
                    .withValues(alpha: 0.15))),
            child: TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focused,
              selectedDayPredicate: (d) =>
                  isSameDay(d, _selected),
              eventLoader: _eventsForDay,
              onDaySelected: (sel, foc) {
                setState(() {
                  _selected = sel;
                  _focused = foc;
                  _dayEvents = _allEvents
                      .where((e) =>
                          e['date'] == _fmt(sel))
                      .toList();
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.calendarAccent
                      .withValues(alpha: 0.3),
                  shape: BoxShape.circle),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.calendarAccent,
                  shape: BoxShape.circle),
                defaultTextStyle: const TextStyle(
                  color: AppColors.textCalendar),
                weekendTextStyle: TextStyle(
                  color: AppColors.textCalendar
                      .withValues(alpha: 0.6)),
                outsideTextStyle: TextStyle(
                  color: AppColors.textMuted
                      .withValues(alpha: 0.4)),
                todayTextStyle: const TextStyle(
                  color: AppColors.calendarAccent,
                  fontWeight: FontWeight.bold),
                selectedTextStyle: const TextStyle(
                  color: Color(0xFF14213D),
                  fontWeight: FontWeight.bold),
                markerDecoration: const BoxDecoration(
                  color: AppColors.amber,
                  shape: BoxShape.circle),
                markerSize: 5,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: AppColors.textCalendar,
                  fontWeight: FontWeight.bold),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: AppColors.calendarAccent),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: AppColors.calendarAccent),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12),
                weekendStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 8),
            child: Divider(
              color: AppColors.calendarAccent
                  .withValues(alpha: 0.2),
              height: 1)),

          Expanded(
            child: _dayEvents.isEmpty
              ? Center(child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_note_rounded,
                      color: AppColors.calendarAccent
                          .withValues(alpha: 0.3),
                      size: 56),
                    const SizedBox(height: 12),
                    Text('No events on this day',
                      style: TextStyle(
                        color: AppColors.textCalendar
                            .withValues(alpha: 0.5),
                        fontSize: 15)),
                    const Text('Tap + to add one 🌿',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12)),
                  ]))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16),
                  itemCount: _dayEvents.length,
                  itemBuilder: (_, i) {
                    final e = _dayEvents[i];
                    return GestureDetector(
                      onTap: () =>
                          _showEventDialog(event: e),
                      child: Container(
                        margin: const EdgeInsets.only(
                            bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.calendarCard
                              .withValues(alpha: 0.8),
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.calendarAccent
                                .withValues(alpha: 0.25))),
                        child: Row(children: [
                          Container(
                            width: 3, height: 44,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.calendarAccent,
                              borderRadius:
                                  BorderRadius.circular(2))),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(e['title'],
                                style: const TextStyle(
                                  color:
                                      AppColors.textCalendar,
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 14)),
                              if ((e['time'] ?? '')
                                  .isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(children: [
                                  const Icon(
                                    Icons
                                        .notifications_active_rounded,
                                    color: AppColors
                                        .calendarAccent,
                                    size: 13),
                                  const SizedBox(width: 4),
                                  Text(e['time'],
                                    style: const TextStyle(
                                      color: AppColors
                                          .calendarAccent,
                                      fontSize: 12)),
                                ]),
                              ],
                              if ((e['description'] ?? '')
                                  .isNotEmpty)
                                Text(e['description'],
                                  style: TextStyle(
                                    color: AppColors
                                        .textCalendar
                                        .withValues(
                                            alpha: 0.5),
                                    fontSize: 12),
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis),
                            ])),
                          const Icon(Icons.edit_rounded,
                            color: AppColors.textMuted,
                            size: 16),
                        ]),
                      ),
                    );
                  })),
        ])),
      ),
    );
  }
}