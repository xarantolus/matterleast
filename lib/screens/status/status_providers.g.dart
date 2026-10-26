// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the server's WebSocket is up.

@ProviderFor(socketState)
final socketStateProvider = SocketStateFamily._();

/// Whether the server's WebSocket is up.

final class SocketStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<SocketState>,
          SocketState,
          Stream<SocketState>
        >
    with $FutureModifier<SocketState>, $StreamProvider<SocketState> {
  /// Whether the server's WebSocket is up.
  SocketStateProvider._({
    required SocketStateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'socketStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$socketStateHash();

  @override
  String toString() {
    return r'socketStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<SocketState> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SocketState> create(Ref ref) {
    final argument = this.argument as String;
    return socketState(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SocketStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$socketStateHash() => r'348bb1576a6a1f3ffd2f460a3c4c88582f55c4d3';

/// Whether the server's WebSocket is up.

final class SocketStateFamily extends $Family
    with $FunctionalFamilyOverride<Stream<SocketState>, String> {
  SocketStateFamily._()
    : super(
        retry: null,
        name: r'socketStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the server's WebSocket is up.

  SocketStateProvider call(String url) =>
      SocketStateProvider._(argument: url, from: this);

  @override
  String toString() => r'socketStateProvider';
}

/// Whether the WebSocket has been down for longer than a short blip, so
/// the list can say live updates are paused.

@ProviderFor(socketDown)
final socketDownProvider = SocketDownFamily._();

/// Whether the WebSocket has been down for longer than a short blip, so
/// the list can say live updates are paused.

final class SocketDownProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether the WebSocket has been down for longer than a short blip, so
  /// the list can say live updates are paused.
  SocketDownProvider._({
    required SocketDownFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'socketDownProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$socketDownHash();

  @override
  String toString() {
    return r'socketDownProvider'
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
    return socketDown(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SocketDownProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$socketDownHash() => r'0d9b1fc0eb5088e6a26ad8f7efabbb4f3116d96f';

/// Whether the WebSocket has been down for longer than a short blip, so
/// the list can say live updates are paused.

final class SocketDownFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, String> {
  SocketDownFamily._()
    : super(
        retry: null,
        name: r'socketDownProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the WebSocket has been down for longer than a short blip, so
  /// the list can say live updates are paused.

  SocketDownProvider call(String url) =>
      SocketDownProvider._(argument: url, from: this);

  @override
  String toString() => r'socketDownProvider';
}

/// What the server has stored on this device.

@ProviderFor(serverStorage)
final serverStorageProvider = ServerStorageFamily._();

/// What the server has stored on this device.

final class ServerStorageProvider
    extends
        $FunctionalProvider<
          AsyncValue<StoredCounts>,
          StoredCounts,
          Stream<StoredCounts>
        >
    with $FutureModifier<StoredCounts>, $StreamProvider<StoredCounts> {
  /// What the server has stored on this device.
  ServerStorageProvider._({
    required ServerStorageFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'serverStorageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serverStorageHash();

  @override
  String toString() {
    return r'serverStorageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<StoredCounts> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<StoredCounts> create(Ref ref) {
    final argument = this.argument as String;
    return serverStorage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ServerStorageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serverStorageHash() => r'676c9ba7619465adb2c586092c0bb3e79d5fc527';

/// What the server has stored on this device.

final class ServerStorageFamily extends $Family
    with $FunctionalFamilyOverride<Stream<StoredCounts>, String> {
  ServerStorageFamily._()
    : super(
        retry: null,
        name: r'serverStorageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What the server has stored on this device.

  ServerStorageProvider call(String url) =>
      ServerStorageProvider._(argument: url, from: this);

  @override
  String toString() => r'serverStorageProvider';
}
