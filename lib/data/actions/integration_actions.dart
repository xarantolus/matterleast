import 'package:matterleast/api/coalesce.dart';
import 'package:matterleast/api/json/integration_props.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/integration_blocks.dart';

/// Runs integrations' post actions. The integration answers by changing the
/// post or sending an ephemeral reply, both over the WebSocket; a dialog it
/// opens shows because its trigger is expected here.
class IntegrationActions {
  IntegrationActions(this.session);

  final ServerSession session;
  final _running = <String, Future<String?>>{};

  /// Sends [request] and returns where the integration wants the user to
  /// go, if anywhere. A second tap while the same action runs shares it.
  /// Server errors are thrown as [ApiError]s.
  Future<String?> run(PostActionRequest request) => coalesce(
    _running,
    '${request.postId}/${request.actionId}/${request.selectedOption}',
    () => _run(request),
  );

  Future<String?> _run(PostActionRequest r) async {
    final body = PostActionBody(
      selectedOption: r.selectedOption,
      integrationFormat: r.format.json,
      cookie: r.cookie?.isEmpty ?? true ? null : r.cookie,
      query: r.query?.isEmpty ?? true ? null : r.query,
    );
    final response = await session.api.call(
      () => session.api.dio.post<Object?>(
        '/api/v4/posts/${Uri.encodeComponent(r.postId)}'
        '/actions/${Uri.encodeComponent(r.actionId)}',
        data: body.toJson(),
      ),
    );
    final json = response.data;
    final answer = json is Map<String, Object?>
        ? PostActionAnswer.fromJson(json)
        : const PostActionAnswer();
    if (answer.triggerId case final trigger? when trigger.isNotEmpty) {
      session.connection.dialogs.expect(trigger);
    }
    final location = answer.gotoLocation;
    return location == null || location.isEmpty ? null : location;
  }
}
