// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(channelViews)
final channelViewsProvider = ChannelViewsFamily._();

final class ChannelViewsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChannelViews>,
          ChannelViews,
          FutureOr<ChannelViews>
        >
    with $FutureModifier<ChannelViews>, $FutureProvider<ChannelViews> {
  ChannelViewsProvider._({
    required ChannelViewsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'channelViewsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$channelViewsHash();

  @override
  String toString() {
    return r'channelViewsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ChannelViews> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ChannelViews> create(Ref ref) {
    final argument = this.argument as String;
    return channelViews(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelViewsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$channelViewsHash() => r'c5c97871cb5e7bf269d8d6d22aeafe3c297d9eb0';

final class ChannelViewsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ChannelViews>, String> {
  ChannelViewsFamily._()
    : super(
        retry: null,
        name: r'channelViewsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChannelViewsProvider call(String url) =>
      ChannelViewsProvider._(argument: url, from: this);

  @override
  String toString() => r'channelViewsProvider';
}

@ProviderFor(directory)
final directoryProvider = DirectoryFamily._();

final class DirectoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<Directory>,
          Directory,
          FutureOr<Directory>
        >
    with $FutureModifier<Directory>, $FutureProvider<Directory> {
  DirectoryProvider._({
    required DirectoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'directoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$directoryHash();

  @override
  String toString() {
    return r'directoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Directory> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Directory> create(Ref ref) {
    final argument = this.argument as String;
    return directory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DirectoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$directoryHash() => r'ccc6f61680934a393bec95191e6d91af0bd78bb6';

final class DirectoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Directory>, String> {
  DirectoryFamily._()
    : super(
        retry: null,
        name: r'directoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DirectoryProvider call(String url) =>
      DirectoryProvider._(argument: url, from: this);

  @override
  String toString() => r'directoryProvider';
}

/// One channel for its info screen; null once it is gone.

@ProviderFor(channelInfo)
final channelInfoProvider = ChannelInfoFamily._();

/// One channel for its info screen; null once it is gone.

final class ChannelInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChannelInfo?>,
          ChannelInfo?,
          Stream<ChannelInfo?>
        >
    with $FutureModifier<ChannelInfo?>, $StreamProvider<ChannelInfo?> {
  /// One channel for its info screen; null once it is gone.
  ChannelInfoProvider._({
    required ChannelInfoFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'channelInfoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$channelInfoHash();

  @override
  String toString() {
    return r'channelInfoProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<ChannelInfo?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ChannelInfo?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return channelInfo(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelInfoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$channelInfoHash() => r'b72c1f2df702fe39b269534b226c14a4f7786cb9';

/// One channel for its info screen; null once it is gone.

final class ChannelInfoFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ChannelInfo?>, (String, String)> {
  ChannelInfoFamily._()
    : super(
        retry: null,
        name: r'channelInfoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One channel for its info screen; null once it is gone.

  ChannelInfoProvider call(String url, String channelId) =>
      ChannelInfoProvider._(argument: (url, channelId), from: this);

  @override
  String toString() => r'channelInfoProvider';
}

/// Fetched when the info screen opens; the member count is also stored.

@ProviderFor(channelStats)
final channelStatsProvider = ChannelStatsFamily._();

/// Fetched when the info screen opens; the member count is also stored.

final class ChannelStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<api.ChannelStats>,
          api.ChannelStats,
          FutureOr<api.ChannelStats>
        >
    with $FutureModifier<api.ChannelStats>, $FutureProvider<api.ChannelStats> {
  /// Fetched when the info screen opens; the member count is also stored.
  ChannelStatsProvider._({
    required ChannelStatsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: noRetry,
         name: r'channelStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$channelStatsHash();

  @override
  String toString() {
    return r'channelStatsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<api.ChannelStats> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<api.ChannelStats> create(Ref ref) {
    final argument = this.argument as (String, String);
    return channelStats(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$channelStatsHash() => r'689a0396d0154306ee69f39e1c7c37b28fa42d34';

/// Fetched when the info screen opens; the member count is also stored.

final class ChannelStatsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<api.ChannelStats>,
          (String, String)
        > {
  ChannelStatsFamily._()
    : super(
        retry: noRetry,
        name: r'channelStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetched when the info screen opens; the member count is also stored.

  ChannelStatsProvider call(String url, String channelId) =>
      ChannelStatsProvider._(argument: (url, channelId), from: this);

  @override
  String toString() => r'channelStatsProvider';
}

/// The stored pinned messages of a channel, newest first.

@ProviderFor(pinnedIds)
final pinnedIdsProvider = PinnedIdsFamily._();

/// The stored pinned messages of a channel, newest first.

final class PinnedIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  /// The stored pinned messages of a channel, newest first.
  PinnedIdsProvider._({
    required PinnedIdsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'pinnedIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pinnedIdsHash();

  @override
  String toString() {
    return r'pinnedIdsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return pinnedIds(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is PinnedIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pinnedIdsHash() => r'5e913af66822bbe2d2050ec07f98839d70a108ac';

/// The stored pinned messages of a channel, newest first.

final class PinnedIdsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<String>>, (String, String)> {
  PinnedIdsFamily._()
    : super(
        retry: null,
        name: r'pinnedIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The stored pinned messages of a channel, newest first.

  PinnedIdsProvider call(String url, String channelId) =>
      PinnedIdsProvider._(argument: (url, channelId), from: this);

  @override
  String toString() => r'pinnedIdsProvider';
}

/// Fetches the pinned messages again.

@ProviderFor(pinnedRefresh)
final pinnedRefreshProvider = PinnedRefreshFamily._();

/// Fetches the pinned messages again.

final class PinnedRefreshProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Fetches the pinned messages again.
  PinnedRefreshProvider._({
    required PinnedRefreshFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: noRetry,
         name: r'pinnedRefreshProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pinnedRefreshHash();

  @override
  String toString() {
    return r'pinnedRefreshProvider'
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
    return pinnedRefresh(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is PinnedRefreshProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pinnedRefreshHash() => r'08212e49fb45047c31a842d1f65c75aac6443a6c';

/// Fetches the pinned messages again.

final class PinnedRefreshFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, (String, String)> {
  PinnedRefreshFamily._()
    : super(
        retry: noRetry,
        name: r'pinnedRefreshProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches the pinned messages again.

  PinnedRefreshProvider call(String url, String channelId) =>
      PinnedRefreshProvider._(argument: (url, channelId), from: this);

  @override
  String toString() => r'pinnedRefreshProvider';
}

/// People by id (comma-separated), with live names and presence.

@ProviderFor(peopleRows)
final peopleRowsProvider = PeopleRowsFamily._();

/// People by id (comma-separated), with live names and presence.

final class PeopleRowsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SwitchItem>>,
          List<SwitchItem>,
          Stream<List<SwitchItem>>
        >
    with $FutureModifier<List<SwitchItem>>, $StreamProvider<List<SwitchItem>> {
  /// People by id (comma-separated), with live names and presence.
  PeopleRowsProvider._({
    required PeopleRowsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'peopleRowsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$peopleRowsHash();

  @override
  String toString() {
    return r'peopleRowsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<SwitchItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SwitchItem>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return peopleRows(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is PeopleRowsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$peopleRowsHash() => r'd9a2ad093f63b4ab4747952528072ce5fe9484d8';

/// People by id (comma-separated), with live names and presence.

final class PeopleRowsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<SwitchItem>>, (String, String)> {
  PeopleRowsFamily._()
    : super(
        retry: null,
        name: r'peopleRowsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// People by id (comma-separated), with live names and presence.

  PeopleRowsProvider call(String url, String ids) =>
      PeopleRowsProvider._(argument: (url, ids), from: this);

  @override
  String toString() => r'peopleRowsProvider';
}

@ProviderFor(teamRights)
final teamRightsProvider = TeamRightsFamily._();

final class TeamRightsProvider
    extends
        $FunctionalProvider<
          AsyncValue<({bool join, bool private, bool public})>,
          ({bool join, bool private, bool public}),
          FutureOr<({bool join, bool private, bool public})>
        >
    with
        $FutureModifier<({bool join, bool private, bool public})>,
        $FutureProvider<({bool join, bool private, bool public})> {
  TeamRightsProvider._({
    required TeamRightsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'teamRightsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teamRightsHash();

  @override
  String toString() {
    return r'teamRightsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<({bool join, bool private, bool public})>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<({bool join, bool private, bool public})> create(Ref ref) {
    final argument = this.argument as (String, String);
    return teamRights(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is TeamRightsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teamRightsHash() => r'09ba1804b0934165f0529660bbbc18b9fd92899c';

final class TeamRightsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<({bool join, bool private, bool public})>,
          (String, String)
        > {
  TeamRightsFamily._()
    : super(
        retry: null,
        name: r'teamRightsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TeamRightsProvider call(String url, String teamId) =>
      TeamRightsProvider._(argument: (url, teamId), from: this);

  @override
  String toString() => r'teamRightsProvider';
}
