import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/domain/today.dart';

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
  final status = storedCustomStatus(props);
  return status != null && customStatusActive(status, now) ? status : null;
}

/// Pure: the custom status in a user's props whether or not it expired.
CustomStatus? storedCustomStatus(Map<String, Object?>? props) {
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
  return status;
}

/// Pure: when [status] clears, or null when it stays until changed. A
/// status without a duration never clears, whatever its date says.
DateTime? customStatusEnds(CustomStatus status) {
  final expires = status.expiresAt;
  if (status.duration.isEmpty || expires == null || expires.year <= 1) {
    return null;
  }
  return expires;
}

/// Pure: whether [status] still holds at [now].
bool customStatusActive(CustomStatus status, DateTime now) =>
    customStatusEnds(status)?.isAfter(now) ?? true;

/// Pure: a custom status as a tooltip: its text, then when it clears in
/// local time ("Until 17:00", "Until tomorrow at 09:00").
String customStatusTooltip(
  CustomStatus status,
  DateTime now, {
  required bool use24,
}) {
  final ends = customStatusEnds(status);
  final until = ends == null
      ? null
      : 'Until ${untilLabel(ends, now, use24: use24)}';
  return [if (status.text.isNotEmpty) status.text, ?until].join('\n');
}

/// Pure: the custom statuses the user set lately, newest first, from the
/// `recent_custom_statuses` preference the server keeps up to date.
List<CustomStatus> recentCustomStatuses(String? json) {
  final Object? decoded;
  try {
    decoded = jsonDecode(json ?? '');
  } on FormatException {
    return const [];
  }
  if (decoded is! List<Object?>) return const [];
  return [
    for (final item in decoded)
      if (item is Map<String, Object?>)
        CustomStatus.fromJson({
          for (final e in item.entries)
            if (e.value is String) e.key: e.value,
        }),
  ].where((s) => s.emoji.isNotEmpty || s.text.isNotEmpty).toList();
}

/// The user's time zone setting on the server: the phone's zone, which
/// the server last heard as [automaticZone], or [manualZone] picked by hand.
typedef ZoneSetting = ({
  bool automatic,
  String? automaticZone,
  String? manualZone,
});

/// Pure: the setting from the profile's values; automatic unless the
/// server says `false`, as the server defaults it.
ZoneSetting zoneSettingOf({
  String? useAutomatic,
  String? automatic,
  String? manual,
}) => (
  automatic: useAutomatic != 'false',
  automaticZone: automatic == null || automatic.isEmpty ? null : automatic,
  manualZone: manual == null || manual.isEmpty ? null : manual,
);

/// Pure: how the time zone setting reads in Settings.
String zoneSettingLabel(ZoneSetting setting) => setting.automatic
    ? switch (setting.automaticZone) {
        final zone? => 'Automatic · ${zoneLabel(zone)}',
        null => 'Automatic',
      }
    : zoneLabel(setting.manualZone ?? 'UTC');

/// Pure: an IANA zone as people read it: `America/New_York` as
/// "America / New York".
String zoneLabel(String zone) =>
    zone.replaceAll('_', ' ').replaceAll('/', ' / ');

/// Pure: the zones whose name contains every word of [query], ignoring
/// case, spaces and underscores.
List<String> matchingZones(Iterable<String> zones, String query) {
  final words = [
    for (final w in query.toLowerCase().split(RegExp(r'[\s/_]+')))
      if (w.isNotEmpty) w,
  ];
  return [
    for (final zone in zones)
      if (words.every(
        (w) => zone.toLowerCase().replaceAll('_', ' ').contains(w),
      ))
        zone,
  ];
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

/// The custom status duration that clears at a chosen moment.
const customStatusDateAndTime = 'date_and_time';

/// Pure: whether a custom status can be set to clear at [chosen]: only a
/// moment still ahead of [now].
bool customStatusEndValid(DateTime? chosen, DateTime now) =>
    chosen != null && chosen.isAfter(now);

/// When a custom status set now with [duration] clears, in the user's local
/// time; null for "don't clear" (an empty duration). "Today" and "this
/// week" end at the last moment of the day and of Sunday, the way the
/// official apps send them, so other clients read them the same.
/// `date_and_time` clears at [chosen].
DateTime? customStatusExpiry(
  String duration,
  DateTime now, {
  DateTime? chosen,
}) {
  final local = now.toLocal();
  DateTime endOfDay(int day) =>
      DateTime(local.year, local.month, day, 23, 59, 59, 999);
  return switch (duration) {
    'thirty_minutes' => local.add(const Duration(minutes: 30)),
    'one_hour' => local.add(const Duration(hours: 1)),
    'four_hours' => local.add(const Duration(hours: 4)),
    'today' => endOfDay(local.day),
    'this_week' => endOfDay(local.day + DateTime.sunday - local.weekday),
    customStatusDateAndTime => chosen?.toLocal(),
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
    DndLength.tomorrow => tomorrowMorning(now),
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
    @Default(false) bool isGuest,
    required bool isMe,
  }) = _UserProfile;
}
