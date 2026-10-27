import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/channel_info/people_list.dart';
import 'package:matterleast/screens/channel_info/people_picker_screen.dart';
import 'package:matterleast/screens/you/user_profile_sheet.dart';
import 'package:matterleast/ui/slide_route.dart';

/// Who is in a channel, admins first, with search and presence.
class MembersScreen extends ConsumerWidget {
  const MembersScreen({
    required this.url,
    required this.channelId,
    required this.teamId,
    required this.title,
    required this.canAdd,
    super.key,
  });

  final String url;
  final String channelId;
  final String teamId;
  final String title;
  final bool canAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Members of $title'),
        actions: [
          if (canAdd)
            IconButton(
              tooltip: 'Add people',
              icon: const Icon(Icons.person_add_alt),
              onPressed: () => Navigator.of(context).push(
                SlideRoute<void>(
                  builder: (_) => addMembersScreen(
                    url: url,
                    teamId: teamId,
                    channelId: channelId,
                    channelTitle: title,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: PeopleList(
          url: url,
          loadPage: (page) async =>
              (await ref.read(directoryProvider(url).future))
                  .members(channelId, page: page),
          search: (term) async =>
              (await ref.read(directoryProvider(url).future))
                  .searchPeople(term, teamId: teamId, inChannel: channelId),
          onTap: (person) =>
              showUserProfile(context, url: url, userId: person.id),
          emptyTitle: 'Nobody here yet',
          emptyBody: canAdd
              ? 'Add people with the button at the top.'
              : 'Members show up here once they join.',
        ),
      ),
    );
  }
}
