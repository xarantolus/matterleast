import 'dart:convert';

/// Post type of a message that burns after its recipients read it.
const burnOnReadType = 'burn_on_read';

/// Where a burn-on-read message stands for the reader.
sealed class BurnState {
  const BurnState();
}

/// Someone else's message, not opened yet: only a placeholder shows.
final class BurnUnrevealed extends BurnState {
  const BurnUnrevealed();
}

/// Readable; it burns at [at] when that is known (after the reader opened
/// it, or once every recipient has for the sender's own message).
final class BurnReadable extends BurnState {
  const BurnReadable(this.at);
  final DateTime? at;
}

/// Gone for this reader; it is removed here.
final class BurnExpired extends BurnState {
  const BurnExpired();
}

/// Pure: the state of a burn-on-read post at [now]. [expireAt] is the
/// post's `metadata.expire_at` (when it burns for this reader), [maxExpireAt]
/// its `props.expire_at` (when it burns for everyone).
BurnState burnState({
  required bool own,
  required DateTime? expireAt,
  required DateTime? maxExpireAt,
  required DateTime now,
}) {
  if (maxExpireAt != null && !now.isBefore(maxExpireAt)) {
    return const BurnExpired();
  }
  if (expireAt != null && !now.isBefore(expireAt)) return const BurnExpired();
  if (!own && expireAt == null) return const BurnUnrevealed();
  final ends = [?expireAt, ?maxExpireAt];
  return BurnReadable(
    ends.isEmpty ? null : ends.reduce((a, b) => a.isBefore(b) ? a : b),
  );
}

/// Pure: a countdown such as "9:41", "1:05:00" or "3 days".
String burnCountdown(Duration left) {
  if (left.isNegative) return '0:00';
  if (left.inDays >= 2) return '${left.inDays} days';
  final hours = left.inHours;
  final minutes = left.inMinutes % 60;
  final seconds = (left.inSeconds % 60).toString().padLeft(2, '0');
  return hours > 0
      ? '$hours:${minutes.toString().padLeft(2, '0')}:$seconds'
      : '$minutes:$seconds';
}

/// Pure: a duration as the composer names it, such as "10 min", "1 h" or
/// "2 days".
String burnDurationLabel(Duration d) {
  if (d.inDays >= 1 && d.inHours % 24 == 0) {
    return d.inDays == 1 ? '1 day' : '${d.inDays} days';
  }
  if (d.inHours >= 1 && d.inMinutes % 60 == 0) return '${d.inHours} h';
  if (d.inMinutes >= 1) return '${d.inMinutes} min';
  return '${d.inSeconds} s';
}

/// Pure: when a stored burn-on-read post burns, from its props and
/// metadata JSON: `metadata.expire_at` for this reader, `props.expire_at`
/// for everyone.
({DateTime? expireAt, DateTime? maxExpireAt}) burnEnds(
  String? propsJson,
  String? metadataJson,
) => (
  expireAt: _millis(jsonObjectOrEmpty(metadataJson)['expire_at']),
  maxExpireAt: _millis(jsonObjectOrEmpty(propsJson)['expire_at']),
);

DateTime? _millis(Object? value) {
  final ms = switch (value) {
    final num n => n.toInt(),
    final String s => int.tryParse(s),
    _ => null,
  };
  return ms == null || ms <= 0
      ? null
      : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
}

/// Pure: [json] as an object; empty when it is missing or not one.
Map<String, Object?> jsonObjectOrEmpty(String? json) {
  if (json == null || json.isEmpty) return const {};
  try {
    final decoded = jsonDecode(json);
    return decoded is Map<String, Object?> ? decoded : const {};
  } on FormatException {
    return const {};
  }
}
