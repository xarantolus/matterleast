import 'package:material_ui/material_ui.dart';
import 'package:matterleast/screens/you/user_profile_sheet.dart';
import 'package:matterleast/ui/presence_dot.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/user_avatar.dart';

/// One person in a list: their picture (with presence when [status] is
/// known), display name and @username. A tap opens their profile unless
/// [onTap] says otherwise.
class PersonTile extends StatelessWidget {
  const PersonTile({
    required this.serverUrl,
    required this.userId,
    required this.name,
    required this.username,
    this.pictureUpdate,
    this.status,
    this.note,
    this.trailing,
    this.onTap,
    this.dense = false,
    super.key,
  });

  final String serverUrl;
  final String userId;
  final String name;
  final String username;
  final int? pictureUpdate;
  final String? status;

  /// Said after the @username, such as "not in channel".
  final String? note;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final size = dense ? 32.0 : 40.0;
    final details = [if (username.isNotEmpty) '@$username', ?note];
    return ListTile(
      dense: dense,
      onTap:
          onTap ??
          () => showUserProfile(context, url: serverUrl, userId: userId),
      leading: SizedBox.square(
        dimension: size,
        child: Stack(
          children: [
            UserAvatar(
              serverUrl: serverUrl,
              userId: userId,
              name: name,
              lastPictureUpdate: pictureUpdate,
              size: size,
            ),
            if (status != null)
              PositionedDirectional(
                end: 0,
                bottom: 0,
                child: PresenceDot(status: status, size: dense ? 10 : 12),
              ),
          ],
        ),
      ),
      title: Text(
        name.isEmpty ? username : name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: details.isEmpty
          ? null
          : Text(
              details.join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: context.tokens.muted),
            ),
      trailing: trailing,
    );
  }
}
