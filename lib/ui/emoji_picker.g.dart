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

/// The skin tone the picker applies, 0 for none; kept while the app runs.

@ProviderFor(SkinTone)
final skinToneProvider = SkinToneProvider._();

/// The skin tone the picker applies, 0 for none; kept while the app runs.
final class SkinToneProvider extends $NotifierProvider<SkinTone, int> {
  /// The skin tone the picker applies, 0 for none; kept while the app runs.
  SkinToneProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'skinToneProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$skinToneHash();

  @$internal
  @override
  SkinTone create() => SkinTone();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$skinToneHash() => r'f7c001962f6c4d7cf870355911dcd4ffa9f0d8e8';

/// The skin tone the picker applies, 0 for none; kept while the app runs.

abstract class _$SkinTone extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
