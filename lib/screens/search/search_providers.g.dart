// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One server's channels, conversations and people for the quick switcher.

@ProviderFor(switchItems)
final switchItemsProvider = SwitchItemsFamily._();

/// One server's channels, conversations and people for the quick switcher.

final class SwitchItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SwitchItem>>,
          List<SwitchItem>,
          Stream<List<SwitchItem>>
        >
    with $FutureModifier<List<SwitchItem>>, $StreamProvider<List<SwitchItem>> {
  /// One server's channels, conversations and people for the quick switcher.
  SwitchItemsProvider._({
    required SwitchItemsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'switchItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$switchItemsHash();

  @override
  String toString() {
    return r'switchItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<SwitchItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SwitchItem>> create(Ref ref) {
    final argument = this.argument as String;
    return switchItems(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SwitchItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$switchItemsHash() => r'5d55cd3a822578e419e97ae81f027848cb4590ae';

/// One server's channels, conversations and people for the quick switcher.

final class SwitchItemsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<SwitchItem>>, String> {
  SwitchItemsFamily._()
    : super(
        retry: null,
        name: r'switchItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One server's channels, conversations and people for the quick switcher.

  SwitchItemsProvider call(String url) =>
      SwitchItemsProvider._(argument: url, from: this);

  @override
  String toString() => r'switchItemsProvider';
}

/// What one server knows about [term] beyond what is stored.

@ProviderFor(switchRemote)
final switchRemoteProvider = SwitchRemoteFamily._();

/// What one server knows about [term] beyond what is stored.

final class SwitchRemoteProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SwitchItem>>,
          List<SwitchItem>,
          FutureOr<List<SwitchItem>>
        >
    with $FutureModifier<List<SwitchItem>>, $FutureProvider<List<SwitchItem>> {
  /// What one server knows about [term] beyond what is stored.
  SwitchRemoteProvider._({
    required SwitchRemoteFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: noRetry,
         name: r'switchRemoteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$switchRemoteHash();

  @override
  String toString() {
    return r'switchRemoteProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<SwitchItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SwitchItem>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return switchRemote(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SwitchRemoteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$switchRemoteHash() => r'fce70f760325ff38dfa7ea86e95341048d68deac';

/// What one server knows about [term] beyond what is stored.

final class SwitchRemoteFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SwitchItem>>,
          (String, String)
        > {
  SwitchRemoteFamily._()
    : super(
        retry: noRetry,
        name: r'switchRemoteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What one server knows about [term] beyond what is stored.

  SwitchRemoteProvider call(String url, String term) =>
      SwitchRemoteProvider._(argument: (url, term), from: this);

  @override
  String toString() => r'switchRemoteProvider';
}

/// The team the user is in on [url], as the server's sync last stored it.

@ProviderFor(currentTeam)
final currentTeamProvider = CurrentTeamFamily._();

/// The team the user is in on [url], as the server's sync last stored it.

final class CurrentTeamProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The team the user is in on [url], as the server's sync last stored it.
  CurrentTeamProvider._({
    required CurrentTeamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'currentTeamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$currentTeamHash();

  @override
  String toString() {
    return r'currentTeamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return currentTeam(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentTeamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$currentTeamHash() => r'aff7d96f9a2ddc282821bdd19e17a057ec23cf58';

/// The team the user is in on [url], as the server's sync last stored it.

final class CurrentTeamFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  CurrentTeamFamily._()
    : super(
        retry: null,
        name: r'currentTeamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The team the user is in on [url], as the server's sync last stored it.

  CurrentTeamProvider call(String url) =>
      CurrentTeamProvider._(argument: url, from: this);

  @override
  String toString() => r'currentTeamProvider';
}

@ProviderFor(messageSearch)
final messageSearchProvider = MessageSearchFamily._();

final class MessageSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<MessageSearch>,
          MessageSearch,
          FutureOr<MessageSearch>
        >
    with $FutureModifier<MessageSearch>, $FutureProvider<MessageSearch> {
  MessageSearchProvider._({
    required MessageSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'messageSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$messageSearchHash();

  @override
  String toString() {
    return r'messageSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MessageSearch> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MessageSearch> create(Ref ref) {
    final argument = this.argument as String;
    return messageSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messageSearchHash() => r'916610e47bed353c4dc2402647d281d11924a32c';

final class MessageSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MessageSearch>, String> {
  MessageSearchFamily._()
    : super(
        retry: null,
        name: r'messageSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MessageSearchProvider call(String url) =>
      MessageSearchProvider._(argument: url, from: this);

  @override
  String toString() => r'messageSearchProvider';
}

@ProviderFor(recentSearches)
final recentSearchesProvider = RecentSearchesFamily._();

final class RecentSearchesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  RecentSearchesProvider._({
    required RecentSearchesFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'recentSearchesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recentSearchesHash();

  @override
  String toString() {
    return r'recentSearchesProvider'
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
    return recentSearches(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentSearchesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentSearchesHash() => r'e36257475495c3de33d284c4cf785d4168b14985';

final class RecentSearchesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<String>>, (String, String)> {
  RecentSearchesFamily._()
    : super(
        retry: null,
        name: r'recentSearchesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RecentSearchesProvider call(String url, String teamId) =>
      RecentSearchesProvider._(argument: (url, teamId), from: this);

  @override
  String toString() => r'recentSearchesProvider';
}

/// Stored posts matching [query] in [scope], at once and without a server.

@ProviderFor(localPostResults)
final localPostResultsProvider = LocalPostResultsFamily._();

/// Stored posts matching [query] in [scope], at once and without a server.

final class LocalPostResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Stored posts matching [query] in [scope], at once and without a server.
  LocalPostResultsProvider._({
    required LocalPostResultsFamily super.from,
    required (String, SearchScope, String) super.argument,
  }) : super(
         retry: null,
         name: r'localPostResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$localPostResultsHash();

  @override
  String toString() {
    return r'localPostResultsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as (String, SearchScope, String);
    return localPostResults(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalPostResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$localPostResultsHash() => r'0d27d0a087ddca4f027b7221666efcc2dd954cc3';

/// Stored posts matching [query] in [scope], at once and without a server.

final class LocalPostResultsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<String>>,
          (String, SearchScope, String)
        > {
  LocalPostResultsFamily._()
    : super(
        retry: null,
        name: r'localPostResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stored posts matching [query] in [scope], at once and without a server.

  LocalPostResultsProvider call(String url, SearchScope scope, String query) =>
      LocalPostResultsProvider._(argument: (url, scope, query), from: this);

  @override
  String toString() => r'localPostResultsProvider';
}

@ProviderFor(serverPostResults)
final serverPostResultsProvider = ServerPostResultsFamily._();

final class ServerPostResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  ServerPostResultsProvider._({
    required ServerPostResultsFamily super.from,
    required (String, SearchScope, String) super.argument,
  }) : super(
         retry: noRetry,
         name: r'serverPostResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serverPostResultsHash();

  @override
  String toString() {
    return r'serverPostResultsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as (String, SearchScope, String);
    return serverPostResults(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is ServerPostResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serverPostResultsHash() => r'a0ec1b1a52484b17ab434d6e487e8a7349c7999d';

final class ServerPostResultsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<String>>,
          (String, SearchScope, String)
        > {
  ServerPostResultsFamily._()
    : super(
        retry: noRetry,
        name: r'serverPostResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ServerPostResultsProvider call(String url, SearchScope scope, String query) =>
      ServerPostResultsProvider._(argument: (url, scope, query), from: this);

  @override
  String toString() => r'serverPostResultsProvider';
}

@ProviderFor(localFileResults)
final localFileResultsProvider = LocalFileResultsFamily._();

final class LocalFileResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FileHit>>,
          List<FileHit>,
          FutureOr<List<FileHit>>
        >
    with $FutureModifier<List<FileHit>>, $FutureProvider<List<FileHit>> {
  LocalFileResultsProvider._({
    required LocalFileResultsFamily super.from,
    required (String, SearchScope, String) super.argument,
  }) : super(
         retry: null,
         name: r'localFileResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$localFileResultsHash();

  @override
  String toString() {
    return r'localFileResultsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<FileHit>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FileHit>> create(Ref ref) {
    final argument = this.argument as (String, SearchScope, String);
    return localFileResults(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalFileResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$localFileResultsHash() => r'9d6dc44476d9eb3258dd335726562aa39026950c';

final class LocalFileResultsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<FileHit>>,
          (String, SearchScope, String)
        > {
  LocalFileResultsFamily._()
    : super(
        retry: null,
        name: r'localFileResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LocalFileResultsProvider call(String url, SearchScope scope, String query) =>
      LocalFileResultsProvider._(argument: (url, scope, query), from: this);

  @override
  String toString() => r'localFileResultsProvider';
}

@ProviderFor(serverFileResults)
final serverFileResultsProvider = ServerFileResultsFamily._();

final class ServerFileResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FileHit>>,
          List<FileHit>,
          FutureOr<List<FileHit>>
        >
    with $FutureModifier<List<FileHit>>, $FutureProvider<List<FileHit>> {
  ServerFileResultsProvider._({
    required ServerFileResultsFamily super.from,
    required (String, SearchScope, String) super.argument,
  }) : super(
         retry: noRetry,
         name: r'serverFileResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serverFileResultsHash();

  @override
  String toString() {
    return r'serverFileResultsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<FileHit>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FileHit>> create(Ref ref) {
    final argument = this.argument as (String, SearchScope, String);
    return serverFileResults(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is ServerFileResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serverFileResultsHash() => r'e4b4b62677728b728e4c3b6df174c0e94429e263';

final class ServerFileResultsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<FileHit>>,
          (String, SearchScope, String)
        > {
  ServerFileResultsFamily._()
    : super(
        retry: noRetry,
        name: r'serverFileResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ServerFileResultsProvider call(String url, SearchScope scope, String query) =>
      ServerFileResultsProvider._(argument: (url, scope, query), from: this);

  @override
  String toString() => r'serverFileResultsProvider';
}

/// Message previews of the posts [ids] (comma-separated), in that order.

@ProviderFor(searchPostItems)
final searchPostItemsProvider = SearchPostItemsFamily._();

/// Message previews of the posts [ids] (comma-separated), in that order.

final class SearchPostItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InboxItem>>,
          List<InboxItem>,
          Stream<List<InboxItem>>
        >
    with $FutureModifier<List<InboxItem>>, $StreamProvider<List<InboxItem>> {
  /// Message previews of the posts [ids] (comma-separated), in that order.
  SearchPostItemsProvider._({
    required SearchPostItemsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'searchPostItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchPostItemsHash();

  @override
  String toString() {
    return r'searchPostItemsProvider'
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
    return searchPostItems(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchPostItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchPostItemsHash() => r'870433721bea004d6fef626654fd56f5348a6350';

/// Message previews of the posts [ids] (comma-separated), in that order.

final class SearchPostItemsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<InboxItem>>, (String, String)> {
  SearchPostItemsFamily._()
    : super(
        retry: null,
        name: r'searchPostItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Message previews of the posts [ids] (comma-separated), in that order.

  SearchPostItemsProvider call(String url, String ids) =>
      SearchPostItemsProvider._(argument: (url, ids), from: this);

  @override
  String toString() => r'searchPostItemsProvider';
}
