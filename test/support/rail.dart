import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/root/rail_selection.dart';

/// The rail's selection, kept in memory instead of settings, starting at
/// [start].
class MemoryRailSelection extends RailSelection {
  MemoryRailSelection([this.start]);

  final RailTarget? start;

  @override
  RailTarget? build() => start;

  @override
  void select(RailTarget? target) => state = target;
}
