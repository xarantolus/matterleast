// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extras_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bookmarkActions)
final bookmarkActionsProvider = BookmarkActionsFamily._();

final class BookmarkActionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<BookmarkActions>,
          BookmarkActions,
          FutureOr<BookmarkActions>
        >
    with $FutureModifier<BookmarkActions>, $FutureProvider<BookmarkActions> {
  BookmarkActionsProvider._({
    required BookmarkActionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookmarkActionsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookmarkActionsHash();

  @override
  String toString() {
    return r'bookmarkActionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BookmarkActions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BookmarkActions> create(Ref ref) {
    final argument = this.argument as String;
    return bookmarkActions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookmarkActionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookmarkActionsHash() => r'44a3448e3231d8e27d1242e890198d423f75c7e9';

final class BookmarkActionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BookmarkActions>, String> {
  BookmarkActionsFamily._()
    : super(
        retry: null,
        name: r'bookmarkActionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  BookmarkActionsProvider call(String url) =>
      BookmarkActionsProvider._(argument: url, from: this);

  @override
  String toString() => r'bookmarkActionsProvider';
}

@ProviderFor(attributeActions)
final attributeActionsProvider = AttributeActionsFamily._();

final class AttributeActionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AttributeActions>,
          AttributeActions,
          FutureOr<AttributeActions>
        >
    with $FutureModifier<AttributeActions>, $FutureProvider<AttributeActions> {
  AttributeActionsProvider._({
    required AttributeActionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'attributeActionsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$attributeActionsHash();

  @override
  String toString() {
    return r'attributeActionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AttributeActions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AttributeActions> create(Ref ref) {
    final argument = this.argument as String;
    return attributeActions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AttributeActionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$attributeActionsHash() => r'f1f6d70899c1261e8cd9f8772ae00b667edfbcde';

final class AttributeActionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AttributeActions>, String> {
  AttributeActionsFamily._()
    : super(
        retry: null,
        name: r'attributeActionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  AttributeActionsProvider call(String url) =>
      AttributeActionsProvider._(argument: url, from: this);

  @override
  String toString() => r'attributeActionsProvider';
}

@ProviderFor(channelBookmarks)
final channelBookmarksProvider = ChannelBookmarksFamily._();

final class ChannelBookmarksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Bookmark>>,
          List<Bookmark>,
          Stream<List<Bookmark>>
        >
    with $FutureModifier<List<Bookmark>>, $StreamProvider<List<Bookmark>> {
  ChannelBookmarksProvider._({
    required ChannelBookmarksFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'channelBookmarksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$channelBookmarksHash();

  @override
  String toString() {
    return r'channelBookmarksProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<Bookmark>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Bookmark>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return channelBookmarks(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelBookmarksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$channelBookmarksHash() => r'ab325c6c97732674449bc6b6248c924ee868bcae';

final class ChannelBookmarksFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Bookmark>>, (String, String)> {
  ChannelBookmarksFamily._()
    : super(
        retry: null,
        name: r'channelBookmarksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChannelBookmarksProvider call(String url, String channelId) =>
      ChannelBookmarksProvider._(argument: (url, channelId), from: this);

  @override
  String toString() => r'channelBookmarksProvider';
}

@ProviderFor(bookmarkRightsIn)
final bookmarkRightsInProvider = BookmarkRightsInFamily._();

final class BookmarkRightsInProvider
    extends
        $FunctionalProvider<
          AsyncValue<BookmarkRights>,
          BookmarkRights,
          Stream<BookmarkRights>
        >
    with $FutureModifier<BookmarkRights>, $StreamProvider<BookmarkRights> {
  BookmarkRightsInProvider._({
    required BookmarkRightsInFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'bookmarkRightsInProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookmarkRightsInHash();

  @override
  String toString() {
    return r'bookmarkRightsInProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<BookmarkRights> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<BookmarkRights> create(Ref ref) {
    final argument = this.argument as (String, String);
    return bookmarkRightsIn(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is BookmarkRightsInProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookmarkRightsInHash() => r'd4797116364e176f3007e8127cf972a5e2440c01';

final class BookmarkRightsInFamily extends $Family
    with $FunctionalFamilyOverride<Stream<BookmarkRights>, (String, String)> {
  BookmarkRightsInFamily._()
    : super(
        retry: null,
        name: r'bookmarkRightsInProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BookmarkRightsInProvider call(String url, String channelId) =>
      BookmarkRightsInProvider._(argument: (url, channelId), from: this);

  @override
  String toString() => r'bookmarkRightsInProvider';
}

/// Fetched once while a channel's bar is shown, so it catches up with
/// changes made while the app wasn't listening.

@ProviderFor(bookmarksRefresh)
final bookmarksRefreshProvider = BookmarksRefreshFamily._();

/// Fetched once while a channel's bar is shown, so it catches up with
/// changes made while the app wasn't listening.

final class BookmarksRefreshProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Fetched once while a channel's bar is shown, so it catches up with
  /// changes made while the app wasn't listening.
  BookmarksRefreshProvider._({
    required BookmarksRefreshFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: noRetry,
         name: r'bookmarksRefreshProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookmarksRefreshHash();

  @override
  String toString() {
    return r'bookmarksRefreshProvider'
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
    return bookmarksRefresh(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is BookmarksRefreshProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookmarksRefreshHash() => r'1436d0d159eda042cc06c1a4a77e3e7bc2c5342d';

/// Fetched once while a channel's bar is shown, so it catches up with
/// changes made while the app wasn't listening.

final class BookmarksRefreshFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, (String, String)> {
  BookmarksRefreshFamily._()
    : super(
        retry: noRetry,
        name: r'bookmarksRefreshProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetched once while a channel's bar is shown, so it catches up with
  /// changes made while the app wasn't listening.

  BookmarksRefreshProvider call(String url, String channelId) =>
      BookmarksRefreshProvider._(argument: (url, channelId), from: this);

  @override
  String toString() => r'bookmarksRefreshProvider';
}

@ProviderFor(profileAttributes)
final profileAttributesProvider = ProfileAttributesFamily._();

final class ProfileAttributesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ShownAttribute>>,
          List<ShownAttribute>,
          Stream<List<ShownAttribute>>
        >
    with
        $FutureModifier<List<ShownAttribute>>,
        $StreamProvider<List<ShownAttribute>> {
  ProfileAttributesProvider._({
    required ProfileAttributesFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'profileAttributesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileAttributesHash();

  @override
  String toString() {
    return r'profileAttributesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<ShownAttribute>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ShownAttribute>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return profileAttributes(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileAttributesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileAttributesHash() => r'688e74530c2b26174c24119995fc826c03bf7104';

final class ProfileAttributesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<ShownAttribute>>,
          (String, String)
        > {
  ProfileAttributesFamily._()
    : super(
        retry: null,
        name: r'profileAttributesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfileAttributesProvider call(String url, String userId) =>
      ProfileAttributesProvider._(argument: (url, userId), from: this);

  @override
  String toString() => r'profileAttributesProvider';
}

@ProviderFor(editableAttributes)
final editableAttributesProvider = EditableAttributesFamily._();

final class EditableAttributesProvider
    extends
        $FunctionalProvider<
          AsyncValue<(List<AttributeField>, Map<String, List<String>>)>,
          (List<AttributeField>, Map<String, List<String>>),
          Stream<(List<AttributeField>, Map<String, List<String>>)>
        >
    with
        $FutureModifier<(List<AttributeField>, Map<String, List<String>>)>,
        $StreamProvider<(List<AttributeField>, Map<String, List<String>>)> {
  EditableAttributesProvider._({
    required EditableAttributesFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'editableAttributesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editableAttributesHash();

  @override
  String toString() {
    return r'editableAttributesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<(List<AttributeField>, Map<String, List<String>>)>
  $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<(List<AttributeField>, Map<String, List<String>>)> create(Ref ref) {
    final argument = this.argument as (String, String);
    return editableAttributes(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is EditableAttributesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editableAttributesHash() =>
    r'f9370500b4dff74fac0b926408c88e780161bef8';

final class EditableAttributesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<(List<AttributeField>, Map<String, List<String>>)>,
          (String, String)
        > {
  EditableAttributesFamily._()
    : super(
        retry: null,
        name: r'editableAttributesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EditableAttributesProvider call(String url, String userId) =>
      EditableAttributesProvider._(argument: (url, userId), from: this);

  @override
  String toString() => r'editableAttributesProvider';
}

/// Fetched when a profile opens.

@ProviderFor(attributesRefresh)
final attributesRefreshProvider = AttributesRefreshFamily._();

/// Fetched when a profile opens.

final class AttributesRefreshProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Fetched when a profile opens.
  AttributesRefreshProvider._({
    required AttributesRefreshFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: noRetry,
         name: r'attributesRefreshProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$attributesRefreshHash();

  @override
  String toString() {
    return r'attributesRefreshProvider'
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
    return attributesRefresh(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is AttributesRefreshProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$attributesRefreshHash() => r'dd2af6b1c78523274521673ae4c7695a3cac8d10';

/// Fetched when a profile opens.

final class AttributesRefreshFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, (String, String)> {
  AttributesRefreshFamily._()
    : super(
        retry: noRetry,
        name: r'attributesRefreshProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetched when a profile opens.

  AttributesRefreshProvider call(String url, String userId) =>
      AttributesRefreshProvider._(argument: (url, userId), from: this);

  @override
  String toString() => r'attributesRefreshProvider';
}
