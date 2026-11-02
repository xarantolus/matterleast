// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'integration_props.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntegrationProps _$IntegrationPropsFromJson(Map<String, dynamic> json) =>
    IntegrationProps(
      mmBlocks:
          (json['mm_blocks'] as List<dynamic>?)
              ?.map((e) => MmBlockJson.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      mmBlocksActions: const LenientString().fromJson(
        json['mm_blocks_actions'],
      ),
      blocks:
          (json['blocks'] as List<dynamic>?)
              ?.map((e) => BlockKitJson.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      cards:
          (json['cards'] as List<dynamic>?)
              ?.map((e) => AdaptiveCardJson.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      attachments: json['attachments'] == null
          ? const []
          : const AttachmentList().fromJson(json['attachments']),
    );

MmBlockJson _$MmBlockJsonFromJson(Map<String, dynamic> json) => MmBlockJson(
  type: const LenientString().fromJson(json['type']),
  text: const LenientString().fromJson(json['text']),
  isSubtle: const LenientBool().fromJson(json['is_subtle']),
  size: const LenientString().fromJson(json['size']),
  url: const LenientString().fromJson(json['url']),
  altText: const LenientString().fromJson(json['alt_text']),
  title: const LenientString().fromJson(json['title']),
  maxWidth: const _Scalar().fromJson(json['max_width']),
  maxHeight: const _Scalar().fromJson(json['max_height']),
  imageStyle: const LenientString().fromJson(json['image_style']),
  horizontalAlignment: const LenientString().fromJson(
    json['horizontal_alignment'],
  ),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => MmBlockJson.fromJson(e as Map<String, dynamic>))
      .toList(),
  columns: (json['columns'] as List<dynamic>?)
      ?.map((e) => MmBlockJson.fromJson(e as Map<String, dynamic>))
      .toList(),
  width: const LenientString().fromJson(json['width']),
  gap: const LenientString().fromJson(json['gap']),
  content: (json['content'] as List<dynamic>?)
      ?.map((e) => MmBlockJson.fromJson(e as Map<String, dynamic>))
      .toList(),
  header: (json['header'] as List<dynamic>?)
      ?.map((e) => MmBlockJson.fromJson(e as Map<String, dynamic>))
      .toList(),
  collapsed: const LenientBool().fromJson(json['collapsed']),
  border: const LenientBool().fromJson(json['border']),
  accentColor: const LenientString().fromJson(json['accent_color']),
  flow: const LenientString().fromJson(json['flow']),
  background: const LenientString().fromJson(json['background']),
  actionId: const LenientString().fromJson(json['action_id']),
  style: const LenientString().fromJson(json['style']),
  tooltip: const LenientString().fromJson(json['tooltip']),
  disabled: const LenientBool().fromJson(json['disabled']),
  query: const StringMap().fromJson(json['query']),
  cookie: const LenientString().fromJson(json['cookie']),
  placeholder: const LenientString().fromJson(json['placeholder']),
  options:
      (json['options'] as List<dynamic>?)
          ?.map((e) => SelectOptionJson.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  initialOption: const LenientString().fromJson(json['initial_option']),
  dataSource: const LenientString().fromJson(json['data_source']),
);

SelectOptionJson _$SelectOptionJsonFromJson(Map<String, dynamic> json) =>
    SelectOptionJson(
      text: const SlackText().fromJson(json['text']),
      value: const _Scalar().fromJson(json['value']),
    );

BlockKitJson _$BlockKitJsonFromJson(Map<String, dynamic> json) => BlockKitJson(
  type: const LenientString().fromJson(json['type']),
  text: const SlackText().fromJson(json['text']),
  fields: json['fields'] == null
      ? const []
      : const _SlackTexts().fromJson(json['fields']),
  accessory: json['accessory'] == null
      ? null
      : BlockKitJson.fromJson(json['accessory'] as Map<String, dynamic>),
  elements:
      (json['elements'] as List<dynamic>?)
          ?.map((e) => BlockKitJson.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  imageUrl: const LenientString().fromJson(json['image_url']),
  altText: const LenientString().fromJson(json['alt_text']),
  title: const SlackText().fromJson(json['title']),
  actionId: const LenientString().fromJson(json['action_id']),
  style: const LenientString().fromJson(json['style']),
  placeholder: const SlackText().fromJson(json['placeholder']),
  options:
      (json['options'] as List<dynamic>?)
          ?.map((e) => SelectOptionJson.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

AdaptiveCardJson _$AdaptiveCardJsonFromJson(Map<String, dynamic> json) =>
    AdaptiveCardJson(
      type: const LenientString().fromJson(json['type']),
      body:
          (json['body'] as List<dynamic>?)
              ?.map((e) => AdaptiveCardJson.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      actions:
          (json['actions'] as List<dynamic>?)
              ?.map((e) => AdaptiveCardJson.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      text: const LenientString().fromJson(json['text']),
      isSubtle: const LenientBool().fromJson(json['isSubtle']),
      size: const LenientString().fromJson(json['size']),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => AdaptiveCardJson.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      columns:
          (json['columns'] as List<dynamic>?)
              ?.map((e) => AdaptiveCardJson.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      width: const _Scalar().fromJson(json['width']),
      height: const _Scalar().fromJson(json['height']),
      url: const LenientString().fromJson(json['url']),
      altText: const LenientString().fromJson(json['altText']),
      style: const LenientString().fromJson(json['style']),
      horizontalAlignment: const LenientString().fromJson(
        json['horizontalAlignment'],
      ),
      title: const LenientString().fromJson(json['title']),
      id: const LenientString().fromJson(json['id']),
    );

Map<String, dynamic> _$PostActionBodyToJson(PostActionBody instance) =>
    <String, dynamic>{
      'selected_option': instance.selectedOption,
      'cookie': ?instance.cookie,
      'query': ?instance.query,
      'integration_format': instance.integrationFormat,
    };

PostActionAnswer _$PostActionAnswerFromJson(Map<String, dynamic> json) =>
    PostActionAnswer(
      triggerId: const LenientString().fromJson(json['trigger_id']),
      gotoLocation: const LenientString().fromJson(json['goto_location']),
    );
