// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'magic_link_sign_in.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(magicLinkSignIn)
final magicLinkSignInProvider = MagicLinkSignInProvider._();

final class MagicLinkSignInProvider
    extends
        $FunctionalProvider<MagicLinkSignIn, MagicLinkSignIn, MagicLinkSignIn>
    with $Provider<MagicLinkSignIn> {
  MagicLinkSignInProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'magicLinkSignInProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$magicLinkSignInHash();

  @$internal
  @override
  $ProviderElement<MagicLinkSignIn> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MagicLinkSignIn create(Ref ref) {
    return magicLinkSignIn(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MagicLinkSignIn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MagicLinkSignIn>(value),
    );
  }
}

String _$magicLinkSignInHash() => r'5eba4bc8427079466decaff2d4c526ca8f00b09e';
