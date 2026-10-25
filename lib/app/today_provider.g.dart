// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The local day, for "Today" and "Yesterday" labels. It changes at local
/// midnight and is checked again when the app comes back, so labels follow
/// the date without rebuilding more than once a day.

@ProviderFor(Today)
final todayProvider = TodayProvider._();

/// The local day, for "Today" and "Yesterday" labels. It changes at local
/// midnight and is checked again when the app comes back, so labels follow
/// the date without rebuilding more than once a day.
final class TodayProvider extends $NotifierProvider<Today, DateTime> {
  /// The local day, for "Today" and "Yesterday" labels. It changes at local
  /// midnight and is checked again when the app comes back, so labels follow
  /// the date without rebuilding more than once a day.
  TodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayHash();

  @$internal
  @override
  Today create() => Today();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$todayHash() => r'ff3956c64498410bfa65d3ae13755c80dde332d6';

/// The local day, for "Today" and "Yesterday" labels. It changes at local
/// midnight and is checked again when the app comes back, so labels follow
/// the date without rebuilding more than once a day.

abstract class _$Today extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
