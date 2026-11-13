import 'package:json_annotation/json_annotation.dart';
import 'package:matterleast/api/json/lenient.dart';

part 'dialog.g.dart';

/// An interactive dialog an integration asked this client to show
/// (`open_dialog`), answered through `POST /actions/dialogs/submit`.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class OpenDialog {
  const OpenDialog({
    this.triggerId,
    this.url,
    this.dialog = const DialogForm(),
  });

  factory OpenDialog.fromJson(Map<String, Object?> json) =>
      _$OpenDialogFromJson(json);

  @LenientString()
  final String? triggerId;

  /// Where the submission goes; sent back as it came.
  @LenientString()
  final String? url;
  @JsonKey(fromJson: _dialog)
  final DialogForm dialog;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class DialogForm {
  const DialogForm({
    this.callbackId,
    this.title,
    this.introductionText,
    this.iconUrl,
    this.elements = const [],
    this.submitLabel,
    this.notifyOnCancel,
    this.state,
    this.sourceUrl,
    this.submitButtons,
    this.refreshOnReturn,
  });

  factory DialogForm.fromJson(Map<String, Object?> json) =>
      _$DialogFormFromJson(json);

  @LenientString()
  final String? callbackId;
  @LenientString()
  final String? title;

  /// Markdown shown above the fields.
  @LenientString()
  final String? introductionText;
  @LenientString()
  final String? iconUrl;
  @JsonKey(fromJson: _elements)
  final List<DialogElement> elements;
  @LenientString()
  final String? submitLabel;

  /// The integration wants to hear when the user cancels.
  @LenientBool()
  final bool? notifyOnCancel;

  /// Opaque to us; sent back with the submission.
  @LenientString()
  final String? state;

  /// Where the integration is asked for this dialog again.
  @LenientString()
  final String? sourceUrl;

  /// The name of a select whose options are shown as the submit buttons.
  @LenientString()
  final String? submitButtons;

  /// Ask [sourceUrl] for the dialog again when a dialog opened over this
  /// one closes.
  @LenientBool()
  final bool? refreshOnReturn;
}

enum DialogElementType {
  text,
  textarea,
  select,
  bool,
  radio,

  /// A calendar date, sent as `YYYY-MM-DD`.
  date,

  /// A moment, sent as UTC `YYYY-MM-DDTHH:MM:SSZ`.
  datetime,

  /// A button that asks the integration to open another dialog.
  actionButton,
  unknown;

  static DialogElementType parse(Object? json) => values.firstWhere(
    (t) =>
        t != unknown &&
        (t == actionButton ? json == 'action_button' : t.name == json),
    orElse: () => unknown,
  );
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class DialogElement {
  const DialogElement({
    this.name = '',
    this.displayName,
    this.type = DialogElementType.unknown,
    this.subtype,
    this.defaultValue,
    this.placeholder,
    this.helpText,
    this.optional,
    this.minLength,
    this.maxLength,
    this.dataSource,
    this.options = const [],
    this.datetimeConfig,
    this.legacyMinDate,
    this.legacyMaxDate,
    this.legacyTimeInterval,
    this.actionButton,
  });

  factory DialogElement.fromJson(Map<String, Object?> json) =>
      _$DialogElementFromJson(json);

  /// The key of the field's value in the submission.
  @JsonKey(fromJson: stringOrEmpty)
  final String name;
  @LenientString()
  final String? displayName;
  @JsonKey(fromJson: DialogElementType.parse)
  final DialogElementType type;

  /// For text fields: `email`, `number`, `password`, `tel`, `url`, ….
  @LenientString()
  final String? subtype;
  @LenientString()
  @JsonKey(name: 'default')
  final String? defaultValue;
  @LenientString()
  final String? placeholder;
  @LenientString()
  final String? helpText;
  @LenientBool()
  final bool? optional;
  @LenientInt()
  final int? minLength;
  @LenientInt()
  final int? maxLength;

  /// `users` or `channels` for a select picked from the server; empty for
  /// [options].
  @LenientString()
  final String? dataSource;
  @JsonKey(fromJson: _options)
  final List<DialogOption> options;

  @JsonKey(fromJson: _datetimeConfig)
  final DialogDateTimeConfig? datetimeConfig;

  @JsonKey(fromJson: _button)
  final DialogActionButton? actionButton;

  // Servers before 12.0 sent these next to the other fields.
  @LenientString()
  @JsonKey(name: 'min_date')
  final String? legacyMinDate;
  @LenientString()
  @JsonKey(name: 'max_date')
  final String? legacyMaxDate;
  @LenientInt()
  @JsonKey(name: 'time_interval')
  final int? legacyTimeInterval;

  /// The earliest date or moment allowed: ISO, or relative like `today`,
  /// `+2d` or `-3H`.
  String? get minDate => datetimeConfig?.minDate ?? legacyMinDate;
  String? get maxDate => datetimeConfig?.maxDate ?? legacyMaxDate;

  /// Minutes between the times offered, 60 unless set.
  int get timeInterval {
    final minutes = datetimeConfig?.timeInterval ?? legacyTimeInterval ?? 0;
    return minutes > 0 && minutes <= 1440 && 1440 % minutes == 0 ? minutes : 60;
  }
}

/// What an `action_button` element asks for when pressed.
@JsonSerializable(createToJson: false)
class DialogActionButton {
  const DialogActionButton({this.url = '', this.context = const {}});

  factory DialogActionButton.fromJson(Map<String, Object?> json) =>
      _$DialogActionButtonFromJson(json);

  @JsonKey(fromJson: stringOrEmpty)
  final String url;
  @JsonKey(fromJson: _strings)
  final Map<String, String> context;
}

/// The body of `POST /actions/dialogs/submit` when it asks the integration
/// for the dialog again instead of sending answers.
@JsonSerializable(
  createFactory: false,
  includeIfNull: false,
  fieldRename: FieldRename.snake,
)
class DialogRefreshBody {
  const DialogRefreshBody({
    required this.url,
    required this.channelId,
    required this.submission,
    this.teamId,
    this.callbackId,
    this.state,
  });

  final String url;
  final String channelId;
  final String? teamId;
  final String? callbackId;
  final String? state;
  final Map<String, Object?> submission;
  final String type = 'refresh';

  Map<String, Object?> toJson() => _$DialogRefreshBodyToJson(this);
}

/// The answer to asking for a dialog again.
@JsonSerializable(createToJson: false)
class DialogRefreshAnswer {
  const DialogRefreshAnswer({this.form});

  factory DialogRefreshAnswer.fromJson(Map<String, Object?> json) =>
      _$DialogRefreshAnswerFromJson(json);

  @JsonKey(fromJson: _formOrNull)
  final DialogForm? form;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class DialogDateTimeConfig {
  const DialogDateTimeConfig({
    this.minDate,
    this.maxDate,
    this.timeInterval,
    this.locationTimezone,
    this.manualTimeEntry,
    this.allowManualTimeEntry,
  });

  factory DialogDateTimeConfig.fromJson(Map<String, Object?> json) =>
      _$DialogDateTimeConfigFromJson(json);

  @LenientString()
  final String? minDate;
  @LenientString()
  final String? maxDate;
  @LenientInt()
  final int? timeInterval;

  /// IANA zone the times are shown and picked in, instead of the phone's.
  @LenientString()
  final String? locationTimezone;

  /// Any minute may be picked, not only the [timeInterval] steps.
  @LenientBool()
  final bool? manualTimeEntry;

  /// The name before 12.0.
  @LenientBool()
  final bool? allowManualTimeEntry;

  bool get anyMinute => manualTimeEntry ?? allowManualTimeEntry ?? false;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class DialogOption {
  const DialogOption({this.text = '', this.value = ''});

  factory DialogOption.fromJson(Map<String, Object?> json) =>
      _$DialogOptionFromJson(json);

  @JsonKey(fromJson: stringOrEmpty)
  final String text;
  @JsonKey(fromJson: stringOrEmpty)
  final String value;
}

DialogActionButton? _button(Object? json) =>
    json is Map<String, Object?> ? DialogActionButton.fromJson(json) : null;

Map<String, String> _strings(Object? json) => json is Map<String, Object?>
    ? {
        for (final e in json.entries)
          if (e.value case final String value) e.key: value,
      }
    : const {};

DialogForm? _formOrNull(Object? json) =>
    json is Map<String, Object?> ? DialogForm.fromJson(json) : null;

DialogForm _dialog(Object? json) => json is Map<String, Object?>
    ? DialogForm.fromJson(json)
    : const DialogForm();

List<DialogElement> _elements(Object? json) =>
    decodeList(json, DialogElement.fromJson);

DialogDateTimeConfig? _datetimeConfig(Object? json) =>
    json is Map<String, Object?> ? DialogDateTimeConfig.fromJson(json) : null;

List<DialogOption> _options(Object? json) =>
    decodeList(json, DialogOption.fromJson);
