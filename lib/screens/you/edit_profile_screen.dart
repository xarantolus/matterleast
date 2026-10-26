import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/data/files/local_copies.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/user_profile.dart';
import 'package:matterleast/screens/you/profile_providers.dart';
import 'package:matterleast/ui/narrow_page.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/user_avatar.dart';

/// The user's picture, names, nickname, position and username on one
/// server, and a way to change their password.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({
    required this.url,
    required this.profile,
    super.key,
  });

  final String url;
  final UserProfile profile;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final _first = TextEditingController(text: widget.profile.firstName);
  late final _last = TextEditingController(text: widget.profile.lastName);
  late final _nickname = TextEditingController(text: widget.profile.nickname);
  late final _position = TextEditingController(text: widget.profile.position);
  late final _username = TextEditingController(text: widget.profile.username);
  File? _picture;
  var _saving = false;
  String? _error;
  String? _usernameError;

  List<TextEditingController> get _fields => [
    _first,
    _last,
    _nickname,
    _position,
    _username,
  ];

  @override
  void initState() {
    super.initState();
    for (final f in _fields) {
      f.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final f in _fields) {
      f.dispose();
    }
    if (_picture case final picture?) {
      unawaited(
        LocalCopies.cacheDirectory().then(
          (dir) => LocalCopies.deletePicked(dir, picture.path),
        ),
      );
    }
    super.dispose();
  }

  String? _changed(TextEditingController c, String before) =>
      c.text.trim() == before ? null : c.text.trim();

  bool get _dirty =>
      _picture != null ||
      _changed(_first, widget.profile.firstName) != null ||
      _changed(_last, widget.profile.lastName) != null ||
      _changed(_nickname, widget.profile.nickname) != null ||
      _changed(_position, widget.profile.position) != null ||
      _changed(_username, widget.profile.username) != null;

  Future<void> _pick() async {
    final platform = ImagePickerPlatform.instance;
    // The system photo picker needs no storage permission.
    if (platform is ImagePickerAndroid) platform.useAndroidPhotoPicker = true;
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (file != null && mounted) setState(() => _picture = File(file.path));
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    setState(() {
      _saving = true;
      _error = null;
      _usernameError = null;
    });
    try {
      final actions = await ref.read(profileActionsProvider(widget.url).future);
      if (_picture case final picture?) await actions.setPicture(picture);
      final first = _changed(_first, widget.profile.firstName);
      final last = _changed(_last, widget.profile.lastName);
      final nickname = _changed(_nickname, widget.profile.nickname);
      final position = _changed(_position, widget.profile.position);
      final username = _changed(_username, widget.profile.username);
      if ([first, last, nickname, position, username].any((v) => v != null)) {
        await actions.patchMe(
          firstName: first,
          lastName: last,
          nickname: nickname,
          position: position,
          username: username,
        );
      }
      navigator.pop();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        switch (e) {
          case ServerError(:final id?, :final message)
              when id.contains('username'):
            _usernameError = message ?? 'This username is not available.';
          default:
            _error = requestProblemText(e, Uri.parse(widget.url).host);
        }
      });
    }
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLength = 64,
    String? error,
    String? helper,
    String? lockedBy,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: Spacing.md),
    child: TextField(
      controller: controller,
      enabled: !_saving && lockedBy == null,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: error,
        helperText: lockedBy == null ? helper : 'Set by $lockedBy',
        helperMaxLines: 2,
        suffixIcon: lockedBy == null ? null : const Icon(Icons.lock_outline),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final picture = _picture;
    final locks = ref.watch(myProfileLocksProvider(widget.url)).value;
    String? by(bool? locked) => (locked ?? false) ? locks!.source : null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: _saving || !_dirty ? null : _save,
            child: const Text('Save'),
          ),
        ],
        bottom: ProgressSlot(active: _saving),
      ),
      body: NarrowPage(
        children: [
          Center(
            child: Stack(
              children: [
                ClipOval(
                  child: SizedBox.square(
                    dimension: 112,
                    child: picture != null
                        ? Image.file(picture, fit: BoxFit.cover)
                        : UserAvatar(
                            serverUrl: widget.url,
                            userId: widget.profile.id,
                            name: widget.profile.name,
                            lastPictureUpdate: widget.profile.pictureUpdate,
                            size: 112,
                          ),
                  ),
                ),
                if (!(locks?.picture ?? false))
                  PositionedDirectional(
                    end: 0,
                    bottom: 0,
                    child: IconButton.filledTonal(
                      tooltip: 'Change picture',
                      onPressed: _saving ? null : _pick,
                      icon: const Icon(Icons.photo_camera_outlined),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
          _field(_first, 'First name', lockedBy: by(locks?.firstName)),
          _field(_last, 'Last name', lockedBy: by(locks?.lastName)),
          _field(
            _nickname,
            'Nickname',
            maxLength: 22,
            lockedBy: by(locks?.nickname),
          ),
          _field(
            _position,
            'Position',
            maxLength: 128,
            lockedBy: by(locks?.position),
          ),
          _field(
            _username,
            'Username',
            maxLength: 22,
            error: _usernameError,
            helper: 'Letters, digits, dots, dashes and underscores.',
            lockedBy: by(locks?.username),
          ),
          if (_error case final error?)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (!(locks?.password ?? false))
            OutlinedButton.icon(
              icon: const Icon(Icons.password),
              label: const Text('Change password'),
              onPressed: _saving
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ChangePasswordScreen(url: widget.url),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({required this.url, super.key});

  final String url;

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _again = TextEditingController();
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final c in [_current, _next, _again]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _again.dispose();
    super.dispose();
  }

  bool get _mismatch => _again.text.isNotEmpty && _again.text != _next.text;

  bool get _ready =>
      _current.text.isNotEmpty &&
      _next.text.isNotEmpty &&
      _again.text == _next.text;

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final actions = await ref.read(profileActionsProvider(widget.url).future);
      await actions.changePassword(current: _current.text, next: _next.text);
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Password changed')));
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = switch (e) {
          // The server explains its password rules and wrong current
          // passwords in its own words.
          ServerError(:final message?) when message.isNotEmpty => message,
          _ => requestProblemText(e, Uri.parse(widget.url).host),
        };
      });
    }
  }

  Widget _field(TextEditingController c, String label, {String? error}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: Spacing.md),
        child: TextField(
          controller: c,
          enabled: !_saving,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            errorText: error,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Change password'),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: _saving || !_ready ? null : _save,
          child: const Text('Save'),
        ),
      ],
      bottom: ProgressSlot(active: _saving),
    ),
    body: NarrowPage(
      children: [
        _field(_current, 'Current password'),
        _field(_next, 'New password'),
        _field(
          _again,
          'New password again',
          error: _mismatch ? "The new passwords don't match." : null,
        ),
        if (_error case final error?)
          Text(
            error,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    ),
  );
}
