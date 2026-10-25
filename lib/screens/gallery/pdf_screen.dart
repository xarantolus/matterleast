import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:pdfrx/pdfrx.dart';

Route<void> pdfRoute(File file, String name) => MaterialPageRoute<void>(
  builder: (_) => PdfScreen(file: file, name: name),
);

/// A downloaded PDF, page after page, with pinch zoom.
class PdfScreen extends StatelessWidget {
  const PdfScreen({required this.file, required this.name, super.key});

  final File file;
  final String name;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(name, maxLines: 1)),
    body: PdfViewer.file(file.path),
  );
}
