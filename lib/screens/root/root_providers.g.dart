// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'root_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The teams of one server for the rail, with their badges.

@ProviderFor(railTeams)
final railTeamsProvider = RailTeamsFamily._();

/// The teams of one server for the rail, with their badges.

final class RailTeamsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RailTeam>>,
          List<RailTeam>,
          Stream<List<RailTeam>>
        >
    with $FutureModifier<List<RailTeam>>, $StreamProvider<List<RailTeam>> {
  /// The teams of one server for the rail, with their badges.
  RailTeamsProvider._({
    required RailTeamsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'railTeamsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$railTeamsHash();

  @override
  String toString() {
    return r'railTeamsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RailTeam>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RailTeam>> create(Ref ref) {
    final argument = this.argument as String;
    return railTeams(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RailTeamsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$railTeamsHash() => r'eae4afed9df4a3b1ebd2869599be46d7d89e2d84';

/// The teams of one server for the rail, with their badges.

final class RailTeamsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RailTeam>>, String> {
  RailTeamsFamily._()
    : super(
        retry: null,
        name: r'railTeamsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The teams of one server for the rail, with their badges.

  RailTeamsProvider call(String url) =>
      RailTeamsProvider._(argument: url, from: this);

  @override
  String toString() => r'railTeamsProvider';
}

/// One team's channel list.

@ProviderFor(channelList)
final channelListProvider = ChannelListFamily._();

/// One team's channel list.

final class ChannelListProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChannelList>,
          ChannelList,
          Stream<ChannelList>
        >
    with $FutureModifier<ChannelList>, $StreamProvider<ChannelList> {
  /// One team's channel list.
  ChannelListProvider._({
    required ChannelListFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'channelListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$channelListHash();

  @override
  String toString() {
    return r'channelListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<ChannelList> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ChannelList> create(Ref ref) {
    final argument = this.argument as (String, String);
    return channelList(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$channelListHash() => r'25376dcf9fd108f2cb00b1b8f48902b32b876550';

/// One team's channel list.

final class ChannelListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ChannelList>, (String, String)> {
  ChannelListFamily._()
    : super(
        retry: null,
        name: r'channelListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One team's channel list.

  ChannelListProvider call(String url, String teamId) =>
      ChannelListProvider._(argument: (url, teamId), from: this);

  @override
  String toString() => r'channelListProvider';
}

/// What the server's sync runner is doing, for the progress bar and the
/// offline notice.

@ProviderFor(syncStatus)
final syncStatusProvider = SyncStatusFamily._();

/// What the server's sync runner is doing, for the progress bar and the
/// offline notice.

final class SyncStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<SyncStatus>,
          SyncStatus,
          Stream<SyncStatus>
        >
    with $FutureModifier<SyncStatus>, $StreamProvider<SyncStatus> {
  /// What the server's sync runner is doing, for the progress bar and the
  /// offline notice.
  SyncStatusProvider._({
    required SyncStatusFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'syncStatusProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$syncStatusHash();

  @override
  String toString() {
    return r'syncStatusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<SyncStatus> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<SyncStatus> create(Ref ref) {
    final argument = this.argument as String;
    return syncStatus(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SyncStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$syncStatusHash() => r'23ea1c30688a86a35585f7b7c4705ae55eb1c13f';

/// What the server's sync runner is doing, for the progress bar and the
/// offline notice.

final class SyncStatusFamily extends $Family
    with $FunctionalFamilyOverride<Stream<SyncStatus>, String> {
  SyncStatusFamily._()
    : super(
        retry: null,
        name: r'syncStatusProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What the server's sync runner is doing, for the progress bar and the
  /// offline notice.

  SyncStatusProvider call(String url) =>
      SyncStatusProvider._(argument: url, from: this);

  @override
  String toString() => r'syncStatusProvider';
}

/// Kept while the app runs, like the session it wraps, so the rail can use
/// it.

@ProviderFor(channelActions)
final channelActionsProvider = ChannelActionsFamily._();

/// Kept while the app runs, like the session it wraps, so the rail can use
/// it.

final class ChannelActionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChannelActions>,
          ChannelActions,
          FutureOr<ChannelActions>
        >
    with $FutureModifier<ChannelActions>, $FutureProvider<ChannelActions> {
  /// Kept while the app runs, like the session it wraps, so the rail can use
  /// it.
  ChannelActionsProvider._({
    required ChannelActionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'channelActionsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$channelActionsHash();

  @override
  String toString() {
    return r'channelActionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ChannelActions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ChannelActions> create(Ref ref) {
    final argument = this.argument as String;
    return channelActions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelActionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$channelActionsHash() => r'927b1c312c1d3ec66ef7988ff5d8a80c69952f0f';

/// Kept while the app runs, like the session it wraps, so the rail can use
/// it.

final class ChannelActionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ChannelActions>, String> {
  ChannelActionsFamily._()
    : super(
        retry: null,
        name: r'channelActionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Kept while the app runs, like the session it wraps, so the rail can use
  /// it.

  ChannelActionsProvider call(String url) =>
      ChannelActionsProvider._(argument: url, from: this);

  @override
  String toString() => r'channelActionsProvider';
}

@ProviderFor(serverRefresh)
final serverRefreshProvider = ServerRefreshFamily._();

final class ServerRefreshProvider
    extends
        $FunctionalProvider<
          AsyncValue<ServerRefresh>,
          ServerRefresh,
          FutureOr<ServerRefresh>
        >
    with $FutureModifier<ServerRefresh>, $FutureProvider<ServerRefresh> {
  ServerRefreshProvider._({
    required ServerRefreshFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'serverRefreshProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serverRefreshHash();

  @override
  String toString() {
    return r'serverRefreshProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ServerRefresh> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ServerRefresh> create(Ref ref) {
    final argument = this.argument as String;
    return serverRefresh(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ServerRefreshProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serverRefreshHash() => r'7c9efa0bf1696a3e482257be9806537944da15aa';

final class ServerRefreshFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ServerRefresh>, String> {
  ServerRefreshFamily._()
    : super(
        retry: null,
        name: r'serverRefreshProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ServerRefreshProvider call(String url) =>
      ServerRefreshProvider._(argument: url, from: this);

  @override
  String toString() => r'serverRefreshProvider';
}
