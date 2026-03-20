import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../themes/app_theme.dart';
import '../utils/todo_notifier.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});
  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Map<String, dynamic>> _todos = [];
  final _ctrl = TextEditingController();

  String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool notify = false}) async {
    final data =
        await DBHelper.instance.getTodosByDate(_today());
    setState(() => _todos = data);
    if (notify) TodoNotifier.instance.value++;
  }

  Future<void> _addTodo() async {
    if (_ctrl.text.trim().isEmpty) return;
    await DBHelper.instance.insertTodo({
      'title': _ctrl.text.trim(),
      'date': _today(),
      'is_completed': 0
    });
    _ctrl.clear();
    _load(notify: true);
  }

  Future<void> _toggle(Map<String, dynamic> todo) async {
    await DBHelper.instance.updateTodo({
      ...todo,
      'is_completed': todo['is_completed'] == 1 ? 0 : 1
    });
    _load(notify: true);
  }

  int get _completed =>
      _todos.where((t) => t['is_completed'] == 1).length;
  bool get _allDone =>
      _todos.isNotEmpty && _completed == _todos.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.todoGrad1,
              AppColors.todoGrad2,
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
                const Text("Today's Tasks ✅",
                  style: TextStyle(
                    color: AppColors.textTodo,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.todoAccent
                        .withValues(alpha: 0.2),
                    borderRadius:
                        BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.todoAccent
                          .withValues(alpha: 0.4))),
                  child: Text(
                    '$_completed / ${_todos.length}',
                    style: const TextStyle(
                      color: AppColors.todoAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13))),
              ])),

          // Completion message
          if (_allDone)
            Container(
              margin: const EdgeInsets.fromLTRB(
                  16, 0, 16, 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.todoAccent
                      .withValues(alpha: 0.2),
                  AppColors.todoAccent
                      .withValues(alpha: 0.1),
                ]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.todoAccent
                      .withValues(alpha: 0.5))),
              child: const Row(children: [
                Text('🎉',
                    style: TextStyle(fontSize: 28)),
                SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text("Outstanding! All done! 🌟",
                      style: TextStyle(
                        color: AppColors.textTodo,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                    Text(
                      "You showed up for yourself today 💚",
                      style: TextStyle(
                        color: AppColors.todoAccent,
                        fontSize: 12)),
                  ])),
              ])),

          // Add task
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: Row(children: [
              Expanded(child: Container(
                decoration: BoxDecoration(
                  color: AppColors.todoCard
                      .withValues(alpha: 0.8),
                  borderRadius:
                      BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.todoAccent
                        .withValues(alpha: 0.2))),
                child: TextField(
                  controller: _ctrl,
                  style: const TextStyle(
                      color: AppColors.textTodo),
                  onSubmitted: (_) => _addTodo(),
                  decoration: const InputDecoration(
                    hintText: 'Add a new task...',
                    hintStyle: TextStyle(
                        color: AppColors.textMuted),
                    prefixIcon: Icon(
                      Icons.add_task_rounded,
                      color: AppColors.todoAccent),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14))))),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _addTodo,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: AppColors.todoAccent,
                    shape: BoxShape.circle),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.todoBg, size: 20))),
            ])),

          // Tasks list
          Expanded(
            child: _todos.isEmpty
              ? Center(child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(Icons.checklist_rounded,
                      color: AppColors.todoAccent
                          .withValues(alpha: 0.3),
                      size: 64),
                    const SizedBox(height: 16),
                    Text('No tasks for today',
                      style: TextStyle(
                        color: AppColors.textTodo
                            .withValues(alpha: 0.6),
                        fontSize: 16)),
                    const Text('Add your first task above 🌿',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13)),
                  ]))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16),
                  itemCount: _todos.length,
                  itemBuilder: (_, i) {
                    final t = _todos[i];
                    final done = t['is_completed'] == 1;
                    return Dismissible(
                      key: Key(t['id'].toString()),
                      direction:
                          DismissDirection.endToStart,
                      background: Container(
                        alignment:
                            Alignment.centerRight,
                        padding: const EdgeInsets.only(
                            right: 20),
                        margin: const EdgeInsets.only(
                            bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.redAccent
                              .withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(14)),
                        child: const Icon(
                          Icons.delete_rounded,
                          color: Colors.redAccent)),
                      onDismissed: (_) async {
                        await DBHelper.instance
                            .deleteTodo(t['id']);
                        _load(notify: true);
                      },
                      child: GestureDetector(
                        onTap: () => _toggle(t),
                        child: Container(
                          margin: const EdgeInsets.only(
                              bottom: 10),
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14),
                          decoration: BoxDecoration(
                            color: done
                              ? AppColors.todoAccent
                                  .withValues(alpha: 0.12)
                              : AppColors.todoCard
                                  .withValues(alpha: 0.8),
                            borderRadius:
                                BorderRadius.circular(14),
                            border: Border.all(
                              color: done
                                ? AppColors.todoAccent
                                    .withValues(alpha: 0.5)
                                : AppColors.todoAccent
                                    .withValues(
                                        alpha: 0.15))),
                          child: Row(children: [
                            Icon(
                              done
                                ? Icons
                                    .check_circle_rounded
                                : Icons.circle_outlined,
                              color: done
                                ? AppColors.todoAccent
                                : AppColors.textMuted,
                              size: 24),
                            const SizedBox(width: 14),
                            Expanded(child: Text(
                              t['title'],
                              style: TextStyle(
                                color: done
                                  ? AppColors.textMuted
                                  : AppColors.textTodo,
                                fontSize: 15,
                                decoration: done
                                  ? TextDecoration
                                      .lineThrough
                                  : null,
                                decorationColor:
                                    AppColors.textMuted))),
                          ]),
                        ),
                      ),
                    );
                  })),
        ])),
      ),
    );
  }
}