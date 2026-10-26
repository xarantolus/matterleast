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
