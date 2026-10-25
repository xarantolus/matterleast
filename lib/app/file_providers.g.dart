// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fileDownloads)
final fileDownloadsProvider = FileDownloadsFamily._();

final class FileDownloadsProvider
    extends
        $FunctionalProvider<
          AsyncValue<FileDownloads>,
          FileDownloads,
          FutureOr<FileDownloads>
        >
    with $FutureModifier<FileDownloads>, $FutureProvider<FileDownloads> {
  FileDownloadsProvider._({
    required FileDownloadsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'fileDownloadsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fileDownloadsHash();

  @override
  String toString() {
    return r'fileDownloadsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FileDownloads> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FileDownloads> create(Ref ref) {
    final argument = this.argument as String;
    return fileDownloads(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FileDownloadsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fileDownloadsHash() => r'41cd3fea6bae11d07ede21f970f74f7e316045d3';

final class FileDownloadsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FileDownloads>, String> {
  FileDownloadsFamily._()
    : super(
        retry: null,
        name: r'fileDownloadsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  FileDownloadsProvider call(String url) =>
      FileDownloadsProvider._(argument: url, from: this);

  @override
  String toString() => r'fileDownloadsProvider';
}

/// The message files of one server being downloaded: file id → the share
/// received, null while the size is unknown. Kept while the app runs, so a
/// download finishes even when the screen that started it closes.

@ProviderFor(FileTransfers)
final fileTransfersProvider = FileTransfersFamily._();

/// The message files of one server being downloaded: file id → the share
/// received, null while the size is unknown. Kept while the app runs, so a
/// download finishes even when the screen that started it closes.
final class FileTransfersProvider
    extends $NotifierProvider<FileTransfers, Map<String, double?>> {
  /// The message files of one server being downloaded: file id → the share
  /// received, null while the size is unknown. Kept while the app runs, so a
  /// download finishes even when the screen that started it closes.
  FileTransfersProvider._({
    required FileTransfersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'fileTransfersProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fileTransfersHash();

  @override
  String toString() {
    return r'fileTransfersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FileTransfers create() => FileTransfers();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, double?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, double?>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FileTransfersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fileTransfersHash() => r'cafa1026872a26a0561ab06e38dbe00fbf9d5322';

/// The message files of one server being downloaded: file id → the share
/// received, null while the size is unknown. Kept while the app runs, so a
/// download finishes even when the screen that started it closes.

final class FileTransfersFamily extends $Family
    with
        $ClassFamilyOverride<
          FileTransfers,
          Map<String, double?>,
          Map<String, double?>,
          Map<String, double?>,
          String
        > {
  FileTransfersFamily._()
    : super(
        retry: null,
        name: r'fileTransfersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// The message files of one server being downloaded: file id → the share
  /// received, null while the size is unknown. Kept while the app runs, so a
  /// download finishes even when the screen that started it closes.

  FileTransfersProvider call(String url) =>
      FileTransfersProvider._(argument: url, from: this);

  @override
  String toString() => r'fileTransfersProvider';
}

/// The message files of one server being downloaded: file id → the share
/// received, null while the size is unknown. Kept while the app runs, so a
/// download finishes even when the screen that started it closes.

abstract class _$FileTransfers extends $Notifier<Map<String, double?>> {
  late final _$args = ref.$arg as String;
  String get url => _$args;

  Map<String, double?> build(String url);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Map<String, double?>, Map<String, double?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, double?>, Map<String, double?>>,
              Map<String, double?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
