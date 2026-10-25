// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji_picker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Emoji the user picked or wrote lately, newest first.

@ProviderFor(recentEmoji)
final recentEmojiProvider = RecentEmojiFamily._();

/// Emoji the user picked or wrote lately, newest first.

final class RecentEmojiProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Emoji the user picked or wrote lately, newest first.
  RecentEmojiProvider._({
    required RecentEmojiFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recentEmojiProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recentEmojiHash();

  @override
  String toString() {
    return r'recentEmojiProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as String;
    return recentEmoji(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentEmojiProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentEmojiHash() => r'2ec8944e6e826727c0f987d5e8dcaad8543fe86a';

/// Emoji the user picked or wrote lately, newest first.

final class RecentEmojiFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<String>>, String> {
  RecentEmojiFamily._()
    : super(
        retry: null,
        name: r'recentEmojiProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Emoji the user picked or wrote lately, newest first.

  RecentEmojiProvider call(String url) =>
      RecentEmojiProvider._(argument: url, from: this);

  @override
  String toString() => r'recentEmojiProvider';
}

/// The skin tone the picker applies, 0 for none, as the user's preference
/// on [url] has it.

@ProviderFor(skinTone)
final skinToneProvider = SkinToneFamily._();

/// The skin tone the picker applies, 0 for none, as the user's preference
/// on [url] has it.

final class SkinToneProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// The skin tone the picker applies, 0 for none, as the user's preference
  /// on [url] has it.
  SkinToneProvider._({
    required SkinToneFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'skinToneProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$skinToneHash();

  @override
  String toString() {
    return r'skinToneProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as String;
    return skinTone(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SkinToneProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$skinToneHash() => r'1983f1c17756938cde2cbf08ccfa9c3f50290aa3';

/// The skin tone the picker applies, 0 for none, as the user's preference
/// on [url] has it.

final class SkinToneFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, String> {
  SkinToneFamily._()
    : super(
        retry: null,
        name: r'skinToneProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The skin tone the picker applies, 0 for none, as the user's preference
  /// on [url] has it.

  SkinToneProvider call(String url) =>
      SkinToneProvider._(argument: url, from: this);

  @override
  String toString() => r'skinToneProvider';
}
