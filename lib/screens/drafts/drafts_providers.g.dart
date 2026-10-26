// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drafts_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One team's drafts, newest first.

@ProviderFor(teamDrafts)
final teamDraftsProvider = TeamDraftsFamily._();

/// One team's drafts, newest first.

final class TeamDraftsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DraftItem>>,
          List<DraftItem>,
          Stream<List<DraftItem>>
        >
    with $FutureModifier<List<DraftItem>>, $StreamProvider<List<DraftItem>> {
  /// One team's drafts, newest first.
  TeamDraftsProvider._({
    required TeamDraftsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'teamDraftsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teamDraftsHash();

  @override
  String toString() {
    return r'teamDraftsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<DraftItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DraftItem>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return teamDrafts(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is TeamDraftsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teamDraftsHash() => r'315e98db10aec88de3d3b1ebd0bf92eea1874cde';

/// One team's drafts, newest first.

final class TeamDraftsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<DraftItem>>, (String, String)> {
  TeamDraftsFamily._()
    : super(
        retry: null,
        name: r'teamDraftsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One team's drafts, newest first.

  TeamDraftsProvider call(String url, String teamId) =>
      TeamDraftsProvider._(argument: (url, teamId), from: this);

  @override
  String toString() => r'teamDraftsProvider';
}

/// One team's scheduled messages, failed first, then the soonest.

@ProviderFor(teamScheduled)
final teamScheduledProvider = TeamScheduledFamily._();

/// One team's scheduled messages, failed first, then the soonest.

final class TeamScheduledProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ScheduledItem>>,
          List<ScheduledItem>,
          Stream<List<ScheduledItem>>
        >
    with
        $FutureModifier<List<ScheduledItem>>,
        $StreamProvider<List<ScheduledItem>> {
  /// One team's scheduled messages, failed first, then the soonest.
  TeamScheduledProvider._({
    required TeamScheduledFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'teamScheduledProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teamScheduledHash();

  @override
  String toString() {
    return r'teamScheduledProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<ScheduledItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ScheduledItem>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return teamScheduled(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is TeamScheduledProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teamScheduledHash() => r'6b0cd5c5099b069f59b9ac7faf09649f43d78413';

/// One team's scheduled messages, failed first, then the soonest.

final class TeamScheduledFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<ScheduledItem>>,
          (String, String)
        > {
  TeamScheduledFamily._()
    : super(
        retry: null,
        name: r'teamScheduledProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One team's scheduled messages, failed first, then the soonest.

  TeamScheduledProvider call(String url, String teamId) =>
      TeamScheduledProvider._(argument: (url, teamId), from: this);

  @override
  String toString() => r'teamScheduledProvider';
}

/// How many messages wait to be sent in a channel or thread.

@ProviderFor(scheduledCount)
final scheduledCountProvider = ScheduledCountFamily._();

/// How many messages wait to be sent in a channel or thread.

final class ScheduledCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// How many messages wait to be sent in a channel or thread.
  ScheduledCountProvider._({
    required ScheduledCountFamily super.from,
    required (String, String, String) super.argument,
  }) : super(
         retry: null,
         name: r'scheduledCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$scheduledCountHash();

  @override
  String toString() {
    return r'scheduledCountProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as (String, String, String);
    return scheduledCount(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is ScheduledCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$scheduledCountHash() => r'be029aadb5b164805ae172420cab24f704644b7b';

/// How many messages wait to be sent in a channel or thread.

final class ScheduledCountFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, (String, String, String)> {
  ScheduledCountFamily._()
    : super(
        retry: null,
        name: r'scheduledCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How many messages wait to be sent in a channel or thread.

  ScheduledCountProvider call(String url, String channelId, String rootId) =>
      ScheduledCountProvider._(argument: (url, channelId, rootId), from: this);

  @override
  String toString() => r'scheduledCountProvider';
}

/// The IANA zone the user set by hand in their profile; null when the
/// phone's zone applies.

@ProviderFor(manualTimeZone)
final manualTimeZoneProvider = ManualTimeZoneFamily._();

/// The IANA zone the user set by hand in their profile; null when the
/// phone's zone applies.

final class ManualTimeZoneProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  /// The IANA zone the user set by hand in their profile; null when the
  /// phone's zone applies.
  ManualTimeZoneProvider._({
    required ManualTimeZoneFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'manualTimeZoneProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$manualTimeZoneHash();

  @override
  String toString() {
    return r'manualTimeZoneProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    final argument = this.argument as String;
    return manualTimeZone(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ManualTimeZoneProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$manualTimeZoneHash() => r'2c3c7ba5974b7ca3c48403f70f7b5cb694a440fe';

/// The IANA zone the user set by hand in their profile; null when the
/// phone's zone applies.

final class ManualTimeZoneFamily extends $Family
    with $FunctionalFamilyOverride<Stream<String?>, String> {
  ManualTimeZoneFamily._()
    : super(
        retry: null,
        name: r'manualTimeZoneProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The IANA zone the user set by hand in their profile; null when the
  /// phone's zone applies.

  ManualTimeZoneProvider call(String url) =>
      ManualTimeZoneProvider._(argument: url, from: this);

  @override
  String toString() => r'manualTimeZoneProvider';
}

/// Fetches the team's synced drafts and scheduled messages while the drafts
/// screen is open; what is stored shows meanwhile, and a failure keeps it.

@ProviderFor(refreshDrafts)
final refreshDraftsProvider = RefreshDraftsFamily._();

/// Fetches the team's synced drafts and scheduled messages while the drafts
/// screen is open; what is stored shows meanwhile, and a failure keeps it.

final class RefreshDraftsProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Fetches the team's synced drafts and scheduled messages while the drafts
  /// screen is open; what is stored shows meanwhile, and a failure keeps it.
  RefreshDraftsProvider._({
    required RefreshDraftsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'refreshDraftsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$refreshDraftsHash();

  @override
  String toString() {
    return r'refreshDraftsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as (String, String);
    return refreshDrafts(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is RefreshDraftsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$refreshDraftsHash() => r'e14296bfa31f5cf46ac66e1a44934084d1ef34df';

/// Fetches the team's synced drafts and scheduled messages while the drafts
/// screen is open; what is stored shows meanwhile, and a failure keeps it.

final class RefreshDraftsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, (String, String)> {
  RefreshDraftsFamily._()
    : super(
        retry: null,
        name: r'refreshDraftsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches the team's synced drafts and scheduled messages while the drafts
  /// screen is open; what is stored shows meanwhile, and a failure keeps it.

  RefreshDraftsProvider call(String url, String teamId) =>
      RefreshDraftsProvider._(argument: (url, teamId), from: this);

  @override
  String toString() => r'refreshDraftsProvider';
}
