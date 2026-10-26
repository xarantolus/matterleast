import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/category_moves.dart';
import 'package:matterleast/domain/channel_list.dart';

/// Favourites: town; Channels: eng, ops; Direct Messages: bob.
const entries = <ReorderEntry>[
  HeaderEntry('fav'),
  RowEntry('fav', 'town'),
  HeaderEntry('chan'),
  RowEntry('chan', 'eng'),
  RowEntry('chan', 'ops'),
  HeaderEntry('dm'),
  RowEntry('dm', 'bob'),
];

List<String> shape(List<ReorderEntry> list) => [
  for (final e in list)
    switch (e) {
      HeaderEntry(:final categoryId) => '#$categoryId',
      RowEntry(:final channelId) => channelId,
    },
];

void main() {
  group('dragging in the reorder list', () {
    test('a channel moved down inside its category', () {
      final drop = dropOf(entries, 3, 4) as ChannelDrop;
      expect(drop.toCategory, 'chan');
      expect(drop.index, 1);
      expect(shape(reorderEntries(entries, 3, 4)), [
        '#fav',
        'town',
        '#chan',
        'ops',
        'eng',
        '#dm',
        'bob',
      ]);
    });

    test('a channel moved up into another category', () {
      final drop = dropOf(entries, 4, 1) as ChannelDrop;
      expect(drop.fromCategory, 'chan');
      expect(drop.toCategory, 'fav');
      expect(drop.index, 0);
      expect(shape(reorderEntries(entries, 4, 1)), [
        '#fav',
        'ops',
        'town',
        '#chan',
        'eng',
        '#dm',
        'bob',
      ]);
    });

    test('a channel dropped at the end joins the last category', () {
      final drop = dropOf(entries, 1, entries.length - 1) as ChannelDrop;
      expect(drop.toCategory, 'dm');
      expect(drop.index, 1);
    });

    test('nothing happens above the first header or back in place', () {
      expect(dropOf(entries, 1, 0), isNull);
      expect(dropOf(entries, 3, 3), isNull);
    });

    test('a category takes its channels along', () {
      final drop = dropOf(entries, 5, 0) as CategoryDrop;
      expect(drop.categoryId, 'dm');
      expect(drop.shownOrder, ['dm', 'fav', 'chan']);
      expect(shape(reorderEntries(entries, 5, 0)), [
        '#dm',
        'bob',
        '#fav',
        'town',
        '#chan',
        'eng',
        'ops',
      ]);
    });

    test('a category dropped among its own channels stays', () {
      expect(dropOf(entries, 2, 3), isNull);
      expect(shape(reorderEntries(entries, 2, 3)), shape(entries));
    });
  });

  test('conversations and channels keep to their own categories', () {
    expect(canPlace(ChannelKind.direct, CategoryKind.channels), isFalse);
    expect(canPlace(ChannelKind.group, CategoryKind.directMessages), isTrue);
    expect(canPlace(ChannelKind.public, CategoryKind.directMessages), isFalse);
    expect(canPlace(ChannelKind.private, CategoryKind.channels), isTrue);
    expect(canPlace(ChannelKind.direct, CategoryKind.favorites), isTrue);
    expect(canPlace(ChannelKind.public, CategoryKind.custom), isTrue);
  });

  group('the stored order after a drop', () {
    test('keeps the order the user sees, hidden channels after it', () {
      expect(
        placeChannel(
          stored: ['a', 'closed', 'b', 'c'],
          shown: ['c', 'a', 'b'],
          channelId: 'new',
          index: 1,
        ),
        ['c', 'new', 'a', 'b', 'closed'],
      );
    });

    test('moving within a category does not duplicate the channel', () {
      expect(
        placeChannel(
          stored: ['a', 'b', 'c'],
          shown: ['a', 'b', 'c'],
          channelId: 'a',
          index: 2,
        ),
        ['b', 'c', 'a'],
      );
    });

    test('a category goes before the shown one that now follows it', () {
      // Favourites is empty and not in the list.
      expect(
        placeCategory(
          stored: ['fav', 'chan', 'work', 'dm'],
          shown: ['dm', 'chan', 'work'],
          categoryId: 'dm',
        ),
        ['fav', 'dm', 'chan', 'work'],
      );
      expect(
        placeCategory(
          stored: ['fav', 'chan', 'work', 'dm'],
          shown: ['work', 'dm', 'chan'],
          categoryId: 'chan',
        ),
        ['fav', 'work', 'dm', 'chan'],
      );
    });
  });

  group('unread channels out of view', () {
    final rows = [
      (id: 'a', unread: true),
      (id: 'b', unread: false),
      (id: 'c', unread: true),
      (id: 'd', unread: false),
      (id: 'e', unread: true),
      (id: 'f', unread: true),
    ];

    test('the nearest above and below, laid out or not', () {
      final result = unreadOutside(
        rows: rows,
        placed: {
          'b': (top: -40, bottom: -10),
          'c': (top: -10, bottom: 20),
          'd': (top: 20, bottom: 50),
          'e': (top: 300, bottom: 330),
        },
        height: 300,
      );
      expect(result.above, 'a', reason: 'not laid out, before the first row');
      expect(result.below, 'e', reason: 'laid out below the visible part');
    });

    test('none while every unread channel is visible', () {
      final result = unreadOutside(
        rows: rows,
        placed: {
          for (final (i, r) in rows.indexed)
            r.id: (top: i * 30.0, bottom: i * 30.0 + 30),
        },
        height: 300,
      );
      expect(result.above, isNull);
      expect(result.below, isNull);
    });
  });
}
