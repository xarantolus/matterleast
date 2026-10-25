// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'clients/users_client.dart';
import 'clients/threads_client.dart';
import 'clients/data_retention_client.dart';
import 'clients/status_client.dart';
import 'clients/teams_client.dart';
import 'clients/channels_client.dart';
import 'clients/posts_client.dart';
import 'clients/preferences_client.dart';
import 'clients/files_client.dart';
import 'clients/system_client.dart';
import 'clients/emoji_client.dart';
import 'clients/groups_client.dart';
import 'clients/commands_client.dart';
import 'clients/plugins_client.dart';
import 'clients/roles_client.dart';
import 'clients/terms_of_service_client.dart';
import 'clients/remote_clusters_client.dart';
import 'clients/shared_channels_client.dart';
import 'clients/reactions_client.dart';
import 'clients/integration_actions_client.dart';
import 'clients/bookmarks_client.dart';
import 'clients/scheduled_post_client.dart';
import 'clients/custom_profile_attributes_client.dart';
import 'clients/ephemeral_mode_client.dart';
import 'clients/access_control_client.dart';

class MattermostClient {
  MattermostClient(Dio dio, {String? baseUrl}) : _dio = dio, _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '4.0.0';

  UsersClient? _users;
  ThreadsClient? _threads;
  DataRetentionClient? _dataRetention;
  StatusClient? _status;
  TeamsClient? _teams;
  ChannelsClient? _channels;
  PostsClient? _posts;
  PreferencesClient? _preferences;
  FilesClient? _files;
  SystemClient? _system;
  EmojiClient? _emoji;
  GroupsClient? _groups;
  CommandsClient? _commands;
  PluginsClient? _plugins;
  RolesClient? _roles;
  TermsOfServiceClient? _termsOfService;
  RemoteClustersClient? _remoteClusters;
  SharedChannelsClient? _sharedChannels;
  ReactionsClient? _reactions;
  IntegrationActionsClient? _integrationActions;
  BookmarksClient? _bookmarks;
  ScheduledPostClient? _scheduledPost;
  CustomProfileAttributesClient? _customProfileAttributes;
  EphemeralModeClient? _ephemeralMode;
  AccessControlClient? _accessControl;

  UsersClient get users => _users ??= UsersClient(_dio, baseUrl: _baseUrl);

  ThreadsClient get threads =>
      _threads ??= ThreadsClient(_dio, baseUrl: _baseUrl);

  DataRetentionClient get dataRetention =>
      _dataRetention ??= DataRetentionClient(_dio, baseUrl: _baseUrl);

  StatusClient get status => _status ??= StatusClient(_dio, baseUrl: _baseUrl);

  TeamsClient get teams => _teams ??= TeamsClient(_dio, baseUrl: _baseUrl);

  ChannelsClient get channels =>
      _channels ??= ChannelsClient(_dio, baseUrl: _baseUrl);

  PostsClient get posts => _posts ??= PostsClient(_dio, baseUrl: _baseUrl);

  PreferencesClient get preferences =>
      _preferences ??= PreferencesClient(_dio, baseUrl: _baseUrl);

  FilesClient get files => _files ??= FilesClient(_dio, baseUrl: _baseUrl);

  SystemClient get system => _system ??= SystemClient(_dio, baseUrl: _baseUrl);

  EmojiClient get emoji => _emoji ??= EmojiClient(_dio, baseUrl: _baseUrl);

  GroupsClient get groups => _groups ??= GroupsClient(_dio, baseUrl: _baseUrl);

  CommandsClient get commands =>
      _commands ??= CommandsClient(_dio, baseUrl: _baseUrl);

  PluginsClient get plugins =>
      _plugins ??= PluginsClient(_dio, baseUrl: _baseUrl);

  RolesClient get roles => _roles ??= RolesClient(_dio, baseUrl: _baseUrl);

  TermsOfServiceClient get termsOfService =>
      _termsOfService ??= TermsOfServiceClient(_dio, baseUrl: _baseUrl);

  RemoteClustersClient get remoteClusters =>
      _remoteClusters ??= RemoteClustersClient(_dio, baseUrl: _baseUrl);

  SharedChannelsClient get sharedChannels =>
      _sharedChannels ??= SharedChannelsClient(_dio, baseUrl: _baseUrl);

  ReactionsClient get reactions =>
      _reactions ??= ReactionsClient(_dio, baseUrl: _baseUrl);

  IntegrationActionsClient get integrationActions =>
      _integrationActions ??= IntegrationActionsClient(_dio, baseUrl: _baseUrl);

  BookmarksClient get bookmarks =>
      _bookmarks ??= BookmarksClient(_dio, baseUrl: _baseUrl);

  ScheduledPostClient get scheduledPost =>
      _scheduledPost ??= ScheduledPostClient(_dio, baseUrl: _baseUrl);

  CustomProfileAttributesClient get customProfileAttributes =>
      _customProfileAttributes ??= CustomProfileAttributesClient(
        _dio,
        baseUrl: _baseUrl,
      );

  EphemeralModeClient get ephemeralMode =>
      _ephemeralMode ??= EphemeralModeClient(_dio, baseUrl: _baseUrl);

  AccessControlClient get accessControl =>
      _accessControl ??= AccessControlClient(_dio, baseUrl: _baseUrl);
}
