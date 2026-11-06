import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/ui/picker_modes.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('a phone says tap and a desktop says click', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(tapWord(), 'tap');
    expect('${tapWord(capital: true)} to change', 'Tap to change');

    for (final desktop in [TargetPlatform.linux, TargetPlatform.windows]) {
      debugDefaultTargetPlatformOverride = desktop;
      expect(tapWord(), 'click');
      expect('${tapWord(capital: true)} to change', 'Click to change');
    }
  });

  test('desktops type dates and times, phones pick them', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(dateEntryMode, DatePickerEntryMode.calendar);
    expect(timeEntryMode, TimePickerEntryMode.dial);

    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    expect(dateEntryMode, DatePickerEntryMode.input);
    expect(timeEntryMode, TimePickerEntryMode.input);
  });
}
