// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoticeTarget _$NoticeTargetFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'NoticeTarget',
      json,
      ($checkedConvert) {
        final val = NoticeTarget(
          serverUrl: $checkedConvert('s', (v) => v as String),
          channelId: $checkedConvert('c', (v) => v as String),
          postId: $checkedConvert('p', (v) => v as String),
          newestAt: $checkedConvert(
            'n',
            (v) => _fromMillis((v as num).toInt()),
          ),
          rootId: $checkedConvert('r', (v) => v as String? ?? ''),
          teamId: $checkedConvert('t', (v) => v as String? ?? ''),
          action: $checkedConvert('a', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'serverUrl': 's',
        'channelId': 'c',
        'postId': 'p',
        'newestAt': 'n',
        'rootId': 'r',
        'teamId': 't',
        'action': 'a',
      },
    );

Map<String, dynamic> _$NoticeTargetToJson(NoticeTarget instance) =>
    <String, dynamic>{
      's': instance.serverUrl,
      'c': instance.channelId,
      'r': instance.rootId,
      'p': instance.postId,
      't': instance.teamId,
      'n': _toMillis(instance.newestAt),
      'a': ?instance.action,
    };
