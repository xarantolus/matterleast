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
}

enum DialogElementType {
  text,
  textarea,
  select,
  bool,
  radio,
  unknown;

  static DialogElementType parse(Object? json) => values.firstWhere(
    (t) => t.name == json && t != unknown,
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
  });

  factory DialogElement.fromJson(Map<String, Object?> json) =>
      _$DialogElementFromJson(json);

  /// The key of the field's value in the submission.
  @JsonKey(fromJson: _string)
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
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class DialogOption {
  const DialogOption({this.text = '', this.value = ''});

  factory DialogOption.fromJson(Map<String, Object?> json) =>
      _$DialogOptionFromJson(json);

  @JsonKey(fromJson: _string)
  final String text;
  @JsonKey(fromJson: _string)
  final String value;
}

String _string(Object? json) => json is String ? json : '';

DialogForm _dialog(Object? json) => json is Map<String, Object?>
    ? DialogForm.fromJson(json)
    : const DialogForm();

List<DialogElement> _elements(Object? json) => [
  if (json is List)
    for (final e in json)
      if (e is Map<String, Object?>) DialogElement.fromJson(e),
];

List<DialogOption> _options(Object? json) => [
  if (json is List)
    for (final e in json)
      if (e is Map<String, Object?>) DialogOption.fromJson(e),
];
