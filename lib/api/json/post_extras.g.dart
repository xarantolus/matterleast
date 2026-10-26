// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_extras.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostProps _$PostPropsFromJson(Map<String, dynamic> json) => PostProps(
  fromWebhook: const LenientString().fromJson(json['from_webhook']),
  fromBot: const LenientString().fromJson(json['from_bot']),
  fromPlugin: const LenientString().fromJson(json['from_plugin']),
  overrideUsername: const LenientString().fromJson(json['override_username']),
  overrideIconUrl: const LenientString().fromJson(json['override_icon_url']),
  overrideIconEmoji: const LenientString().fromJson(
    json['override_icon_emoji'],
  ),
  useUserIcon: const LenientString().fromJson(json['use_user_icon']),
  unsafeLinks: const LenientString().fromJson(json['unsafe_links']),
  attachments: json['attachments'] == null
      ? const []
      : const AttachmentList().fromJson(json['attachments']),
  channelMentions: json['channel_mentions'] == null
      ? const {}
      : const _ChannelMentions().fromJson(json['channel_mentions']),
  username: const LenientString().fromJson(json['username']),
  addedUsername: const LenientString().fromJson(json['addedUsername']),
  removedUsername: const LenientString().fromJson(json['removedUsername']),
  oldHeader: const LenientString().fromJson(json['old_header']),
  newHeader: const LenientString().fromJson(json['new_header']),
  oldPurpose: const LenientString().fromJson(json['old_purpose']),
  newPurpose: const LenientString().fromJson(json['new_purpose']),
  oldDisplayname: const LenientString().fromJson(json['old_displayname']),
  newDisplayname: const LenientString().fromJson(json['new_displayname']),
);

Attachment _$AttachmentFromJson(Map<String, dynamic> json) => Attachment(
  fallback: const LenientString().fromJson(json['fallback']),
  color: const LenientString().fromJson(json['color']),
  pretext: const LenientString().fromJson(json['pretext']),
  authorName: const LenientString().fromJson(json['author_name']),
  authorLink: const LenientString().fromJson(json['author_link']),
  authorIcon: const LenientString().fromJson(json['author_icon']),
  title: const LenientString().fromJson(json['title']),
  titleLink: const LenientString().fromJson(json['title_link']),
  text: const LenientString().fromJson(json['text']),
  fields: json['fields'] == null
      ? const []
      : const _Fields().fromJson(json['fields']),
  imageUrl: const LenientString().fromJson(json['image_url']),
  thumbUrl: const LenientString().fromJson(json['thumb_url']),
  footer: const LenientString().fromJson(json['footer']),
  footerIcon: const LenientString().fromJson(json['footer_icon']),
  actions: json['actions'] == null
      ? const []
      : const _Actions().fromJson(json['actions']),
);

AttachmentField _$AttachmentFieldFromJson(Map<String, dynamic> json) =>
    AttachmentField(
      title: const LenientString().fromJson(json['title']),
      value: const _Scalar().fromJson(json['value']),
      short: const LenientBool().fromJson(json['short']),
    );

AttachmentAction _$AttachmentActionFromJson(Map<String, dynamic> json) =>
    AttachmentAction(
      id: const LenientString().fromJson(json['id']),
      name: const LenientString().fromJson(json['name']),
      type: const LenientString().fromJson(json['type']),
      style: const LenientString().fromJson(json['style']),
      tooltip: const LenientString().fromJson(json['tooltip']),
      disabled: const LenientBool().fromJson(json['disabled']),
      cookie: const LenientString().fromJson(json['cookie']),
      dataSource: const LenientString().fromJson(json['data_source']),
      defaultOption: const LenientString().fromJson(json['default_option']),
      options: json['options'] == null
          ? const []
          : const _ActionOptions().fromJson(json['options']),
    );

AttachmentOption _$AttachmentOptionFromJson(Map<String, dynamic> json) =>
    AttachmentOption(
      text: const LenientString().fromJson(json['text']),
      value: const LenientString().fromJson(json['value']),
    );

OpenGraph _$OpenGraphFromJson(Map<String, dynamic> json) => OpenGraph(
  url: const LenientString().fromJson(json['url']),
  title: const LenientString().fromJson(json['title']),
  description: const LenientString().fromJson(json['description']),
  siteName: const LenientString().fromJson(json['site_name']),
  images: json['images'] == null
      ? const []
      : const _Images().fromJson(json['images']),
);

OpenGraphImage _$OpenGraphImageFromJson(Map<String, dynamic> json) =>
    OpenGraphImage(
      url: const LenientString().fromJson(json['url']),
      secureUrl: const LenientString().fromJson(json['secure_url']),
      width: const LenientInt().fromJson(json['width']),
      height: const LenientInt().fromJson(json['height']),
    );

ImageSize _$ImageSizeFromJson(Map<String, dynamic> json) => ImageSize(
  width: const LenientInt().fromJson(json['width']),
  height: const LenientInt().fromJson(json['height']),
  format: const LenientString().fromJson(json['format']),
);

PermalinkEmbed _$PermalinkEmbedFromJson(Map<String, dynamic> json) =>
    PermalinkEmbed(
      postId: const LenientString().fromJson(json['post_id']),
      teamName: const LenientString().fromJson(json['team_name']),
      channelDisplayName: const LenientString().fromJson(
        json['channel_display_name'],
      ),
      channelType: const LenientString().fromJson(json['channel_type']),
      channelId: const LenientString().fromJson(json['channel_id']),
      post: const LenientPost().fromJson(json['post']),
    );
