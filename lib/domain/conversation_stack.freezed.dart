// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_stack.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StackStep {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is StackStep);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'StackStep()';
}


}

/// @nodoc
class $StackStepCopyWith<$Res>  {
$StackStepCopyWith(StackStep _, $Res Function(StackStep) __);
}


/// Adds pattern-matching-related methods to [StackStep].
extension StackStepPatterns on StackStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PushStep value)?  push,TResult Function( ReturnToStep value)?  returnTo,TResult Function( PushOverStep value)?  pushOver,TResult Function( ReplaceStep value)?  replace,TResult Function( OverListStep value)?  overList,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PushStep() when push != null:
return push(_that);case ReturnToStep() when returnTo != null:
return returnTo(_that);case PushOverStep() when pushOver != null:
return pushOver(_that);case ReplaceStep() when replace != null:
return replace(_that);case OverListStep() when overList != null:
return overList(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PushStep value)  push,required TResult Function( ReturnToStep value)  returnTo,required TResult Function( PushOverStep value)  pushOver,required TResult Function( ReplaceStep value)  replace,required TResult Function( OverListStep value)  overList,}){
final _that = this;
switch (_that) {
case PushStep():
return push(_that);case ReturnToStep():
return returnTo(_that);case PushOverStep():
return pushOver(_that);case ReplaceStep():
return replace(_that);case OverListStep():
return overList(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PushStep value)?  push,TResult? Function( ReturnToStep value)?  returnTo,TResult? Function( PushOverStep value)?  pushOver,TResult? Function( ReplaceStep value)?  replace,TResult? Function( OverListStep value)?  overList,}){
final _that = this;
switch (_that) {
case PushStep() when push != null:
return push(_that);case ReturnToStep() when returnTo != null:
return returnTo(_that);case PushOverStep() when pushOver != null:
return pushOver(_that);case ReplaceStep() when replace != null:
return replace(_that);case OverListStep() when overList != null:
return overList(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  push,TResult Function( int index)?  returnTo,TResult Function( int index)?  pushOver,TResult Function( int index)?  replace,TResult Function()?  overList,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PushStep() when push != null:
return push();case ReturnToStep() when returnTo != null:
return returnTo(_that.index);case PushOverStep() when pushOver != null:
return pushOver(_that.index);case ReplaceStep() when replace != null:
return replace(_that.index);case OverListStep() when overList != null:
return overList();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  push,required TResult Function( int index)  returnTo,required TResult Function( int index)  pushOver,required TResult Function( int index)  replace,required TResult Function()  overList,}) {final _that = this;
switch (_that) {
case PushStep():
return push();case ReturnToStep():
return returnTo(_that.index);case PushOverStep():
return pushOver(_that.index);case ReplaceStep():
return replace(_that.index);case OverListStep():
return overList();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  push,TResult? Function( int index)?  returnTo,TResult? Function( int index)?  pushOver,TResult? Function( int index)?  replace,TResult? Function()?  overList,}) {final _that = this;
switch (_that) {
case PushStep() when push != null:
return push();case ReturnToStep() when returnTo != null:
return returnTo(_that.index);case PushOverStep() when pushOver != null:
return pushOver(_that.index);case ReplaceStep() when replace != null:
return replace(_that.index);case OverListStep() when overList != null:
return overList();case _:
  return null;

}
}

}

/// @nodoc


class PushStep implements StackStep {
  const PushStep();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PushStep);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'StackStep.push()';
}


}




/// @nodoc


class ReturnToStep implements StackStep {
  const ReturnToStep(this.index);
  

 final  int index;

/// Create a copy of StackStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReturnToStepCopyWith<ReturnToStep> get copyWith => _$ReturnToStepCopyWithImpl<ReturnToStep>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReturnToStep&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode {
    return Object.hash(runtimeType,index);
}

@override
String toString() {
    return 'StackStep.returnTo(index: $index)';
}


}

/// @nodoc
abstract mixin class $ReturnToStepCopyWith<$Res> implements $StackStepCopyWith<$Res> {
  factory $ReturnToStepCopyWith(ReturnToStep value, $Res Function(ReturnToStep) _then) = _$ReturnToStepCopyWithImpl;
@useResult
$Res call({
 int index
});




}
/// @nodoc
class _$ReturnToStepCopyWithImpl<$Res>
    implements $ReturnToStepCopyWith<$Res> {
  _$ReturnToStepCopyWithImpl(this._self, this._then);

  final ReturnToStep _self;
  final $Res Function(ReturnToStep) _then;

/// Create a copy of StackStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? index = null,}) {
  return _then(ReturnToStep(
null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class PushOverStep implements StackStep {
  const PushOverStep(this.index);
  

 final  int index;

/// Create a copy of StackStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PushOverStepCopyWith<PushOverStep> get copyWith => _$PushOverStepCopyWithImpl<PushOverStep>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PushOverStep&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode {
    return Object.hash(runtimeType,index);
}

@override
String toString() {
    return 'StackStep.pushOver(index: $index)';
}


}

/// @nodoc
abstract mixin class $PushOverStepCopyWith<$Res> implements $StackStepCopyWith<$Res> {
  factory $PushOverStepCopyWith(PushOverStep value, $Res Function(PushOverStep) _then) = _$PushOverStepCopyWithImpl;
@useResult
$Res call({
 int index
});




}
/// @nodoc
class _$PushOverStepCopyWithImpl<$Res>
    implements $PushOverStepCopyWith<$Res> {
  _$PushOverStepCopyWithImpl(this._self, this._then);

  final PushOverStep _self;
  final $Res Function(PushOverStep) _then;

/// Create a copy of StackStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? index = null,}) {
  return _then(PushOverStep(
null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ReplaceStep implements StackStep {
  const ReplaceStep(this.index);
  

 final  int index;

/// Create a copy of StackStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplaceStepCopyWith<ReplaceStep> get copyWith => _$ReplaceStepCopyWithImpl<ReplaceStep>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplaceStep&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode {
    return Object.hash(runtimeType,index);
}

@override
String toString() {
    return 'StackStep.replace(index: $index)';
}


}

/// @nodoc
abstract mixin class $ReplaceStepCopyWith<$Res> implements $StackStepCopyWith<$Res> {
  factory $ReplaceStepCopyWith(ReplaceStep value, $Res Function(ReplaceStep) _then) = _$ReplaceStepCopyWithImpl;
@useResult
$Res call({
 int index
});




}
/// @nodoc
class _$ReplaceStepCopyWithImpl<$Res>
    implements $ReplaceStepCopyWith<$Res> {
  _$ReplaceStepCopyWithImpl(this._self, this._then);

  final ReplaceStep _self;
  final $Res Function(ReplaceStep) _then;

/// Create a copy of StackStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? index = null,}) {
  return _then(ReplaceStep(
null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class OverListStep implements StackStep {
  const OverListStep();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OverListStep);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'StackStep.overList()';
}


}




// dart format on
