// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'integration_props.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntegrationProps _$IntegrationPropsFromJson(Map<String, dynamic> json) =>
    IntegrationProps(
      mmBlocks: json['mm_blocks'] == null
          ? const []
          : const _MmBlocks().fromJson(json['mm_blocks']),
      mmBlocksActions: const LenientString().fromJson(
        json['mm_blocks_actions'],
      ),
      blocks: json['blocks'] == null
          ? const []
          : const _BlockKit().fromJson(json['blocks']),
      cards: json['cards'] == null
          ? const []
          : const _Cards().fromJson(json['cards']),
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
  items: const _MmBlocksOrNull().fromJson(json['items']),
  columns: const _MmBlocksOrNull().fromJson(json['columns']),
  width: const LenientString().fromJson(json['width']),
  gap: const LenientString().fromJson(json['gap']),
  content: const _MmBlocksOrNull().fromJson(json['content']),
  header: const _MmBlocksOrNull().fromJson(json['header']),
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
  options: json['options'] == null
      ? const []
      : const _Options().fromJson(json['options']),
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
  accessory: const _BlockKitOne().fromJson(json['accessory']),
  elements: json['elements'] == null
      ? const []
      : const _BlockKit().fromJson(json['elements']),
  imageUrl: const LenientString().fromJson(json['image_url']),
  altText: const LenientString().fromJson(json['alt_text']),
  title: const SlackText().fromJson(json['title']),
  actionId: const LenientString().fromJson(json['action_id']),
  style: const LenientString().fromJson(json['style']),
  placeholder: const SlackText().fromJson(json['placeholder']),
  options: json['options'] == null
      ? const []
      : const _Options().fromJson(json['options']),
);

AdaptiveCardJson _$AdaptiveCardJsonFromJson(Map<String, dynamic> json) =>
    AdaptiveCardJson(
      type: const LenientString().fromJson(json['type']),
      body: json['body'] == null
          ? const []
          : const _Cards().fromJson(json['body']),
      actions: json['actions'] == null
          ? const []
          : const _Cards().fromJson(json['actions']),
      text: const LenientString().fromJson(json['text']),
      isSubtle: const LenientBool().fromJson(json['isSubtle']),
      size: const LenientString().fromJson(json['size']),
      items: json['items'] == null
          ? const []
          : const _Cards().fromJson(json['items']),
      columns: json['columns'] == null
          ? const []
          : const _Cards().fromJson(json['columns']),
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
