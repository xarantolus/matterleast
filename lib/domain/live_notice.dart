/// The quiet line for a live connection that has been down for a while;
/// a failed refresh's own text takes precedence where one is shown.
String? liveNotice({required bool socketDown, required bool offline}) {
  if (!socketDown) return null;
  return offline ? 'Offline' : 'Connecting…';
}
