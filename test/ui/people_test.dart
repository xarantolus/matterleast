import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/user_profile.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/screens/you/profile_providers.dart';
import 'package:matterleast/screens/you/user_profile_sheet.dart';
import 'package:matterleast/ui/initials_badge.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/person_tile.dart';
import 'package:matterleast/ui/post_tile.dart';
import 'package:matterleast/ui/user_avatar.dart';

const _url = 'https://chat.example.test';

const _pat = UserProfile(
  id: 'u-pat',
  name: 'Pat Doe',
  username: 'pat',
  nickname: '',
  firstName: 'Pat',
  lastName: 'Doe',
  position: 'Harbour master',
  status: 'online',
  isBot: false,
  isMe: false,
);

const PostPerson _patPerson = (
  id: 'u-pat',
  name: 'Pat Doe',
  username: 'pat',
  pictureAt: 7,
);
const PostPerson _samPerson = (
  id: 'u-sam',
  name: 'Sam Roe',
  username: 'sam',
  pictureAt: null,
);

List<Override> _overrides({bool profileFails = false}) => [
  serverImageCachesProvider(_url)
      .overrideWith((ref) => Completer<ServerImageCaches>().future),
  userProfileProvider(
    _url,
    'u-pat',
  ).overrideWith((ref) => Stream.value(profileFails ? null : _pat)),
  profileRefreshProvider(_url, 'u-pat').overrideWith((ref) async {
    if (profileFails) throw const ServerError(statusCode: 500);
  }),
];

Future<void> _show(
  WidgetTester tester,
  Widget child, {
  bool profileFails = false,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: _overrides(profileFails: profileFails),
      child: MaterialApp(
        theme: MatterleastApp.lightTheme,
        home: Scaffold(
          body: PostEnvironment(
            server: Uri.parse(_url),
            options: const ParseOptions(),
            myUsername: 'me',
            onMention: (_) {},
            onChannel: (_) {},
            onLink: (_) {},
            child: ListView(children: [child]),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

PostItem _post({
  List<ReactionGroup> reactions = const [],
  List<PostPerson> participants = const [],
  int replyCount = 0,
  String? propsJson,
}) => PostItem(
  id: 'p1',
  key: 'p1',
  userId: 'u-pat',
  authorName: 'Pat Doe',
  createAt: DateTime.utc(2026, 10, 20, 9),
  message: 'Tide is high',
  reactions: reactions,
  participants: participants,
  replyCount: replyCount,
  propsJson: propsJson,
);

void main() {
  testWidgets("tapping the author's name opens their profile", (tester) async {
    await _show(tester, PostTile(post: _post()));
    await tester.tap(find.text('Pat Doe'));
    await tester.pumpAndSettle();
    expect(find.byType(UserProfileSheet), findsOneWidget);
    expect(find.text('Harbour master'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Message'), findsOneWidget);
  });

  testWidgets("tapping the author's picture opens their profile", (
    tester,
  ) async {
    await _show(tester, PostTile(post: _post()));
    await tester.tap(find.byType(UserAvatar));
    await tester.pumpAndSettle();
    expect(find.byType(UserProfileSheet), findsOneWidget);
  });

  testWidgets('a webhook post opens no profile', (tester) async {
    await _show(
      tester,
      PostTile(post: _post(propsJson: '{"from_webhook":"true"}')),
    );
    await tester.tap(find.text('Pat Doe'));
    await tester.pumpAndSettle();
    expect(find.byType(UserProfileSheet), findsNothing);
  });

  testWidgets('who reacted lists people with picture and @username', (
    tester,
  ) async {
    final group = ReactionGroup(
      emojiName: 'tada',
      people: const [_patPerson, _samPerson],
      mine: false,
    );
    await _show(tester, PostTile(post: _post(reactions: [group])));
    await tester.longPress(find.text('2'));
    await tester.pumpAndSettle();
    expect(find.byType(PersonTile), findsNWidgets(2));
    expect(find.text('@sam'), findsOneWidget);
    await tester.tap(find.text('@pat'));
    await tester.pumpAndSettle();
    expect(find.byType(UserProfileSheet), findsOneWidget);
  });

  testWidgets("the thread bar shows the repliers' pictures", (tester) async {
    await _show(
      tester,
      PostTile(
        post: _post(
          participants: const [_patPerson, _samPerson],
          replyCount: 3,
        ),
        onOpenThread: () {},
      ),
    );
    final avatars = tester
        .widgetList<UserAvatar>(find.byType(UserAvatar))
        .map((a) => (a.userId, a.lastPictureUpdate));
    expect(avatars, containsAll([('u-pat', 7), ('u-sam', null)]));
  });

  testWidgets("a profile that can't load says why and offers Retry", (
    tester,
  ) async {
    await _show(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showUserProfile(context, url: _url, userId: 'u-pat'),
          child: const Text('open'),
        ),
      ),
      profileFails: true,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text("Couldn't load the profile"), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(InitialsBadge), findsNothing);
  });
}
