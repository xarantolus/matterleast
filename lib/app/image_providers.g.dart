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

/// Whether the server proxies images from other hosts, from its stored
/// client config.

@ProviderFor(imageProxy)
final imageProxyProvider = ImageProxyFamily._();

/// Whether the server proxies images from other hosts, from its stored
/// client config.

final class ImageProxyProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether the server proxies images from other hosts, from its stored
  /// client config.
  ImageProxyProvider._({
    required ImageProxyFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'imageProxyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$imageProxyHash();

  @override
  String toString() {
    return r'imageProxyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    final argument = this.argument as String;
    return imageProxy(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ImageProxyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$imageProxyHash() => r'6b61aafc1a3371ac6da8fbf2da4de2aebf312e3f';

/// Whether the server proxies images from other hosts, from its stored
/// client config.

final class ImageProxyFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, String> {
  ImageProxyFamily._()
    : super(
        retry: null,
        name: r'imageProxyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the server proxies images from other hosts, from its stored
  /// client config.

  ImageProxyProvider call(String url) =>
      ImageProxyProvider._(argument: url, from: this);

  @override
  String toString() => r'imageProxyProvider';
}

@ProviderFor(connection)
final connectionProvider = ConnectionProvider._();

final class ConnectionProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConnectivityResult>>,
          List<ConnectivityResult>,
          Stream<List<ConnectivityResult>>
        >
    with
        $FutureModifier<List<ConnectivityResult>>,
        $StreamProvider<List<ConnectivityResult>> {
  ConnectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionHash();

  @$internal
  @override
  $StreamProviderElement<List<ConnectivityResult>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ConnectivityResult>> create(Ref ref) {
    return connection(ref);
  }
}

String _$connectionHash() => r'98f6f9b8ae72fe796602b6bbfca611a75812ca26';

@ProviderFor(imagesOnMobileData)
final imagesOnMobileDataProvider = ImagesOnMobileDataProvider._();

final class ImagesOnMobileDataProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  ImagesOnMobileDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imagesOnMobileDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imagesOnMobileDataHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return imagesOnMobileData(ref);
  }
}

String _$imagesOnMobileDataHash() =>
    r'214327f9a38d21642922a9732b739709f3f0f0db';

/// Whether message images load without a tap; null until the connection
/// and the setting are known.

@ProviderFor(autoLoadImages)
final autoLoadImagesProvider = AutoLoadImagesProvider._();

/// Whether message images load without a tap; null until the connection
/// and the setting are known.

final class AutoLoadImagesProvider
    extends $FunctionalProvider<bool?, bool?, bool?>
    with $Provider<bool?> {
  /// Whether message images load without a tap; null until the connection
  /// and the setting are known.
  AutoLoadImagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoLoadImagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoLoadImagesHash();

  @$internal
  @override
  $ProviderElement<bool?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool? create(Ref ref) {
    return autoLoadImages(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool?>(value),
    );
  }
}

String _$autoLoadImagesHash() => r'6299ed5c457a9ee870b71341519b750d34cecc8b';
