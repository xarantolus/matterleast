// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'desktop_window.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WindowPlacement _$WindowPlacementFromJson(Map<String, dynamic> json) =>
    _WindowPlacement(
      x: (json['x'] as num?)?.toDouble(),
      y: (json['y'] as num?)?.toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      maximized: json['maximized'] as bool? ?? false,
    );

Map<String, dynamic> _$WindowPlacementToJson(_WindowPlacement instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
      'maximized': instance.maximized,
    };
