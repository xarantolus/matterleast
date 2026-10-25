// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'links.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LinkTarget {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkTarget);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LinkTarget()';
}


}

/// @nodoc
class $LinkTargetCopyWith<$Res>  {
$LinkTargetCopyWith(LinkTarget _, $Res Function(LinkTarget) __);
}


/// Adds pattern-matching-related methods to [LinkTarget].
extension LinkTargetPatterns on LinkTarget {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( UriLink value)?  uri,TResult Function( NoLink value)?  none,required TResult orElse(),}){
final _that = this;
switch (_that) {
case UriLink() when uri != null:
return uri(_that);case NoLink() when none != null:
return none(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( UriLink value)  uri,required TResult Function( NoLink value)  none,}){
final _that = this;
switch (_that) {
case UriLink():
return uri(_that);case NoLink():
return none(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( UriLink value)?  uri,TResult? Function( NoLink value)?  none,}){
final _that = this;
switch (_that) {
case UriLink() when uri != null:
return uri(_that);case NoLink() when none != null:
return none(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Uri uri)?  uri,TResult Function()?  none,required TResult orElse(),}) {final _that = this;
switch (_that) {
case UriLink() when uri != null:
return uri(_that.uri);case NoLink() when none != null:
return none();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Uri uri)  uri,required TResult Function()  none,}) {final _that = this;
switch (_that) {
case UriLink():
return uri(_that.uri);case NoLink():
return none();}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Uri uri)?  uri,TResult? Function()?  none,}) {final _that = this;
switch (_that) {
case UriLink() when uri != null:
return uri(_that.uri);case NoLink() when none != null:
return none();case _:
  return null;

}
}

}

/// @nodoc


class UriLink implements LinkTarget {
  const UriLink(this.uri);
  

 final  Uri uri;

/// Create a copy of LinkTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UriLinkCopyWith<UriLink> get copyWith => _$UriLinkCopyWithImpl<UriLink>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UriLink&&(identical(other.uri, uri) || other.uri == uri));
}


@override
int get hashCode {
    return Object.hash(runtimeType,uri);
}

@override
String toString() {
    return 'LinkTarget.uri(uri: $uri)';
}


}

/// @nodoc
abstract mixin class $UriLinkCopyWith<$Res> implements $LinkTargetCopyWith<$Res> {
  factory $UriLinkCopyWith(UriLink value, $Res Function(UriLink) _then) = _$UriLinkCopyWithImpl;
@useResult
$Res call({
 Uri uri
});




}
/// @nodoc
class _$UriLinkCopyWithImpl<$Res>
    implements $UriLinkCopyWith<$Res> {
  _$UriLinkCopyWithImpl(this._self, this._then);

  final UriLink _self;
  final $Res Function(UriLink) _then;

/// Create a copy of LinkTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? uri = null,}) {
  return _then(UriLink(
null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as Uri,
  ));
}


}

/// @nodoc


class NoLink implements LinkTarget {
  const NoLink();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NoLink);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LinkTarget.none()';
}


}




// dart format on
