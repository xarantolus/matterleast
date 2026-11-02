import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/server_features.dart';

/// What the server asks of a report of a message.
typedef ReportForm = ({List<String> reasons, bool commentRequired});

/// Reporting messages to the people who review them, where the server's
/// licence has it and a team switched it on.
class ContentFlagging {
  ContentFlagging(this.session);

  final ServerSession session;

  api.ContentFlaggingClient get _client => session.api.client.contentFlagging;

  /// Whether [teamId] takes reports; false where the server doesn't have
  /// the feature at all.
  Future<bool> enabled(String teamId) async {
    try {
      final status = await session.api.call(
        () => _client.getCfTeamStatus(teamId: teamId),
      );
      return status.enabled ?? false;
    } on ServerError catch (e) {
      if (endpointUnavailable(e, refusalMeansAbsent: true)) return false;
      rethrow;
    }
  }

  Future<ReportForm> form() async {
    final config = await session.api.call(() => _client.getCfFlagConfig());
    return (
      reasons: config.reasons,
      commentRequired: config.reporterCommentRequired ?? false,
    );
  }

  Future<void> report(String postId, {String? reason, String? comment}) =>
      session.api.call(
        () => _client.postCfPostFlag(
          postId: postId,
          body: api.ApiV4ContentFlaggingPostPostIdFlagRequestBody(
            reason: reason,
            comment: comment,
          ),
        ),
      );
}
