// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_menu.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(postMenuFacts)
final postMenuFactsProvider = PostMenuFactsFamily._();

final class PostMenuFactsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PostMenuFacts>,
          PostMenuFacts,
          FutureOr<PostMenuFacts>
        >
    with $FutureModifier<PostMenuFacts>, $FutureProvider<PostMenuFacts> {
  PostMenuFactsProvider._({
    required PostMenuFactsFamily super.from,
    required (String, PostItem, String) super.argument,
  }) : super(
         retry: null,
         name: r'postMenuFactsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postMenuFactsHash();

  @override
  String toString() {
    return r'postMenuFactsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PostMenuFacts> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PostMenuFacts> create(Ref ref) {
    final argument = this.argument as (String, PostItem, String);
    return postMenuFacts(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is PostMenuFactsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postMenuFactsHash() => r'51e169420b5495bfa58a0a44b51131e6d519a3d5';

final class PostMenuFactsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PostMenuFacts>,
          (String, PostItem, String)
        > {
  PostMenuFactsFamily._()
    : super(
        retry: null,
        name: r'postMenuFactsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PostMenuFactsProvider call(String url, PostItem post, String teamId) =>
      PostMenuFactsProvider._(argument: (url, post, teamId), from: this);

  @override
  String toString() => r'postMenuFactsProvider';
}

/// Whether reports of messages are on for the team, false where the server
/// doesn't have the feature or can't say.

@ProviderFor(reportsEnabled)
final reportsEnabledProvider = ReportsEnabledFamily._();

/// Whether reports of messages are on for the team, false where the server
/// doesn't have the feature or can't say.

final class ReportsEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether reports of messages are on for the team, false where the server
  /// doesn't have the feature or can't say.
  ReportsEnabledProvider._({
    required ReportsEnabledFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'reportsEnabledProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reportsEnabledHash();

  @override
  String toString() {
    return r'reportsEnabledProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as (String, String);
    return reportsEnabled(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ReportsEnabledProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reportsEnabledHash() => r'4dad4c7af2f06405d51112d2f13e838dd0f8a7f5';

/// Whether reports of messages are on for the team, false where the server
/// doesn't have the feature or can't say.

final class ReportsEnabledFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, (String, String)> {
  ReportsEnabledFamily._()
    : super(
        retry: null,
        name: r'reportsEnabledProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Whether reports of messages are on for the team, false where the server
  /// doesn't have the feature or can't say.

  ReportsEnabledProvider call(String url, String teamId) =>
      ReportsEnabledProvider._(argument: (url, teamId), from: this);

  @override
  String toString() => r'reportsEnabledProvider';
}
