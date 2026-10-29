import 'package:material_ui/material_ui.dart';

/// Sizes and times of the message area; [desktop] is a compact chat window,
/// [phone] is what touch needs.
@immutable
class AppDensity extends ThemeExtension<AppDensity> {
  const AppDensity({
    required this.avatar,
    required this.lineHeight,
    required this.rowTop,
    required this.followUpTop,
    required this.radius,
    required this.chipHeight,
    required this.chipRadius,
    required this.menuRowHeight,
    required this.threadBarHeight,
    required this.flat,
    required this.plainComposer,
    required this.fieldRadius,
    required this.arrive,
    required this.expand,
    required this.pageFade,
  });

  final double avatar;
  final double? lineHeight;
  final double rowTop;
  final double followUpTop;
  final double radius;
  final double? chipHeight;
  final double chipRadius;
  final double? menuRowHeight;
  final double threadBarHeight;

  /// No shadows on cards, pills and menus.
  final bool flat;

  /// A bordered message box with a formatting row, not a pill.
  final bool plainComposer;
  final double fieldRadius;
  final Duration arrive;
  final Duration expand;
  final Duration pageFade;

  static const phone = AppDensity(
    avatar: 36,
    lineHeight: null,
    rowTop: 8,
    followUpTop: 2,
    radius: 8,
    chipHeight: null,
    chipRadius: 8,
    menuRowHeight: null,
    threadBarHeight: 44,
    flat: false,
    plainComposer: false,
    fieldRadius: 24,
    arrive: Duration(milliseconds: 200),
    expand: Duration(milliseconds: 200),
    pageFade: Duration(milliseconds: 250),
  );

  static const desktop = AppDensity(
    avatar: 32,
    lineHeight: 1.35,
    rowTop: 4,
    followUpTop: 1,
    radius: 6,
    chipHeight: 24,
    chipRadius: 6,
    menuRowHeight: 30,
    threadBarHeight: 32,
    flat: true,
    plainComposer: true,
    fieldRadius: 6,
    arrive: Duration.zero,
    expand: Duration(milliseconds: 80),
    pageFade: Duration(milliseconds: 100),
  );

  /// The left gutter of a message: the avatar and the space after it.
  double get gutter => avatar + 12;

  @override
  AppDensity copyWith() => this;

  @override
  AppDensity lerp(AppDensity? other, double t) =>
      t < 0.5 ? this : other ?? this;
}

extension AppDensityContext on BuildContext {
  AppDensity get density =>
      Theme.of(this).extension<AppDensity>() ?? AppDensity.phone;
}
