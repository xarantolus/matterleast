// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_screens.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(teamActions)
final teamActionsProvider = TeamActionsFamily._();

final class TeamActionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<TeamActions>,
          TeamActions,
          FutureOr<TeamActions>
        >
    with $FutureModifier<TeamActions>, $FutureProvider<TeamActions> {
  TeamActionsProvider._({
    required TeamActionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'teamActionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teamActionsHash();

  @override
  String toString() {
    return r'teamActionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TeamActions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TeamActions> create(Ref ref) {
    final argument = this.argument as String;
    return teamActions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TeamActionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teamActionsHash() => r'6eff09d5003c42ce57f1282dc6e931f9328adb45';

final class TeamActionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TeamActions>, String> {
  TeamActionsFamily._()
    : super(
        retry: null,
        name: r'teamActionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TeamActionsProvider call(String url) =>
      TeamActionsProvider._(argument: url, from: this);

  @override
  String toString() => r'teamActionsProvider';
}

/// Open teams on [url] the user isn't in; asked again on each visit.

@ProviderFor(joinableTeamList)
final joinableTeamListProvider = JoinableTeamListFamily._();

/// Open teams on [url] the user isn't in; asked again on each visit.

final class JoinableTeamListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<JoinableTeam>>,
          List<JoinableTeam>,
          FutureOr<List<JoinableTeam>>
        >
    with
        $FutureModifier<List<JoinableTeam>>,
        $FutureProvider<List<JoinableTeam>> {
  /// Open teams on [url] the user isn't in; asked again on each visit.
  JoinableTeamListProvider._({
    required JoinableTeamListFamily super.from,
    required String super.argument,
  }) : super(
         retry: _noRetry,
         name: r'joinableTeamListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$joinableTeamListHash();

  @override
  String toString() {
    return r'joinableTeamListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<JoinableTeam>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<JoinableTeam>> create(Ref ref) {
    final argument = this.argument as String;
    return joinableTeamList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is JoinableTeamListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$joinableTeamListHash() => r'9f2ed4ad15fddbb27387943105bbbd9b80e9176e';

/// Open teams on [url] the user isn't in; asked again on each visit.

final class JoinableTeamListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<JoinableTeam>>, String> {
  JoinableTeamListFamily._()
    : super(
        retry: _noRetry,
        name: r'joinableTeamListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Open teams on [url] the user isn't in; asked again on each visit.

  JoinableTeamListProvider call(String url) =>
      JoinableTeamListProvider._(argument: url, from: this);

  @override
  String toString() => r'joinableTeamListProvider';
}
