import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/emoji/emoji.dart';

void main() {
  group('unicodeForName', () {
    test('resolves common reaction names', () {
      expect(unicodeForName('+1'), '\u{1F44D}');
      expect(unicodeForName('white_check_mark'), '\u{2705}');
      expect(unicodeForName('tada'), '\u{1F389}');
      expect(unicodeForName('heart'), '\u{2764}\u{FE0F}');
      expect(unicodeForName('rocket'), '\u{1F680}');
      expect(unicodeForName('slightly_smiling_face'), '\u{1F642}');
    });

    test('resolves aliases to the same emoji', () {
      expect(unicodeForName('thumbsup'), '\u{1F44D}');
      expect(unicodeForName('satisfied'), unicodeForName('laughing'));
      expect(unicodeForName('satisfied'), isNotNull);
    });

    test('keeps zero-width joiner sequences intact', () {
      expect(
        unicodeForName('woman_technologist'),
        '\u{1F469}\u{200D}\u{1F4BB}',
      );
      expect(
        unicodeForName('rainbow-flag'),
        '\u{1F3F3}\u{FE0F}\u{200D}\u{1F308}',
      );
    });

    test('resolves skin-toned names, including toned aliases', () {
      expect(unicodeForName('+1_light_skin_tone'), '\u{1F44D}\u{1F3FB}');
      expect(unicodeForName('thumbsup_medium_skin_tone'), '\u{1F44D}\u{1F3FD}');
      expect(unicodeForName('wave_dark_skin_tone'), '\u{1F44B}\u{1F3FF}');
      expect(
        unicodeForName('man-gesturing-no_medium_dark_skin_tone'),
        '\u{1F645}\u{1F3FE}\u{200D}\u{2642}\u{FE0F}',
      );
      expect(
        unicodeForName('people_holding_hands_light_skin_tone_dark_skin_tone'),
        '\u{1F9D1}\u{1F3FB}\u{200D}\u{1F91D}\u{200D}\u{1F9D1}\u{1F3FF}',
      );
    });

    test('ignores case', () {
      expect(unicodeForName('TaDa'), '\u{1F389}');
      expect(unicodeForName('ThumbsUp_Light_Skin_Tone'), '\u{1F44D}\u{1F3FB}');
    });

    test('returns null for unknown names', () {
      expect(unicodeForName('not_an_emoji'), isNull);
      expect(unicodeForName(''), isNull);
      expect(unicodeForName('heart_light_skin_tone'), isNull);
      expect(unicodeForName(':tada:'), isNull);
    });
  });

  test('isKnownEmoji tells known from unknown names', () {
    expect(isKnownEmoji('rocket'), isTrue);
    expect(isKnownEmoji('Rocket'), isTrue);
    expect(isKnownEmoji('rocket_ship'), isFalse);
  });

  test('normalizeShortcode strips colons and whitespace and lowercases', () {
    expect(normalizeShortcode(':Tada:'), 'tada');
    expect(normalizeShortcode('  :+1: '), '+1');
    expect(normalizeShortcode('heart'), 'heart');
  });

  group('withSkinTone', () {
    test('picks the toned name for emoji with skin tones', () {
      expect(withSkinTone('+1', 1), '+1_light_skin_tone');
      expect(withSkinTone('thumbsup', 3), 'thumbsup_medium_skin_tone');
      expect(withSkinTone('wave', 5), 'wave_dark_skin_tone');
      expect(
        withSkinTone('wave_dark_skin_tone', 2),
        'wave_medium_light_skin_tone',
      );
    });

    test('falls back to the primary name when an alias has no toned form', () {
      expect(withSkinTone('fu', 4), 'middle_finger_medium_dark_skin_tone');
      expect(isKnownEmoji('fu_medium_dark_skin_tone'), isFalse);
    });

    test('tone 0 gives the base name', () {
      expect(withSkinTone('wave_dark_skin_tone', 0), 'wave');
      expect(withSkinTone('wave', 0), 'wave');
    });

    test('leaves emoji without skin tones unchanged', () {
      expect(withSkinTone('rocket', 3), 'rocket');
      expect(withSkinTone('heart', 5), 'heart');
      expect(withSkinTone('not_an_emoji', 2), 'not_an_emoji');
    });

    test('leaves emoji toned for two people unchanged', () {
      const name = 'people_holding_hands_light_skin_tone_dark_skin_tone';
      expect(withSkinTone(name, 3), name);
    });

    test('rejects tones outside 0 to 5', () {
      expect(() => withSkinTone('wave', 6), throwsRangeError);
      expect(() => withSkinTone('wave', -1), throwsRangeError);
    });
  });

  test('baseName strips one or two tone suffixes', () {
    expect(baseName('+1_medium_light_skin_tone'), '+1');
    expect(baseName('wave_dark_skin_tone'), 'wave');
    expect(
      baseName('people_holding_hands_light_skin_tone_medium_dark_skin_tone'),
      'people_holding_hands',
    );
    expect(baseName('rocket'), 'rocket');
  });

  test('categoryOf gives the category of base and toned names', () {
    expect(categoryOf('tada'), 'activities');
    expect(categoryOf('+1_dark_skin_tone'), 'people-body');
    expect(categoryOf('flag-de'), 'flags');
    expect(categoryOf('not_an_emoji'), isNull);
  });

  test('namesInCategory lists primary names in order without tones', () {
    final smileys = namesInCategory('smileys-emotion');
    expect(smileys.take(3), ['grinning', 'smiley', 'smile']);
    expect(smileys, isNot(contains('satisfied')));

    final people = namesInCategory('people-body');
    expect(people, contains('+1'));
    expect(people, isNot(contains('thumbsup')));
    expect(people.where((n) => n.contains('skin_tone')), isEmpty);

    expect(namesInCategory('no-such-category'), isEmpty);
  });

  test('canonicalName maps aliases to the primary name', () {
    expect(canonicalName('thumbsup'), '+1');
    expect(canonicalName('+1'), '+1');
    expect(canonicalName('thumbsup_light_skin_tone'), '+1_light_skin_tone');
    expect(canonicalName('no_such_emoji'), 'no_such_emoji');
  });

  test('nameForEmoticon maps text emoticons', () {
    expect(nameForEmoticon(':)'), 'slightly_smiling_face');
    expect(nameForEmoticon('<3'), 'heart');
    expect(nameForEmoticon(':nope'), isNull);
  });
}
