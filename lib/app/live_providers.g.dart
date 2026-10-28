// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The time now; tests set their own.

@ProviderFor(wallClock)
final wallClockProvider = WallClockProvider._();

/// The time now; tests set their own.

final class WallClockProvider
    extends
        $FunctionalProvider<
          DateTime Function(),
          DateTime Function(),
          DateTime Function()
        >
    with $Provider<DateTime Function()> {
  /// The time now; tests set their own.
  WallClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wallClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wallClockHash();

  @$internal
  @override
  $ProviderElement<DateTime Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DateTime Function() create(Ref ref) {
    return wallClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime Function()>(value),
    );
  }
}

String _$wallClockHash() => r'a4f2598c2930d43a57805794cc47d1cec20990fe';

/// Whether [url]'s server is live: its socket is connected and it answers.
/// Each server decides for itself.

@ProviderFor(serverLive)
final serverLiveProvider = ServerLiveFamily._();

/// Whether [url]'s server is live: its socket is connected and it answers.
/// Each server decides for itself.

final class ServerLiveProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether [url]'s server is live: its socket is connected and it answers.
  /// Each server decides for itself.
  ServerLiveProvider._({
    required ServerLiveFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'serverLiveProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serverLiveHash();

  @override
  String toString() {
    return r'serverLiveProvider'
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
    return serverLive(ref, argument);
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
    return other is ServerLiveProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serverLiveHash() => r'a5908ce2f42127e177b00d326e199018eab5389e';

/// Whether [url]'s server is live: its socket is connected and it answers.
/// Each server decides for itself.

final class ServerLiveFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  ServerLiveFamily._()
    : super(
        retry: null,
        name: r'serverLiveProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether [url]'s server is live: its socket is connected and it answers.
  /// Each server decides for itself.

  ServerLiveProvider call(String url) =>
      ServerLiveProvider._(argument: url, from: this);

  @override
  String toString() => r'serverLiveProvider';
}

/// The people on [url]'s server whose presence came fresh from it since it
/// last became live; empty while it isn't.

@ProviderFor(knownPresence)
final knownPresenceProvider = KnownPresenceFamily._();

/// The people on [url]'s server whose presence came fresh from it since it
/// last became live; empty while it isn't.

final class KnownPresenceProvider
    extends $FunctionalProvider<Set<String>, Set<String>, Set<String>>
    with $Provider<Set<String>> {
  /// The people on [url]'s server whose presence came fresh from it since it
  /// last became live; empty while it isn't.
  KnownPresenceProvider._({
    required KnownPresenceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'knownPresenceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$knownPresenceHash();

  @override
  String toString() {
    return r'knownPresenceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Set<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<String> create(Ref ref) {
    final argument = this.argument as String;
    return knownPresence(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is KnownPresenceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$knownPresenceHash() => r'4968eb4f2ddffa261ee54c62aaf8f6e2d85dc057';

/// The people on [url]'s server whose presence came fresh from it since it
/// last became live; empty while it isn't.

final class KnownPresenceFamily extends $Family
    with $FunctionalFamilyOverride<Set<String>, String> {
  KnownPresenceFamily._()
    : super(
        retry: null,
        name: r'knownPresenceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The people on [url]'s server whose presence came fresh from it since it
  /// last became live; empty while it isn't.

  KnownPresenceProvider call(String url) =>
      KnownPresenceProvider._(argument: url, from: this);

  @override
  String toString() => r'knownPresenceProvider';
}

/// Whether [userId]'s presence on [url]'s server is current: it shows
/// only while the server is live, from what it told since.

@ProviderFor(presenceKnown)
final presenceKnownProvider = PresenceKnownFamily._();

/// Whether [userId]'s presence on [url]'s server is current: it shows
/// only while the server is live, from what it told since.

final class PresenceKnownProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether [userId]'s presence on [url]'s server is current: it shows
  /// only while the server is live, from what it told since.
  PresenceKnownProvider._({
    required PresenceKnownFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'presenceKnownProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$presenceKnownHash();

  @override
  String toString() {
    return r'presenceKnownProvider'
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
    return presenceKnown(ref, argument.$1, argument.$2);
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
    return other is PresenceKnownProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$presenceKnownHash() => r'1cdb8c77056ba0c16eae591d6e16ec7e13e9439e';

/// Whether [userId]'s presence on [url]'s server is current: it shows
/// only while the server is live, from what it told since.

final class PresenceKnownFamily extends $Family
    with $FunctionalFamilyOverride<bool, (String, String)> {
  PresenceKnownFamily._()
    : super(
        retry: null,
        name: r'presenceKnownProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether [userId]'s presence on [url]'s server is current: it shows
  /// only while the server is live, from what it told since.

  PresenceKnownProvider call(String url, String userId) =>
      PresenceKnownProvider._(argument: (url, userId), from: this);

  @override
  String toString() => r'presenceKnownProvider';
}

/// Whether the app came back and [url]'s server is catching up on what
/// it may have missed.

@ProviderFor(serverCatchingUp)
final serverCatchingUpProvider = ServerCatchingUpFamily._();

/// Whether the app came back and [url]'s server is catching up on what
/// it may have missed.

final class ServerCatchingUpProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the app came back and [url]'s server is catching up on what
  /// it may have missed.
  ServerCatchingUpProvider._({
    required ServerCatchingUpFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'serverCatchingUpProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serverCatchingUpHash();

  @override
  String toString() {
    return r'serverCatchingUpProvider'
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
    return serverCatchingUp(ref, argument);
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
    return other is ServerCatchingUpProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serverCatchingUpHash() => r'561ccce4573261337e0539a744ca5fd027e548a8';

/// Whether the app came back and [url]'s server is catching up on what
/// it may have missed.

final class ServerCatchingUpFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  ServerCatchingUpFamily._()
    : super(
        retry: null,
        name: r'serverCatchingUpProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the app came back and [url]'s server is catching up on what
  /// it may have missed.

  ServerCatchingUpProvider call(String url) =>
      ServerCatchingUpProvider._(argument: url, from: this);

  @override
  String toString() => r'serverCatchingUpProvider';
}

/// Everyone's custom status on [url]'s server as stored, expired or not.

@ProviderFor(customStatuses)
final customStatusesProvider = CustomStatusesFamily._();

/// Everyone's custom status on [url]'s server as stored, expired or not.

final class CustomStatusesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, CustomStatus>>,
          Map<String, CustomStatus>,
          Stream<Map<String, CustomStatus>>
        >
    with
        $FutureModifier<Map<String, CustomStatus>>,
        $StreamProvider<Map<String, CustomStatus>> {
  /// Everyone's custom status on [url]'s server as stored, expired or not.
  CustomStatusesProvider._({
    required CustomStatusesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'customStatusesProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customStatusesHash();

  @override
  String toString() {
    return r'customStatusesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, CustomStatus>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, CustomStatus>> create(Ref ref) {
    final argument = this.argument as String;
    return customStatuses(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomStatusesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customStatusesHash() => r'e1a485a8ae1a5ce946ae35f2382106e8b9c059a6';

/// Everyone's custom status on [url]'s server as stored, expired or not.

final class CustomStatusesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<String, CustomStatus>>, String> {
  CustomStatusesFamily._()
    : super(
        retry: null,
        name: r'customStatusesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Everyone's custom status on [url]'s server as stored, expired or not.

  CustomStatusesProvider call(String url) =>
      CustomStatusesProvider._(argument: url, from: this);

  @override
  String toString() => r'customStatusesProvider';
}

/// [userId]'s custom status while it is set and not expired by the clock;
/// it goes at its expiry without a refetch. Nothing where the server has
/// custom statuses turned off.

@ProviderFor(activeCustomStatus)
final activeCustomStatusProvider = ActiveCustomStatusFamily._();

/// [userId]'s custom status while it is set and not expired by the clock;
/// it goes at its expiry without a refetch. Nothing where the server has
/// custom statuses turned off.

final class ActiveCustomStatusProvider
    extends $FunctionalProvider<CustomStatus?, CustomStatus?, CustomStatus?>
    with $Provider<CustomStatus?> {
  /// [userId]'s custom status while it is set and not expired by the clock;
  /// it goes at its expiry without a refetch. Nothing where the server has
  /// custom statuses turned off.
  ActiveCustomStatusProvider._({
    required ActiveCustomStatusFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'activeCustomStatusProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeCustomStatusHash();

  @override
  String toString() {
    return r'activeCustomStatusProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<CustomStatus?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CustomStatus? create(Ref ref) {
    final argument = this.argument as (String, String);
    return activeCustomStatus(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomStatus? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomStatus?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveCustomStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeCustomStatusHash() =>
    r'd858a63db3d195440a6bd9e915493ed3270c34e4';

/// [userId]'s custom status while it is set and not expired by the clock;
/// it goes at its expiry without a refetch. Nothing where the server has
/// custom statuses turned off.

final class ActiveCustomStatusFamily extends $Family
    with $FunctionalFamilyOverride<CustomStatus?, (String, String)> {
  ActiveCustomStatusFamily._()
    : super(
        retry: null,
        name: r'activeCustomStatusProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// [userId]'s custom status while it is set and not expired by the clock;
  /// it goes at its expiry without a refetch. Nothing where the server has
  /// custom statuses turned off.

  ActiveCustomStatusProvider call(String url, String userId) =>
      ActiveCustomStatusProvider._(argument: (url, userId), from: this);

  @override
  String toString() => r'activeCustomStatusProvider';
}
