// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sso_resume.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ssoResume)
final ssoResumeProvider = SsoResumeProvider._();

final class SsoResumeProvider
    extends $FunctionalProvider<SsoResume, SsoResume, SsoResume>
    with $Provider<SsoResume> {
  SsoResumeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ssoResumeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ssoResumeHash();

  @$internal
  @override
  $ProviderElement<SsoResume> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SsoResume create(Ref ref) {
    return ssoResume(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SsoResume value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SsoResume>(value),
    );
  }
}

String _$ssoResumeHash() => r'6fc2d2086cea373f8b4d6bfeb38399dac0a653a8';
