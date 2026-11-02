// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A server's known custom emoji, name → id.

@ProviderFor(customEmoji)
final customEmojiProvider = CustomEmojiFamily._();

/// A server's known custom emoji, name → id.

final class CustomEmojiProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, String>>,
          Map<String, String>,
          Stream<Map<String, String>>
        >
    with
        $FutureModifier<Map<String, String>>,
        $StreamProvider<Map<String, String>> {
  /// A server's known custom emoji, name → id.
  CustomEmojiProvider._({
    required CustomEmojiFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'customEmojiProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customEmojiHash();

  @override
  String toString() {
    return r'customEmojiProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, String>> create(Ref ref) {
    final argument = this.argument as String;
    return customEmoji(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomEmojiProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customEmojiHash() => r'673bce04c2625f20e8842786c8e0314e96bc1ceb';

/// A server's known custom emoji, name → id.

final class CustomEmojiFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<String, String>>, String> {
  CustomEmojiFamily._()
    : super(
        retry: null,
        name: r'customEmojiProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A server's known custom emoji, name → id.

  CustomEmojiProvider call(String url) =>
      CustomEmojiProvider._(argument: url, from: this);

  @override
  String toString() => r'customEmojiProvider';
}

/// Who added custom emoji [name]; loads that person if not stored.

@ProviderFor(customEmojiCreator)
final customEmojiCreatorProvider = CustomEmojiCreatorFamily._();

/// Who added custom emoji [name]; loads that person if not stored.

final class CustomEmojiCreatorProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  /// Who added custom emoji [name]; loads that person if not stored.
  CustomEmojiCreatorProvider._({
    required CustomEmojiCreatorFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'customEmojiCreatorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customEmojiCreatorHash();

  @override
  String toString() {
    return r'customEmojiCreatorProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return customEmojiCreator(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomEmojiCreatorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customEmojiCreatorHash() =>
    r'ecc14ef6208686aad4e34a1c81472964d336115b';

/// Who added custom emoji [name]; loads that person if not stored.

final class CustomEmojiCreatorFamily extends $Family
    with $FunctionalFamilyOverride<Stream<String?>, (String, String)> {
  CustomEmojiCreatorFamily._()
    : super(
        retry: null,
        name: r'customEmojiCreatorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Who added custom emoji [name]; loads that person if not stored.

  CustomEmojiCreatorProvider call(String url, String name) =>
      CustomEmojiCreatorProvider._(argument: (url, name), from: this);

  @override
  String toString() => r'customEmojiCreatorProvider';
}

/// Names the server has no custom emoji for, as far as asked.

@ProviderFor(customEmojiMissing)
final customEmojiMissingProvider = CustomEmojiMissingFamily._();

/// Names the server has no custom emoji for, as far as asked.

final class CustomEmojiMissingProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          Stream<Set<String>>
        >
    with $FutureModifier<Set<String>>, $StreamProvider<Set<String>> {
  /// Names the server has no custom emoji for, as far as asked.
  CustomEmojiMissingProvider._({
    required CustomEmojiMissingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'customEmojiMissingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customEmojiMissingHash();

  @override
  String toString() {
    return r'customEmojiMissingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<String>> create(Ref ref) {
    final argument = this.argument as String;
    return customEmojiMissing(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomEmojiMissingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customEmojiMissingHash() =>
    r'36e6ae0b65a2cd64dd70e93f2af36560563c8c6c';

/// Names the server has no custom emoji for, as far as asked.

final class CustomEmojiMissingFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Set<String>>, String> {
  CustomEmojiMissingFamily._()
    : super(
        retry: null,
        name: r'customEmojiMissingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Names the server has no custom emoji for, as far as asked.

  CustomEmojiMissingProvider call(String url) =>
      CustomEmojiMissingProvider._(argument: url, from: this);

  @override
  String toString() => r'customEmojiMissingProvider';
}

/// Where to report custom emoji names the map above doesn't have yet.

@ProviderFor(customEmojiResolver)
final customEmojiResolverProvider = CustomEmojiResolverFamily._();

/// Where to report custom emoji names the map above doesn't have yet.

final class CustomEmojiResolverProvider
    extends
        $FunctionalProvider<
          AsyncValue<CustomEmojiResolver>,
          CustomEmojiResolver,
          FutureOr<CustomEmojiResolver>
        >
    with
        $FutureModifier<CustomEmojiResolver>,
        $FutureProvider<CustomEmojiResolver> {
  /// Where to report custom emoji names the map above doesn't have yet.
  CustomEmojiResolverProvider._({
    required CustomEmojiResolverFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'customEmojiResolverProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customEmojiResolverHash();

  @override
  String toString() {
    return r'customEmojiResolverProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CustomEmojiResolver> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CustomEmojiResolver> create(Ref ref) {
    final argument = this.argument as String;
    return customEmojiResolver(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomEmojiResolverProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customEmojiResolverHash() =>
    r'28d575676f8f24ca4e3c78547096069fe6e400b4';

/// Where to report custom emoji names the map above doesn't have yet.

final class CustomEmojiResolverFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CustomEmojiResolver>, String> {
  CustomEmojiResolverFamily._()
    : super(
        retry: null,
        name: r'customEmojiResolverProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Where to report custom emoji names the map above doesn't have yet.

  CustomEmojiResolverProvider call(String url) =>
      CustomEmojiResolverProvider._(argument: url, from: this);

  @override
  String toString() => r'customEmojiResolverProvider';
}

/// Every custom emoji of the server, stored for the picker.

@ProviderFor(customEmojiCatalog)
final customEmojiCatalogProvider = CustomEmojiCatalogFamily._();

/// Every custom emoji of the server, stored for the picker.

final class CustomEmojiCatalogProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Every custom emoji of the server, stored for the picker.
  CustomEmojiCatalogProvider._({
    required CustomEmojiCatalogFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'customEmojiCatalogProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customEmojiCatalogHash();

  @override
  String toString() {
    return r'customEmojiCatalogProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return customEmojiCatalog(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomEmojiCatalogProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customEmojiCatalogHash() =>
    r'6182b70a0cd832b4468dc8f73f32983da9fbe8ab';

/// Every custom emoji of the server, stored for the picker.

final class CustomEmojiCatalogFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  CustomEmojiCatalogFamily._()
    : super(
        retry: null,
        name: r'customEmojiCatalogProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every custom emoji of the server, stored for the picker.

  CustomEmojiCatalogProvider call(String url) =>
      CustomEmojiCatalogProvider._(argument: url, from: this);

  @override
  String toString() => r'customEmojiCatalogProvider';
}

/// What the user may do with custom emoji; nothing when the server has
/// them off.

@ProviderFor(emojiRightsOn)
final emojiRightsOnProvider = EmojiRightsOnFamily._();

/// What the user may do with custom emoji; nothing when the server has
/// them off.

final class EmojiRightsOnProvider
    extends
        $FunctionalProvider<
          AsyncValue<EmojiRights>,
          EmojiRights,
          Stream<EmojiRights>
        >
    with $FutureModifier<EmojiRights>, $StreamProvider<EmojiRights> {
  /// What the user may do with custom emoji; nothing when the server has
  /// them off.
  EmojiRightsOnProvider._({
    required EmojiRightsOnFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'emojiRightsOnProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$emojiRightsOnHash();

  @override
  String toString() {
    return r'emojiRightsOnProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<EmojiRights> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<EmojiRights> create(Ref ref) {
    final argument = this.argument as String;
    return emojiRightsOn(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EmojiRightsOnProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$emojiRightsOnHash() => r'27fb40e3f0f2053048e13b60a4720190096798e9';

/// What the user may do with custom emoji; nothing when the server has
/// them off.

final class EmojiRightsOnFamily extends $Family
    with $FunctionalFamilyOverride<Stream<EmojiRights>, String> {
  EmojiRightsOnFamily._()
    : super(
        retry: null,
        name: r'emojiRightsOnProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What the user may do with custom emoji; nothing when the server has
  /// them off.

  EmojiRightsOnProvider call(String url) =>
      EmojiRightsOnProvider._(argument: url, from: this);

  @override
  String toString() => r'emojiRightsOnProvider';
}

/// The stored custom emoji by name, with what the user may do to each.

@ProviderFor(emojiEntries)
final emojiEntriesProvider = EmojiEntriesFamily._();

/// The stored custom emoji by name, with what the user may do to each.

final class EmojiEntriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EmojiEntry>>,
          List<EmojiEntry>,
          Stream<List<EmojiEntry>>
        >
    with $FutureModifier<List<EmojiEntry>>, $StreamProvider<List<EmojiEntry>> {
  /// The stored custom emoji by name, with what the user may do to each.
  EmojiEntriesProvider._({
    required EmojiEntriesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'emojiEntriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$emojiEntriesHash();

  @override
  String toString() {
    return r'emojiEntriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<EmojiEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<EmojiEntry>> create(Ref ref) {
    final argument = this.argument as String;
    return emojiEntries(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EmojiEntriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$emojiEntriesHash() => r'163de28c79be90112505368bba9e56662a10bd24';

/// The stored custom emoji by name, with what the user may do to each.

final class EmojiEntriesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<EmojiEntry>>, String> {
  EmojiEntriesFamily._()
    : super(
        retry: null,
        name: r'emojiEntriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The stored custom emoji by name, with what the user may do to each.

  EmojiEntriesProvider call(String url) =>
      EmojiEntriesProvider._(argument: url, from: this);

  @override
  String toString() => r'emojiEntriesProvider';
}

@ProviderFor(emojiActionsOn)
final emojiActionsOnProvider = EmojiActionsOnFamily._();

final class EmojiActionsOnProvider
    extends
        $FunctionalProvider<
          AsyncValue<EmojiActions>,
          EmojiActions,
          FutureOr<EmojiActions>
        >
    with $FutureModifier<EmojiActions>, $FutureProvider<EmojiActions> {
  EmojiActionsOnProvider._({
    required EmojiActionsOnFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'emojiActionsOnProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$emojiActionsOnHash();

  @override
  String toString() {
    return r'emojiActionsOnProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<EmojiActions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EmojiActions> create(Ref ref) {
    final argument = this.argument as String;
    return emojiActionsOn(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EmojiActionsOnProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$emojiActionsOnHash() => r'd99432602529b63add2a7dbabfea3d7ac46f555f';

final class EmojiActionsOnFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<EmojiActions>, String> {
  EmojiActionsOnFamily._()
    : super(
        retry: null,
        name: r'emojiActionsOnProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  EmojiActionsOnProvider call(String url) =>
      EmojiActionsOnProvider._(argument: url, from: this);

  @override
  String toString() => r'emojiActionsOnProvider';
}
