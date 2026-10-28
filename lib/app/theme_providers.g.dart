// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The themes and mode for the colours the server in use is set to.

@ProviderFor(appThemes)
final appThemesProvider = AppThemesProvider._();

/// The themes and mode for the colours the server in use is set to.

final class AppThemesProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppThemes>,
          AppThemes,
          FutureOr<AppThemes>
        >
    with $FutureModifier<AppThemes>, $FutureProvider<AppThemes> {
  /// The themes and mode for the colours the server in use is set to.
  AppThemesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemesHash();

  @$internal
  @override
  $FutureProviderElement<AppThemes> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AppThemes> create(Ref ref) {
    return appThemes(ref);
  }
}

String _$appThemesHash() => r'5f240ac73c16dc1e4d4fb24dd8a40ddb1829998f';

/// The user's Mattermost theme on the server at [url].

@ProviderFor(serverPalettes)
final serverPalettesProvider = ServerPalettesFamily._();

/// The user's Mattermost theme on the server at [url].

final class ServerPalettesProvider
    extends
        $FunctionalProvider<
          AsyncValue<ServerPalettes>,
          ServerPalettes,
          Stream<ServerPalettes>
        >
    with $FutureModifier<ServerPalettes>, $StreamProvider<ServerPalettes> {
  /// The user's Mattermost theme on the server at [url].
  ServerPalettesProvider._({
    required ServerPalettesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'serverPalettesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serverPalettesHash();

  @override
  String toString() {
    return r'serverPalettesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ServerPalettes> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ServerPalettes> create(Ref ref) {
    final argument = this.argument as String;
    return serverPalettes(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ServerPalettesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serverPalettesHash() => r'113ea8032dd8c9d21a78a3ee00793477ba1920aa';

/// The user's Mattermost theme on the server at [url].

final class ServerPalettesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ServerPalettes>, String> {
  ServerPalettesFamily._()
    : super(
        retry: null,
        name: r'serverPalettesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The user's Mattermost theme on the server at [url].

  ServerPalettesProvider call(String url) =>
      ServerPalettesProvider._(argument: url, from: this);

  @override
  String toString() => r'serverPalettesProvider';
}

/// The phone's wallpaper colours, read again when the app comes back, since
/// the wallpaper may have changed meanwhile. Null where the phone has none
/// (before Android 12).

@ProviderFor(WallpaperPalette)
final wallpaperPaletteProvider = WallpaperPaletteProvider._();

/// The phone's wallpaper colours, read again when the app comes back, since
/// the wallpaper may have changed meanwhile. Null where the phone has none
/// (before Android 12).
final class WallpaperPaletteProvider
    extends $AsyncNotifierProvider<WallpaperPalette, WallpaperColours?> {
  /// The phone's wallpaper colours, read again when the app comes back, since
  /// the wallpaper may have changed meanwhile. Null where the phone has none
  /// (before Android 12).
  WallpaperPaletteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wallpaperPaletteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wallpaperPaletteHash();

  @$internal
  @override
  WallpaperPalette create() => WallpaperPalette();
}

String _$wallpaperPaletteHash() => r'83017289030a2391305e59ab895742e2231ca313';

/// The phone's wallpaper colours, read again when the app comes back, since
/// the wallpaper may have changed meanwhile. Null where the phone has none
/// (before Android 12).

abstract class _$WallpaperPalette extends $AsyncNotifier<WallpaperColours?> {
  FutureOr<WallpaperColours?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<WallpaperColours?>, WallpaperColours?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WallpaperColours?>, WallpaperColours?>,
              AsyncValue<WallpaperColours?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
