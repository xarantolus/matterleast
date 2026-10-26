// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'channel_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChannelItem {

 String get id; String get title; ChannelKind get kind; bool get unread; int get mentions; bool get muted; bool get favorite; bool get hasDraft;/// Presence of the other person in a direct message.
 String? get status;/// Other members of a group message.
 int? get others;/// The other person of a direct message and their picture's version.
 String? get userId; int? get pictureUpdate;
/// Create a copy of ChannelItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelItemCopyWith<ChannelItem> get copyWith => _$ChannelItemCopyWithImpl<ChannelItem>(this as ChannelItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChannelItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.unread, _this.unread) || other.unread == _this.unread)&&(identical(other.mentions, _this.mentions) || other.mentions == _this.mentions)&&(identical(other.muted, _this.muted) || other.muted == _this.muted)&&(identical(other.favorite, _this.favorite) || other.favorite == _this.favorite)&&(identical(other.hasDraft, _this.hasDraft) || other.hasDraft == _this.hasDraft)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.others, _this.others) || other.others == _this.others)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.pictureUpdate, _this.pictureUpdate) || other.pictureUpdate == _this.pictureUpdate));
}


@override
int get hashCode {
  final _this = this as ChannelItem;
  return Object.hash(runtimeType,_this.id,_this.title,_this.kind,_this.unread,_this.mentions,_this.muted,_this.favorite,_this.hasDraft,_this.status,_this.others,_this.userId,_this.pictureUpdate);
}

@override
String toString() {
  final _this = this as ChannelItem;
  return 'ChannelItem(id: ${_this.id}, title: ${_this.title}, kind: ${_this.kind}, unread: ${_this.unread}, mentions: ${_this.mentions}, muted: ${_this.muted}, favorite: ${_this.favorite}, hasDraft: ${_this.hasDraft}, status: ${_this.status}, others: ${_this.others}, userId: ${_this.userId}, pictureUpdate: ${_this.pictureUpdate})';
}


}

/// @nodoc
abstract mixin class $ChannelItemCopyWith<$Res>  {
  factory $ChannelItemCopyWith(ChannelItem value, $Res Function(ChannelItem) _then) = _$ChannelItemCopyWithImpl;
@useResult
$Res call({
 String id, String title, ChannelKind kind, bool unread, int mentions, bool muted, bool favorite, bool hasDraft, String? status, int? others, String? userId, int? pictureUpdate
});




}
/// @nodoc
class _$ChannelItemCopyWithImpl<$Res>
    implements $ChannelItemCopyWith<$Res> {
  _$ChannelItemCopyWithImpl(this._self, this._then);

  final ChannelItem _self;
  final $Res Function(ChannelItem) _then;

/// Create a copy of ChannelItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? kind = null,Object? unread = null,Object? mentions = null,Object? muted = null,Object? favorite = null,Object? hasDraft = null,Object? status = freezed,Object? others = freezed,Object? userId = freezed,Object? pictureUpdate = freezed,}) {
  return _then(ChannelItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ChannelKind,unread: null == unread ? _self.unread : unread // ignore: cast_nullable_to_non_nullable
as bool,mentions: null == mentions ? _self.mentions : mentions // ignore: cast_nullable_to_non_nullable
as int,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,favorite: null == favorite ? _self.favorite : favorite // ignore: cast_nullable_to_non_nullable
as bool,hasDraft: null == hasDraft ? _self.hasDraft : hasDraft // ignore: cast_nullable_to_non_nullable
as bool,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,others: freezed == others ? _self.others : others // ignore: cast_nullable_to_non_nullable
as int?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,pictureUpdate: freezed == pictureUpdate ? _self.pictureUpdate : pictureUpdate // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChannelItem].
extension ChannelItemPatterns on ChannelItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChannelItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChannelItem() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChannelItem value)  $default,){
final _that = this;
switch (_that) {
case _ChannelItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChannelItem value)?  $default,){
final _that = this;
switch (_that) {
case _ChannelItem() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  ChannelKind kind,  bool unread,  int mentions,  bool muted,  bool favorite,  bool hasDraft,  String? status,  int? others,  String? userId,  int? pictureUpdate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChannelItem() when $default != null:
return $default(_that.id,_that.title,_that.kind,_that.unread,_that.mentions,_that.muted,_that.favorite,_that.hasDraft,_that.status,_that.others,_that.userId,_that.pictureUpdate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  ChannelKind kind,  bool unread,  int mentions,  bool muted,  bool favorite,  bool hasDraft,  String? status,  int? others,  String? userId,  int? pictureUpdate)  $default,) {final _that = this;
switch (_that) {
case _ChannelItem():
return $default(_that.id,_that.title,_that.kind,_that.unread,_that.mentions,_that.muted,_that.favorite,_that.hasDraft,_that.status,_that.others,_that.userId,_that.pictureUpdate);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  ChannelKind kind,  bool unread,  int mentions,  bool muted,  bool favorite,  bool hasDraft,  String? status,  int? others,  String? userId,  int? pictureUpdate)?  $default,) {final _that = this;
switch (_that) {
case _ChannelItem() when $default != null:
return $default(_that.id,_that.title,_that.kind,_that.unread,_that.mentions,_that.muted,_that.favorite,_that.hasDraft,_that.status,_that.others,_that.userId,_that.pictureUpdate);case _:
  return null;

}
}

}

/// @nodoc


class _ChannelItem implements ChannelItem {
  const _ChannelItem({required this.id, required this.title, required this.kind, required this.unread, required this.mentions, required this.muted, required this.favorite, required this.hasDraft, this.status, this.others, this.userId, this.pictureUpdate});
  

@override final  String id;
@override final  String title;
@override final  ChannelKind kind;
@override final  bool unread;
@override final  int mentions;
@override final  bool muted;
@override final  bool favorite;
@override final  bool hasDraft;
/// Presence of the other person in a direct message.
@override final  String? status;
/// Other members of a group message.
@override final  int? others;
/// The other person of a direct message and their picture's version.
@override final  String? userId;
@override final  int? pictureUpdate;

/// Create a copy of ChannelItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChannelItemCopyWith<_ChannelItem> get copyWith => __$ChannelItemCopyWithImpl<_ChannelItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChannelItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.unread, unread) || other.unread == unread)&&(identical(other.mentions, mentions) || other.mentions == mentions)&&(identical(other.muted, muted) || other.muted == muted)&&(identical(other.favorite, favorite) || other.favorite == favorite)&&(identical(other.hasDraft, hasDraft) || other.hasDraft == hasDraft)&&(identical(other.status, status) || other.status == status)&&(identical(other.others, others) || other.others == others)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.pictureUpdate, pictureUpdate) || other.pictureUpdate == pictureUpdate));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,title,kind,unread,mentions,muted,favorite,hasDraft,status,others,userId,pictureUpdate);
}

@override
String toString() {
    return 'ChannelItem(id: $id, title: $title, kind: $kind, unread: $unread, mentions: $mentions, muted: $muted, favorite: $favorite, hasDraft: $hasDraft, status: $status, others: $others, userId: $userId, pictureUpdate: $pictureUpdate)';
}


}

/// @nodoc
abstract mixin class _$ChannelItemCopyWith<$Res> implements $ChannelItemCopyWith<$Res> {
  factory _$ChannelItemCopyWith(_ChannelItem value, $Res Function(_ChannelItem) _then) = __$ChannelItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, ChannelKind kind, bool unread, int mentions, bool muted, bool favorite, bool hasDraft, String? status, int? others, String? userId, int? pictureUpdate
});




}
/// @nodoc
class __$ChannelItemCopyWithImpl<$Res>
    implements _$ChannelItemCopyWith<$Res> {
  __$ChannelItemCopyWithImpl(this._self, this._then);

  final _ChannelItem _self;
  final $Res Function(_ChannelItem) _then;

/// Create a copy of ChannelItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? kind = null,Object? unread = null,Object? mentions = null,Object? muted = null,Object? favorite = null,Object? hasDraft = null,Object? status = freezed,Object? others = freezed,Object? userId = freezed,Object? pictureUpdate = freezed,}) {
  return _then(_ChannelItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ChannelKind,unread: null == unread ? _self.unread : unread // ignore: cast_nullable_to_non_nullable
as bool,mentions: null == mentions ? _self.mentions : mentions // ignore: cast_nullable_to_non_nullable
as int,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,favorite: null == favorite ? _self.favorite : favorite // ignore: cast_nullable_to_non_nullable
as bool,hasDraft: null == hasDraft ? _self.hasDraft : hasDraft // ignore: cast_nullable_to_non_nullable
as bool,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,others: freezed == others ? _self.others : others // ignore: cast_nullable_to_non_nullable
as int?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,pictureUpdate: freezed == pictureUpdate ? _self.pictureUpdate : pictureUpdate // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$CategorySection {

 String get id; String get title; CategoryKind get kind; bool get collapsed;/// Every visible channel, also while [collapsed].
 List<ChannelItem> get rows;
/// Create a copy of CategorySection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategorySectionCopyWith<CategorySection> get copyWith => _$CategorySectionCopyWithImpl<CategorySection>(this as CategorySection, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CategorySection;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategorySection&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.collapsed, _this.collapsed) || other.collapsed == _this.collapsed)&&const DeepCollectionEquality().equals(other.rows, _this.rows));
}


@override
int get hashCode {
  final _this = this as CategorySection;
  return Object.hash(runtimeType,_this.id,_this.title,_this.kind,_this.collapsed,const DeepCollectionEquality().hash(_this.rows));
}

@override
String toString() {
  final _this = this as CategorySection;
  return 'CategorySection(id: ${_this.id}, title: ${_this.title}, kind: ${_this.kind}, collapsed: ${_this.collapsed}, rows: ${_this.rows})';
}


}

/// @nodoc
abstract mixin class $CategorySectionCopyWith<$Res>  {
  factory $CategorySectionCopyWith(CategorySection value, $Res Function(CategorySection) _then) = _$CategorySectionCopyWithImpl;
@useResult
$Res call({
 String id, String title, CategoryKind kind, bool collapsed, List<ChannelItem> rows
});




}
/// @nodoc
class _$CategorySectionCopyWithImpl<$Res>
    implements $CategorySectionCopyWith<$Res> {
  _$CategorySectionCopyWithImpl(this._self, this._then);

  final CategorySection _self;
  final $Res Function(CategorySection) _then;

/// Create a copy of CategorySection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? kind = null,Object? collapsed = null,Object? rows = null,}) {
  return _then(CategorySection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CategoryKind,collapsed: null == collapsed ? _self.collapsed : collapsed // ignore: cast_nullable_to_non_nullable
as bool,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<ChannelItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [CategorySection].
extension CategorySectionPatterns on CategorySection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategorySection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategorySection() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategorySection value)  $default,){
final _that = this;
switch (_that) {
case _CategorySection():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategorySection value)?  $default,){
final _that = this;
switch (_that) {
case _CategorySection() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  CategoryKind kind,  bool collapsed,  List<ChannelItem> rows)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategorySection() when $default != null:
return $default(_that.id,_that.title,_that.kind,_that.collapsed,_that.rows);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  CategoryKind kind,  bool collapsed,  List<ChannelItem> rows)  $default,) {final _that = this;
switch (_that) {
case _CategorySection():
return $default(_that.id,_that.title,_that.kind,_that.collapsed,_that.rows);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  CategoryKind kind,  bool collapsed,  List<ChannelItem> rows)?  $default,) {final _that = this;
switch (_that) {
case _CategorySection() when $default != null:
return $default(_that.id,_that.title,_that.kind,_that.collapsed,_that.rows);case _:
  return null;

}
}

}

/// @nodoc


class _CategorySection extends CategorySection {
  const _CategorySection({required this.id, required this.title, required this.kind, required this.collapsed, required  List<ChannelItem> rows}): _rows = rows,super._();
  

@override final  String id;
@override final  String title;
@override final  CategoryKind kind;
@override final  bool collapsed;
/// Every visible channel, also while [collapsed].
 final  List<ChannelItem> _rows;
/// Every visible channel, also while [collapsed].
@override List<ChannelItem> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}


/// Create a copy of CategorySection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategorySectionCopyWith<_CategorySection> get copyWith => __$CategorySectionCopyWithImpl<_CategorySection>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategorySection&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.collapsed, collapsed) || other.collapsed == collapsed)&&const DeepCollectionEquality().equals(other.rows, _rows));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,title,kind,collapsed,const DeepCollectionEquality().hash(_rows));
}

@override
String toString() {
    return 'CategorySection(id: $id, title: $title, kind: $kind, collapsed: $collapsed, rows: $rows)';
}


}

/// @nodoc
abstract mixin class _$CategorySectionCopyWith<$Res> implements $CategorySectionCopyWith<$Res> {
  factory _$CategorySectionCopyWith(_CategorySection value, $Res Function(_CategorySection) _then) = __$CategorySectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, CategoryKind kind, bool collapsed, List<ChannelItem> rows
});




}
/// @nodoc
class __$CategorySectionCopyWithImpl<$Res>
    implements _$CategorySectionCopyWith<$Res> {
  __$CategorySectionCopyWithImpl(this._self, this._then);

  final _CategorySection _self;
  final $Res Function(_CategorySection) _then;

/// Create a copy of CategorySection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? kind = null,Object? collapsed = null,Object? rows = null,}) {
  return _then(_CategorySection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CategoryKind,collapsed: null == collapsed ? _self.collapsed : collapsed // ignore: cast_nullable_to_non_nullable
as bool,rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<ChannelItem>,
  ));
}


}

/// @nodoc
mixin _$ChannelList {

 String get teamName; List<CategorySection> get sections;/// Followed threads with unread replies; null when threads are not
/// collapsed, so there is no Threads row.
 int? get unreadThreads; int get drafts;/// The team's channels were fetched at least once.
 bool get synced;
/// Create a copy of ChannelList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelListCopyWith<ChannelList> get copyWith => _$ChannelListCopyWithImpl<ChannelList>(this as ChannelList, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChannelList;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelList&&(identical(other.teamName, _this.teamName) || other.teamName == _this.teamName)&&const DeepCollectionEquality().equals(other.sections, _this.sections)&&(identical(other.unreadThreads, _this.unreadThreads) || other.unreadThreads == _this.unreadThreads)&&(identical(other.drafts, _this.drafts) || other.drafts == _this.drafts)&&(identical(other.synced, _this.synced) || other.synced == _this.synced));
}


@override
int get hashCode {
  final _this = this as ChannelList;
  return Object.hash(runtimeType,_this.teamName,const DeepCollectionEquality().hash(_this.sections),_this.unreadThreads,_this.drafts,_this.synced);
}

@override
String toString() {
  final _this = this as ChannelList;
  return 'ChannelList(teamName: ${_this.teamName}, sections: ${_this.sections}, unreadThreads: ${_this.unreadThreads}, drafts: ${_this.drafts}, synced: ${_this.synced})';
}


}

/// @nodoc
abstract mixin class $ChannelListCopyWith<$Res>  {
  factory $ChannelListCopyWith(ChannelList value, $Res Function(ChannelList) _then) = _$ChannelListCopyWithImpl;
@useResult
$Res call({
 String teamName, List<CategorySection> sections, int? unreadThreads, int drafts, bool synced
});




}
/// @nodoc
class _$ChannelListCopyWithImpl<$Res>
    implements $ChannelListCopyWith<$Res> {
  _$ChannelListCopyWithImpl(this._self, this._then);

  final ChannelList _self;
  final $Res Function(ChannelList) _then;

/// Create a copy of ChannelList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? teamName = null,Object? sections = null,Object? unreadThreads = freezed,Object? drafts = null,Object? synced = null,}) {
  return _then(ChannelList(
teamName: null == teamName ? _self.teamName : teamName // ignore: cast_nullable_to_non_nullable
as String,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<CategorySection>,unreadThreads: freezed == unreadThreads ? _self.unreadThreads : unreadThreads // ignore: cast_nullable_to_non_nullable
as int?,drafts: null == drafts ? _self.drafts : drafts // ignore: cast_nullable_to_non_nullable
as int,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChannelList].
extension ChannelListPatterns on ChannelList {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChannelList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChannelList() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChannelList value)  $default,){
final _that = this;
switch (_that) {
case _ChannelList():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChannelList value)?  $default,){
final _that = this;
switch (_that) {
case _ChannelList() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String teamName,  List<CategorySection> sections,  int? unreadThreads,  int drafts,  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChannelList() when $default != null:
return $default(_that.teamName,_that.sections,_that.unreadThreads,_that.drafts,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String teamName,  List<CategorySection> sections,  int? unreadThreads,  int drafts,  bool synced)  $default,) {final _that = this;
switch (_that) {
case _ChannelList():
return $default(_that.teamName,_that.sections,_that.unreadThreads,_that.drafts,_that.synced);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String teamName,  List<CategorySection> sections,  int? unreadThreads,  int drafts,  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _ChannelList() when $default != null:
return $default(_that.teamName,_that.sections,_that.unreadThreads,_that.drafts,_that.synced);case _:
  return null;

}
}

}

/// @nodoc


class _ChannelList extends ChannelList {
  const _ChannelList({required this.teamName, required  List<CategorySection> sections, required this.unreadThreads, required this.drafts, required this.synced}): _sections = sections,super._();
  

@override final  String teamName;
 final  List<CategorySection> _sections;
@override List<CategorySection> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}

/// Followed threads with unread replies; null when threads are not
/// collapsed, so there is no Threads row.
@override final  int? unreadThreads;
@override final  int drafts;
/// The team's channels were fetched at least once.
@override final  bool synced;

/// Create a copy of ChannelList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChannelListCopyWith<_ChannelList> get copyWith => __$ChannelListCopyWithImpl<_ChannelList>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChannelList&&(identical(other.teamName, teamName) || other.teamName == teamName)&&const DeepCollectionEquality().equals(other.sections, _sections)&&(identical(other.unreadThreads, unreadThreads) || other.unreadThreads == unreadThreads)&&(identical(other.drafts, drafts) || other.drafts == drafts)&&(identical(other.synced, synced) || other.synced == synced));
}


@override
int get hashCode {
    return Object.hash(runtimeType,teamName,const DeepCollectionEquality().hash(_sections),unreadThreads,drafts,synced);
}

@override
String toString() {
    return 'ChannelList(teamName: $teamName, sections: $sections, unreadThreads: $unreadThreads, drafts: $drafts, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$ChannelListCopyWith<$Res> implements $ChannelListCopyWith<$Res> {
  factory _$ChannelListCopyWith(_ChannelList value, $Res Function(_ChannelList) _then) = __$ChannelListCopyWithImpl;
@override @useResult
$Res call({
 String teamName, List<CategorySection> sections, int? unreadThreads, int drafts, bool synced
});




}
/// @nodoc
class __$ChannelListCopyWithImpl<$Res>
    implements _$ChannelListCopyWith<$Res> {
  __$ChannelListCopyWithImpl(this._self, this._then);

  final _ChannelList _self;
  final $Res Function(_ChannelList) _then;

/// Create a copy of ChannelList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? teamName = null,Object? sections = null,Object? unreadThreads = freezed,Object? drafts = null,Object? synced = null,}) {
  return _then(_ChannelList(
teamName: null == teamName ? _self.teamName : teamName // ignore: cast_nullable_to_non_nullable
as String,sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<CategorySection>,unreadThreads: freezed == unreadThreads ? _self.unreadThreads : unreadThreads // ignore: cast_nullable_to_non_nullable
as int?,drafts: null == drafts ? _self.drafts : drafts // ignore: cast_nullable_to_non_nullable
as int,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
