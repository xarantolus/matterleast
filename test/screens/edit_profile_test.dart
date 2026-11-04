import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/user_profile.dart';
import 'package:matterleast/screens/you/edit_profile_screen.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('a nickname can be as long as the server allows', (tester) async {
    await pumpApp(
      tester,
      const EditProfileScreen(
        url: 'https://chat.example.test',
        profile: UserProfile(
          id: 'u1',
          name: 'River',
          username: 'river',
          nickname: '',
          firstName: '',
          lastName: '',
          position: '',
          status: 'online',
          isBot: false,
          isMe: true,
        ),
      ),
    );
    final nickname = find.widgetWithText(TextField, 'Nickname');
    final long = 'n' * 60;
    await tester.enterText(nickname, long);
    expect(tester.widget<TextField>(nickname).controller!.text, long);
  });
}
