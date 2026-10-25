// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(serverPalettes)
final serverPalettesProvider = ServerPalettesProvider._();

final class ServerPalettesProvider
    extends
        $FunctionalProvider<
          AsyncValue<ServerPalettes?>,
          ServerPalettes?,
          Stream<ServerPalettes?>
        >
    with $FutureModifier<ServerPalettes?>, $StreamProvider<ServerPalettes?> {
  ServerPalettesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverPalettesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverPalettesHash();

  @$internal
  @override
  $StreamProviderElement<ServerPalettes?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ServerPalettes?> create(Ref ref) {
    return serverPalettes(ref);
  }
}

String _$serverPalettesHash() => r'3925f77cedf8e881af709ae433bc96bc33664032';
