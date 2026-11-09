// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the server runs the Calls plugin. False while unknown, so
/// nothing shows that might vanish.

@ProviderFor(callsAvailable)
final callsAvailableProvider = CallsAvailableFamily._();

/// Whether the server runs the Calls plugin. False while unknown, so
/// nothing shows that might vanish.

final class CallsAvailableProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the server runs the Calls plugin. False while unknown, so
  /// nothing shows that might vanish.
  CallsAvailableProvider._({
    required CallsAvailableFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'callsAvailableProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$callsAvailableHash();

  @override
  String toString() {
    return r'callsAvailableProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return callsAvailable(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CallsAvailableProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$callsAvailableHash() => r'c84a19fec1343b35cf306d30df9653a7e4b15b01';

/// Whether the server runs the Calls plugin. False while unknown, so
/// nothing shows that might vanish.

final class CallsAvailableFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  CallsAvailableFamily._()
    : super(
        retry: null,
        name: r'callsAvailableProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the server runs the Calls plugin. False while unknown, so
  /// nothing shows that might vanish.

  CallsAvailableProvider call(String url) =>
      CallsAvailableProvider._(argument: url, from: this);

  @override
  String toString() => r'callsAvailableProvider';
}

/// The server's Calls settings; null until they arrived.

@ProviderFor(callsConfig)
final callsConfigProvider = CallsConfigFamily._();

/// The server's Calls settings; null until they arrived.

final class CallsConfigProvider
    extends $FunctionalProvider<CallsConfig?, CallsConfig?, CallsConfig?>
    with $Provider<CallsConfig?> {
  /// The server's Calls settings; null until they arrived.
  CallsConfigProvider._({
    required CallsConfigFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'callsConfigProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$callsConfigHash();

  @override
  String toString() {
    return r'callsConfigProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<CallsConfig?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CallsConfig? create(Ref ref) {
    final argument = this.argument as String;
    return callsConfig(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CallsConfig? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CallsConfig?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CallsConfigProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$callsConfigHash() => r'e370763a9355846f518cebff3426854651acda82';

/// The server's Calls settings; null until they arrived.

final class CallsConfigFamily extends $Family
    with $FunctionalFamilyOverride<CallsConfig?, String> {
  CallsConfigFamily._()
    : super(
        retry: null,
        name: r'callsConfigProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The server's Calls settings; null until they arrived.

  CallsConfigProvider call(String url) =>
      CallsConfigProvider._(argument: url, from: this);

  @override
  String toString() => r'callsConfigProvider';
}

@ProviderFor(callsState)
final callsStateProvider = CallsStateFamily._();

final class CallsStateProvider
    extends $FunctionalProvider<CallsState, CallsState, CallsState>
    with $Provider<CallsState> {
  CallsStateProvider._({
    required CallsStateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'callsStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$callsStateHash();

  @override
  String toString() {
    return r'callsStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<CallsState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CallsState create(Ref ref) {
    final argument = this.argument as String;
    return callsState(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CallsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CallsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CallsStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$callsStateHash() => r'4cdd35140ba4699e25a203a5028a6b51e7b7a776';

final class CallsStateFamily extends $Family
    with $FunctionalFamilyOverride<CallsState, String> {
  CallsStateFamily._()
    : super(
        retry: null,
        name: r'callsStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CallsStateProvider call(String url) =>
      CallsStateProvider._(argument: url, from: this);

  @override
  String toString() => r'callsStateProvider';
}

/// The call running in [channelId], if any.

@ProviderFor(callInChannel)
final callInChannelProvider = CallInChannelFamily._();

/// The call running in [channelId], if any.

final class CallInChannelProvider
    extends $FunctionalProvider<ActiveCall?, ActiveCall?, ActiveCall?>
    with $Provider<ActiveCall?> {
  /// The call running in [channelId], if any.
  CallInChannelProvider._({
    required CallInChannelFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'callInChannelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$callInChannelHash();

  @override
  String toString() {
    return r'callInChannelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<ActiveCall?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ActiveCall? create(Ref ref) {
    final argument = this.argument as (String, String);
    return callInChannel(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActiveCall? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActiveCall?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CallInChannelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$callInChannelHash() => r'20996d76171b33c77ac969a007ea80f3f510c859';

/// The call running in [channelId], if any.

final class CallInChannelFamily extends $Family
    with $FunctionalFamilyOverride<ActiveCall?, (String, String)> {
  CallInChannelFamily._()
    : super(
        retry: null,
        name: r'callInChannelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The call running in [channelId], if any.

  CallInChannelProvider call(String url, String channelId) =>
      CallInChannelProvider._(argument: (url, channelId), from: this);

  @override
  String toString() => r'callInChannelProvider';
}

/// The running call whose post is [postId], with its channel.

@ProviderFor(callOfPost)
final callOfPostProvider = CallOfPostFamily._();

/// The running call whose post is [postId], with its channel.

final class CallOfPostProvider
    extends
        $FunctionalProvider<
          ({ActiveCall call, String channelId})?,
          ({ActiveCall call, String channelId})?,
          ({ActiveCall call, String channelId})?
        >
    with $Provider<({ActiveCall call, String channelId})?> {
  /// The running call whose post is [postId], with its channel.
  CallOfPostProvider._({
    required CallOfPostFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'callOfPostProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$callOfPostHash();

  @override
  String toString() {
    return r'callOfPostProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<({ActiveCall call, String channelId})?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ({ActiveCall call, String channelId})? create(Ref ref) {
    final argument = this.argument as (String, String);
    return callOfPost(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(({ActiveCall call, String channelId})? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<({ActiveCall call, String channelId})?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CallOfPostProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$callOfPostHash() => r'31f61eebaf7a94ace78cfae30a4118ab6afa34ea';

/// The running call whose post is [postId], with its channel.

final class CallOfPostFamily extends $Family
    with
        $FunctionalFamilyOverride<
          ({ActiveCall call, String channelId})?,
          (String, String)
        > {
  CallOfPostFamily._()
    : super(
        retry: null,
        name: r'callOfPostProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The running call whose post is [postId], with its channel.

  CallOfPostProvider call(String url, String postId) =>
      CallOfPostProvider._(argument: (url, postId), from: this);

  @override
  String toString() => r'callOfPostProvider';
}

/// Whether a call runs in [channelId] on a server with the plugin.

@ProviderFor(channelHasCall)
final channelHasCallProvider = ChannelHasCallFamily._();

/// Whether a call runs in [channelId] on a server with the plugin.

final class ChannelHasCallProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether a call runs in [channelId] on a server with the plugin.
  ChannelHasCallProvider._({
    required ChannelHasCallFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'channelHasCallProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$channelHasCallHash();

  @override
  String toString() {
    return r'channelHasCallProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as (String, String);
    return channelHasCall(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelHasCallProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$channelHasCallHash() => r'630a35eab3b8779eadef4e669a974c83c3c095c8';

/// Whether a call runs in [channelId] on a server with the plugin.

final class ChannelHasCallFamily extends $Family
    with $FunctionalFamilyOverride<bool, (String, String)> {
  ChannelHasCallFamily._()
    : super(
        retry: null,
        name: r'channelHasCallProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether a call runs in [channelId] on a server with the plugin.

  ChannelHasCallProvider call(String url, String channelId) =>
      ChannelHasCallProvider._(argument: (url, channelId), from: this);

  @override
  String toString() => r'channelHasCallProvider';
}

/// What [channelId] offers the user: starting a call, joining the one
/// that runs, or nothing.

@ProviderFor(callActionIn)
final callActionInProvider = CallActionInFamily._();

/// What [channelId] offers the user: starting a call, joining the one
/// that runs, or nothing.

final class CallActionInProvider
    extends $FunctionalProvider<CallAction, CallAction, CallAction>
    with $Provider<CallAction> {
  /// What [channelId] offers the user: starting a call, joining the one
  /// that runs, or nothing.
  CallActionInProvider._({
    required CallActionInFamily super.from,
    required (String, String, String) super.argument,
  }) : super(
         retry: null,
         name: r'callActionInProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$callActionInHash();

  @override
  String toString() {
    return r'callActionInProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<CallAction> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CallAction create(Ref ref) {
    final argument = this.argument as (String, String, String);
    return callActionIn(ref, argument.$1, argument.$2, argument.$3);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CallAction value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CallAction>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CallActionInProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$callActionInHash() => r'3004a7bd85385dc9bb60e7d0419aebd339371719';

/// What [channelId] offers the user: starting a call, joining the one
/// that runs, or nothing.

final class CallActionInFamily extends $Family
    with $FunctionalFamilyOverride<CallAction, (String, String, String)> {
  CallActionInFamily._()
    : super(
        retry: null,
        name: r'callActionInProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What [channelId] offers the user: starting a call, joining the one
  /// that runs, or nothing.

  CallActionInProvider call(String url, String channelId, String channelType) =>
      CallActionInProvider._(
        argument: (url, channelId, channelType),
        from: this,
      );

  @override
  String toString() => r'callActionInProvider';
}

/// Starts and joins calls; null while no part of the app registers one.

@ProviderFor(callController)
final callControllerProvider = CallControllerProvider._();

/// Starts and joins calls; null while no part of the app registers one.

final class CallControllerProvider
    extends
        $FunctionalProvider<CallController?, CallController?, CallController?>
    with $Provider<CallController?> {
  /// Starts and joins calls; null while no part of the app registers one.
  CallControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'callControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$callControllerHash();

  @$internal
  @override
  $ProviderElement<CallController?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CallController? create(Ref ref) {
    return callController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CallController? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CallController?>(value),
    );
  }
}

String _$callControllerHash() => r'192daaf860f624b55c12de7237c7613437eb1083';
