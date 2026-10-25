import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// A person's custom status as the server keeps it in their props
/// (`customStatus`, itself a JSON string).
@freezed
abstract class CustomStatus with _$CustomStatus {
  const factory CustomStatus({
    @Default('') String emoji,
    @Default('') String text,

    /// Empty for "don't clear", else `thirty_minutes`, `one_hour`,
    /// `four_hours`, `today`, `this_week` or `date_and_time`.
    @Default('') String duration,
    @JsonKey(name: 'expires_at', fromJson: _date, toJson: _dateJson)
    DateTime? expiresAt,
  }) = _CustomStatus;

  factory CustomStatus.fromJson(Map<String, Object?> json) =>
      _$CustomStatusFromJson(json);
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toUtc() : null;

String? _dateJson(DateTime? value) => value?.toUtc().toIso8601String();

/// Pure: the custom status in a user's props, or null when there is none
/// or it has expired by [now]. Other people's JSON: anything odd is no
/// status.
CustomStatus? customStatusOf(Map<String, Object?>? props, DateTime now) {
  final raw = props?['customStatus'];
  if (raw is! String || raw.isEmpty) return null;
  final Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException {
    return null;
  }
  if (decoded is! Map<String, Object?>) return null;
  final status = CustomStatus.fromJson({
    for (final e in decoded.entries)
      if (e.value is String) e.key: e.value,
  });
  if (status.emoji.isEmpty && status.text.isEmpty) return null;
  final expires = status.expiresAt;
  if (status.duration.isNotEmpty &&
      expires != null &&
      expires.year > 1 &&
      !expires.isAfter(now)) {
    return null;
  }
  return status;
}

/// Pure: the IANA zone a user's timezone settings stand for, or null.
String? timezoneName({
  String? useAutomatic,
  String? automatic,
  String? manual,
}) {
  final name = useAutomatic == 'false' ? manual : automatic;
  return (name == null || name.isEmpty) ? null : name;
}

/// When a custom status set now with [duration] clears, in the user's local
/// time; null for "don't clear" (an empty duration). "Today" ends at local midnight and "this
/// week" at the end of Sunday, as in the official apps.
DateTime? customStatusExpiry(String duration, DateTime now) {
  final local = now.toLocal();
  final midnight = DateTime(local.year, local.month, local.day + 1);
  return switch (duration) {
    'thirty_minutes' => local.add(const Duration(minutes: 30)),
    'one_hour' => local.add(const Duration(hours: 1)),
    'four_hours' => local.add(const Duration(hours: 4)),
    'today' => midnight,
    'this_week' => DateTime(
      local.year,
      local.month,
      local.day + (DateTime.sunday - local.weekday) + 1,
    ),
    _ => null,
  };
}

/// How long do not disturb lasts.
enum DndLength { untilChanged, thirtyMinutes, oneHour, twoHours, tomorrow }

/// Pure: when do not disturb set at [now] ends, in local time; null when
/// it lasts until the user changes it. "Tomorrow" ends at 9:00 the next
/// day, as on the web.
DateTime? dndEnd(DndLength length, DateTime now) {
  final local = now.toLocal();
  return switch (length) {
    DndLength.untilChanged => null,
    DndLength.thirtyMinutes => local.add(const Duration(minutes: 30)),
    DndLength.oneHour => local.add(const Duration(hours: 1)),
    DndLength.twoHours => local.add(const Duration(hours: 2)),
    DndLength.tomorrow => DateTime(local.year, local.month, local.day + 1, 9),
  };
}

/// Someone as their profile shows them.
@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String name,
    required String username,
    required String nickname,
    required String firstName,
    required String lastName,
    required String position,
    required String status,
    int? pictureUpdate,
    String? timezone,
    CustomStatus? customStatus,
    required bool isBot,
    required bool isMe,
  }) = _UserProfile;
}
