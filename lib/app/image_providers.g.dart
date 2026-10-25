// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The image caches of one signed-in server.

@ProviderFor(serverImageCaches)
final serverImageCachesProvider = ServerImageCachesFamily._();

/// The image caches of one signed-in server.

final class ServerImageCachesProvider
    extends
        $FunctionalProvider<
          AsyncValue<ServerImageCaches>,
          ServerImageCaches,
          FutureOr<ServerImageCaches>
        >
    with
        $FutureModifier<ServerImageCaches>,
        $FutureProvider<ServerImageCaches> {
  /// The image caches of one signed-in server.
  ServerImageCachesProvider._({
    required ServerImageCachesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'serverImageCachesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serverImageCachesHash();

  @override
  String toString() {
    return r'serverImageCachesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ServerImageCaches> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ServerImageCaches> create(Ref ref) {
    final argument = this.argument as String;
    return serverImageCaches(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ServerImageCachesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serverImageCachesHash() => r'55c82c79afa7780b3648898dd1a16f28c6242658';

/// The image caches of one signed-in server.

final class ServerImageCachesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ServerImageCaches>, String> {
  ServerImageCachesFamily._()
    : super(
        retry: null,
        name: r'serverImageCachesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The image caches of one signed-in server.

  ServerImageCachesProvider call(String url) =>
      ServerImageCachesProvider._(argument: url, from: this);

  @override
  String toString() => r'serverImageCachesProvider';
}
