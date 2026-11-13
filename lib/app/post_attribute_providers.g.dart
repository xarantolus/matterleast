// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_attribute_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(postAttributeSetup)
final postAttributeSetupProvider = PostAttributeSetupFamily._();

final class PostAttributeSetupProvider
    extends
        $FunctionalProvider<
          AsyncValue<PostAttributeSetup>,
          PostAttributeSetup,
          FutureOr<PostAttributeSetup>
        >
    with
        $FutureModifier<PostAttributeSetup>,
        $FutureProvider<PostAttributeSetup> {
  PostAttributeSetupProvider._({
    required PostAttributeSetupFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'postAttributeSetupProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postAttributeSetupHash();

  @override
  String toString() {
    return r'postAttributeSetupProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PostAttributeSetup> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PostAttributeSetup> create(Ref ref) {
    final argument = this.argument as (String, String);
    return postAttributeSetup(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is PostAttributeSetupProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postAttributeSetupHash() =>
    r'13ac50eed1ad7faa1649b4e9b595e1a1cbdf65f0';

final class PostAttributeSetupFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PostAttributeSetup>,
          (String, String)
        > {
  PostAttributeSetupFamily._()
    : super(
        retry: null,
        name: r'postAttributeSetupProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  PostAttributeSetupProvider call(String url, String postId) =>
      PostAttributeSetupProvider._(argument: (url, postId), from: this);

  @override
  String toString() => r'postAttributeSetupProvider';
}

/// The attribute fields a new channel in a team takes, and what the user
/// may set.

@ProviderFor(channelAttributeSetup)
final channelAttributeSetupProvider = ChannelAttributeSetupFamily._();

/// The attribute fields a new channel in a team takes, and what the user
/// may set.

final class ChannelAttributeSetupProvider
    extends
        $FunctionalProvider<
          AsyncValue<PostAttributeSetup>,
          PostAttributeSetup,
          FutureOr<PostAttributeSetup>
        >
    with
        $FutureModifier<PostAttributeSetup>,
        $FutureProvider<PostAttributeSetup> {
  /// The attribute fields a new channel in a team takes, and what the user
  /// may set.
  ChannelAttributeSetupProvider._({
    required ChannelAttributeSetupFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'channelAttributeSetupProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$channelAttributeSetupHash();

  @override
  String toString() {
    return r'channelAttributeSetupProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PostAttributeSetup> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PostAttributeSetup> create(Ref ref) {
    final argument = this.argument as (String, String);
    return channelAttributeSetup(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelAttributeSetupProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$channelAttributeSetupHash() =>
    r'8c6100f01971b4da1e9826b84856425a96bf4ade';

/// The attribute fields a new channel in a team takes, and what the user
/// may set.

final class ChannelAttributeSetupFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PostAttributeSetup>,
          (String, String)
        > {
  ChannelAttributeSetupFamily._()
    : super(
        retry: null,
        name: r'channelAttributeSetupProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The attribute fields a new channel in a team takes, and what the user
  /// may set.

  ChannelAttributeSetupProvider call(String url, String teamId) =>
      ChannelAttributeSetupProvider._(argument: (url, teamId), from: this);

  @override
  String toString() => r'channelAttributeSetupProvider';
}

/// The names of the people attributes point at, by id; [ids] is the ids
/// joined with commas.

@ProviderFor(attributeUserNames)
final attributeUserNamesProvider = AttributeUserNamesFamily._();

/// The names of the people attributes point at, by id; [ids] is the ids
/// joined with commas.

final class AttributeUserNamesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, String>>,
          Map<String, String>,
          FutureOr<Map<String, String>>
        >
    with
        $FutureModifier<Map<String, String>>,
        $FutureProvider<Map<String, String>> {
  /// The names of the people attributes point at, by id; [ids] is the ids
  /// joined with commas.
  AttributeUserNamesProvider._({
    required AttributeUserNamesFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'attributeUserNamesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$attributeUserNamesHash();

  @override
  String toString() {
    return r'attributeUserNamesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, String>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return attributeUserNames(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is AttributeUserNamesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$attributeUserNamesHash() =>
    r'd0d40d79b4f6b9af6d56df83eb214de58d3bf0a5';

/// The names of the people attributes point at, by id; [ids] is the ids
/// joined with commas.

final class AttributeUserNamesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<String, String>>,
          (String, String)
        > {
  AttributeUserNamesFamily._()
    : super(
        retry: null,
        name: r'attributeUserNamesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The names of the people attributes point at, by id; [ids] is the ids
  /// joined with commas.

  AttributeUserNamesProvider call(String url, String ids) =>
      AttributeUserNamesProvider._(argument: (url, ids), from: this);

  @override
  String toString() => r'attributeUserNamesProvider';
}
