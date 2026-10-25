// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'visibility.dart';
import 'options2.dart';
import 'value_type.dart';
import 'access_mode.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'attrs.g.dart';

@JsonSerializable()
class Attrs {
  const Attrs({
    this.sortOrder,
    this.valueType,
    this.ldap,
    this.saml,
    this.protected,
    this.sourcePluginId,
    this.accessMode,
    this.displayName,
    this.visibility = Visibility.whenSet,
    this.options = const [],
  });

  factory Attrs.fromJson(Map<String, Object?> json) => _$AttrsFromJson(json);

  final Visibility visibility;

  @LenientDouble()
  @JsonKey(name: 'sort_order')
  final num? sortOrder;

  @LenientListOfOptions2()
  final List<Options2> options;

  @JsonKey(name: 'value_type')
  final ValueType? valueType;

  @LenientString()
  final String? ldap;

  @LenientString()
  final String? saml;

  @LenientBool()
  final bool? protected;

  @LenientString()
  @JsonKey(name: 'source_plugin_id')
  final String? sourcePluginId;

  @JsonKey(name: 'access_mode')
  final AccessMode? accessMode;

  @LenientString()
  @JsonKey(name: 'display_name')
  final String? displayName;

  Map<String, Object?> toJson() => _$AttrsToJson(this);
}
