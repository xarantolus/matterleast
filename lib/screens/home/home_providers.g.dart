// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The chip picked on Home; kept while the app runs so Saved can be opened
/// from the You page.

@ProviderFor(HomeFilterSelection)
final homeFilterSelectionProvider = HomeFilterSelectionProvider._();

/// The chip picked on Home; kept while the app runs so Saved can be opened
/// from the You page.
final class HomeFilterSelectionProvider
    extends $NotifierProvider<HomeFilterSelection, InboxFilter> {
  /// The chip picked on Home; kept while the app runs so Saved can be opened
  /// from the You page.
  HomeFilterSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeFilterSelectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeFilterSelectionHash();

  @$internal
  @override
  HomeFilterSelection create() => HomeFilterSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InboxFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InboxFilter>(value),
    );
  }
}

String _$homeFilterSelectionHash() =>
    r'3eb76bf21a6588ddf6b028a84d062636038f34bb';

/// The chip picked on Home; kept while the app runs so Saved can be opened
/// from the You page.

abstract class _$HomeFilterSelection extends $Notifier<InboxFilter> {
  InboxFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<InboxFilter, InboxFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InboxFilter, InboxFilter>,
              InboxFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// One server's inbox rows for every chip.

@ProviderFor(serverInbox)
final serverInboxProvider = ServerInboxFamily._();

/// One server's inbox rows for every chip.

final class ServerInboxProvider
    extends
        $FunctionalProvider<
          AsyncValue<ServerInbox>,
          ServerInbox,
          Stream<ServerInbox>
        >
    with $FutureModifier<ServerInbox>, $StreamProvider<ServerInbox> {
  /// One server's inbox rows for every chip.
  ServerInboxProvider._({
    required ServerInboxFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'serverInboxProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serverInboxHash();

  @override
  String toString() {
    return r'serverInboxProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ServerInbox> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ServerInbox> create(Ref ref) {
    final argument = this.argument as String;
    return serverInbox(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ServerInboxProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serverInboxHash() => r'647820ae214d5c72a200e5f340bfc77f93fbecac';

/// One server's inbox rows for every chip.

final class ServerInboxFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ServerInbox>, String> {
  ServerInboxFamily._()
    : super(
        retry: null,
        name: r'serverInboxProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One server's inbox rows for every chip.

  ServerInboxProvider call(String url) =>
      ServerInboxProvider._(argument: url, from: this);

  @override
  String toString() => r'serverInboxProvider';
}

/// The followed threads of one team.

@ProviderFor(teamThreads)
final teamThreadsProvider = TeamThreadsFamily._();

/// The followed threads of one team.

final class TeamThreadsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InboxItem>>,
          List<InboxItem>,
          Stream<List<InboxItem>>
        >
    with $FutureModifier<List<InboxItem>>, $StreamProvider<List<InboxItem>> {
  /// The followed threads of one team.
  TeamThreadsProvider._({
    required TeamThreadsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'teamThreadsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teamThreadsHash();

  @override
  String toString() {
    return r'teamThreadsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<InboxItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<InboxItem>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return teamThreads(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is TeamThreadsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teamThreadsHash() => r'70ac279d9be3e33c0fbc6f093dc2afe5a2f7b8ad';

/// The followed threads of one team.

final class TeamThreadsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<InboxItem>>, (String, String)> {
  TeamThreadsFamily._()
    : super(
        retry: null,
        name: r'teamThreadsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The followed threads of one team.

  TeamThreadsProvider call(String url, String teamId) =>
      TeamThreadsProvider._(argument: (url, teamId), from: this);

  @override
  String toString() => r'teamThreadsProvider';
}
