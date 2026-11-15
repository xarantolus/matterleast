import 'package:material_ui/material_ui.dart';

/// Lets the reader tick the tasks in the message text below: [onToggle]
/// flips the task with that index; null where the reader may not edit it.
class TaskToggle extends InheritedWidget {
  const TaskToggle({required this.onToggle, required super.child, super.key});

  final ValueChanged<int>? onToggle;

  static ValueChanged<int>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TaskToggle>()?.onToggle;

  @override
  bool updateShouldNotify(TaskToggle old) => onToggle != old.onToggle;
}
