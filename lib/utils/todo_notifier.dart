import 'package:flutter/foundation.dart';

/// Singleton notifier — TodoScreen increments this whenever tasks change.
/// HomeScreen listens to it and refreshes the progress bar instantly.
class TodoNotifier {
  TodoNotifier._();
  static final instance = ValueNotifier<int>(0);
}

class EventNotifier {
  EventNotifier._();
  static final instance = ValueNotifier<int>(0);
}
