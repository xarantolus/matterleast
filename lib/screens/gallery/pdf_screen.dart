import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/markdown/links.dart';
import 'package:matterleast/screens/channel/link_opener.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/post_files.dart';
import 'package:matterleast/ui/window_bar.dart';
import 'package:pdfrx/pdfrx.dart';

Route<void> pdfRoute(
  File local, {
  required String url,
  required PostFile file,
}) => MaterialPageRoute<void>(
  builder: (_) => PdfScreen(local: local, url: url, file: file),
);

/// A downloaded PDF, page after page: pinch or double-tap zoom, text
/// selection, links, search, its contents and a page thumb. A PDF with a
/// password asks for it.
class PdfScreen extends StatefulWidget {
  const PdfScreen({
    required this.local,
    required this.url,
    required this.file,
    super.key,
  });

  final File local;
  final String url;
  final PostFile file;

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  final _controller = PdfViewerController();

  /// Made once the document is open; it needs one.
  PdfTextSearcher? _searcher;
  final _query = TextEditingController();
  final _queryFocus = FocusNode();
  var _searching = false;
  List<PdfOutlineNode> _outline = const [];

  /// Bumped to open the file again after the password prompt was closed.
  var _attempt = 0;
  var _passwordAsked = 0;

  @override
  void dispose() {
    _searcher?.dispose();
    _query.dispose();
    _queryFocus.dispose();
    super.dispose();
  }

  Future<void> _viewerReady(PdfDocument document, PdfViewerController _) async {
    _searcher?.dispose();
    setState(() => _searcher = PdfTextSearcher(_controller));
    final outline = await document.loadOutline();
    if (mounted) setState(() => _outline = outline);
  }

  Future<String?> _askPassword() async {
    final wrong = _passwordAsked++ > 0;
    if (!mounted) return null;
    return showDialog<String>(
      context: context,
      builder: (_) => _PasswordDialog(name: widget.file.name, wrong: wrong),
    );
  }

  void _openAgain() => setState(() {
    _attempt++;
    _passwordAsked = 0;
  });

  void _startSearch() {
    if (_searcher == null) return;
    // Its menu would stay over the matches.
    unawaited(_controller.textSelectionDelegate.clearTextSelection());
    setState(() => _searching = true);
    _queryFocus.requestFocus();
    _query.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _query.text.length,
    );
  }

  void _endSearch() {
    _searcher?.resetTextSearch();
    _query.clear();
    setState(() => _searching = false);
  }

  void _onLink(PdfLink link) {
    if (link.url case final url?) {
      if (classifyLink(url.toString(), Uri.parse(widget.url)) case UriLink(
        :final uri,
      )) {
        unawaited(openLinkFromMessage(Navigator.of(context), uri));
      }
    } else if (link.dest case final dest?) {
      unawaited(_controller.goToDest(dest));
    }
  }

  /// Fits the page width, the way the document opened.
  void _fitWidth() => unawaited(
    _controller.setZoom(_controller.centerPosition, _controller.coverScale),
  );

  bool? _onKey(
    PdfViewerKeyHandlerParams params,
    LogicalKeyboardKey key,
    bool isRealKeyPress,
  ) {
    final keyboard = HardwareKeyboard.instance;
    if (!keyboard.isControlPressed && !keyboard.isMetaPressed) return null;
    switch (key) {
      case LogicalKeyboardKey.digit0 || LogicalKeyboardKey.numpad0:
        _fitWidth();
      case LogicalKeyboardKey.numpadAdd || LogicalKeyboardKey.add:
        unawaited(_controller.zoomUp());
      case LogicalKeyboardKey.numpadSubtract:
        unawaited(_controller.zoomDown());
      default:
        return null;
    }
    return true;
  }

  bool _onTap(
    BuildContext context,
    PdfViewerController controller,
    PdfViewerGeneralTapHandlerDetails details,
  ) {
    // A double click on desktop selects a word instead.
    if (details.type != PdfViewerGeneralTapType.doubleTap || isDesktop) {
      return false;
    }
    final fit = controller.coverScale;
    final zoomedIn = controller.currentZoom > fit * 1.1;
    unawaited(
      controller.zoomOnLocalPosition(
        localPosition: details.localPosition,
        newZoom: zoomedIn ? fit : fit * 2.5,
      ),
    );
    return true;
  }

  Future<void> _showOutline(Rect? anchor) async {
    final dest = await showAppSheet<PdfDest>(
      context: context,
      isScrollControlled: true,
      anchor: anchor,
      builder: (_) => _OutlineSheet(outline: _outline),
    );
    if (dest != null) unawaited(_controller.goToDest(dest));
  }

  Widget _error(BuildContext context, Object error) => switch (error) {
    PdfPasswordException() => EmptyState(
      icon: Icons.lock_outline,
      title: 'This PDF has a password',
      body: 'Enter the password to read ${widget.file.name}.',
      action: FilledButton(
        onPressed: _openAgain,
        child: const Text('Enter password'),
      ),
    ),
    _ => EmptyState(
      icon: Icons.picture_as_pdf_outlined,
      title: "Couldn't open this PDF",
      body:
          "The file may be damaged or use a feature the viewer can't "
          'show. Download it to open it in another app.',
      action: OutlinedButton(
        onPressed: _openAgain,
        child: const Text('Try again'),
      ),
    ),
  };

  void _paintMatches(Canvas canvas, Rect pageRect, PdfPage page) =>
      _searcher?.pageTextMatchPaintCallback(canvas, pageRect, page);

  PdfViewerParams? _params;
  ColorScheme? _paramsColors;

  /// Made once per theme, so a rebuild hands the viewer the same params.
  PdfViewerParams _paramsFor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (_params case final same? when _paramsColors == colors) return same;
    _paramsColors = colors;
    return _params = PdfViewerParams(
      backgroundColor: colors.surfaceContainerHighest,
      // The default physics stop a fling much sooner than a list does.
      scrollPhysics: PdfViewerParams.getScrollPhysics(context),
      textSelectionParams: const PdfTextSelectionParams(),
      linkHandlerParams: PdfLinkHandlerParams(
        onLinkTap: _onLink,
        linkColor: colors.primary.withAlpha(24),
        linkHoverColor: colors.primary.withAlpha(56),
      ),
      pagePaintCallbacks: [_paintMatches],
      keyHandlerParams: const PdfViewerKeyHandlerParams(autofocus: true),
      onKey: _onKey,
      onGeneralTap: _onTap,
      onViewerReady: _viewerReady,
      errorBannerBuilder: (context, error, _, _) => _error(context, error),
      viewerOverlayBuilder: (context, size, handleLinkTap) => [
        PdfViewerScrollThumb(
          controller: _controller,
          thumbSize: const Size(72, 32),
          thumbBuilder: (context, size, page, controller) =>
              _PageThumb(page: page, pages: controller.pageCount),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_searching,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _endSearch();
    },
    child: CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            _startSearch,
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true):
            _startSearch,
      },
      child: Scaffold(
        appBar: switch (_searcher) {
          final searcher? when _searching => _searchBar(searcher),
          _ => _titleBar(),
        },
        body: PdfViewer.file(
          widget.local.path,
          key: ValueKey(_attempt),
          controller: _controller,
          passwordProvider: _askPassword,
          params: _paramsFor(context),
        ),
      ),
    ),
  );

  PreferredSizeWidget _titleBar() => WindowAppBar(
    title: Text(widget.file.name, maxLines: 1),
    actions: [
      if (_searcher != null)
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Search',
          onPressed: _startSearch,
        ),
      if (_outline.isNotEmpty)
        Builder(
          builder: (button) => IconButton(
            icon: const Icon(Icons.toc),
            tooltip: 'Contents',
            onPressed: () => _showOutline(globalRectOf(button)),
          ),
        ),
      FileActionsMenu(url: widget.url, file: widget.file),
    ],
  );

  PreferredSizeWidget _searchBar(PdfTextSearcher searcher) {
    final theme = Theme.of(context);
    final onBar =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary;
    return WindowAppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Close search',
        onPressed: _endSearch,
      ),
      title: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): _endSearch,
          const SingleActivator(LogicalKeyboardKey.enter, shift: true): () =>
              unawaited(searcher.goToPrevMatch()),
        },
        child: TextField(
          controller: _query,
          focusNode: _queryFocus,
          autofocus: true,
          textInputAction: TextInputAction.search,
          style: theme.textTheme.titleMedium?.copyWith(color: onBar),
          cursorColor: onBar,
          decoration: InputDecoration(
            hintText: 'Search in the PDF',
            hintStyle: theme.textTheme.titleMedium?.copyWith(color: onBar),
            border: InputBorder.none,
          ),
          onChanged: (text) => searcher.startTextSearch(text),
          onSubmitted: (_) {
            unawaited(searcher.goToNextMatch());
            _queryFocus.requestFocus();
          },
        ),
      ),
      actions: [
        ListenableBuilder(
          listenable: searcher,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _matchText(searcher),
                style: theme.textTheme.labelLarge?.copyWith(color: onBar),
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up),
                tooltip: 'Previous match',
                onPressed: searcher.hasMatches
                    ? () => unawaited(searcher.goToPrevMatch())
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                tooltip: 'Next match',
                onPressed: searcher.hasMatches
                    ? () => unawaited(searcher.goToNextMatch())
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _matchText(PdfTextSearcher searcher) => matchCountText(
    query: _query.text,
    matches: searcher.matches.length,
    current: searcher.currentIndex,
    searching: searcher.isSearching,
  );
}

/// Pure: the count beside the search field.
String matchCountText({
  required String query,
  required int matches,
  required int? current,
  required bool searching,
}) {
  if (query.isEmpty) return '';
  if (matches == 0) return searching ? 'Searching…' : 'No matches';
  final total = searching ? '$matches…' : '$matches';
  return current == null ? total : '${current + 1} of $total';
}

class _PageThumb extends StatelessWidget {
  const _PageThumb({required this.page, required this.pages});

  final int? page;
  final int pages;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.secondaryContainer,
      elevation: 2,
      shape: const StadiumBorder(),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              page == null ? '' : '$page / $pages',
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: colors.onSecondaryContainer),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.name, required this.wrong});

  final String name;
  final bool wrong;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _open() => Navigator.of(context).pop(_password.text);

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Password needed'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${widget.name} is protected with a password.'),
        const SizedBox(height: 16),
        TextField(
          controller: _password,
          autofocus: true,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            errorText: widget.wrong
                ? "That password didn't open it. Try again."
                : null,
          ),
          onSubmitted: (_) => _open(),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _open, child: const Text('Open')),
    ],
  );
}

class _OutlineSheet extends StatelessWidget {
  const _OutlineSheet({required this.outline});

  final List<PdfOutlineNode> outline;

  @override
  Widget build(BuildContext context) {
    final rows = <(PdfOutlineNode, int)>[];
    void add(List<PdfOutlineNode> nodes, int depth) {
      for (final node in nodes) {
        rows.add((node, depth));
        add(node.children, depth + 1);
      }
    }

    add(outline, 0);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Text(
                'Contents',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final (node, depth) in rows)
                    ListTile(
                      contentPadding: EdgeInsetsDirectional.only(
                        start: 24.0 + 16 * depth,
                        end: 24,
                      ),
                      title: Text(node.title),
                      enabled: node.dest != null,
                      onTap: () => Navigator.of(context).pop(node.dest),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
