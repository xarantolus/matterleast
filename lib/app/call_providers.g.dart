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

/// Who is in the call of [channelId], in the order they joined.

@ProviderFor(callSessionIds)
final callSessionIdsProvider = CallSessionIdsFamily._();

/// Who is in the call of [channelId], in the order they joined.

final class CallSessionIdsProvider
    extends $FunctionalProvider<SessionIds, SessionIds, SessionIds>
    with $Provider<SessionIds> {
  /// Who is in the call of [channelId], in the order they joined.
  CallSessionIdsProvider._({
    required CallSessionIdsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'callSessionIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$callSessionIdsHash();

  @override
  String toString() {
    return r'callSessionIdsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<SessionIds> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionIds create(Ref ref) {
    final argument = this.argument as (String, String);
    return callSessionIds(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionIds value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionIds>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CallSessionIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$callSessionIdsHash() => r'45f05a77c7870fcfd5ba679c27347d1b205e2df3';

/// Who is in the call of [channelId], in the order they joined.

final class CallSessionIdsFamily extends $Family
    with $FunctionalFamilyOverride<SessionIds, (String, String)> {
  CallSessionIdsFamily._()
    : super(
        retry: null,
        name: r'callSessionIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Who is in the call of [channelId], in the order they joined.

  CallSessionIdsProvider call(String url, String channelId) =>
      CallSessionIdsProvider._(argument: (url, channelId), from: this);

  @override
  String toString() => r'callSessionIdsProvider';
}

/// One person's connection to the call of [channelId].

@ProviderFor(callSessionOf)
final callSessionOfProvider = CallSessionOfFamily._();

/// One person's connection to the call of [channelId].

final class CallSessionOfProvider
    extends $FunctionalProvider<CallSession?, CallSession?, CallSession?>
    with $Provider<CallSession?> {
  /// One person's connection to the call of [channelId].
  CallSessionOfProvider._({
    required CallSessionOfFamily super.from,
    required (String, String, String) super.argument,
  }) : super(
         retry: null,
         name: r'callSessionOfProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$callSessionOfHash();

  @override
  String toString() {
    return r'callSessionOfProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<CallSession?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CallSession? create(Ref ref) {
    final argument = this.argument as (String, String, String);
    return callSessionOf(ref, argument.$1, argument.$2, argument.$3);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CallSession? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CallSession?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CallSessionOfProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$callSessionOfHash() => r'e038dfa494424318b32001112a2e1b19779bb02b';

/// One person's connection to the call of [channelId].

final class CallSessionOfFamily extends $Family
    with $FunctionalFamilyOverride<CallSession?, (String, String, String)> {
  CallSessionOfFamily._()
    : super(
        retry: null,
        name: r'callSessionOfProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One person's connection to the call of [channelId].

  CallSessionOfProvider call(String url, String channelId, String sessionId) =>
      CallSessionOfProvider._(
        argument: (url, channelId, sessionId),
        from: this,
      );

  @override
  String toString() => r'callSessionOfProvider';
}

/// The host of the call of [channelId].

@ProviderFor(callHost)
final callHostProvider = CallHostFamily._();

/// The host of the call of [channelId].

final class CallHostProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The host of the call of [channelId].
  CallHostProvider._({
    required CallHostFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'callHostProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$callHostHash();

  @override
  String toString() {
    return r'callHostProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    final argument = this.argument as (String, String);
    return callHost(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CallHostProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$callHostHash() => r'a0108f6e0c9784d8f57f61e7b08c8c7c0f8e264e';

/// The host of the call of [channelId].

final class CallHostFamily extends $Family
    with $FunctionalFamilyOverride<String?, (String, String)> {
  CallHostFamily._()
    : super(
        retry: null,
        name: r'callHostProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The host of the call of [channelId].

  CallHostProvider call(String url, String channelId) =>
      CallHostProvider._(argument: (url, channelId), from: this);

  @override
  String toString() => r'callHostProvider';
}

/// How many hands are up in the call of [channelId].

@ProviderFor(callHandsUp)
final callHandsUpProvider = CallHandsUpFamily._();

/// How many hands are up in the call of [channelId].

final class CallHandsUpProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// How many hands are up in the call of [channelId].
  CallHandsUpProvider._({
    required CallHandsUpFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'callHandsUpProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$callHandsUpHash();

  @override
  String toString() {
    return r'callHandsUpProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as (String, String);
    return callHandsUp(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CallHandsUpProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$callHandsUpHash() => r'73d749b4c80b890e4e59e0bcb5c54e8fc263f6af';

/// How many hands are up in the call of [channelId].

final class CallHandsUpFamily extends $Family
    with $FunctionalFamilyOverride<int, (String, String)> {
  CallHandsUpFamily._()
    : super(
        retry: null,
        name: r'callHandsUpProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How many hands are up in the call of [channelId].

  CallHandsUpProvider call(String url, String channelId) =>
      CallHandsUpProvider._(argument: (url, channelId), from: this);

  @override
  String toString() => r'callHandsUpProvider';
}

/// The session that shares its screen in the call of [channelId], if any.

@ProviderFor(callScreenSharer)
final callScreenSharerProvider = CallScreenSharerFamily._();

/// The session that shares its screen in the call of [channelId], if any.

final class CallScreenSharerProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// The session that shares its screen in the call of [channelId], if any.
  CallScreenSharerProvider._({
    required CallScreenSharerFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'callScreenSharerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$callScreenSharerHash();

  @override
  String toString() {
    return r'callScreenSharerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    final argument = this.argument as (String, String);
    return callScreenSharer(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CallScreenSharerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$callScreenSharerHash() => r'7eee726bf540b30728e386b63cf615a77a98b49e';

/// The session that shares its screen in the call of [channelId], if any.

final class CallScreenSharerFamily extends $Family
    with $FunctionalFamilyOverride<String, (String, String)> {
  CallScreenSharerFamily._()
    : super(
        retry: null,
        name: r'callScreenSharerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The session that shares its screen in the call of [channelId], if any.

  CallScreenSharerProvider call(String url, String channelId) =>
      CallScreenSharerProvider._(argument: (url, channelId), from: this);

  @override
  String toString() => r'callScreenSharerProvider';
}

/// The emoji [sessionId] shows right now.

@ProviderFor(callReaction)
final callReactionProvider = CallReactionFamily._();

/// The emoji [sessionId] shows right now.

final class CallReactionProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The emoji [sessionId] shows right now.
  CallReactionProvider._({
    required CallReactionFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'callReactionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$callReactionHash();

  @override
  String toString() {
    return r'callReactionProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    final argument = this.argument as (String, String);
    return callReaction(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CallReactionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$callReactionHash() => r'5de642c2d831eb16a06ba88885676d0125778fe6';

/// The emoji [sessionId] shows right now.

final class CallReactionFamily extends $Family
    with $FunctionalFamilyOverride<String?, (String, String)> {
  CallReactionFamily._()
    : super(
        retry: null,
        name: r'callReactionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The emoji [sessionId] shows right now.

  CallReactionProvider call(String url, String sessionId) =>
      CallReactionProvider._(argument: (url, sessionId), from: this);

  @override
  String toString() => r'callReactionProvider';
}

@ProviderFor(_reactions)
final _reactionsProvider = _ReactionsFamily._();

final class _ReactionsProvider
    extends
        $FunctionalProvider<
          Map<String, String>,
          Map<String, String>,
          Map<String, String>
        >
    with $Provider<Map<String, String>> {
  _ReactionsProvider._({
    required _ReactionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'_reactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$_reactionsHash();

  @override
  String toString() {
    return r'_reactionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Map<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, String> create(Ref ref) {
    final argument = this.argument as String;
    return _reactions(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _ReactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$_reactionsHash() => r'0d9cee924a5861c70df60e8511763a71f0512443';

final class _ReactionsFamily extends $Family
    with $FunctionalFamilyOverride<Map<String, String>, String> {
  _ReactionsFamily._()
    : super(
        retry: null,
        name: r'_reactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  _ReactionsProvider call(String url) =>
      _ReactionsProvider._(argument: url, from: this);

  @override
  String toString() => r'_reactionsProvider';
}

/// The calls that ring the user on [url]'s server, by channel.

@ProviderFor(incomingCalls)
final incomingCallsProvider = IncomingCallsFamily._();

/// The calls that ring the user on [url]'s server, by channel.

final class IncomingCallsProvider
    extends
        $FunctionalProvider<
          Map<String, ActiveCall>,
          Map<String, ActiveCall>,
          Map<String, ActiveCall>
        >
    with $Provider<Map<String, ActiveCall>> {
  /// The calls that ring the user on [url]'s server, by channel.
  IncomingCallsProvider._({
    required IncomingCallsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'incomingCallsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$incomingCallsHash();

  @override
  String toString() {
    return r'incomingCallsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Map<String, ActiveCall>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, ActiveCall> create(Ref ref) {
    final argument = this.argument as String;
    return incomingCalls(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, ActiveCall> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, ActiveCall>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IncomingCallsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$incomingCallsHash() => r'3852cda61bc77bec201e4f0bc92aa41ff67c6002';

/// The calls that ring the user on [url]'s server, by channel.

final class IncomingCallsFamily extends $Family
    with $FunctionalFamilyOverride<Map<String, ActiveCall>, String> {
  IncomingCallsFamily._()
    : super(
        retry: null,
        name: r'incomingCallsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The calls that ring the user on [url]'s server, by channel.

  IncomingCallsProvider call(String url) =>
      IncomingCallsProvider._(argument: url, from: this);

  @override
  String toString() => r'incomingCallsProvider';
}

/// Whether the call screen is the page the user looks at; the bar hides
/// then.

@ProviderFor(CallScreenOpen)
final callScreenOpenProvider = CallScreenOpenProvider._();

/// Whether the call screen is the page the user looks at; the bar hides
/// then.
final class CallScreenOpenProvider
    extends $NotifierProvider<CallScreenOpen, int> {
  /// Whether the call screen is the page the user looks at; the bar hides
  /// then.
  CallScreenOpenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'callScreenOpenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$callScreenOpenHash();

  @$internal
  @override
  CallScreenOpen create() => CallScreenOpen();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$callScreenOpenHash() => r'8f4390066dce04612ed29d9fd781f1794b511956';

/// Whether the call screen is the page the user looks at; the bar hides
/// then.

abstract class _$CallScreenOpen extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Starts and joins calls; null where the app can't.

@ProviderFor(callController)
final callControllerProvider = CallControllerProvider._();

/// Starts and joins calls; null where the app can't.

final class CallControllerProvider
    extends
        $FunctionalProvider<CallController?, CallController?, CallController?>
    with $Provider<CallController?> {
  /// Starts and joins calls; null where the app can't.
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

String _$callControllerHash() => r'a2e764d79079dc75835b78f4cf0438b951f45eb5';
