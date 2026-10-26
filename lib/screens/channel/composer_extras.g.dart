// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composer_extras.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the next message in a channel burns after it is read; off again
/// once it went out.

@ProviderFor(BurnOnReadChoice)
final burnOnReadChoiceProvider = BurnOnReadChoiceFamily._();

/// Whether the next message in a channel burns after it is read; off again
/// once it went out.
final class BurnOnReadChoiceProvider
    extends $NotifierProvider<BurnOnReadChoice, bool> {
  /// Whether the next message in a channel burns after it is read; off again
  /// once it went out.
  BurnOnReadChoiceProvider._({
    required BurnOnReadChoiceFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'burnOnReadChoiceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$burnOnReadChoiceHash();

  @override
  String toString() {
    return r'burnOnReadChoiceProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  BurnOnReadChoice create() => BurnOnReadChoice();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BurnOnReadChoiceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$burnOnReadChoiceHash() => r'd9f8aac5192ccd3c488702896742903af14f7899';

/// Whether the next message in a channel burns after it is read; off again
/// once it went out.

final class BurnOnReadChoiceFamily extends $Family
    with
        $ClassFamilyOverride<
          BurnOnReadChoice,
          bool,
          bool,
          bool,
          (String, String)
        > {
  BurnOnReadChoiceFamily._()
    : super(
        retry: null,
        name: r'burnOnReadChoiceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the next message in a channel burns after it is read; off again
  /// once it went out.

  BurnOnReadChoiceProvider call(String url, String channelId) =>
      BurnOnReadChoiceProvider._(argument: (url, channelId), from: this);

  @override
  String toString() => r'burnOnReadChoiceProvider';
}

/// Whether the next message in a channel burns after it is read; off again
/// once it went out.

abstract class _$BurnOnReadChoice extends $Notifier<bool> {
  late final _$args = ref.$arg as (String, String);
  String get url => _$args.$1;
  String get channelId => _$args.$2;

  bool build(String url, String channelId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
