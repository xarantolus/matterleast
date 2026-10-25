import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/actions/message_links.dart';
import 'package:matterleast/domain/server_link.dart';

void main() {
  final chat = Uri.parse('https://chat.example.test');
  final sub = Uri.parse('https://tools.example.test/mm');
  final known = [chat, sub];
  const id = 'abcdefghijklmnopqrstuvwxyz';

  ServerLink? parse(String url) => parseServerLink(Uri.parse(url), known);

  test('a permalink opens the message on its server', () {
    expect(
      parse('https://chat.example.test/crew/pl/$id'),
      ServerLink.post(server: chat, team: 'crew', postId: id),
    );
    expect(
      parse('https://chat.example.test/crew/threads/$id?x=1#top'),
      ServerLink.post(server: chat, team: 'crew', postId: id),
    );
  });

  test('channel and direct message links name what they open', () {
    expect(
      parse('https://chat.example.test/crew/channels/Town-Square'),
      ServerLink.channel(server: chat, team: 'crew', name: 'town-square'),
    );
    expect(
      parse('https://chat.example.test/crew/messages/@Bob'),
      ServerLink.directMessage(server: chat, team: 'crew', username: 'bob'),
    );
  });

  test('the bare server and a team open the server', () {
    expect(parse('https://chat.example.test/'), ServerLink.home(server: chat));
    expect(
      parse('https://chat.example.test/crew'),
      ServerLink.home(server: chat, team: 'crew'),
    );
  });

  test('a server below a sub-path matches only below it', () {
    expect(
      parse('https://tools.example.test/mm/ops/pl/$id'),
      ServerLink.post(server: sub, team: 'ops', postId: id),
    );
    expect(parse('https://tools.example.test/wiki/page'), isNull);
  });

  test('other hosts, ports, paths and schemes stay outside', () {
    expect(parse('https://other.example.test/crew/pl/$id'), isNull);
    expect(parse('https://chat.example.test:8443/crew/pl/$id'), isNull);
    expect(parse('https://chat.example.test/crew/pl/not-an-id'), isNull);
    expect(parse('https://chat.example.test/crew/settings/x/y'), isNull);
    expect(parse('mailto:crew@chat.example.test'), isNull);
  });

  test('an app link opens the same path on a known server', () {
    final local = Uri.parse('http://10.0.2.2:8065');
    ServerLink? incoming(String url) =>
        parseIncomingLink(Uri.parse(url), [...known, local]);
    expect(
      incoming('matterleast://chat.example.test/crew/pl/$id'),
      ServerLink.post(server: chat, team: 'crew', postId: id),
    );
    expect(
      incoming('matterleast://10.0.2.2:8065/crew/channels/boats'),
      ServerLink.channel(server: local, team: 'crew', name: 'boats'),
    );
    expect(
      incoming('https://chat.example.test/crew/pl/$id'),
      ServerLink.post(server: chat, team: 'crew', postId: id),
    );
    expect(incoming('matterleast://other.example.test/crew/pl/$id'), isNull);
    expect(incoming('matterleast://callback?MMAUTHTOKEN=x'), isNull);
    expect(incoming('mmauth://callback?MMAUTHTOKEN=x'), isNull);
  });

  test('a reply opens its thread only under collapsed threads', () {
    expect(threadToOpen(rootId: 'r', collapsedThreads: true), 'r');
    expect(threadToOpen(rootId: 'r', collapsedThreads: false), isNull);
    expect(threadToOpen(rootId: '', collapsedThreads: true), isNull);
  });
}
