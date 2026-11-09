import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/json/calls.dart';
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/domain/calls.dart';
import 'package:matterleast/domain/server_features.dart';

const _route = '/plugins/$callsPluginId';

/// Talks to the Calls plugin. Server errors are thrown as [ApiError]s,
/// except that the plugin being absent or refusing turns the feature off
/// and answers null.
class CallsActions {
  CallsActions({required this.api, required this.store});

  final ServerApi api;
  final ServerStore store;

  Future<CallsConfig?> config() => _unlessAbsent(() async {
    final json = await api.coalesced(
      'calls-config',
      () => api.getJsonObject('$_route/config'),
    );
    return json == null ? null : CallsConfig.fromJson(json);
  });

  /// Every channel the plugin has something to say about.
  Future<List<CallsChannelState>?> channels() => _unlessAbsent(
    () => api.coalesced('calls-channels', () async {
      final response = await api.call(
        () => api.dio.get<Object?>(
          '$_route/channels',
          queryParameters: {'mobilev2': 'true'},
        ),
      );
      return decodeCallsChannels(response.data);
    }),
  );

  Future<CallsChannelState?> channel(String id) => _unlessAbsent(() async {
    final json = await api.coalesced(
      'calls-channel:$id',
      () => api.getJsonObject(
        '$_route/${Uri.encodeComponent(id)}',
        query: {'mobilev2': 'true'},
      ),
    );
    return json == null ? null : CallsChannelState.fromJson(json);
  });

  Future<T?> _unlessAbsent<T>(Future<T?> Function() fetch) async {
    try {
      return await fetch();
    } on ServerError catch (e) {
      if (!endpointUnavailable(e, refusalMeansAbsent: true)) rethrow;
      await store.turnOff(OptionalFeature.calls);
      return null;
    }
  }
}
