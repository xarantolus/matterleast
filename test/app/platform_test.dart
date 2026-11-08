import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/screens/login/login_screen.dart';
import 'package:matterleast/ui/post_files.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test("only Android has Android's own services; iOS is a phone without "
      'them', () {
    final services = {
      for (final platform in [
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.linux,
        TargetPlatform.windows,
      ])
        platform: () {
          debugDefaultTargetPlatformOverride = platform;
          return (android: hasAndroidServices, desktop: isDesktop);
        }(),
    };
    expect(services, {
      TargetPlatform.android: (android: true, desktop: false),
      TargetPlatform.iOS: (android: false, desktop: false),
      TargetPlatform.linux: (android: false, desktop: true),
      TargetPlatform.windows: (android: false, desktop: true),
    });
  });

  test('sentences about the phone name its system', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(phoneSystem, 'Android');
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(phoneSystem, 'iOS');
  });

  test('the sign-in hint names what each system asks', () {
    expect(ssoHint(TargetPlatform.android), contains('If Android asks'));
    expect(ssoHint(TargetPlatform.iOS), contains('When iOS asks'));
    expect(ssoHint(TargetPlatform.linux), contains('When it asks'));
  });

  test('Save names the place the file lands on each phone', () {
    expect(saveFolder(FileKind.image, TargetPlatform.android), 'Pictures');
    expect(saveFolder(FileKind.video, TargetPlatform.android), 'Movies');
    expect(saveFolder(FileKind.pdf, TargetPlatform.android), 'Downloads');
    expect(saveFolder(FileKind.gif, TargetPlatform.iOS), 'Photos');
    expect(saveFolder(FileKind.video, TargetPlatform.iOS), 'Photos');
    expect(saveFolder(FileKind.pdf, TargetPlatform.iOS), 'Files');
  });
}
