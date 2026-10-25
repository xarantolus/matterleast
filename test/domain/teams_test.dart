import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/teams.dart';

void main() {
  const teams = [
    (id: 'h', displayName: 'harbor'),
    (id: 'l', displayName: 'Lighthouse'),
    (id: 'a', displayName: 'Atlas'),
  ];

  test('teams follow the order preference, then their names', () {
    expect(sortTeams(teams, 'l,gone').map((t) => t.id), ['l', 'a', 'h']);
    expect(sortTeams(teams, null).map((t) => t.id), ['a', 'h', 'l']);
  });

  test('the remembered team wins while the user is still in it', () {
    expect(pickCurrentTeam(teams, current: 'h'), 'h');
    expect(pickCurrentTeam(teams, current: 'left', teamsOrder: 'l'), 'l');
    expect(pickCurrentTeam(const [], current: 'h'), isNull);
  });

  test('collapsed threads follow the server setting and the user', () {
    expect(collapsedThreadsOn('default_on', null), isTrue);
    expect(collapsedThreadsOn('default_on', 'off'), isFalse);
    expect(collapsedThreadsOn('default_off', null), isFalse);
    expect(collapsedThreadsOn('default_off', 'on'), isTrue);
    expect(collapsedThreadsOn('always_on', 'off'), isTrue);
    expect(collapsedThreadsOn('disabled', 'on'), isFalse);
  });

  test('the partner of a direct message is the other id', () {
    expect(directPartnerId('me__you', 'me'), 'you');
    expect(directPartnerId('you__me', 'me'), 'you');
    expect(directPartnerId('me__me', 'me'), 'me');
    expect(directPartnerId('town-square', 'me'), isNull);
  });
}
