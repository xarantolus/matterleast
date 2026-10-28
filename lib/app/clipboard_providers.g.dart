// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clipboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Puts an image on the system clipboard; tests swap it.

@ProviderFor(imageClipboard)
final imageClipboardProvider = ImageClipboardProvider._();

/// Puts an image on the system clipboard; tests swap it.

final class ImageClipboardProvider
    extends
        $FunctionalProvider<
          Future<void> Function(Uint8List image),
          Future<void> Function(Uint8List image),
          Future<void> Function(Uint8List image)
        >
    with $Provider<Future<void> Function(Uint8List image)> {
  /// Puts an image on the system clipboard; tests swap it.
  ImageClipboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageClipboardProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageClipboardHash();

  @$internal
  @override
  $ProviderElement<Future<void> Function(Uint8List image)> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<void> Function(Uint8List image) create(Ref ref) {
    return imageClipboard(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<void> Function(Uint8List image) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Future<void> Function(Uint8List image)>(value),
    );
  }
}

String _$imageClipboardHash() => r'86bcf8f8a3fbf3c321e94ce32fb73ac9db8f9875';
