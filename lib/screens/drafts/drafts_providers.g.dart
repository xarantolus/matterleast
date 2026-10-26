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
