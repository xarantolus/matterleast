import 'package:flutter/foundation.dart';
import 'package:material_color_utilities/material_color_utilities.dart' as mcu;
import 'package:material_ui/material_ui.dart';

/// The phone's wallpaper colours as Android reports them: the tones of its
/// primary, secondary, tertiary, neutral and neutral variant palettes.
@immutable
class WallpaperColours {
  WallpaperColours(List<int> tones) : tones = List.unmodifiable(tones) {
    if (tones.length != _palettes * _size) {
      throw FormatException('wallpaper colours', tones.length);
    }
  }

  /// The colours Android derives from a wallpaper of mostly [seed].
  factory WallpaperColours.fromSeed(Color seed) {
    final scheme = mcu.SchemeTonalSpot(
      sourceColorHct: mcu.Hct.fromInt(seed.toARGB32()),
      isDark: false,
      contrastLevel: 0,
    );
    return WallpaperColours([
      for (final palette in [
        scheme.primaryPalette,
        scheme.secondaryPalette,
        scheme.tertiaryPalette,
        scheme.neutralPalette,
        scheme.neutralVariantPalette,
      ])
        ...palette.asList,
    ]);
  }

  static const _palettes = 5;
  static final _size = mcu.TonalPalette.commonSize;

  final List<int> tones;

  mcu.TonalPalette _palette(int index) => mcu.TonalPalette.fromList(
    tones.sublist(index * _size, (index + 1) * _size),
  );

  ColorScheme scheme(Brightness brightness) {
    final primary = _palette(0);
    final generated = mcu.DynamicScheme(
      sourceColorHct: mcu.Hct.fromInt(primary.get(40)),
      variant: mcu.Variant.tonalSpot,
      isDark: brightness == Brightness.dark,
      primaryPalette: primary,
      secondaryPalette: _palette(1),
      tertiaryPalette: _palette(2),
      neutralPalette: _palette(3),
      neutralVariantPalette: _palette(4),
    );
    Color c(mcu.DynamicColor role) => Color(role.getArgb(generated));
    return ColorScheme(
      brightness: brightness,
      primary: c(mcu.MaterialDynamicColors.primary),
      onPrimary: c(mcu.MaterialDynamicColors.onPrimary),
      primaryContainer: c(mcu.MaterialDynamicColors.primaryContainer),
      onPrimaryContainer: c(mcu.MaterialDynamicColors.onPrimaryContainer),
      secondary: c(mcu.MaterialDynamicColors.secondary),
      onSecondary: c(mcu.MaterialDynamicColors.onSecondary),
      secondaryContainer: c(mcu.MaterialDynamicColors.secondaryContainer),
      onSecondaryContainer: c(mcu.MaterialDynamicColors.onSecondaryContainer),
      tertiary: c(mcu.MaterialDynamicColors.tertiary),
      onTertiary: c(mcu.MaterialDynamicColors.onTertiary),
      tertiaryContainer: c(mcu.MaterialDynamicColors.tertiaryContainer),
      onTertiaryContainer: c(mcu.MaterialDynamicColors.onTertiaryContainer),
      error: c(mcu.MaterialDynamicColors.error),
      onError: c(mcu.MaterialDynamicColors.onError),
      errorContainer: c(mcu.MaterialDynamicColors.errorContainer),
      onErrorContainer: c(mcu.MaterialDynamicColors.onErrorContainer),
      surface: c(mcu.MaterialDynamicColors.surface),
      onSurface: c(mcu.MaterialDynamicColors.onSurface),
      onSurfaceVariant: c(mcu.MaterialDynamicColors.onSurfaceVariant),
      surfaceDim: c(mcu.MaterialDynamicColors.surfaceDim),
      surfaceBright: c(mcu.MaterialDynamicColors.surfaceBright),
      surfaceContainerLowest: c(
        mcu.MaterialDynamicColors.surfaceContainerLowest,
      ),
      surfaceContainerLow: c(mcu.MaterialDynamicColors.surfaceContainerLow),
      surfaceContainer: c(mcu.MaterialDynamicColors.surfaceContainer),
      surfaceContainerHigh: c(mcu.MaterialDynamicColors.surfaceContainerHigh),
      surfaceContainerHighest: c(
        mcu.MaterialDynamicColors.surfaceContainerHighest,
      ),
      outline: c(mcu.MaterialDynamicColors.outline),
      outlineVariant: c(mcu.MaterialDynamicColors.outlineVariant),
      inverseSurface: c(mcu.MaterialDynamicColors.inverseSurface),
      onInverseSurface: c(mcu.MaterialDynamicColors.inverseOnSurface),
      inversePrimary: c(mcu.MaterialDynamicColors.inversePrimary),
      shadow: c(mcu.MaterialDynamicColors.shadow),
      scrim: c(mcu.MaterialDynamicColors.scrim),
      surfaceTint: c(mcu.MaterialDynamicColors.primary),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is WallpaperColours && listEquals(other.tones, tones);

  @override
  int get hashCode => Object.hashAll(tones);
}
