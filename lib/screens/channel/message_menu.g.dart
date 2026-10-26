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

String _$postMenuFactsHash() => r'71df0037b81dd06ef659ad269d41452d08cc8c97';

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
