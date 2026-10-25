import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/ui/post_files.dart';
import 'package:pdfrx/pdfrx.dart';

Route<void> pdfRoute(
  File local, {
  required String url,
  required PostFile file,
}) => MaterialPageRoute<void>(
  builder: (_) => PdfScreen(local: local, url: url, file: file),
);

/// A downloaded PDF, page after page, with pinch zoom.
class PdfScreen extends StatelessWidget {
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(file.name, maxLines: 1),
      actions: [FileActionsMenu(url: url, file: file)],
    ),
    // The default physics stop a fling much sooner than a list does.
    body: PdfViewer.file(
      local.path,
      params: PdfViewerParams(
        scrollPhysics: PdfViewerParams.getScrollPhysics(context),
      ),
    ),
  );
}
