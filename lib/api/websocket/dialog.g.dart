// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dialog.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenDialog _$OpenDialogFromJson(Map<String, dynamic> json) => OpenDialog(
  triggerId: const LenientString().fromJson(json['trigger_id']),
  url: const LenientString().fromJson(json['url']),
  dialog: json['dialog'] == null ? const DialogForm() : _dialog(json['dialog']),
);

DialogForm _$DialogFormFromJson(Map<String, dynamic> json) => DialogForm(
  callbackId: const LenientString().fromJson(json['callback_id']),
  title: const LenientString().fromJson(json['title']),
  introductionText: const LenientString().fromJson(json['introduction_text']),
  iconUrl: const LenientString().fromJson(json['icon_url']),
  elements: json['elements'] == null ? const [] : _elements(json['elements']),
  submitLabel: const LenientString().fromJson(json['submit_label']),
  notifyOnCancel: const LenientBool().fromJson(json['notify_on_cancel']),
  state: const LenientString().fromJson(json['state']),
);

DialogElement _$DialogElementFromJson(Map<String, dynamic> json) =>
    DialogElement(
      name: json['name'] == null ? '' : _string(json['name']),
      displayName: const LenientString().fromJson(json['display_name']),
      type: json['type'] == null
          ? DialogElementType.unknown
          : DialogElementType.parse(json['type']),
      subtype: const LenientString().fromJson(json['subtype']),
      defaultValue: const LenientString().fromJson(json['default']),
      placeholder: const LenientString().fromJson(json['placeholder']),
      helpText: const LenientString().fromJson(json['help_text']),
      optional: const LenientBool().fromJson(json['optional']),
      minLength: const LenientInt().fromJson(json['min_length']),
      maxLength: const LenientInt().fromJson(json['max_length']),
      dataSource: const LenientString().fromJson(json['data_source']),
      options: json['options'] == null ? const [] : _options(json['options']),
      datetimeConfig: _datetimeConfig(json['datetime_config']),
      legacyMinDate: const LenientString().fromJson(json['min_date']),
      legacyMaxDate: const LenientString().fromJson(json['max_date']),
      legacyTimeInterval: const LenientInt().fromJson(json['time_interval']),
    );

DialogDateTimeConfig _$DialogDateTimeConfigFromJson(
  Map<String, dynamic> json,
) => DialogDateTimeConfig(
  minDate: const LenientString().fromJson(json['min_date']),
  maxDate: const LenientString().fromJson(json['max_date']),
  timeInterval: const LenientInt().fromJson(json['time_interval']),
  locationTimezone: const LenientString().fromJson(json['location_timezone']),
  manualTimeEntry: const LenientBool().fromJson(json['manual_time_entry']),
  allowManualTimeEntry: const LenientBool().fromJson(
    json['allow_manual_time_entry'],
  ),
);

DialogOption _$DialogOptionFromJson(Map<String, dynamic> json) => DialogOption(
  text: json['text'] == null ? '' : _string(json['text']),
  value: json['value'] == null ? '' : _string(json['value']),
);
