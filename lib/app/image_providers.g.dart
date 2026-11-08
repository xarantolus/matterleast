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

String _$connectionHash() => r'0237f4f8074c0a231ac550d5add6e4156d34eccc';

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

@ProviderFor(gifsOnMobileData)
final gifsOnMobileDataProvider = GifsOnMobileDataProvider._();

final class GifsOnMobileDataProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  GifsOnMobileDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gifsOnMobileDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gifsOnMobileDataHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return gifsOnMobileData(ref);
  }
}

String _$gifsOnMobileDataHash() => r'cb5ef715b2fb464fab2790df4ca23bc7bf5217e6';

@ProviderFor(linkPicturesOnMobileData)
final linkPicturesOnMobileDataProvider = LinkPicturesOnMobileDataProvider._();

final class LinkPicturesOnMobileDataProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  LinkPicturesOnMobileDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkPicturesOnMobileDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkPicturesOnMobileDataHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return linkPicturesOnMobileData(ref);
  }
}

String _$linkPicturesOnMobileDataHash() =>
    r'1dfee27cc634f5c5cc3120ce289a0def08f1660f';

/// Whether [kind] loads without a tap; null until the connection and the
/// settings are known.

@ProviderFor(autoLoad)
final autoLoadProvider = AutoLoadFamily._();

/// Whether [kind] loads without a tap; null until the connection and the
/// settings are known.

final class AutoLoadProvider extends $FunctionalProvider<bool?, bool?, bool?>
    with $Provider<bool?> {
  /// Whether [kind] loads without a tap; null until the connection and the
  /// settings are known.
  AutoLoadProvider._({
    required AutoLoadFamily super.from,
    required DataKind super.argument,
  }) : super(
         retry: null,
         name: r'autoLoadProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$autoLoadHash();

  @override
  String toString() {
    return r'autoLoadProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool? create(Ref ref) {
    final argument = this.argument as DataKind;
    return autoLoad(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AutoLoadProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$autoLoadHash() => r'4667135019d532a50c141c474cc02d25a0d6babe';

/// Whether [kind] loads without a tap; null until the connection and the
/// settings are known.

final class AutoLoadFamily extends $Family
    with $FunctionalFamilyOverride<bool?, DataKind> {
  AutoLoadFamily._()
    : super(
        retry: null,
        name: r'autoLoadProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether [kind] loads without a tap; null until the connection and the
  /// settings are known.

  AutoLoadProvider call(DataKind kind) =>
      AutoLoadProvider._(argument: kind, from: this);

  @override
  String toString() => r'autoLoadProvider';
}
