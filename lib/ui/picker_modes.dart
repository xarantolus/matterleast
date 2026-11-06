import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';

/// Typed fields on desktop, where the phone's calendar and dial are slow
/// with a mouse.
DatePickerEntryMode get dateEntryMode =>
    isDesktop ? DatePickerEntryMode.input : DatePickerEntryMode.calendar;

TimePickerEntryMode get timeEntryMode =>
    isDesktop ? TimePickerEntryMode.input : TimePickerEntryMode.dial;
