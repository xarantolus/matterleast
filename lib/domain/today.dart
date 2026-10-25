/// Pure: the local calendar day of [now], as midnight.
DateTime localDay(DateTime now) {
  final local = now.toLocal();
  return DateTime(local.year, local.month, local.day);
}

/// Pure: how long until the local day after [now] begins. Built from the
/// calendar, so a 23 or 25 hour day around a clock change still ends at
/// midnight.
Duration untilNextDay(DateTime now) {
  final local = now.toLocal();
  final next = DateTime(local.year, local.month, local.day + 1);
  return next.difference(local);
}
