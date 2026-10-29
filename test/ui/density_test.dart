import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/theme.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/ui/context_menu.dart';
import 'package:matterleast/ui/density.dart';
import 'package:matterleast/ui/message_display.dart';
import 'package:matterleast/ui/reactions_bar.dart';

const _group = ReactionGroup(
  emojiName: 'tada',
  people: [(id: 'u1', name: 'Wren', username: 'wren', pictureAt: null)],
  mine: false,
);

Widget _app(Widget body) => MaterialApp(
  theme: themeForPlatform(MatterleastApp.lightTheme),
  home: Scaffold(body: body),
);

final _desktop = TargetPlatformVariant.only(TargetPlatform.linux);
final _phone = TargetPlatformVariant.only(TargetPlatform.android);

void main() {
  group('on desktop', () {
    testWidgets('messages are compact', variant: _desktop, (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      );
      final density = context.density;
      expect(density.avatar, 32);
      expect(density.rowTop, 4);
      expect(density.radius, 6);
      expect(density.flat, isTrue);
      expect(density.arrive, Duration.zero);
      expect(
        density.expand,
        lessThanOrEqualTo(const Duration(milliseconds: 100)),
      );
      expect(
        density.pageFade,
        lessThanOrEqualTo(const Duration(milliseconds: 120)),
      );
      final body = Theme.of(context).textTheme.bodyMedium!;
      expect(body.fontSize, 14);
      expect(body.forMessages(context).height, 1.35);
    });

    testWidgets(
      'a reaction chip is 24 px high whether or not it is mine',
      variant: _desktop,
      (tester) async {
        Future<Size> size({required bool mine}) async {
          await tester.pumpWidget(
            _app(
              ReactionsBar(
                reactions: [
                  ReactionGroup(
                    emojiName: 'tada',
                    people: _group.people,
                    mine: mine,
                  ),
                ],
                onAdd: (_) {},
              ),
            ),
          );
          return tester.getSize(find.byType(FilterChip));
        }

        final plain = await size(mine: false);
        expect(plain.height, 24);
        expect(await size(mine: true), plain);
        expect(tester.getSize(find.byType(ActionChip)).height, 24);
      },
    );

    testWidgets(
      'a menu row is 30 px high and shows its shortcut',
      variant: _desktop,
      (tester) async {
        late BuildContext context;
        await tester.pumpWidget(
          _app(
            Builder(
              builder: (c) {
                context = c;
                return const SizedBox();
              },
            ),
          ),
        );
        showMenuAt<int>(context, const Offset(20, 20), const [
          MenuItem(
            value: 1,
            child: MenuEntry(
              icon: Icons.copy,
              label: 'Copy',
              shortcut: 'Ctrl+C',
            ),
          ),
        ]).ignore();
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(PopupMenuItem<int>)).height, 30);
        expect(find.text('Ctrl+C'), findsOneWidget);
        final shortcut = tester.getTopRight(find.text('Ctrl+C')).dx;
        final label = tester.getTopRight(find.text('Copy')).dx;
        expect(shortcut, greaterThan(label));
      },
    );
  });

  group('on a phone', () {
    testWidgets('sizes are the touch sizes', variant: _phone, (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (c) {
              context = c;
              return ReactionsBar(reactions: const [_group], onAdd: (_) {});
            },
          ),
        ),
      );
      final density = context.density;
      expect(density, same(AppDensity.phone));
      expect(density.avatar, 36);
      expect(density.rowTop, 8);
      expect(density.radius, 8);
      expect(density.flat, isFalse);
      expect(density.plainComposer, isFalse);
      expect(density.menuRowHeight, isNull);
      expect(density.chipHeight, isNull);
      final body = Theme.of(context).textTheme.bodyMedium!;
      expect(body.forMessages(context).height, body.height);
      expect(tester.getSize(find.byType(FilterChip)).height, 30);
    });
  });
}
