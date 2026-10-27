// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pane_widths.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaneWidths _$PaneWidthsFromJson(Map<String, dynamic> json) => _PaneWidths(
  list: (json['list'] as num?)?.toDouble(),
  listBesideThread: (json['listBesideThread'] as num?)?.toDouble(),
  thread: (json['thread'] as num?)?.toDouble(),
);

Map<String, dynamic> _$PaneWidthsToJson(_PaneWidths instance) =>
    <String, dynamic>{
      'list': instance.list,
      'listBesideThread': instance.listBesideThread,
      'thread': instance.thread,
    };
